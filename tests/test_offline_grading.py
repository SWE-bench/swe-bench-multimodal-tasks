import unittest
from pathlib import Path
import re
import json
import shlex
import hashlib
import os
import subprocess
import tempfile

from dockerfile_gen import (
    _get_dockerfile,
    _get_eval_script,
    _get_test_cmds_lighthouse,
    _get_test_cmds_openlayers,
    _get_test_cmds_scratch_gui,
    _strip_binary_diffs,
)
from dockerfile_gen.assets import _problem_image_targets
from dockerfile_gen.constants import (
    CARBON_ACHECKER_ARCHIVE,
    CARBON_ACHECKER_ARCHIVE_PATH,
    CARBON_ACHECKER_ENGINE_VERSION,
    CARBON_ACHECKER_OFFLINE_PORT,
    CARBON_ACHECKER_OFFLINE_ROOT,
)
from dockerfile_gen.tasks import TASKS_DIR, load_task
from dockerfile_gen.utils import git_clone_timesafe


class CarbonOfflineAccessibilityCheckerTest(unittest.TestCase):
    CASES = (
        "carbon-design-system__carbon-7350",   # accessibility-checker 3.1.1
        "carbon-design-system__carbon-12027",  # accessibility-checker 3.1.32
    )

    def test_dockerfiles_bundle_pinned_rule_engines(self):
        for instance_id in self.CASES:
            task_dir = TASKS_DIR / instance_id
            dockerfile = _get_dockerfile(load_task(task_dir), task_dir)
            with self.subTest(instance_id=instance_id):
                self.assertIn(
                    f"accessibility-checker-engine@{CARBON_ACHECKER_ENGINE_VERSION}/ace-node.js",
                    dockerfile,
                )
                self.assertIn(
                    f"accessibility-checker-engine@{CARBON_ACHECKER_ENGINE_VERSION}/ace.js",
                    dockerfile,
                )
                self.assertIn("sha256sum -c -", dockerfile)
                self.assertIn(
                    f'"path":"/archives/{CARBON_ACHECKER_ARCHIVE_PATH}"',
                    dockerfile,
                )
                self.assertIn(f"ruleArchive: {CARBON_ACHECKER_ARCHIVE}", dockerfile)
                self.assertIn("customRuleServer: true", dockerfile)
                self.assertIn(
                    f"ruleServer: http://127.0.0.1:{CARBON_ACHECKER_OFFLINE_PORT}",
                    dockerfile,
                )
                self.assertIn(
                    f"> {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml",
                    dockerfile,
                )
                self.assertIn(
                    "s#https://able.ibm.com/tools#http://127.0.0.1:18080/tools#g",
                    dockerfile,
                )
                self.assertIn(
                    "for checker_dir in node_modules/accessibility-checker",
                    dockerfile,
                )

    def test_eval_starts_cors_enabled_loopback_server(self):
        for instance_id in self.CASES:
            evaluation = _get_eval_script(load_task(TASKS_DIR / instance_id))
            with self.subTest(instance_id=instance_id):
                self.assertIn(CARBON_ACHECKER_OFFLINE_ROOT, evaluation)
                self.assertIn(
                    f"cp {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml .achecker.yml",
                    evaluation,
                )
                self.assertIn(
                    f"cp {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml .aat.yml",
                    evaluation,
                )
                self.assertIn('pathname===engineBase+"awe-node.js"', evaluation)
                self.assertIn('pathname=engineBase+"ace-node.js"', evaluation)
                self.assertIn('pathname===engineBase+"awe.js"', evaluation)
                self.assertIn('pathname=engineBase+"ace.js"', evaluation)
                self.assertIn("window.IBMAwe=ace", evaluation)
                self.assertIn("filename.indexOf(root+path.sep)!==0", evaluation)
                self.assertIn("-name AATMetricsLogger.js", evaluation)
                self.assertIn("-name ACMetricsLogger.js", evaluation)
                self.assertIn(
                    "s#http:/[/]ibmac96.austin.ibm.com/cgi-bin/log-cio/log.py#"
                    "http://127.0.0.1:18080/tools/api/pub/meter/v2#g",
                    evaluation,
                )
                self.assertIn(
                    "s#https:/[/]able.ibm.com/tools#http://127.0.0.1:18080/tools#g",
                    evaluation,
                )
                self.assertIn('listen(port,"127.0.0.1")', evaluation)
                self.assertIn("Access-Control-Allow-Origin", evaluation)
                self.assertIn("ACHECKER_OFFLINE_PID=$!", evaluation)
                self.assertIn("ACHECKER_OFFLINE_READY", evaluation)
                self.assertIn("trap 'kill $ACHECKER_OFFLINE_PID", evaluation)
                self.assertIn("--noproxy '*'", evaluation)
                self.assertIn("/tools/api/pub/meter/v2", evaluation)

    def test_non_carbon_eval_does_not_start_rule_server(self):
        task_dir = TASKS_DIR / "markedjs__marked-684"
        evaluation = _get_eval_script(load_task(task_dir))
        self.assertNotIn("ACHECKER_OFFLINE_PID", evaluation)

    def test_all_carbon_generated_files_are_current(self):
        task_dirs = sorted(TASKS_DIR.glob("carbon-design-system__carbon-*"))
        self.assertEqual(133, len(task_dirs))
        for task_dir in task_dirs:
            task = load_task(task_dir)
            with self.subTest(instance_id=task_dir.name):
                self.assertEqual(
                    _get_dockerfile(task, task_dir),
                    (task_dir / "Dockerfile").read_text(),
                )
                self.assertEqual(
                    _get_eval_script(task),
                    (task_dir / "eval.sh").read_text(),
                )


