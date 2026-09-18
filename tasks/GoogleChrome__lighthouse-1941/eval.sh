#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9dd433c020ffd150f765bfa026e04e7259119bfc
git checkout 9dd433c020ffd150f765bfa026e04e7259119bfc lighthouse-core/test/report/v2/report-generator-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/report/v2/report-generator-test.js b/lighthouse-core/test/report/v2/report-generator-test.js
index 5db2db1089b2..cc685d57cb28 100644
--- a/lighthouse-core/test/report/v2/report-generator-test.js
+++ b/lighthouse-core/test/report/v2/report-generator-test.js
@@ -21,6 +21,27 @@ const ReportGeneratorV2 = require('../../../report/v2/report-generator.js');
 /* eslint-env mocha */
 
 describe('ReportGeneratorV2', () => {
+  describe('#replaceStrings', () => {
+    it('should replace all occurrences', () => {
+      const source = '%foo! %foo %bar!';
+      const result = ReportGeneratorV2.replaceStrings(source, [
+        {search: '%foo', replacement: 'hey'},
+        {search: '%bar', replacement: 'you'},
+      ]);
+
+      assert.equal(result, 'hey! hey you!');
+    });
+
+    it('should not replace serial occurences', () => {
+      const result = ReportGeneratorV2.replaceStrings('%1', [
+        {search: '%1', replacement: '%2'},
+        {search: '%2', replacement: 'pwnd'},
+      ]);
+
+      assert.equal(result, '%2');
+    });
+  });
+
   describe('#arithmeticMean', () => {
     it('should work for empty list', () => {
       assert.equal(ReportGeneratorV2.arithmeticMean([]), 0);
@@ -106,4 +127,27 @@ describe('ReportGeneratorV2', () => {
       assert.equal(result.categories[1].score, 55);
     });
   });
+
+  describe('#generateHtmlReport', () => {
+    it('should return html', () => {
+      const result = new ReportGeneratorV2().generateReportHtml({});
+      assert.ok(result.includes('doctype html'), 'includes doctype');
+      assert.ok(result.trim().match(/<\/html>$/), 'ends with HTML tag');
+    });
+
+    it('should inject the report JSON', () => {
+      const code = 'hax</script><script>console.log("pwned");%%LIGHTHOUSE_JAVASCRIPT%%';
+      const result = new ReportGeneratorV2().generateReportHtml({code});
+      assert.ok(result.includes('"code":"hax'), 'injects the json');
+      assert.ok(result.includes('\\u003c/script'), 'escapes HTML tags');
+      assert.ok(result.includes('LIGHTHOUSE_JAVASCRIPT'), 'cannot be tricked');
+    });
+
+    it('should inject the report renderer javascript', () => {
+      const result = new ReportGeneratorV2().generateReportHtml({});
+      assert.ok(result.includes('ReportRenderer'), 'injects the script');
+      assert.ok(result.includes('pre$`post'), 'does not break from String.replace');
+      assert.ok(result.includes('LIGHTHOUSE_JSON'), 'cannot be tricked');
+    });
+  });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/report/v2/report-generator-test.js
: '>>>>> End Test Output'
git checkout 9dd433c020ffd150f765bfa026e04e7259119bfc lighthouse-core/test/report/v2/report-generator-test.js
