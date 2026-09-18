#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 6159de61b6c07f8affe37f617a85be041ec06654
git checkout 6159de61b6c07f8affe37f617a85be041ec06654 lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js lighthouse-core/test/results/sample_v2.json
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js b/lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js
index c63e504f2751..eeaece514a9b 100644
--- a/lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js
+++ b/lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js
@@ -164,6 +164,8 @@ module.exports = [
         },
       },
       'efficient-animated-content': {
+        score: '<1',
+        rawValue: '>2000',
         extendedInfo: {
           value: {
             wastedKb: 666,
diff --git a/lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js b/lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js
index a1c1fba64d3b..addba84b3b31 100644
--- a/lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js
+++ b/lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js
@@ -218,11 +218,41 @@ describe('Byte efficiency base audit', () => {
     let settings = {throttlingMethod: 'simulate', throttling: modestThrottling};
     let result = await MockAudit.audit(artifacts, {settings});
     // expect modest savings
-    assert.equal(result.rawValue, 800);
+    assert.equal(result.rawValue, 1480);
 
     settings = {throttlingMethod: 'simulate', throttling: ultraSlowThrottling};
     result = await MockAudit.audit(artifacts, {settings});
     // expect lots of savings
     assert.equal(result.rawValue, 22350);
   });
+
+  it('should allow overriding of computeWasteWithTTIGraph', async () => {
+    class MockAudit extends ByteEfficiencyAudit {
+      static audit_(artifacts, records) {
+        return {
+          results: records.map(record => ({url: record.url, wastedBytes: record.transferSize})),
+          headings: [],
+        };
+      }
+    }
+
+    class MockJustTTIAudit extends MockAudit {
+      static computeWasteWithTTIGraph(results, graph, simulator) {
+        return ByteEfficiencyAudit.computeWasteWithTTIGraph(results, graph, simulator,
+          {includeLoad: false});
+      }
+    }
+
+    const artifacts = Runner.instantiateComputedArtifacts();
+    artifacts.traces = {defaultPass: trace};
+    artifacts.devtoolsLogs = {defaultPass: devtoolsLog};
+
+    const modestThrottling = {rttMs: 150, throughputKbps: 1000, cpuSlowdownMultiplier: 2};
+    const settings = {throttlingMethod: 'simulate', throttling: modestThrottling};
+    const result = await MockAudit.audit(artifacts, {settings});
+    const resultTti = await MockJustTTIAudit.audit(artifacts, {settings});
+    // expect more savings from default
+    assert.equal(result.rawValue, 1480);
+    assert.equal(resultTti.rawValue, 800);
+  });
 });
diff --git a/lighthouse-core/test/results/sample_v2.json b/lighthouse-core/test/results/sample_v2.json
index 15d542d82a8d..5023baa3e875 100644
--- a/lighthouse-core/test/results/sample_v2.json
+++ b/lighthouse-core/test/results/sample_v2.json
@@ -636,7 +636,7 @@
       },
       "scoreDisplayMode": "numeric",
       "name": "redirects",
-      "description": "Avoids page redirects",
+      "description": "Avoid multiple page redirects",
       "helpText": "Redirects introduce additional delays before the page can be loaded. [Learn more](https://developers.google.com/speed/docs/insights/AvoidRedirects).",
       "details": {
         "type": "table",
@@ -2843,8 +2843,8 @@
       "scoreDisplayMode": "numeric",
       "informative": true,
       "name": "offscreen-images",
-      "description": "Offscreen images",
-      "helpText": "Consider lazy-loading offscreen and hidden images to improve page load speed and time to interactive. [Learn more](https://developers.google.com/web/tools/lighthouse/audits/offscreen-images).",
+      "description": "Defer offscreen images",
+      "helpText": "Consider lazy-loading offscreen and hidden images after all critical resources have finished loading to lower time to interactive. [Learn more](https://developers.google.com/web/tools/lighthouse/audits/offscreen-images).",
       "details": {
         "type": "table",
         "headings": [],
@@ -3111,7 +3111,7 @@
       "scoreDisplayMode": "numeric",
       "informative": true,
       "name": "uses-optimized-images",
-      "description": "Optimize images",
+      "description": "Efficiently encode images",
       "helpText": "Optimized images load faster and consume less cellular data. [Learn more](https://developers.google.com/web/tools/lighthouse/audits/optimize-images).",
       "details": {
         "type": "table",
@@ -5240,8 +5240,5 @@
       "title": "Additional items to manually check",
       "description": "Run these additional validators on your site to check additional SEO best practices."
     }
-  },
-  "timing": {
-    "total": 667
   }
 }
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js
: '>>>>> End Test Output'
git checkout 6159de61b6c07f8affe37f617a85be041ec06654 lighthouse-cli/test/smokehouse/dobetterweb/dbw-expectations.js lighthouse-core/test/audits/byte-efficiency/byte-efficiency-audit-test.js lighthouse-core/test/results/sample_v2.json
