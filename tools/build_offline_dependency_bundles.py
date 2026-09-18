#!/usr/bin/env python3
"""Build private npm/Yarn cache bundles for gold dependency changes.

The output is evaluator-only: never copy it into an image shown to an agent.
Images must already be present in the selected Docker/Podman store. Network access is
used only while building the cache; grading consumes the resulting directory with
network mode ``none``.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

import yaml


CONFIG_FILE = "offline_dependencies.json"


def run(argv: list[str], **kwargs) -> subprocess.CompletedProcess[str]:
    return subprocess.run(argv, check=True, text=True, **kwargs)


def image_ref(raw: str) -> str:
    return raw if "." in raw.split("/", 1)[0] else f"docker.io/{raw}"


def default_engine() -> str:
    override = os.environ.get("SWEBENCH_CONTAINER_CLI")
    if override in {"docker", "podman"}:
        return override
    for candidate in ("docker", "podman"):
        if shutil.which(candidate):
            return candidate
    raise FileNotFoundError("Neither docker nor podman is available")


def build_input_digest(task_dir: Path) -> str:
    """Match the harness image label for public build inputs."""
    digest = hashlib.sha256()

    def add(name: str, payload: bytes) -> None:
        digest.update(name.encode())
        digest.update(b"\0")
        digest.update(str(len(payload)).encode())
        digest.update(b"\0")
        digest.update(payload)

    add("Dockerfile", (task_dir / "Dockerfile").read_bytes())
    dockerignore = task_dir / ".dockerignore"
    if dockerignore.is_file():
        add(".dockerignore", dockerignore.read_bytes())
    problem_assets = task_dir / "problem_assets"
    if problem_assets.is_dir():
        for asset in sorted(path for path in problem_assets.rglob("*") if path.is_file()):
            add(asset.relative_to(task_dir).as_posix(), asset.read_bytes())
    return digest.hexdigest()


def build_bundle(
    task_root: Path,
    output_root: Path,
    instance_id: str,
    config: dict[str, dict[str, str]],
    engine: str,
    force: bool = False,
) -> None:
    manager = config[instance_id]["manager"]
    npm_mode = config[instance_id]["mode"]
    task_dir = task_root / "tasks" / instance_id
    task = yaml.safe_load((task_dir / "task.yaml").read_text())
    image = image_ref(task["image"])
    actual_build_input = run(
        [
            engine,
            "image",
            "inspect",
            image,
            "--format",
            '{{ index .Config.Labels "org.swebench.build-input-sha256" }}',
        ],
        capture_output=True,
    ).stdout.strip()
    expected_build_input = build_input_digest(task_dir)
    if actual_build_input != expected_build_input:
        raise RuntimeError(
            f"{image} was not built from the current task inputs: "
            f"{actual_build_input!r} != {expected_build_input!r}"
        )
    destination = output_root / instance_id
    if destination.exists():
        if not force:
            raise FileExistsError(
                f"{destination} already exists; pass --force to replace it"
            )
        try:
            shutil.rmtree(destination)
        except PermissionError:
            if engine != "podman":
                raise
            # Cache entries may use a rootless-container UID. Remove them through
            # Podman's user namespace rather than weakening host permissions.
            run(["podman", "unshare", "rm", "-rf", str(destination)])
    cache_dir = destination / manager
    cache_dir.mkdir(parents=True)
    destination.chmod(0o700)

    if manager == "yarn":
        setup = """
base_cache=$(yarn cache dir)
mkdir -p /bundle/yarn
cp -a "$base_cache/." /bundle/yarn/ 2>/dev/null || true
git checkout HEAD -- package.json
git checkout HEAD -- yarn.lock 2>/dev/null || true
git -c core.fileMode=false apply --include=package.json --include=yarn.lock /task/gold.patch
YARN_CACHE_FOLDER=/bundle/yarn yarn install --ignore-scripts --non-interactive
"""
    else:
        install = "npm ci" if npm_mode == "ci" else "npm install"
        setup = f"""
mkdir -p /bundle/npm
cp -a /root/.npm/. /bundle/npm/ 2>/dev/null || true
cp -a /home/chromeuser/.npm/. /bundle/npm/ 2>/dev/null || true
git checkout HEAD -- package.json
git checkout HEAD -- package-lock.json 2>/dev/null || true
git -c core.fileMode=false apply --include=package.json --include=package-lock.json /task/gold.patch
PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \\
CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_cache=/bundle/npm \\
{install} --legacy-peer-deps --ignore-scripts --no-audit --no-fund
"""

    command = "set -euo pipefail\nsource \"$NVM_DIR/nvm.sh\"\ncd /testbed\n" + setup
    if engine == "docker":
        command += f"\nchown -R {os.getuid()}:{os.getgid()} /bundle\n"
    argv = [
        engine,
        "run",
        "--rm",
        "--pull=never",
        "--network",
        "host",
        "--volume",
        f"{task_dir}:/task:ro,z",
        "--volume",
        f"{destination}:/bundle:rw,z",
    ]
    for name in ("HTTP_PROXY", "HTTPS_PROXY", "NO_PROXY", "http_proxy", "https_proxy", "no_proxy"):
        if os.environ.get(name):
            argv.extend(["--env", name])
    argv.extend(["--entrypoint", "bash", image, "-c", command])
    run(argv)
    if engine == "podman":
        run(["podman", "unshare", "chown", "-R", "0:0", str(destination)])

    digest = run(
        [engine, "image", "inspect", image, "--format", "{{.Id}}"],
        capture_output=True,
    ).stdout.strip()
    if not digest.startswith("sha256:"):
        digest = f"sha256:{digest}"
    manifest = {
        "schema_version": 1,
        "instance_id": instance_id,
        "image": image,
        "image_digest": digest,
        "gold_patch_sha256": hashlib.sha256(
            (task_dir / "gold.patch").read_bytes()
        ).hexdigest(),
        "dependency_config_sha256": hashlib.sha256(
            json.dumps(
                config[instance_id], sort_keys=True, separators=(",", ":")
            ).encode()
        ).hexdigest(),
        "manager": manager,
        "npm_mode": npm_mode if manager == "npm" else None,
    }
    payload = json.dumps(manifest, indent=2, sort_keys=True) + "\n"
    manifest_path = destination / "manifest.json"
    manifest_path.write_text(payload)
    manifest_path.chmod(0o600)
    checksum = hashlib.sha256(payload.encode()).hexdigest()
    print(f"{instance_id}: {manager} cache ready (manifest sha256:{checksum})")


def main() -> None:
    os.umask(0o077)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--task-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--instance", action="append")
    parser.add_argument("--force", action="store_true")
    parser.add_argument(
        "--engine",
        choices=("docker", "podman"),
        default=None,
        help="Container CLI (default: docker when available, otherwise podman)",
    )
    args = parser.parse_args()
    task_root = args.task_root.resolve()
    raw_config = json.loads((task_root / CONFIG_FILE).read_text())
    if raw_config.get("schema_version") != 1:
        raise ValueError(f"Unsupported {CONFIG_FILE} schema")
    config = raw_config["instances"]
    selected = args.instance or sorted(config)
    engine = args.engine or default_engine()
    unknown = sorted(set(selected) - set(config))
    if unknown:
        parser.error(f"no offline dependency metadata for: {' '.join(unknown)}")
    for instance_id in selected:
        build_bundle(
            task_root,
            args.output.resolve(),
            instance_id,
            config,
            engine,
            force=args.force,
        )


if __name__ == "__main__":
    main()