class TestSplitOfflineContractTest(unittest.TestCase):
    def test_history_prune_removes_backdated_descendant_tag_and_object(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp) / "repo"
            subprocess.run(["git", "init", "-q", str(repo)], check=True)
            subprocess.run(
                ["git", "-C", str(repo), "config", "user.email", "test@example.com"],
                check=True,
            )
            subprocess.run(
                ["git", "-C", str(repo), "config", "user.name", "Test"],
                check=True,
            )
            (repo / "public.txt").write_text("public\n")
            subprocess.run(["git", "-C", str(repo), "add", "public.txt"], check=True)
            subprocess.run(
                ["git", "-C", str(repo), "commit", "-qm", "base"], check=True
            )
            base_commit = subprocess.check_output(
                ["git", "-C", str(repo), "rev-parse", "HEAD"], text=True
            ).strip()
            subprocess.run(
                ["git", "-C", str(repo), "tag", "safe-base", base_commit], check=True
            )

            (repo / "hidden-grading-fixture.txt").write_text("secret\n")
            subprocess.run(
                ["git", "-C", str(repo), "add", "hidden-grading-fixture.txt"],
                check=True,
            )
            backdated_env = {
                **os.environ,
                "GIT_AUTHOR_DATE": "2000-01-01T00:00:00Z",
                "GIT_COMMITTER_DATE": "2000-01-01T00:00:00Z",
            }
            subprocess.run(
                ["git", "-C", str(repo), "commit", "-qm", "backdated future"],
                check=True,
                env=backdated_env,
            )
            future_commit = subprocess.check_output(
                ["git", "-C", str(repo), "rev-parse", "HEAD"], text=True
            ).strip()
            subprocess.run(
                ["git", "-C", str(repo), "tag", "future-backdated"], check=True
            )
            subprocess.run(
                ["git", "-C", str(repo), "remote", "add", "origin", "https://example.invalid/repo"],
                check=True,
            )

            cleanup = git_clone_timesafe("example/repo", base_commit, str(repo))[1:]
            subprocess.run(
                ["bash", "-c", "set -euo pipefail\n" + "\n".join(cleanup)],
                check=True,
            )
            tags = subprocess.check_output(
                ["git", "-C", str(repo), "tag", "-l"], text=True
            ).splitlines()
            self.assertEqual(["safe-base"], tags)
            self.assertFalse((repo / ".git" / "ORIG_HEAD").exists())
            self.assertFalse((repo / ".git" / "FETCH_HEAD").exists())
            self.assertEqual(
                "",
                subprocess.check_output(
                    ["git", "-C", str(repo), "fsck", "--unreachable", "--no-reflogs"],
                    text=True,
                    stderr=subprocess.DEVNULL,
                ).strip(),
            )
            self.assertNotEqual(
                0,
                subprocess.run(
                    ["git", "-C", str(repo), "cat-file", "-e", future_commit],
                    capture_output=True,
                ).returncode,
            )

    @staticmethod
    def _read_exact(path: Path) -> str:
        with open(path, newline="") as handle:
            return handle.read()

    @staticmethod
    def _without_patch_payload(eval_script: str) -> str:
        """Remove the embedded test patch, whose text is data rather than shell."""
        output = []
        delimiter = None
        for line in eval_script.splitlines():
            if delimiter is not None:
                if line == delimiter:
                    delimiter = None
                continue
            match = re.search(r"git apply -v - <<'([^']+)'", line)
            if match:
                delimiter = match.group(1)
                continue
            output.append(line)
        return "\n".join(output)

    def test_all_480_test_evals_are_statically_offline(self):
        task_dirs = [
            task_dir
            for task_dir in TASKS_DIR.iterdir()
            if (task_dir / "task.yaml").is_file()
            and load_task(task_dir).get("split") == "test"
        ]
        self.assertEqual(480, len(task_dirs))
        forbidden = {
            "external URL": re.compile(r"https?://(?!127\.0\.0\.1|localhost)"),
            "wget": re.compile(r"(^|[;&|]\s*)wget\b", re.MULTILINE),
            "external curl": re.compile(
                r"\bcurl\b(?![^\n]*(?:127\.0\.0\.1|localhost))"
            ),
            "online npm install": re.compile(
                r"\bnpm\s+(?:install|i|ci|add)\b(?![^\n]*--offline)"
            ),
            "online yarn install": re.compile(
                r"\byarn\s+install\b(?![^\n]*(?:--offline|--immutable-cache))"
            ),
            "pnpm install": re.compile(r"\bpnpm\s+(?:install|i|add)\b"),
            "npm install-all": re.compile(r"\bnpm\s+run\s+install-all\b"),
            "git network operation": re.compile(
                r"\bgit\s+(?:clone|fetch|pull|submodule)\b"
            ),
        }
        failures = []
        for task_dir in task_dirs:
            task = load_task(task_dir)
            evaluation = _get_eval_script(task)
            self.assertTrue(evaluation.startswith("#!/bin/bash\nexec 2>&1\n"))
            self.assertIn("npm_config_offline=true", evaluation)
            self.assertIn(
                "git -c core.fileMode=false diff --quiet HEAD -- package.json",
                evaluation,
            )
            shell = self._without_patch_payload(evaluation)
            for label, pattern in forbidden.items():
                if pattern.search(shell):
                    failures.append(f"{task_dir.name}: {label}")
        self.assertEqual([], failures)

    def test_all_generated_files_are_current(self):
        task_dirs = [
            task_dir
            for task_dir in TASKS_DIR.iterdir()
            if (task_dir / "task.yaml").is_file()
        ]
        self.assertEqual(612, len(task_dirs))
        stale = []
        for task_dir in task_dirs:
            task = load_task(task_dir)
            if self._read_exact(task_dir / "Dockerfile") != _get_dockerfile(task, task_dir):
                stale.append(f"{task_dir.name}:Dockerfile")
            if self._read_exact(task_dir / "eval.sh") != _get_eval_script(task):
                stale.append(f"{task_dir.name}:eval.sh")
        self.assertEqual([], stale)

    def test_test_split_binary_assets_are_locally_archived_but_not_baked_in(self):
        missing = []
        declared_count = 0
        asset_only = {
            "openlayers__openlayers-10694": {
                "rendering/cases/icon-opacity/expected.png"
            },
            "openlayers__openlayers-11401": {
                "rendering/cases/icon-scale/expected.png"
            },
            "openlayers__openlayers-12172": {
                "rendering/cases/regularshape-style/expected.png"
            },
        }
        for task_dir in TASKS_DIR.iterdir():
            if not (task_dir / "task.yaml").is_file():
                continue
            task = load_task(task_dir)
            if task.get("split") != "test":
                continue
            dockerfile = _get_dockerfile(task, task_dir)
            _, binary_paths = _strip_binary_diffs(task["test_patch"])
            binary_blobs = {}
            for section in re.split(r"(?=^diff --git )", task["test_patch"], flags=re.M):
                if "Binary files" not in section:
                    continue
                path_match = re.match(r"diff --git a/.+ b/(.+)$", section, flags=re.M)
                blob_match = re.search(
                    r"^index [0-9a-f]+\.\.([0-9a-f]+)", section, flags=re.M
                )
                self.assertIsNotNone(path_match, task_dir.name)
                self.assertIsNotNone(blob_match, task_dir.name)
                binary_blobs[path_match.group(1)] = blob_match.group(1)
            self.assertEqual(set(binary_paths), set(binary_blobs), task_dir.name)
            declared_paths = {
                item["path"]
                for item in (task.get("image_assets") or {}).get("test_patch") or []
                if isinstance(item, dict) and item.get("path")
            }
            declared_count += len(declared_paths)
            self.assertEqual(set(), set(binary_paths) - declared_paths, task_dir.name)
            self.assertEqual(
                asset_only.get(task_dir.name, set()),
                declared_paths - set(binary_paths),
                task_dir.name,
            )
            for kind in ("test_patch", "patch"):
                for asset in (task.get("image_assets") or {}).get(kind) or []:
                    path = asset.get("path") if isinstance(asset, dict) else None
                    if not path:
                        continue
                    source = task_dir / "test_assets" / path
                    if not source.is_file():
                        missing.append(f"{task_dir.name}:{kind}:{path}")
                    elif path in binary_blobs:
                        data = source.read_bytes()
                        digest = hashlib.sha1(
                            f"blob {len(data)}\0".encode() + data
                        ).hexdigest()
                        self.assertTrue(
                            digest.startswith(binary_blobs[path]),
                            f"{task_dir.name}:{path}",
                        )
                    url = asset.get("url", "")
                    if url:
                        self.assertNotIn(url, dockerfile)
                    self.assertNotIn(f'test_assets/{path}', dockerfile)
        self.assertEqual([], missing)
        self.assertEqual(109, declared_count)

    def test_test_split_problem_assets_are_locally_archived(self):
        missing = []
        for task_dir in TASKS_DIR.iterdir():
            if not (task_dir / "task.yaml").is_file():
                continue
            task = load_task(task_dir)
            if task.get("split") != "test":
                continue
            for path, _url in _problem_image_targets(task_dir, task):
                if not path.is_file():
                    missing.append(f"{task_dir.name}:{path.name}")
            dockerfile = _get_dockerfile(task, task_dir)
            self.assertNotIn("curl -fsSL -o '/problem_assets/", dockerfile)
        self.assertEqual([], missing)

    def test_build_context_excludes_all_grading_material(self):
        expected = "*\n!Dockerfile\n!problem_assets\n!problem_assets/**\n"
        missing = []
        checked = 0
        for task_dir in TASKS_DIR.iterdir():
            if not (task_dir / "task.yaml").is_file():
                continue
            checked += 1
            dockerignore = task_dir / ".dockerignore"
            if not dockerignore.is_file() or self._read_exact(dockerignore) != expected:
                missing.append(task_dir.name)
            dockerfile = self._read_exact(task_dir / "Dockerfile")
            for history_guard in (
                "git remote remove origin",
                "git merge-base --is-ancestor",
                "rm -f .git/ORIG_HEAD .git/FETCH_HEAD",
                "git reflog expire --expire=now --all",
                "git gc --prune=now --aggressive",
                'git rev-list --all --not "$BASE_COMMIT"',
                "git cat-file --batch-all-objects",
                "git fsck --unreachable --no-reflogs",
            ):
                self.assertIn(history_guard, dockerfile, task_dir.name)
            for private_name in (
                "test_assets",
                "gold.patch",
                "test.patch",
                "tests.json",
                "eval.sh",
                "/swebench/image_assets",
                "/image_assets",
                "/run/swebench-offline",
            ):
                self.assertNotIn(private_name, dockerfile, task_dir.name)
        self.assertEqual(612, checked)
        self.assertEqual([], missing)

    def test_gold_only_dependencies_use_private_grader_bundles(self):
        metadata = json.loads(
            (TASKS_DIR.parent / "offline_dependencies.json").read_text()
        )
        expected = {
            "GoogleChrome__lighthouse-10176",
            "alibaba-fusion__next-2131",
            "alibaba-fusion__next-3345",
            "bpmn-io__bpmn-js-1802",
            "bpmn-io__bpmn-js-1928",
            "grommet__grommet-2131",
            "openlayers__openlayers-13648",
            "prettier__prettier-9514",
            "scratchfoundation__scratch-gui-2778",
        }
        self.assertEqual(1, metadata["schema_version"])
        self.assertEqual(expected, set(metadata["instances"]))

        # These were previously installed into public images and directly revealed
        # part of the corresponding gold patches.
        self.assertNotIn(
            "lodash.clonedeep@4.5.0",
            _get_dockerfile(
                load_task(TASKS_DIR / "alibaba-fusion__next-2131"),
                TASKS_DIR / "alibaba-fusion__next-2131",
            ),
        )
        self.assertNotIn(
            "yarn add meriyah@3.1.2",
            _get_dockerfile(
                load_task(TASKS_DIR / "prettier__prettier-9514"),
                TASKS_DIR / "prettier__prettier-9514",
            ),
        )

    def test_dev_split_keeps_connected_manifest_resync(self):
        task = load_task(TASKS_DIR / "Automattic__wp-calypso-21635")
        self.assertEqual("dev", task["split"])
        evaluation = _get_eval_script(task)
        self.assertNotIn("npm_config_offline=true", evaluation)
        self.assertIn("re-syncing dependencies", evaluation)

    def test_modern_prettier_bridges_ephemeral_build_proxy_to_yarn(self):
        for instance_id in (
            "prettier__prettier-14688",
            "prettier__prettier-14961",
            "prettier__prettier-16347",
        ):
            dockerfile = _get_dockerfile(
                load_task(TASKS_DIR / instance_id), TASKS_DIR / instance_id
            )
            with self.subTest(instance_id=instance_id):
                self.assertIn('export YARN_HTTP_PROXY="$HTTP_PROXY"', dockerfile)
                self.assertIn('export YARN_HTTPS_PROXY="$HTTPS_PROXY"', dockerfile)
                self.assertNotIn("ENV YARN_HTTP_PROXY", dockerfile)
                self.assertNotIn("ENV YARN_HTTPS_PROXY", dockerfile)

    def test_openlayers_rendering_uses_puppeteer_compatible_browsers(self):
        expected_archives = {
            "openlayers__openlayers-14414": (
                "chromium-browser-snapshots/Linux_x64/1069273/chrome-linux.zip"
            ),
            "openlayers__openlayers-14659": (
                "chromium-browser-snapshots/Linux_x64/1108766/chrome-linux.zip"
            ),
            "openlayers__openlayers-15168": (
                "chrome-for-testing-public/116.0.5845.96/linux64/chrome-linux64.zip"
            ),
            "openlayers__openlayers-15234": (
                "chrome-for-testing-public/117.0.5938.92/linux64/chrome-linux64.zip"
            ),
            "openlayers__openlayers-15365": (
                "chrome-for-testing-public/119.0.6045.105/linux64/chrome-linux64.zip"
            ),
            "openlayers__openlayers-15825": (
                "chrome-for-testing-public/124.0.6367.91/linux64/chrome-linux64.zip"
            ),
        }
        for instance_id, archive in expected_archives.items():
            task_dir = TASKS_DIR / instance_id
            dockerfile = _get_dockerfile(load_task(task_dir), task_dir)
            with self.subTest(instance_id=instance_id):
                self.assertIn(archive, dockerfile)
                self.assertGreater(
                    dockerfile.rfind(archive),
                    dockerfile.find("151.0.7922.137/linux64/chrome-linux64.zip"),
                )
                self.assertIn(
                    'exec /opt/chrome-linux',
                    dockerfile[dockerfile.rfind(archive) :],
                )

    def test_openlayers_rendering_cases_use_anchored_exact_matches(self):
        for task_dir in TASKS_DIR.glob("openlayers__openlayers-*"):
            task = load_task(task_dir)
            if task.get("split") != "test":
                continue
            commands = _get_test_cmds_openlayers(task)
            rendering = [command for command in commands if "--match" in command]
            declared_cases = [
                test.split("/")[2]
                for test in task["FAIL_TO_PASS"] + task["PASS_TO_PASS"]
                if test.startswith("./cases/")
            ]
            if declared_cases:
                self.assertEqual(1, len(rendering), task_dir.name)
                argv = shlex.split(rendering[0])
                if "--match" not in argv:
                    argv = next(
                        nested
                        for argument in argv
                        if "--match" in (nested := shlex.split(argument))
                    )
                match_pattern = argv[argv.index("--match") + 1]
                self.assertIn("(?:^|/)cases/(?:", match_pattern)
                self.assertIn("/main\\.js$", match_pattern)
                for case in declared_cases:
                    self.assertIn(re.escape(case), match_pattern)

    def test_openlayers_karma_runs_only_patched_spec_files(self):
        cases = {
            "openlayers__openlayers-7554": (
                "spec/ol/renderer/canvas/vectorlayer.test.js",
            ),
            "openlayers__openlayers-10478": (
                "spec/ol/render/canvas/labelcache.test.js",
                "spec/ol/renderer/canvas/vectortilelayer.test.js",
            ),
            "openlayers__openlayers-12695": (
                "spec/ol/format/kml.test.js",
            ),
        }
        for instance_id, expected_paths in cases.items():
            task_dir = TASKS_DIR / instance_id
            commands = _get_test_cmds_openlayers(load_task(task_dir))
            karma = [command for command in commands if "npm run karma" in command]
            with self.subTest(instance_id=instance_id):
                self.assertEqual(1, len(karma))
                self.assertIn("printf '%s\\n'", karma[0])
                for path in expected_paths:
                    self.assertIn(path, karma[0])
                self.assertIn('exit "$OPENLAYERS_STATUS"', karma[0])
                self.assertNotIn('npm run test-browser"', karma[0])
                if instance_id == "openlayers__openlayers-12695":
                    self.assertIn("KARMA_CONFIG=test/browser/karma.config.cjs", karma[0])
                if instance_id == "openlayers__openlayers-7554":
                    self.assertIn("KARMA_CONFIG=test/karma.config.js", karma[0])
                    self.assertIn(r"/\*\*\/\*\.test\.js/g", karma[0])

    def test_lighthouse_json_reporter_runs_all_files_in_one_process(self):
        for task_dir in TASKS_DIR.glob("GoogleChrome__lighthouse-*"):
            task = load_task(task_dir)
            if task.get("split") != "test" or float(task["version"]) >= 3:
                continue
            commands = _get_test_cmds_lighthouse(task)
            mocha = [
                command
                for command in commands
                if command.startswith("./node_modules/.bin/mocha --reporter json")
            ]
            self.assertLessEqual(len(mocha), 1, task_dir.name)

    def test_scratch_runs_only_declared_unit_test_files(self):
        for task_dir in TASKS_DIR.glob("scratchfoundation__scratch-gui-*"):
            task = load_task(task_dir)
            if task.get("split") != "test":
                continue
            commands = _get_test_cmds_scratch_gui(task)
            argv = [shlex.split(command) for command in commands]
            selected = {
                command[command.index("--runTestsByPath") + 1]
                for command in argv
            }
            declared = set(task["FAIL_TO_PASS"] + task["PASS_TO_PASS"])
            self.assertEqual(declared, selected, task_dir.name)
            self.assertTrue(
                all(command.count("--runTestsByPath") == 1 for command in argv),
                task_dir.name,
            )
            self.assertFalse(any(path.startswith("test/integration/") for path in selected))


if __name__ == "__main__":
    unittest.main()
