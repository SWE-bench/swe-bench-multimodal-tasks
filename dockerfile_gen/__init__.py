import json
import re
import shlex
from argparse import ArgumentParser
from pathlib import Path

from .constants import (
    CARBON_ACHECKER_ARCHIVE,
    CARBON_ACHECKER_ARCHIVE_PATH,
    CARBON_ACHECKER_OFFLINE_PORT,
    CARBON_ACHECKER_OFFLINE_ROOT,
    CONTAINER_WORKDIR,
    PINNED_CHROME_VERSION,
    END_TEST_OUTPUT,
    INSTANCE_OVERRIDES,
    MAP_REPO_VERSION_TO_SPECS_JS,
    START_TEST_OUTPUT,
)
from .assets import PROBLEM_ASSETS_DIR
from .utils import (
    git_clone_timesafe,
    make_heredoc_run_command,
)


_DOCKERFILE_BASE_JS = r"""
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    software-properties-common \
    wget \
    gnupg \
    jq \
    ca-certificates \
    dbus \
    ffmpeg \
    imagemagick \
    unzip \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg \
        fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 dbus dbus-x11 \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# Pin Chrome. The apt repo only ever serves the current stable, so an unpinned install
# silently changes version on every rebuild -- Chrome 151 broke openlayers' WebGL and
# Cypress's browser connection that way. Chrome for Testing archives every build, so this
# stays reproducible. Keep both binary names: 160 eval scripts reference one or the other.
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/__CHROME_VERSION__/linux64/chrome-linux64.zip -O /tmp/chrome.zip \
    && unzip -q /tmp/chrome.zip -d /opt/chrome-pinned \
    && rm /tmp/chrome.zip \
    && printf '#!/bin/bash\nexec /opt/chrome-pinned/chrome-linux64/chrome "$@"\n' > /usr/bin/google-chrome \
    && chmod +x /usr/bin/google-chrome \
    && cp /usr/bin/google-chrome /usr/bin/google-chrome-stable

ENV NVM_DIR /usr/local/nvm

RUN mkdir -p $NVM_DIR
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.3/install.sh | bash
RUN apt-get update && apt-get install -y \
    procps \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 \
    libgbm1 libgconf-2-4 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 \
    libnss3 libpango-1.0-0 libpangocairo-1.0-0 libxcomposite1 \
    libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 libxss1 libxshmfence1 libglu1 \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN /usr/bin/google-chrome
RUN echo "CHROME_BIN=$CHROME_BIN" >> /etc/environment
RUN mkdir -p /run/dbus

ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"

RUN dbus-daemon --system --fork

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# puppeteer v20+ renamed the variable; without it install.mjs hangs fetching Chrome
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV OPENSSL_CONF /etc/ssl

RUN useradd -m chromeuser

USER chromeuser

WORKDIR /home/chromeuser

USER root
"""


# ── Dockerfile generation ──────────────────────────────────────────────


def make_env_script_list(instance, specs):
    docker_specs = {
        **specs.get("docker_specs", {}),
        **INSTANCE_OVERRIDES.get(instance["instance_id"], {}).get("docker_specs", {}),
    }
    node_version = docker_specs.get("node_version", "18.17.1")
    pnpm_version = docker_specs.get("pnpm_version", None)
    python_version = docker_specs.get("python_version", "3.9")
    commands = []
    if "apt-pkgs" in specs:
        apt_packages = " ".join(specs["apt-pkgs"])
        commands.extend([
            "apt-get update",
            f"apt-get install -y {apt_packages}",
            "rm -rf /var/lib/apt/lists/*",
        ])
    commands.extend([
        f"export NODE_VERSION={node_version}",
        "source $NVM_DIR/nvm.sh",
        "nvm install $NODE_VERSION",
        "nvm alias default $NODE_VERSION",
        "nvm use default",
    ])
    commands.extend([
        "add-apt-repository ppa:deadsnakes/ppa",
        "apt-get update",
        f"apt-get install -y python{python_version}",
        f"ln -sf /usr/bin/python{python_version} /usr/bin/python",
    ])
    commands.append("apt-get install -y python2")
    commands.extend([
        f'echo "export NODE_PATH=$NVM_DIR/v{node_version}/lib/node_modules" >> /etc/environment',
        f'echo "export PATH=$NVM_DIR/versions/node/v{node_version}/bin:$PATH" >> /etc/environment',
    ])
    if pnpm_version:
        commands.extend([
            f"export PNPM_VERSION={pnpm_version}",
            "export PNPM_HOME=/usr/local/pnpm",
            "mkdir -p $PNPM_HOME",
            'wget -qO $PNPM_HOME/pnpm "https://github.com/pnpm/pnpm/releases/download/v$PNPM_VERSION/pnpm-linux-x64"',
            "chmod +x $PNPM_HOME/pnpm",
            "ln -s $PNPM_HOME/pnpm /usr/local/bin/pnpm",
            'echo "export PNPM_HOME=$PNPM_HOME" >> /etc/profile',
            'echo "export PATH=$PNPM_HOME:$PATH" >> /etc/profile',
        ])
    commands.extend([
        "source $NVM_DIR/nvm.sh && node -v",
        "source $NVM_DIR/nvm.sh && npm -v",
        "python -V",
        "python2 -V",
    ])
    if pnpm_version:
        commands.append("pnpm -v")
    return make_heredoc_run_command(commands)


