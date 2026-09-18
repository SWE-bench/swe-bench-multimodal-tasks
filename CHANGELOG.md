# Changelog

- **[2026-09-17] Harden exact browser-test selection**: OpenLayers' focused Karma
  runner now supports both the modern `test/browser/karma.config.*` layout and the
  legacy `test/karma.config.js` layout. Scratch passes declared unit-test files through
  Jest's explicit `--runTestsByPath` selector, so repeated array-valued ignore options
  cannot consume a trailing path and accidentally launch the broad suite.
- **[2026-09-17] Match OpenLayers rendering browsers to Puppeteer**: six rendering
  images now replace the global Chrome 151 build with the exact Chromium/Chrome for
  Testing revision declared by their bundled Puppeteer release. This prevents DevTools
  targets closing before any rendering case starts, without retrying or altering tests.
- **[2026-09-16] Forward build-only proxies to modern Yarn**: Prettier 3.x uses
  Yarn Berry, which ignores Docker's standard proxy variables and attempted direct DNS
  lookups on restricted builders. Its install step now maps those variables to Yarn's
  process-local proxy settings without persisting proxy configuration in the image.
- **[2026-09-15] Make Carbon accessibility checks offline**: bundle the pinned
  Accessibility Checker 3.1.0 Node and browser engines into every Carbon image, verify
  their hashes at build time, and serve them from a CORS-enabled loopback server during
  evaluation. The config, engine filenames/browser global, and metrics endpoints support
  both legacy `@ibma/aat` and the newer 3.1.32+ engine manager. This removes eval-time
  access to `able.ibm.com`/jsDelivr and the resulting transient
  `Checker is not a constructor` failures. All 133 Carbon tasks.
- **[2026-09-15] Remove grading-time package and browser downloads**: test commands no
  longer repeat build-time installs for Highlight.js, Grommet, or Lighthouse v1; the
  Chromium 115 binary needed by `openlayers__openlayers-14932` is now installed while
  building its image. Manifest changes are reconciled only from an offline cache and a
  missing cache is an explicit infrastructure failure rather than an ignored error.
- **[2026-09-15] Scope broad browser suites to graded tests**: OpenLayers Karma and
  rendering runs now select the patched spec/case files, and Scratch runs only declared
  unit tests. This prevents unrelated browser failures and external smoke tests from
  hiding whether the target tests actually ran.
- **[2026-09-15] Stage binary test fixtures from the local mirror**: image builds no
  longer download hidden grading fixtures from their original URLs or bake them into the
  solver-visible image. The evaluator injects the archived `test_assets/` only after a
  patch is submitted. All 109 grading assets used by the 480-task test split are present
  (106 binary patch files plus three supplemental OpenLayers rendering baselines).
- **[2026-09-15] Complete the problem-asset mirror**: archive the missing BPMN reference
  diagram and Marked emoji, and stop classifying a Marked demo hyperlink and a templated
  Nextzen tile endpoint as problem images. No test-split image now downloads problem
  context while it is built.
- **[2026-08-18] Deprecate alibaba-fusion__next-870**: its eval script hangs
  indefinitely and is not interrupted by the harness's 3600s grading timeout, so the
  instance occupies a worker until the job is killed. An earlier run did produce a verdict
  (`F2P=38/72`), so the hang is intermittent rather than inherent, but an instance that can
  stall a sweep without timing out is not gradeable. `split: test` -> `split: deprecated`,
  taking the test split from 481 to 480.
- **[2026-08-14] Skip puppeteer's Chrome download**: puppeteer v20+ ignores
  `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD` and runs `install.mjs`, which hung indefinitely
  fetching Chrome; added `PUPPETEER_SKIP_DOWNLOAD=true`. All openlayers 15xxx instances
  (the build path only; the eval path already set both names).
- **[2026-08-14] Full git history for lighthouse**: the depth-1 fetch leaves no tag, so the
  build's `git describe` version stamp failed. Cloning full history restores it; its .git is
  399MB (48MB after gc), unlike carbon's 7.8GB, and the ancestry-based prune + gc still
  guarantees zero future commits. `GoogleChrome__lighthouse-14479`, `-14515`, `-14587`,
  `-14672`, `-14800`, `-15054`, `-15092`, and `-5084` (whose tests read the stamped version).
- **[2026-08-14] chmod after the git reset, and again after install**: `chmod -R 777` ran
  before `git reset --hard`, so restored files stayed root-owned 0644 and npm could not
  rewrite a committed `package-lock.json`; install/build also leave root-owned artifacts
  while tests run as chromeuser. `alibaba-fusion__next-4806`, `-4859`.
