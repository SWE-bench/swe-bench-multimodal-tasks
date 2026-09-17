#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b12f2ea70a4f786138c24730d6d569f77d26dbfc
git checkout b12f2ea70a4f786138c24730d6d569f77d26dbfc lighthouse-core/test/report/v2/renderer/report-renderer-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/report/v2/renderer/report-renderer-test.js b/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
index 1575a5100f88..bdc810f370f5 100644
--- a/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
+++ b/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
@@ -95,6 +95,32 @@ describe('ReportRenderer V2', () => {
     });
   });
 
+  describe('grouping passed/failed', () => {
+    it('separates audits in the DOM', () => {
+      const category = sampleResults.reportCategories[0];
+      const elem = renderer._renderCategory(category);
+      const passedAudits = elem.querySelectorAll('.lh-category > .lh-passed-audits > .lh-audit');
+      const failedAudits = elem.querySelectorAll('.lh-category > .lh-audit');
+
+      assert.equal(passedAudits.length + failedAudits.length, category.audits.length);
+      assert.equal(passedAudits.length, 4);
+      assert.equal(failedAudits.length, 7);
+    });
+
+    it('doesnt create a pased section if there were 0 passed', () => {
+      const category = JSON.parse(JSON.stringify(sampleResults.reportCategories[0]));
+      category.audits.forEach(audit => audit.score = 0);
+      const elem = renderer._renderCategory(category);
+      const passedAudits = elem.querySelectorAll('.lh-category > .lh-passed-audits > .lh-audit');
+      const failedAudits = elem.querySelectorAll('.lh-category > .lh-audit');
+
+      assert.equal(passedAudits.length, 0);
+      assert.equal(failedAudits.length, 11);
+
+      assert.equal(elem.querySelector('.lh-passed-audits-summary'), null);
+    });
+  });
+
   it('can set a custom templateContext', () => {
     assert.equal(renderer._templateContext, renderer._dom.document());
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/report/v2/renderer/report-renderer-test.js
: '>>>>> End Test Output'
git checkout b12f2ea70a4f786138c24730d6d569f77d26dbfc lighthouse-core/test/report/v2/renderer/report-renderer-test.js