def make_repo_script_list(specs, repo, base_commit, instance_id=None):
    commands = [
        *git_clone_timesafe(repo, base_commit, CONTAINER_WORKDIR),
        f"cd {CONTAINER_WORKDIR}",
        "git clean -fdxq",
    ]
    commands.append("source $NVM_DIR/nvm.sh")
    commands.extend(INSTANCE_OVERRIDES.get(instance_id, {}).get("install_pre", []))
    post_install_commands = []
    override_install = INSTANCE_OVERRIDES.get(instance_id, {}).get("install")
    if override_install:
        commands.extend(override_install)
    elif "install" in specs:
        install_commands = specs["install"]
        if isinstance(install_commands, str):
            install_commands = [install_commands]
        if repo == "carbon-design-system/carbon":
            split_at = next(
                i
                for i, command in enumerate(install_commands)
                if command.startswith(
                    f"mkdir -p {CARBON_ACHECKER_OFFLINE_ROOT}/archives/"
                )
            )
            post_install_commands = [
                f"cd {CONTAINER_WORKDIR}",
                *install_commands[split_at:],
                "rm -f .achecker.yml",
            ]
            install_commands = [
                *install_commands[:split_at],
                f"echo 'ruleArchive: {CARBON_ACHECKER_ARCHIVE}' > .achecker.yml",
            ]
        commands.extend(install_commands)
    if "build" in specs:
        build_commands = specs["build"]
        if isinstance(build_commands, str):
            build_commands = [build_commands]
        commands.extend(build_commands)
    commands.extend(INSTANCE_OVERRIDES.get(instance_id, {}).get("install_post", []))
    # install/build run as root and leave root-owned artifacts (e.g. openlayers' build/),
    # but the eval script runs the tests as chromeuser. chmod again at the very end so
    # those directories stay writable.
    commands.append(f"chmod -R 777 {CONTAINER_WORKDIR}")
    layers = [make_heredoc_run_command(commands)]
    if post_install_commands:
        layers.append(make_heredoc_run_command(post_install_commands))
    return "\n".join(layers)


def _strip_binary_diffs(patch_text: str) -> tuple[str, list[str]]:
    """Strip binary file diffs from a patch, returning cleaned patch and list of binary file paths.

    Binary diffs (containing 'Binary files ... differ') can't be applied by git apply
    when the patch was generated without --binary. We strip them and handle the binary
    files separately via image_assets downloads.
    """
    lines = patch_text.split("\n")
    cleaned = []
    binary_files = []
    skip_until_next_diff = False

    for i, line in enumerate(lines):
        if line.startswith("diff --git "):
            skip_until_next_diff = False
            # Look ahead for Binary marker
            for j in range(i + 1, min(len(lines), i + 6)):
                if "Binary files" in lines[j] and "differ" in lines[j]:
                    skip_until_next_diff = True
                    match = re.search(r"diff --git a/.* b/(.*)", line)
                    if match:
                        binary_files.append(match.group(1))
                    break
                if lines[j].startswith("diff --git "):
                    break
        if not skip_until_next_diff:
            cleaned.append(line)

    return "\n".join(cleaned), binary_files


def _make_image_download_script(instance: dict, task_dir=None) -> str:
    """Download only unarchived problem images during image construction.

    Binary grading fixtures are never added here; the evaluator stages their local
    mirrors after the solver submits a patch.
    """
    image_assets = instance.get("image_assets")
    if not image_assets:
        return ""
    if isinstance(image_assets, str):
        image_assets = json.loads(image_assets) if image_assets else {}

    # Binary patch fixtures are intentionally never placed in the solver-visible
    # image. The evaluator stages their local test_assets copies after submission.
    commands = []

    # problem_statement images land in /problem_assets via COPY. Only the handful
    # with no archived copy are still fetched, into the same directory under the
    # archive's own name, so everything a statement links to sits in one place.
    for name, url in _unarchived_problem_images(instance, task_dir):
        dest = f"/problem_assets/{name}"
        commands.append("mkdir -p /problem_assets")
        commands.append(f"curl -fsSL -o '{dest}' '{url}' || true")

    if not commands:
        return ""
    return make_heredoc_run_command(commands)


def _problem_images(instance: dict, task_dir=None):
    """Every problem-statement image, as (archive filename, url, is archived)."""
    if task_dir is None:
        return []
    from .assets import _problem_image_targets

    return [
        (path.name, url, path.is_file())
        for path, url in _problem_image_targets(task_dir, instance)
    ]


def _unarchived_problem_images(instance: dict, task_dir=None) -> list[tuple[str, str]]:
    """The ones with no local copy, deduplicated by url as the download was."""
    out, seen = [], set()
    for name, url, archived in _problem_images(instance, task_dir):
        if archived or url in seen:
            continue
        seen.add(url)
        out.append((name, url))
    return out


def _make_problem_asset_copies(instance: dict, task_dir=None) -> str:
    """COPY the task's archived assets to /problem_assets in the image.

    The whole directory, under the names it is archived with: the index prefix keeps
    images distinct where two of them share a filename, and a statement that links a
    reproduction as well as a screenshot gets both.
    """
    if task_dir is None or not (task_dir / PROBLEM_ASSETS_DIR).is_dir():
        return ""
    return f'COPY ["{PROBLEM_ASSETS_DIR}", "/{PROBLEM_ASSETS_DIR}"]'