- **[2026-08-14] Pin Chrome 120 for one openlayers instance**: google-chrome-stable is
  unpinned, so rebuilds pick up the current release; Chrome 151 broke WebGL
  (`getSupportedExtensions()` undefined). `openlayers__openlayers-11545`.
- **[2026-08-14] Pre-create a writable build dir**: the eval script re-syncs dependencies as
  root before dropping to chromeuser, leaving a root-owned `/testbed/build` that fails the
  later `mkdir build/ol`. `openlayers__openlayers-14932`.
- **[2026-08-14] Move one eslint instance to node 22**: re2 has no prebuilt for node 21's ABI
  (404) and resolves its own node-gyp 13 internally, which needs an API added in node 22;
  env vars and .bin shims are ignored. Added per-instance `docker_specs`/`install` overrides
  so its 10 siblings keep their node versions. `eslint__eslint-17618`.

- **[2026-08-13] Run openlayers rendering tests headless as root**: they ran via
  `su chromeuser` with `CI` unset, so puppeteer launched non-headless without
  `--no-sandbox` and rendering came out ~97% off the expected.png baselines; added
  `CI=1`, `--headless` and `--log-level info` (which also makes passing cases visible).
  53 `openlayers__openlayers-*` instances.
- **[2026-08-13] Force karma singleRun for alibaba-fusion**: `singleRun` derived from
  `runAll`, so single-component runs sat in watch mode after passing and only ended when
  a timeout killed them, making results depend on machine speed. 39
  `alibaba-fusion__next-*` instances.
- **[2026-08-13] Remove future commits reliably when cloning**: the tag prune stopped
  early because a git call inside `git tag -l | while read` consumed the piped stdin,
  leaving 3,729 future commits reachable via tags; switched to a `for` loop plus
  `git gc --prune=now` and build-time assertions. The boundary is graph ancestry, not
  spoofable commit timestamps, and the image also asserts that no extra commit object
  remains readable after pruning. All instances.
- **[2026-08-13] Mirror binary patch assets**: `image_assets` pointed only at
  `raw.githubusercontent.com`, so evaluation depended on that host and nothing fetched
  them at all; the 135 test_patch/patch files now live in `src/assets/<instance_id>/<path>`
  with the urls as fallback. 56 instances (126 files), plus 9 in one patch.
- **[2026-08-13] Deprecate two unfixable openlayers instances**: graded rendering cases
  fail at mismatch 0.000-0.001 against `tolerance = 0`, which needs the GPU/driver that
  produced the committed baselines. `openlayers__openlayers-9333`, `-9389`.

# SWE-bench Multimodal v2

*2026-08-11*

Test split goes from **510 to 485 instances**. Every remaining instance passes gold
evaluation pulling its image from Docker Hub, with no local build required.

## Harness

