#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 796587ad950f6804d60473c2b5998ed3ec71c59e
git checkout 796587ad950f6804d60473c2b5998ed3ec71c59e tests/lib/cli-engine/cli-engine.js tests/lib/cli.js tests/lib/eslint/eslint.js && rm -f tests/fixtures/formatters/async.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/fixtures/formatters/async.js b/tests/fixtures/formatters/async.js
new file mode 100644
index 00000000000..b5651a697a4
--- /dev/null
+++ b/tests/fixtures/formatters/async.js
@@ -0,0 +1,4 @@
+/*global module*/
+module.exports = function(results) {
+  return Promise.resolve('from async formatter');
+};
diff --git a/tests/lib/cli-engine/cli-engine.js b/tests/lib/cli-engine/cli-engine.js
index 31f59bf51b4..16beb92b87b 100644
--- a/tests/lib/cli-engine/cli-engine.js
+++ b/tests/lib/cli-engine/cli-engine.js
@@ -1160,7 +1160,7 @@ describe("CLIEngine", () => {
 
             const report = engine.executeOnFiles([getFixturePath("formatters")]);
 
-            assert.strictEqual(report.results.length, 3);
+            assert.strictEqual(report.results.length, 4);
             assert.strictEqual(report.errorCount, 0);
             assert.strictEqual(report.warningCount, 0);
             assert.strictEqual(report.fixableErrorCount, 0);
@@ -1200,14 +1200,18 @@ describe("CLIEngine", () => {
             assert.strictEqual(report.results[0].warningCount, 0);
             assert.strictEqual(report.results[0].fixableErrorCount, 0);
             assert.strictEqual(report.results[0].fixableWarningCount, 0);
-            assert.strictEqual(report.results[1].errorCount, 3);
+            assert.strictEqual(report.results[1].errorCount, 0);
             assert.strictEqual(report.results[1].warningCount, 0);
-            assert.strictEqual(report.results[1].fixableErrorCount, 3);
+            assert.strictEqual(report.results[1].fixableErrorCount, 0);
             assert.strictEqual(report.results[1].fixableWarningCount, 0);
             assert.strictEqual(report.results[2].errorCount, 3);
             assert.strictEqual(report.results[2].warningCount, 0);
             assert.strictEqual(report.results[2].fixableErrorCount, 3);
             assert.strictEqual(report.results[2].fixableWarningCount, 0);
+            assert.strictEqual(report.results[3].errorCount, 3);
+            assert.strictEqual(report.results[3].warningCount, 0);
+            assert.strictEqual(report.results[3].fixableErrorCount, 3);
+            assert.strictEqual(report.results[3].fixableWarningCount, 0);
         });
 
         it("should process when file is given by not specifying extensions", () => {
diff --git a/tests/lib/cli.js b/tests/lib/cli.js
index 1b3828b4090..143a3ac1efc 100644
--- a/tests/lib/cli.js
+++ b/tests/lib/cli.js
@@ -287,6 +287,17 @@ describe("cli", () => {
         });
     });
 
+    describe("when given an async formatter path", () => {
+        it("should execute without any errors", async () => {
+            const formatterPath = getFixturePath("formatters", "async.js");
+            const filePath = getFixturePath("passing.js");
+            const exit = await cli.execute(`-f ${formatterPath} ${filePath}`);
+
+            assert.strictEqual(log.info.getCall(0).args[0], "from async formatter");
+            assert.strictEqual(exit, 0);
+        });
+    });
+
     describe("when executing a file with a lint error", () => {
         it("should exit with error", async () => {
             const filePath = getFixturePath("undef.js");
diff --git a/tests/lib/eslint/eslint.js b/tests/lib/eslint/eslint.js
index eaf4aaaaf05..d984f5a3082 100644
--- a/tests/lib/eslint/eslint.js
+++ b/tests/lib/eslint/eslint.js
@@ -1212,7 +1212,7 @@ describe("ESLint", () => {
             });
             const results = await eslint.lintFiles([getFixturePath("formatters")]);
 
-            assert.strictEqual(results.length, 3);
+            assert.strictEqual(results.length, 4);
             assert.strictEqual(results[0].messages.length, 0);
             assert.strictEqual(results[1].messages.length, 0);
             assert.strictEqual(results[2].messages.length, 0);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"
: '>>>>> End Test Output'
git checkout 796587ad950f6804d60473c2b5998ed3ec71c59e tests/lib/cli-engine/cli-engine.js tests/lib/cli.js tests/lib/eslint/eslint.js && rm -f tests/fixtures/formatters/async.js