def _get_dockerfile(instance, task_dir=None) -> str:
    repo = instance["repo"]
    version = instance.get("version") or None
    base_commit = instance["base_commit"]
    specs = MAP_REPO_VERSION_TO_SPECS_JS[repo][version]
    dockerfile = _DOCKERFILE_BASE_JS.replace("__CHROME_VERSION__", PINNED_CHROME_VERSION)
    # per-instance docker_specs win over the repo/version spec, so one instance can move
    # off a shared node version without disturbing its siblings
    docker_specs = {
        **specs.get("docker_specs", {}),
        **INSTANCE_OVERRIDES.get(instance["instance_id"], {}).get("docker_specs", {}),
    }
    node_version = docker_specs.get("node_version", "18.17.1")
    pnpm_version = docker_specs.get("pnpm_version", None)
    dockerfile += f"\nENV NODE_VERSION {node_version}\n"
    dockerfile += "ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules\n"
    dockerfile += "ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH\n"
    if pnpm_version:
        dockerfile += f"ENV PNPM_VERSION {pnpm_version}\n"
        dockerfile += "ENV PNPM_HOME /usr/local/pnpm\n"
        dockerfile += "ENV PATH $PNPM_HOME:$PATH\n"
    env_script = make_env_script_list(instance, specs)
    if env_script:
        dockerfile += f"\n{env_script}\n"
    repo_script = make_repo_script_list(specs, repo, base_commit, instance["instance_id"])
    if repo_script:
        dockerfile += f"\n{repo_script}\n"
    # Download image_assets at build time
    image_script = _make_image_download_script(instance, task_dir)
    if image_script:
        dockerfile += f"\n{image_script}\n"
    copies = _make_problem_asset_copies(instance, task_dir)
    if copies:
        dockerfile += f"\n{copies}\n"
    dockerfile += f"\nWORKDIR {CONTAINER_WORKDIR}\n"
    return dockerfile


# ── Per-instance test command generators ──────────────────────────────
# Ported from SWE-bench/private test_spec/javascript.py.
# JS test frameworks often need specific test paths/patterns rather than
# running the entire suite.

try:
    from unidiff import PatchSet
except ImportError:
    PatchSet = None


def _get_test_paths(instance: dict) -> list[str]:
    """Extract test file paths from test_patch."""
    test_patch = instance.get("test_patch", "")
    if not test_patch:
        return []
    if PatchSet is not None:
        return [x.path for x in PatchSet(test_patch)]
    return re.findall(r"diff --git a/.* b/(.*)", test_patch)


def _get_test_cmds_prism(instance: dict) -> list:
    test_cmd = MAP_REPO_VERSION_TO_SPECS_JS[instance["repo"]][instance.get("version") or None]["test_cmd"]
    directives = []
    for test_path in _get_test_paths(instance):
        if test_path.startswith("tests/languages"):
            directives.append(test_cmd + f" --language {test_path.split('/')[2]}")
        elif test_path == "tests/core/greedy.js":
            directives.append("./node_modules/.bin/mocha tests/core/**/*.js --reporter json")
        elif test_path == "test.html":
            continue
    return sorted(list(set(directives)))


