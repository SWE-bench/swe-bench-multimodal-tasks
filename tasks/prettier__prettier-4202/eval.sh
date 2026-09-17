#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e03e4d6d400dd311c0fe76f286a4f5c70aff4a9f
git checkout e03e4d6d400dd311c0fe76f286a4f5c70aff4a9f tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap && rm -f tests/markdown_ignore/top-level-range.md
git apply -v - <<'EOF_114329324912'
diff --git a/tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap b/tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap
index 6f30d6c7f820..0ef30454bf58 100644
--- a/tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap
@@ -27,3 +27,52 @@ This is a long long long long long long long long long long long long long long
 This is a long long long long long long long long long long long long long long long paragraph.
 
 `;
+
+exports[`top-level-range.md 1`] = `
+<!-- prettier-ignore-start -->
+<!-- some tool start (this should be ignored) -->
+
+| some | table |
+| - | - |
+| 1 | a |
+| 2 | b |
+
+<!-- some tool end -->
+<!-- prettier-ignore-end -->
+
+> <!-- prettier-ignore-start -->
+> <!-- some tool start (this shouldn't be ignored) -->
+>
+> | some | table |
+> | - | - |
+> | 1 | a |
+> | 2 | b |
+>
+> <!-- some tool end -->
+> <!-- prettier-ignore-end -->
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+<!-- prettier-ignore-start -->
+<!-- some tool start (this should be ignored) -->
+
+| some | table |
+| - | - |
+| 1 | a |
+| 2 | b |
+
+<!-- some tool end -->
+<!-- prettier-ignore-end -->
+
+> <!-- prettier-ignore-start -->
+>
+> <!-- some tool start (this shouldn't be ignored) -->
+>
+> | some | table |
+> | ---- | ----- |
+> | 1    | a     |
+> | 2    | b     |
+>
+> <!-- some tool end -->
+>
+> <!-- prettier-ignore-end -->
+
+`;
diff --git a/tests/markdown_ignore/top-level-range.md b/tests/markdown_ignore/top-level-range.md
new file mode 100644
index 000000000000..9773a4db69ed
--- /dev/null
+++ b/tests/markdown_ignore/top-level-range.md
@@ -0,0 +1,21 @@
+<!-- prettier-ignore-start -->
+<!-- some tool start (this should be ignored) -->
+
+| some | table |
+| - | - |
+| 1 | a |
+| 2 | b |
+
+<!-- some tool end -->
+<!-- prettier-ignore-end -->
+
+> <!-- prettier-ignore-start -->
+> <!-- some tool start (this shouldn't be ignored) -->
+>
+> | some | table |
+> | - | - |
+> | 1 | a |
+> | 2 | b |
+>
+> <!-- some tool end -->
+> <!-- prettier-ignore-end -->

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests ; yarn test tests/markdown_ignore/
: '>>>>> End Test Output'
git checkout e03e4d6d400dd311c0fe76f286a4f5c70aff4a9f tests/markdown_ignore/__snapshots__/jsfmt.spec.js.snap && rm -f tests/markdown_ignore/top-level-range.md
