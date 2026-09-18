#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8984c91372e64d1e8dd2ce21b87b80977d57bff9
git checkout 8984c91372e64d1e8dd2ce21b87b80977d57bff9 tests/lib/cli.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/lib/cli.js b/tests/lib/cli.js
index 0f8a24c2e28..d1fea182db1 100644
--- a/tests/lib/cli.js
+++ b/tests/lib/cli.js
@@ -778,6 +778,16 @@ describe("cli", () => {
             assert.include(log.error.getCall(0).args[0], "ESLint found too many warnings");
         });
 
+        it("should exit with exit code 1 without printing warnings if the quiet option is enabled and warning count exceeds threshold", async () => {
+            const filePath = getFixturePath("max-warnings");
+            const exitCode = await cli.execute(`--no-ignore --quiet --max-warnings 5 ${filePath}`);
+
+            assert.strictEqual(exitCode, 1);
+            assert.ok(log.error.calledOnce);
+            assert.include(log.error.getCall(0).args[0], "ESLint found too many warnings");
+            assert.ok(log.info.notCalled); // didn't print warnings
+        });
+
         it("should not change exit code if warning count equals threshold", async () => {
             const filePath = getFixturePath("max-warnings");
             const exitCode = await cli.execute(`--no-ignore --max-warnings 6 ${filePath}`);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"
: '>>>>> End Test Output'
git checkout 8984c91372e64d1e8dd2ce21b87b80977d57bff9 tests/lib/cli.js