def _get_test_cmds_openlayers(instance: dict) -> list:
    SET_PUPPETEER = "PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable"
    XVFB = 'xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99"'
    SSL_LEGACY = "NODE_OPTIONS=--openssl-legacy-provider"
    cmds = []
    rendering_cases = set()
    spec_paths = set()
    test_paths = _get_test_paths(instance)
    test_paths += instance.get("FAIL_TO_PASS", [])
    test_paths += instance.get("PASS_TO_PASS", [])
    for test_path in sorted(set(test_paths)):
        if test_path.startswith("./cases/"):
            rendering_cases.add(test_path.split("/")[2])
            continue
        # OpenLayers 6.5+ moved Karma specs below test/browser/spec and removed
        # test/index_test.js. Treat these as exact spec paths instead of invoking
        # the broad test-browser suite.
        if test_path.startswith("test/browser/spec/") and test_path.endswith(
            ".test.js"
        ):
            spec_paths.add(test_path)
            continue
        test_type = test_path.split('/')[1] if '/' in test_path else ""
        if test_type == "browser":
            if instance.get("version") in ['6.9', '6.12', '6.14', '7.0', '7.1', '7.2', '7.3', '7.5']:
                cmds.append(f'su chromeuser -c "npm run test-browser"')
            else:
                cmds.append(f'{SET_PUPPETEER} {XVFB} su chromeuser -c "npm run test-browser"')
        elif test_type == "rendering":
            match = re.search(r"(?:^|/)cases/([^/]+)", test_path)
            if match:
                rendering_cases.add(match.group(1))
            continue
        elif test_type == "spec":
            if test_path.endswith(".test.js"):
                spec_paths.add(test_path)
            continue
        elif test_type == "node":
            cmds.append("npm run test-node")
        else:
            # Human-readable expected test names are graded from the test file selected
            # by the patch; they are not executable paths themselves.
            if not test_path.startswith("test/"):
                continue
            cmds.append("npm run test")
        if test_type == 'browser' and instance.get('version') in [
            '6.1', '6.2', '6.3', '6.4', '6.5', '6.5.1', '6.6',
            '4.3', '4.4', '4.5', '4.6', '5.1', '5.2', '5.3'
        ]:
            cmds[-1] = f"{SSL_LEGACY} {cmds[-1]}"

    if spec_paths:
        entry_lines = " ".join(
            shlex.quote(f"require('./{path.removeprefix('test/')}');")
            for path in sorted(spec_paths)
        )
        runner = (
            f'{SET_PUPPETEER} {XVFB} su chromeuser -c '
            '"npm run karma -- --single-run --log-level error"'
        )
        if instance.get("version") in [
            "6.1", "6.2", "6.3", "6.4", "6.5", "6.5.1", "6.6",
            "4.3", "4.4", "4.5", "4.6", "5.1", "5.2", "5.3",
        ]:
            runner = f"{SSL_LEGACY} {runner}"
        backup = "/tmp/swebench-openlayers-index-test.js"
        modern_paths = sorted(
            path.removeprefix("test/browser/")
            for path in spec_paths
            if path.startswith("test/browser/")
        )
        legacy_paths = sorted(
            path.removeprefix("test/")
            for path in spec_paths
            if path.startswith("test/")
        )
        modern_pattern = (
            modern_paths[0]
            if len(modern_paths) == 1
            else "{" + ",".join(modern_paths) + "}"
        )
        legacy_pattern = (
            legacy_paths[0]
            if len(legacy_paths) == 1
            else "{" + ",".join(legacy_paths) + "}"
        )
        modern_config = (
            "KARMA_CONFIG=test/browser/karma.config.cjs; "
            '[ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; '
            '[ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; '
            "KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; "
            'if [ ! -f "$KARMA_CONFIG" ]; then '
            'echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; '
            'else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; '
            "node -e 'const fs=require(\"fs\");const p=process.argv[1],"
            "modern=process.argv[2],legacy=process.argv[3],"
            "source=fs.readFileSync(p,\"utf8\");let "
            "updated=source.replace(/spec\\/\\*\\*\\/\\*\\.test\\.js/g,modern);"
            "if(updated===source)updated=source.replace(/\\*\\*\\/\\*\\.test\\.js/g,legacy);"
            "if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "
            f'"$KARMA_CONFIG" {shlex.quote(modern_pattern)} '
            f'{shlex.quote(legacy_pattern)}; OPENLAYERS_CONFIG_STATUS=$?; fi; '
            'if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then '
            f"{runner}; OPENLAYERS_STATUS=$?; "
            "else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; "
            'if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; '
            'rm -f "$KARMA_BACKUP"; '
            '(exit "$OPENLAYERS_STATUS")'
        )
        cmds.append(
            "if [ -f test/index_test.js ]; then "
            f"cp test/index_test.js {backup}; "
            f"printf '%s\\n' {entry_lines} > test/index_test.js; "
            f"{runner}; OPENLAYERS_STATUS=$?; "
            f"cp {backup} test/index_test.js; rm -f {backup}; "
            '(exit "$OPENLAYERS_STATUS"); '
            f"else {modern_config}; fi"
        )

    if rendering_cases:
        case_pattern = "|".join(
            re.escape(name) for name in sorted(rendering_cases)
        )
        match_pattern = rf"(?:^|/)cases/(?:{case_pattern})/main\.js$"
        # v7.4: use Puppeteer's bundled Chromium 115 via Xvfb (not --headless,
        # which uses SwiftShader and hangs in Docker). --force continues past failures.
        if instance.get("version") == "7.4":
            penv = "CI=true PUPPETEER_CACHE_DIR=/home/chromeuser/.cache/puppeteer"
            cmds.append(
                f'{penv} {XVFB} su chromeuser -c "'
                f'{penv} npm run build-full && {penv} '
                "node test/rendering/test.js --force --headless --log-level info "
                f"--match '{match_pattern}'\""
            )
        else:
            command = (
                f'CI=1 {SET_PUPPETEER} {XVFB} '
                "npm run test-rendering -- --headless --log-level info "
                f"--match {json.dumps(match_pattern)}"
            )
            if instance.get('version') in [
                '6.1', '6.2', '6.3', '6.4', '6.5', '6.5.1', '6.6',
                '4.3', '4.4', '4.5', '4.6', '5.1', '5.2', '5.3'
            ]:
                command = f"{SSL_LEGACY} {command}"
            cmds.append(command)
    return sorted(set(cmds))


def _get_test_cmds_next(instance: dict) -> list:
    SET_PUPPETEER = "PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable"
    XVFB = 'xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99"'
    return sorted(set([
        # 5m cut off legitimate runs (alibaba-fusion__next-4182 died at 382s with its
        # graded tests passing). Keep this well under the harness's 1800s per-instance
        # cap minus the 900s npm install: 20m here pushed 7 instances over it.
        f'timeout 10m bash -c \'{SET_PUPPETEER} {XVFB} '
        f'su chromeuser -c "npm run test {test_path.split("/")[1]}"\''
        for test_path in _get_test_paths(instance)
    ]))


