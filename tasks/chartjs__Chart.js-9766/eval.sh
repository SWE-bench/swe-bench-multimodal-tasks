#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 12c5f9a8396f2a472f331ef772d6c7ba5cd62513
git checkout 12c5f9a8396f2a472f331ef772d6c7ba5cd62513 test/fixtures/controller.line/stacking/bounds-data.png test/specs/controller.line.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/controller.line.tests.js b/test/specs/controller.line.tests.js
index 7210367ca95..684b1919bb2 100644
--- a/test/specs/controller.line.tests.js
+++ b/test/specs/controller.line.tests.js
@@ -59,6 +59,32 @@ describe('Chart.controllers.line', function() {
     expect(createChart).not.toThrow();
   });
 
+  it('should find min and max for stacked chart', function() {
+    var chart = window.acquireChart({
+      type: 'line',
+      data: {
+        datasets: [{
+          data: [10, 11, 12, 13]
+        }, {
+          data: [1, 2, 3, 4]
+        }],
+        labels: ['a', 'b', 'c', 'd']
+      },
+      options: {
+        scales: {
+          y: {
+            stacked: true
+          }
+        }
+      }
+    });
+    expect(chart.getDatasetMeta(0).controller.getMinMax(chart.scales.y, true)).toEqual({min: 10, max: 13});
+    expect(chart.getDatasetMeta(1).controller.getMinMax(chart.scales.y, true)).toEqual({min: 11, max: 17});
+    chart.hide(0);
+    expect(chart.getDatasetMeta(0).controller.getMinMax(chart.scales.y, true)).toEqual({min: 10, max: 13});
+    expect(chart.getDatasetMeta(1).controller.getMinMax(chart.scales.y, true)).toEqual({min: 1, max: 4});
+  });
+
   it('Should create line elements and point elements for each data item during initialization', function() {
     var chart = window.acquireChart({
       type: 'line',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 12c5f9a8396f2a472f331ef772d6c7ba5cd62513 test/fixtures/controller.line/stacking/bounds-data.png test/specs/controller.line.tests.js
