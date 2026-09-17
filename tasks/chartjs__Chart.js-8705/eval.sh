#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 74f2f85ec3798e9d72c9b40aaac01aa4b4d8658e
git checkout 74f2f85ec3798e9d72c9b40aaac01aa4b4d8658e test/specs/core.ticks.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/core.ticks.tests.js b/test/specs/core.ticks.tests.js
index 149d19e72e6..52857b649aa 100644
--- a/test/specs/core.ticks.tests.js
+++ b/test/specs/core.ticks.tests.js
@@ -96,4 +96,13 @@ describe('Test tick generators', function() {
     expect(xLabels).toEqual(['0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1']);
     expect(yLabels).toEqual(['0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1']);
   });
+
+  describe('formatters.numeric', function() {
+    it('should not fail on empty or 1 item array', function() {
+      const scale = {chart: {options: {locale: 'en'}}, options: {ticks: {format: {}}}};
+      expect(Chart.Ticks.formatters.numeric.apply(scale, [1, 0, []])).toEqual('1');
+      expect(Chart.Ticks.formatters.numeric.apply(scale, [1, 0, [{value: 1}]])).toEqual('1');
+      expect(Chart.Ticks.formatters.numeric.apply(scale, [1, 0, [{value: 1}, {value: 1.01}]])).toEqual('1.00');
+    });
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 74f2f85ec3798e9d72c9b40aaac01aa4b4d8658e test/specs/core.ticks.tests.js