def _get_test_cmds_carbon(instance: dict) -> list:
    cmds = []
    # uncapped jest spawns a worker per core in every container; capping is both faster
    # and stops the accessibility-checker engine fetch failing under contention
    max_workers = " --maxWorkers=1" if instance.get("version") == "12" else " --maxWorkers=4"
    for test_path in _get_test_paths(instance):
        if re.search(r"__snapshots__/(.*).js.snap$", test_path):
            test_path = "/".join(test_path.split("/")[:-2])
        if "__tests__" in test_path:
            test_path = test_path.split("__tests__")[0]
        # For paths under packages/*/src/components/*/next/ or packages/cra-template/,
        # Jest won't match the specific file. Target the component directory instead.
        if "/next/" in test_path and "/components/" in test_path:
            test_path = test_path.split("/next/")[0]
        # cra-template is created by the gold patch as a standalone CRA template.
        # It needs: (1) react-router-dom installed, (2) automatic JSX transform
        # (template files don't import React), (3) bypass modulePathIgnorePatterns.
        if "cra-template/template/" in test_path:
            # cra-template is created by gold patch as a CRA template. Its deps
            # (react-router-dom, @apollo/client, etc.) are listed in template.json
            # but not in package.json. Copy them over and yarn install so PnP can
            # resolve them. Then run jest with automatic JSX runtime.
            cmds.append(
                "node -e '"
                'const p=require("./packages/cra-template/package.json");'
                'p.dependencies={"@apollo/client":"3.7.4","react-router-dom":"6.6.2",'
                '"@testing-library/react":"12.1.5","@testing-library/jest-dom":"5.16.5",'
                '"@testing-library/user-event":"12.8.3","graphql":"16.6.0",'
                '"react":"17.0.1","react-dom":"17.0.1"};'
                'require("fs").writeFileSync("packages/cra-template/package.json",JSON.stringify(p,null,2));'
                "' && yarn install 2>&1 | tail -3 ; "
                'npx jest --no-colors '
                """--config '{"preset":"jest-config-carbon","transform":{"^.+\\\\.(js|jsx)$":["babel-jest",{"presets":["@babel/preset-env",["@babel/preset-react",{"runtime":"automatic"}]]}]}}' """
                'packages/cra-template/template/src'
            )
            continue
        # e2e test files (.e2e.js) are not matched by Jest — target the component directory
        if test_path.endswith(".e2e.js"):
            test_path = "/".join(test_path.split("/")[:-1])
        cmds.append(f"yarn test{max_workers} {test_path}")
    return sorted(set(cmds))


def _get_test_cmds_scratch_gui(instance: dict) -> list:
    test_prefix = MAP_REPO_VERSION_TO_SPECS_JS[instance['repo']][instance['version']]["test_cmd"]
    cmds = []
    # Scratch's broad suite includes an ungraded Sauce Labs smoke test that attempts
    # external network access. Run exactly the patched and graded unit-test paths.
    test_paths = instance.get("FAIL_TO_PASS", []) + instance.get("PASS_TO_PASS", [])
    for test_path in sorted(set(test_paths)):
        if "/__snapshots__/" in test_path and test_path.endswith(".snap"):
            test_path = test_path.replace("/__snapshots__", "")[: -len(".snap")]
        if not re.search(r"^test/unit/.+\.(?:js|jsx|ts|tsx)$", test_path):
            continue
        # Jest treats repeated array-valued options greedily in these historic
        # versions.  A trailing bare path can therefore become another ignore
        # pattern and silently fall back to the broad suite.  The boolean selector
        # gives the following path an unambiguous meaning on every supported Jest.
        cmds.append(f"{test_prefix} --runTestsByPath {shlex.quote(test_path)}")
    return sorted(set(cmds))


def _get_test_cmds_calypso(instance: dict) -> list:
    # parse_log_calypso splits the log on " ./node_modules/.bin/jest " and reads the
    # verbose tick/cross lines, so jest has to be called directly rather than through
    # `npm run test-client`, and with --verbose or a passing suite prints no test names.
    # It also stops at the first "  ● ", so only the patched files are run: a full-suite
    # run has failing suites whose markers truncate the parse.
    cmds = []
    for test_path in _get_test_paths(instance):
        # a snapshot is checked by the test file beside it
        if "__snapshots__/" in test_path and test_path.endswith(".snap"):
            test_path = test_path.replace("__snapshots__/", "")[: -len(".snap")]
        # jest only collects client/**/test/*.js(x); mocks, fixtures and config files
        # in the same patch match nothing, and "No tests found" exits non-zero, which
        # makes the whole run ungradeable
        if not re.search(r"/test/[^/]+\.jsx?$", test_path):
            continue
        cmds.append(
            "CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; "
            f"./node_modules/.bin/jest --verbose -c=$CFG {test_path}"
        )
    return sorted(set(cmds))


