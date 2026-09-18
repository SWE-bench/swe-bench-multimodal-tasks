#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff efe0e4894c729da74a2432a49568472ca598112a
git checkout efe0e4894c729da74a2432a49568472ca598112a lighthouse-core/test/gather/gather-runner-test.js lighthouse-core/test/report/v2/renderer/report-renderer-test.js lighthouse-core/test/runner-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/gather/gather-runner-test.js b/lighthouse-core/test/gather/gather-runner-test.js
index 5e093fce6c11..b64d53cf7a03 100644
--- a/lighthouse-core/test/gather/gather-runner-test.js
+++ b/lighthouse-core/test/gather/gather-runner-test.js
@@ -255,7 +255,7 @@ describe('GatherRunner', function() {
       cleanBrowserCaches: createCheck('calledCleanBrowserCaches'),
       clearDataForOrigin: createCheck('calledClearStorage'),
       blockUrlPatterns: asyncFunc,
-      getUserAgent: asyncFunc,
+      getUserAgent: () => Promise.resolve('Fake user agent'),
     };
 
     return GatherRunner.setupDriver(driver, {}, {flags: {}}).then(_ => {
@@ -313,7 +313,7 @@ describe('GatherRunner', function() {
       cleanBrowserCaches: createCheck('calledCleanBrowserCaches'),
       clearDataForOrigin: createCheck('calledClearStorage'),
       blockUrlPatterns: asyncFunc,
-      getUserAgent: asyncFunc,
+      getUserAgent: () => Promise.resolve('Fake user agent'),
     };
 
     return GatherRunner.setupDriver(driver, {}, {
@@ -739,6 +739,8 @@ describe('GatherRunner', function() {
           Promise.reject(someOtherError),
           Promise.resolve(1729),
         ],
+
+        LighthouseRunWarnings: [],
       };
 
       return GatherRunner.collectArtifacts(gathererResults).then(artifacts => {
@@ -749,6 +751,22 @@ describe('GatherRunner', function() {
       });
     });
 
+    it('produces a LighthouseRunWarnings artifact from array of warnings', () => {
+      const LighthouseRunWarnings = [
+        'warning0',
+        'warning1',
+        'warning2',
+      ];
+
+      const gathererResults = {
+        LighthouseRunWarnings,
+      };
+
+      return GatherRunner.collectArtifacts(gathererResults).then(artifacts => {
+        assert.deepStrictEqual(artifacts.LighthouseRunWarnings, LighthouseRunWarnings);
+      });
+    });
+
     it('supports sync and async throwing of non-fatal errors from gatherers', () => {
       const gatherers = [
         // sync
@@ -923,4 +941,16 @@ describe('GatherRunner', function() {
         });
     });
   });
+
+  it('issues a lighthouseRunWarnings if running in Headless', () => {
+    const userAgent = 'HeadlessChrome/64.0.3240.0';
+    const gathererResults = {
+      LighthouseRunWarnings: [],
+    };
+
+    GatherRunner.warnOnHeadless(userAgent, gathererResults);
+    assert.strictEqual(gathererResults.LighthouseRunWarnings.length, 1);
+    const warning = gathererResults.LighthouseRunWarnings[0];
+    assert.ok(/Headless Chrome/.test(warning));
+  });
 });
diff --git a/lighthouse-core/test/report/v2/renderer/report-renderer-test.js b/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
index f1a9e79205f7..d2f54b8eda25 100644
--- a/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
+++ b/lighthouse-core/test/report/v2/renderer/report-renderer-test.js
@@ -115,6 +115,30 @@ describe('ReportRenderer V2', () => {
       });
     });
 
+    it('renders no warning section when no lighthouseRunWarnings occur', () => {
+      const container = renderer._dom._document.body;
+      const output = renderer.renderReport(sampleResults, container);
+      assert.strictEqual(output.querySelector('.lh-run-warnings'), null);
+    });
+
+    it('renders a warning section', () => {
+      const runWarnings = [
+        'Less bad thing',
+        'Really bad thing',
+        'LH should maybe just retire now',
+      ];
+      const warningResults = Object.assign({}, sampleResults, {runWarnings});
+      const container = renderer._dom._document.body;
+      const output = renderer.renderReport(warningResults, container);
+
+      const warningEls = output.querySelectorAll('.lh-run-warnings > ul > li');
+      assert.strictEqual(warningEls.length, runWarnings.length);
+      warningEls.forEach((warningEl, index) => {
+        const warningText = warningEl.textContent;
+        assert.strictEqual(warningText, runWarnings[index]);
+      });
+    });
+
     it('renders a footer', () => {
       const footer = renderer._renderReportFooter(sampleResults);
       const footerContent = footer.querySelector('.lh-footer').textContent;
diff --git a/lighthouse-core/test/runner-test.js b/lighthouse-core/test/runner-test.js
index 8f3b1cb37e96..2764522e8fbb 100644
--- a/lighthouse-core/test/runner-test.js
+++ b/lighthouse-core/test/runner-test.js
@@ -453,4 +453,22 @@ describe('Runner', () => {
       }
     });
   });
+
+  it('includes any LighthouseRunWarnings from artifacts in output', () => {
+    const url = 'https://example.com';
+    const LighthouseRunWarnings = [
+      'warning0',
+      'warning1',
+    ];
+    const config = new Config({
+      artifacts: {
+        LighthouseRunWarnings,
+      },
+      audits: [],
+    });
+
+    return Runner.run(null, {url, config, driverMock}).then(results => {
+      assert.deepStrictEqual(results.runWarnings, LighthouseRunWarnings);
+    });
+  });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/gather/gather-runner-test.js lighthouse-core/test/report/v2/renderer/report-renderer-test.js lighthouse-core/test/runner-test.js
: '>>>>> End Test Output'
git checkout efe0e4894c729da74a2432a49568472ca598112a lighthouse-core/test/gather/gather-runner-test.js lighthouse-core/test/report/v2/renderer/report-renderer-test.js lighthouse-core/test/runner-test.js