* **Eval containers could not start a browser sandbox on modern Docker** ([SWE-bench#635](https://github.com/SWE-bench/SWE-bench/pull/635), reverted by [#636](https://github.com/SWE-bench/SWE-bench/pull/636)): Docker 29's default seccomp profile blocks `CLONE_NEWUSER`, which Chrome's sandbox needs, so every browser-driven instance failed to launch. Relaxing seccomp fixed alibaba-fusion but regressed openlayers' software-WebGL rendering comparisons, so the relaxation was reverted and the fix moved into the affected instances instead. [alibaba-fusion x39, openlayers x79]
* **A single non-UTF-8 byte discarded a whole instance** ([SWE-bench#635](https://github.com/SWE-bench/SWE-bench/pull/635)): `exec_run_with_timeout` called `.decode()` with strict error handling, so one stray byte in test output raised `UnicodeDecodeError` and the instance produced no report at all. Now decodes with `errors="replace"`. [4 instances in one run; any repo can hit it]
* **Patch-apply fallbacks contaminated each other** ([SWE-bench#633](https://github.com/SWE-bench/SWE-bench/pull/633)): a failed `git apply --reject` left partial state behind, so the next strategy reported `Reversed (or previously applied) patch detected` and the instance was scored unresolved. The tree is now reset between attempts. [carbon-12398]
* **`swebench images build` crashed on every invocation** ([SWE-bench#635](https://github.com/SWE-bench/SWE-bench/pull/635)): `--tag` defaulted to `None`, tripping `assert tag is not None` in `make_image_spec`. [all]

## Images

* **Instance images cloned entire repository history** (this repo, `654500b`): `git_clone_timesafe` did a full clone before resetting to the base commit, so every historical revision of committed artifacts was baked in. carbon commits Yarn zero-install dependency zips, making its `.git` 7.8 GB of a 9.2 GB `/testbed`. Now fetches only the base commit, with a fallback to a full clone if a by-SHA fetch is refused. [carbon x133, all repos benefit]
* **carbon images were 9.9 GB compressed, 75% of a full run's download** (this repo, `654500b`): the shallow fetch drops them to **1.53 GB average** — a 133-image rebuild cut a cold full-split evaluation from over 10 hours to **5.3 hours**, and total pull volume from ~1,756 GB to ~606 GB. [carbon x133]
* **Generated test commands were non-deterministic** (this repo, `1397ea9`): `list(set(...))` reshuffled command order between processes, so regenerating produced phantom diffs in 50-75 rows and you could never tell whether the published dataset was current. Now sorted. [all]

## Environment rot

* **The pinned TeX Live mirror went offline** (this repo, `5939ece`): `ftp.math.utah.edu` became unreachable, so no pinned quarto image could install a LaTeX package, and the `babel-french` step failed silently behind `|| true`. Repointed at a reachable Chemnitz mirror; the frozen 2024 repository is also signed with an expired key, so `tlmgr` is wrapped to pass `--verify-repo=none`. [quarto x24]
* **Pre-2023 quarto could not find its TeX engine** (this repo, `5939ece`): TinyTeX installs to `/root/.TinyTeX/bin/x86_64-linux`, which is not on `PATH`, and the installer points `sys_bin` at `/root/bin` so `tlmgr path add` links nothing usable. Older quarto resolves the engine through `PATH` while newer versions locate TinyTeX themselves, so the symlinks are scoped to the affected instances. [quarto-cli 896, 1029, 1373, 1650, 2583, 2689, 2756, 3853, 4025, 4064, 4184]
* **alibaba-fusion never selected its no-sandbox browser** (this repo, `226dc12`): its karma config defines a `ChromeTravis` launcher with `--no-sandbox`, but gates it behind `TRAVIS` in older versions and `CI` in newer ones, and neither is set during evaluation, so karma fell back to plain Chrome. The default browser now points at the launcher, which works regardless of gating and needs no container privileges. [alibaba-fusion x39]
* **carbon accessibility tests reach the CDN mid-evaluation — known, not fixed** ([mm#8](https://github.com/SWE-bench/swe-bench-multimodal-dockerfiles/issues/8)): `accessibility-checker` fetches both `archives.json` and its engine from `able.ibm.com` at test time, producing `ace.Checker is not a constructor` in roughly 4.5% of runs. A build-time fix was prototyped and works, but only for the older of the two accessibility-checker generations carbon spans, so it was not adopted. Re-running an affected instance clears it. [carbon x133]
* **carbon jest spawned a worker per core in every container** (this repo, `1224461`): with many containers this oversubscribed the host badly enough to trigger the CDN flake. Capped at 4 workers, which was both 20% faster and more reliable in an A/B. Deliberately not applied to grommet, whose full suite times out at that cap. [carbon x133]
* **A stray unhandled rejection killed a whole jest run** (this repo, `1224461`): `audio-context.test.js` throws from `web-audio-test-api`, which Node 20 treats as fatal, aborting the run before the graded `button.test.jsx` reported. That file is not graded, so `NODE_OPTIONS=--unhandled-rejections=warn` keeps a stray rejection from discarding the instance. [scratch-gui-8492]

## Data

* **Drifted accessibility assertions dropped from PASS_TO_PASS**: 50 assertions across 30 carbon instances, each keeping 155-216 checks. All were IBM ACE assertions that tightened after the tasks were written, and every affected instance had a fully passing FAIL_TO_PASS. The removal is baked into the published dataset and cannot be regenerated from this repo, so the exact list is recorded in `docs/dropped-pass-to-pass.json`. [carbon x30]
* **quarto retired to a `deprecated` split**: the suite renders ~180 documents per instance including PDFs through xelatex, needs a pinned TeX distribution, and depends on a historic CTAN mirror staying reachable — 10-30 minutes per instance for the slowest and most fragile repo in the split. [quarto-cli x24]
* **bpmn-js-1203 retired to the `deprecated` split**: 6 of its 10 FAIL_TO_PASS tests fail with the gold patch applied and no PASS_TO_PASS tests to fall back on. Verified that base + gold + test patch exactly reproduces the upstream merge commit, that dependencies match the era two independent ways, and that the failures persist across Chromium 86, 127 and 151 — so it is broken in the data, not the environment. [bpmn-js-1203]

Both retired groups remain downloadable via the `deprecated` split.

Full diagnostics for every entry above, including the dead ends, are in
[`docs/repair-log.md`](docs/repair-log.md). The exact PASS_TO_PASS assertions removed
from the published dataset are listed in
[`docs/dropped-pass-to-pass.json`](docs/dropped-pass-to-pass.json).