def _get_test_cmds_lighthouse(instance: dict) -> list:
    # Keep each runner invocation to one command. Podman may deliver stdout and stderr
    # in separate batches, so several JSON-reporter processes can otherwise appear in
    # a different order than their shell traces and the grader can miss the first file.
    grouped_paths: dict[str, set[str]] = {}
    standalone = set()
    SUBDIRS = ["report", "cli", "report", "treemap", "viewer"]
    LH_PREFIX = "lighthouse-"
    for test_path in _get_test_paths(instance):
        if any(test_path.endswith(ext) for ext in [".html", ".json", ".md", ".txt"]) or "smokehouse" in test_path:
            continue
        # Skip snapshot files — target the directory instead
        if "__snapshots__" in test_path:
            test_path = test_path.split("__snapshots__")[0].rstrip("/")
        # Skip non-test helper files (e.g. fake-driver.js) — target the directory
        if not test_path.endswith("-test.js") and not test_path.endswith("-test.ts") and test_path.endswith(".js"):
            test_path = "/".join(test_path.split("/")[:-1])
        parent_folder = test_path.split("/")[0]
        if instance.get("version") in ['9.5', '10.0', '10.2']:
            if parent_folder == "flow-report":
                standalone.add("yarn unit-flow")
            elif parent_folder in SUBDIRS + [LH_PREFIX + x for x in SUBDIRS]:
                if parent_folder.startswith(LH_PREFIX):
                    parent_folder = parent_folder[len(LH_PREFIX):]
                grouped_paths.setdefault(f"yarn unit-{parent_folder}", set()).add(
                    test_path
                )
            else:
                grouped_paths.setdefault("yarn mocha", set()).add(test_path)
        elif '3.0' <= str(instance.get("version", "")) <= '8.6':
            grouped_paths.setdefault("yarn jest --no-colors", set()).add(test_path)
        else:
            grouped_paths.setdefault(
                "./node_modules/.bin/mocha --reporter json", set()
            ).add(test_path)
    commands = standalone | {
        f"{prefix} {' '.join(sorted(paths))}"
        for prefix, paths in grouped_paths.items()
    }
    return sorted(commands)


def _get_test_cmds_prettier(instance: dict) -> list:
    cmds = []
    for test_path in _get_test_paths(instance):
        if "__snapshots__" in test_path:
            test_path = test_path.split("__snapshots__")[0]
        if test_path.endswith(".md"):
            test_path = "/".join(test_path.split("/")[:-1])
        # Only jsfmt.spec.js and __tests__/*.js are actual specs — everything else
        # (fixture .js, .ts, .css, .snap, etc.) needs the directory instead
        if not test_path.endswith("jsfmt.spec.js") and not "/__tests__/" in test_path and not test_path.endswith("/"):
            test_path = "/".join(test_path.split("/")[:-1])
        cmds.append(f"yarn test {test_path}")
    return sorted(set(cmds))


_MAP_REPO_TO_TEST_CMDS = {
    "alibaba-fusion/next": _get_test_cmds_next,
    "Automattic/wp-calypso": _get_test_cmds_calypso,
    "carbon-design-system/carbon": _get_test_cmds_carbon,
    "GoogleChrome/lighthouse": _get_test_cmds_lighthouse,
    "openlayers/openlayers": _get_test_cmds_openlayers,
    "prettier/prettier": _get_test_cmds_prettier,
    "PrismJS/prism": _get_test_cmds_prism,
    "scratchfoundation/scratch-gui": _get_test_cmds_scratch_gui,
    # react-pdf: static test_cmd runs the whole monorepo, which is what its
    # P2P lists need -- they span packages the patched one does not contain.
}


def _get_test_commands(instance: dict, specs: dict) -> str:
    """Get test command(s) for an instance. Uses per-repo handler if available."""
    repo = instance["repo"]
    if repo in _MAP_REPO_TO_TEST_CMDS and instance.get("test_patch"):
        cmds = _MAP_REPO_TO_TEST_CMDS[repo](instance)
        if cmds:
            # Use ; instead of && so all test commands run even if one fails.
            # We need output from ALL tests for correct F2P/P2P grading.
            return " ; ".join(cmds)
    # Fallback to static test_cmd from specs
    test_cmd = specs["test_cmd"]
    if isinstance(test_cmd, list):
        return " ; ".join(test_cmd)
    return test_cmd


