# Offline grading

The test split is intended to run with the evaluation container's network disabled.
Image construction still needs network access to clone repositories and install pinned
toolchains and dependencies.

## Runtime contract

- Run the solver/agent container without unrestricted Internet access, and never mount
  this task-repository checkout into it. The public repository necessarily contains
  `gold.patch`, `test.patch`, `tests.json`, and `test_assets/`; an agent that can fetch
  the repository can bypass image-level isolation.
- Give the solver only the clean task image and public `/problem_assets` context.
- Create evaluation containers with Docker/Podman network mode `none`.
- Do not expose proxy variables to the container.
- Mount or copy only evaluator inputs after the model has submitted its patch.
- Treat a failed dependency synchronization as an infrastructure failure. Do not ignore
  it and continue into tests with a partially updated dependency tree.
- Use the task repository as the binary-asset mirror. Its `test_assets/` files replace
  URLs embedded in a binary patch.

Every test-split generated `eval.sh` disables npm and Yarn network access. If a submitted patch
changes the root `package.json`, it synchronizes dependencies from native caches only:

- npm: `npm install --offline --legacy-peer-deps --ignore-scripts`
- Yarn Classic: `yarn install --offline --frozen-lockfile --ignore-scripts`
- modern Yarn: `yarn install --immutable-cache --mode=skip-builds`

Browser-driven repositories are scoped through their runner's native selectors rather
than by changing benchmark tests. OpenLayers rewrites only the temporary Karma collection
glob for its declared spec files (supporting both legacy and modern config locations), and
Scratch uses Jest's `--runTestsByPath` for the unchanged declared unit-test paths.
OpenLayers rendering images whose bundled Puppeteer predates the global browser pin use
Puppeteer's exact archived Chromium/Chrome-for-Testing revision instead; browser transport
failures are not treated as test results or hidden with unconditional retries.

An optional grader-only cache can be mounted at:

```text
/run/swebench-offline/npm
/run/swebench-offline/yarn
```

The cache must be made available only after the agent submits its answer. A cache warmed
from the gold manifest must never be included in the agent-visible image: package names
and versions can reveal part of the reference solution. The same union cache should be
used for baseline, candidate, and gold grading.

Test-split instances that require such a bundle are declared in
`offline_dependencies.json`. Build their caches in connected, trusted infrastructure:

```bash
swebench images build . --split test -j 4 --force-rebuild
python tools/build_offline_dependency_bundles.py \
  --output /private/swebench-offline-deps
```

Build the PR images first. The bundle builder starts those exact images, applies the gold
patch only in a disposable connected container, and saves the union of the baseline and
gold package-manager cache. Each bundle records its image digest, and the evaluator
also binds it to the exact gold patch and dependency policy; stale bundles are rejected.
The resulting directory is private grading infrastructure, not a publishable task asset.
With a compatible SWE-bench harness, reuse the already-verified images and pass the
bundles using:

```bash
swebench eval multimodal -s test --no-patch --task-repo . --reuse-images \
  --offline-deps-dir /private/swebench-offline-deps
swebench eval multimodal -s test --gold --task-repo . --reuse-images \
  --offline-deps-dir /private/swebench-offline-deps
```

## Carbon accessibility checks

Carbon's `accessibility-checker` releases fetch their ACE engine at test time. Carbon
images now contain the pinned 2020-10-07 archive under `/opt/achecker-offline`. During
evaluation, a CORS-enabled HTTP server exposes it only on `127.0.0.1:18080`. The combined
configuration is installed as both `.achecker.yml` and the legacy `.aat.yml`. The pinned
ACE engines are also exposed under the legacy `awe-node.js` and `awe.js` names; the
browser copy defines the `IBMAwe` global expected by `@ibma/aat`. Telemetry from both
`AATMetricsLogger.js` and `ACMetricsLogger.js` is redirected to the same local server.

## Release gate

Before publishing images, run a fresh baseline and gold container for every test-split
task with `--pull=never --network=none`. Require parseable test output, the expected
unresolved baseline, a resolved gold result, and no attempted non-loopback connection.
Before any patch or grader fixture is staged, also reject images containing
`/swebench/image_assets`, `/image_assets`, `/run/swebench-offline*`, `/gold.patch`,
`/test.patch`, `/tmp/patch.diff`, `/tests.json`, or `/eval.sh`.
The static unit test rejects obvious download/install commands in generated evaluation
scripts and verifies that all declared binary test assets are mirrored locally.