def _carbon_achecker_server_commands() -> list[str]:
    """Start the image-bundled accessibility-checker rule server.

    Carbon versions in this benchmark span the legacy @ibma/aat API and the current
    accessibility-checker API. Both insist on HTTP, and browser-like Jest environments
    enforce CORS, so serve the pinned engine over loopback. Exact-path aliases adapt the
    hash-verified ACE engine to the legacy AWE filenames without weakening the server's
    traversal guard.
    """
    engine_base = f"/archives/{CARBON_ACHECKER_ARCHIVE_PATH}/js/"
    server_js = (
        'var fs=require("fs"),http=require("http"),path=require("path"),'
        'url=require("url");'
        f'var root="{CARBON_ACHECKER_OFFLINE_ROOT}",'
        f'port={CARBON_ACHECKER_OFFLINE_PORT},engineBase="{engine_base}";'
        "http.createServer(function(request,response){"
        'response.setHeader("Access-Control-Allow-Origin","*");'
        'var pathname=decodeURIComponent(url.parse(request.url).pathname);'
        'if(pathname==="/tools/api/pub/meter/v2"){response.statusCode=204;'
        'response.end();return;}'
        "var legacyBrowserEngine=false;"
        "if(pathname===engineBase+\"awe-node.js\"){"
        'pathname=engineBase+"ace-node.js";}'
        "else if(pathname===engineBase+\"awe.js\"){"
        'pathname=engineBase+"ace.js";legacyBrowserEngine=true;}'
        'var filename=path.resolve(root,"."+pathname);'
        'if(filename.indexOf(root+path.sep)!==0){response.statusCode=403;'
        'response.end("forbidden");return;}'
        'if(/\\.json$/.test(filename)){response.setHeader("Content-Type",'
        '"application/json");}else if(/\\.js$/.test(filename)){'
        'response.setHeader("Content-Type","application/javascript");}'
        "if(legacyBrowserEngine){fs.readFile(filename,function(error,contents){"
        'if(error){response.statusCode=404;response.end("not found");return;}'
        'response.end(Buffer.concat([contents,Buffer.from('
        '"\\n;window.IBMAwe=ace;\\n")]));});return;}'
        "var stream=fs.createReadStream(filename);"
        'stream.on("error",function(){if(!response.headersSent){'
        'response.statusCode=404;}response.end("not found");});'
        "stream.pipe(response);"
        '}).listen(port,"127.0.0.1");'
    )
    log = "/tmp/achecker-offline-server.log"
    return [
        "rm -rf -- .achecker.yml .aat.yml && "
        f"cp {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml .achecker.yml && "
        f"cp {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml .aat.yml",
        (
            "for checker_dir in node_modules/@ibma/aat "
            "node_modules/accessibility-checker "
            "config/jest-config-carbon/node_modules/@ibma/aat "
            "config/jest-config-carbon/node_modules/accessibility-checker; do "
            "if [ -d \"$checker_dir\" ]; then "
            "find \"$checker_dir\" -type f "
            "\\( -name AATMetricsLogger.js -o -name ACMetricsLogger.js \\) "
            "-exec sed -i "
            f"-e 's#http:/[/]ibmac96.austin.ibm.com/cgi-bin/log-cio/log.py#"
            f"http://127.0.0.1:{CARBON_ACHECKER_OFFLINE_PORT}/tools/api/pub/meter/v2#g' "
            f"-e 's#https:/[/]able.ibm.com/tools#http://127.0.0.1:"
            f"{CARBON_ACHECKER_OFFLINE_PORT}/tools#g' {{}} +; fi; done"
        ),
        (
            'export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost" '
            'no_proxy="${no_proxy:+$no_proxy,}127.0.0.1,localhost"'
        ),
        f"node -e '{server_js}' > {log} 2>&1 &",
        "ACHECKER_OFFLINE_PID=$!",
        "trap 'kill $ACHECKER_OFFLINE_PID 2>/dev/null || true' EXIT",
        "ACHECKER_OFFLINE_READY=0",
        (
            "for _ in {1..50}; do "
            "if curl --noproxy '*' -fsS "
            f"http://127.0.0.1:{CARBON_ACHECKER_OFFLINE_PORT}/archives.json "
            "> /dev/null 2>&1; then ACHECKER_OFFLINE_READY=1; break; fi; "
            "sleep 0.1; done"
        ),
        (
            '[ "$ACHECKER_OFFLINE_READY" -eq 1 ] || '
            f'{{ cat {log}; exit 1; }}'
        ),
    ]


# ── Eval script generation ─────────────────────────────────────────────


def _get_eval_script(instance: dict) -> str:
    """Generate the eval.sh script for a multimodal instance."""
    repo = instance["repo"]
    version = instance.get("version") or None
    base_commit = instance["base_commit"]
    test_patch = instance.get("test_patch", "")
    specs = MAP_REPO_VERSION_TO_SPECS_JS[repo][version]
    offline_grading = instance.get("split") == "test"

    test_command = _get_test_commands(instance, specs)

    eval_commands = [
        "#!/bin/bash",
        # Podman can otherwise batch the two Docker exec streams independently,
        # separating a command trace from its result and confusing log parsers.
        "exec 2>&1",
        "set -uxo pipefail",
        f"cd {CONTAINER_WORKDIR}",
        f"git config --global --add safe.directory {CONTAINER_WORKDIR}",
        "source $NVM_DIR/nvm.sh",
        "git status",
        "git show",
        f"git -c core.fileMode=false diff {base_commit}",
    ]
    if offline_grading:
        eval_commands.insert(
            6,
            "export npm_config_offline=true npm_config_audit=false "
            "npm_config_fund=false YARN_ENABLE_NETWORK=0",
        )

    # Carbon: accessibility-checker races on mkdir for engine dir when parallel workers
    # all try to download rules simultaneously. Pre-create the dir to avoid EEXIST.
    if repo == "carbon-design-system/carbon":
        eval_commands.append("mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true")
    # Carbon: gold patch modifies source files — rebuild so tests use updated code.
    # The image's yarn build output is stale after the gold patch is applied.
    _CARBON_POST_PATCH_BUILD = {"16.16", "18.14"}
    if repo == "carbon-design-system/carbon" and version in _CARBON_POST_PATCH_BUILD:
        eval_commands.append("yarn build 2>&1 | tail -5 || true")

    if test_patch:
        # Strip binary diffs — they can't be applied via heredoc
        clean_test_patch, _ = _strip_binary_diffs(test_patch)

        test_files = re.findall(r"diff --git a/.* b/(.*)", test_patch)
        # Separate existing files (can git checkout) from new files (need rm)
        new_file_markers = set()
        lines = test_patch.split("\n")
        for i, line in enumerate(lines):
            if "new file mode" in line:
                for j in range(max(0, i - 2), i):
                    m = re.match(r"diff --git a/.* b/(.*)", lines[j])
                    if m:
                        new_file_markers.add(m.group(1))
                        break
        existing_files = [f for f in test_files if f not in new_file_markers]
        new_files = [f for f in test_files if f in new_file_markers]

        reset_parts = []
        if existing_files:
            reset_parts.append(f"git checkout {base_commit} {' '.join(existing_files)}")
        if new_files:
            reset_parts.append(f"rm -f {' '.join(new_files)}")
        reset_tests_command = " && ".join(reset_parts) if reset_parts else "true"

        eval_commands.append(reset_tests_command)

        # Apply text-only portion of test_patch
        if clean_test_patch.strip():
            HEREDOC_DELIMITER = "EOF_114329324912"
            apply_test_patch_command = (
                f"git apply -v - <<'{HEREDOC_DELIMITER}'\n{clean_test_patch}\n{HEREDOC_DELIMITER}"
            )
            eval_commands.append(apply_test_patch_command)

        # Binary files are injected by the evaluator only after the solver submits.
        # Never accept the legacy build-time staging path: its presence means the
        # solver-visible image leaked hidden grading material.

    # Next v1.27: Cypress/Vite tests run as chromeuser; ensure writable dirs
    if repo == "alibaba-fusion/next" and version == "1.27":
        eval_commands.append("chmod -R a+w /testbed/node_modules 2>/dev/null || true")

    if offline_grading:
        # A patch that changes package.json can leave node_modules stale. Test-split
        # grading is deliberately network-isolated: task images must pre-cache every
        # needed package, and this step may only consume those caches. Fail explicitly
        # when an image is incomplete instead of hiding a failed install.
        eval_commands.append(
            'if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then '
            'echo "package.json changed by patch; re-syncing from the image cache"; '
            "export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true "
            "CHROMEDRIVER_SKIP_DOWNLOAD=true "
            "npm_config_offline=true npm_config_audit=false npm_config_fund=false "
            "YARN_ENABLE_NETWORK=0; "
            "if [ -d /run/swebench-offline/npm ]; then "
            "export npm_config_cache=/run/swebench-offline/npm; fi; "
            "if [ -d /run/swebench-offline/yarn ]; then "
            "export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; "
            "if [ -f yarn.lock ]; then "
            "case \"$(yarn --version)\" in 0.*|1.*) "
            "timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts "
            "--non-interactive --silent > /dev/null 2>&1;; "
            "*) timeout 900 yarn install --immutable-cache --mode=skip-builds "
            "> /dev/null 2>&1;; esac; "
            "else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts "
            "--no-audit --no-fund --silent "
            "> /dev/null 2>&1; fi || "
            '{ echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; '
            "chmod -R a+rX node_modules > /dev/null 2>&1 || true; "
            "fi"
        )
    else:
        # Preserve the connected dev/deprecated workflow; its dependency changes are
        # outside the test-split offline contract and do not have private cache bundles.
        eval_commands.append(
            'if ! git diff --quiet HEAD -- package.json 2>/dev/null; then '
            'echo "package.json changed by patch; re-syncing dependencies"; '
            "export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; "
            "if [ -f yarn.lock ]; then "
            "timeout 900 yarn install --silent > /dev/null 2>&1 || true; "
            "else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; "
            "chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi"
        )

    eval_commands += INSTANCE_OVERRIDES.get(instance["instance_id"], {}).get("eval_pre", [])

    if repo == "carbon-design-system/carbon":
        eval_commands += _carbon_achecker_server_commands()

    eval_commands += [
        f": '{START_TEST_OUTPUT}'",
        test_command,
        f": '{END_TEST_OUTPUT}'",
    ]

    if test_patch:
        eval_commands.append(reset_tests_command)

    return "\n".join(eval_commands) + "\n"


# ── CLI ────────────────────────────────────────────────────────────────


def load_instances(
    dataset_name_or_path: str,
    split: str = "test",
    instance_ids: list[str] | None = None,
):
    """Load instances from HuggingFace dataset name or local JSON/JSONL file."""
    path = Path(dataset_name_or_path)
    if path.exists() and path.is_file():
        if path.suffix == ".jsonl":
            with open(path) as f:
                instances = [json.loads(line) for line in f if line.strip()]
        else:
            with open(path) as f:
                instances = json.load(f)
            if isinstance(instances, dict):
                instances = list(instances.values())
        if instance_ids:
            instance_ids_set = set(instance_ids)
            instances = [
                i for i in instances if i["instance_id"] in instance_ids_set
            ]
        return instances
    # Fall back to HuggingFace (optional dependency)
    from swebench.harness.utils import load_swebench_dataset

    return load_swebench_dataset(
        dataset_name_or_path, split, instance_ids=instance_ids
    )


def regenerate(instance_ids: list[str] | None = None) -> int:
    """Rewrite Dockerfile and eval.sh for each task, from its task.yaml."""
    from .tasks import load_task, task_dirs, write_generated

    wanted = set(instance_ids or [])
    count = 0
    for task_dir in task_dirs():
        if wanted and task_dir.name not in wanted:
            continue
        instance = load_task(task_dir)
        write_generated(
            task_dir, _get_dockerfile(instance, task_dir), _get_eval_script(instance)
        )
        count += 1
    return count


def main():
    parser = ArgumentParser(
        description="Regenerate Dockerfile and eval.sh for SWE-bench Multimodal tasks"
    )
    parser.add_argument("--instance_ids", nargs="+", default=None)
    args = parser.parse_args()
    print(f"regenerated {regenerate(args.instance_ids)} tasks")


if __name__ == "__main__":
    main()
