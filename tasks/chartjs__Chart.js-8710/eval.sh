#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff bbf298f4614c058e2ec86329566a56bfcd8bc685
git checkout bbf298f4614c058e2ec86329566a56bfcd8bc685 test/specs/scale.linear.tests.js test/specs/scale.logarithmic.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/scale.linear.tests.js b/test/specs/scale.linear.tests.js
index 9ed4641056d..9ff00e7240f 100644
--- a/test/specs/scale.linear.tests.js
+++ b/test/specs/scale.linear.tests.js
@@ -303,6 +303,46 @@ describe('Linear Scale', function() {
     expect(chart.scales.y.getLabelForValue(7)).toBe('7');
   });
 
+  it('Should correctly use the locale setting when getting a label', function() {
+    var chart = window.acquireChart({
+      type: 'line',
+      data: {
+        datasets: [{
+          xAxisID: 'x',
+          yAxisID: 'y',
+          data: [{
+            x: 10,
+            y: 100
+          }, {
+            x: -10,
+            y: 0
+          }, {
+            x: 0,
+            y: 0
+          }, {
+            x: 99,
+            y: 7
+          }]
+        }],
+      },
+      options: {
+        locale: 'de-DE',
+        scales: {
+          x: {
+            type: 'linear',
+            position: 'bottom'
+          },
+          y: {
+            type: 'linear'
+          }
+        }
+      }
+    });
+    chart.update();
+
+    expect(chart.scales.y.getLabelForValue(7.07)).toBe('7,07');
+  });
+
   it('Should correctly determine the min and max data values when stacked mode is turned on', function() {
     var chart = window.acquireChart({
       type: 'line',
diff --git a/test/specs/scale.logarithmic.tests.js b/test/specs/scale.logarithmic.tests.js
index 0f0dc3303eb..221152b66b5 100644
--- a/test/specs/scale.logarithmic.tests.js
+++ b/test/specs/scale.logarithmic.tests.js
@@ -712,6 +712,39 @@ describe('Logarithmic Scale tests', function() {
     expect(chart.scales.y.getLabelForValue(150)).toBe('150');
   });
 
+  it('should correctly use the locale when generating the label', function() {
+    var chart = window.acquireChart({
+      type: 'bar',
+      data: {
+        datasets: [{
+          yAxisID: 'y',
+          data: [10, 5, 5000, 78, 450]
+        }, {
+          yAxisID: 'y1',
+          data: [1, 1000, 10, 100],
+        }, {
+          yAxisID: 'y',
+          data: [150]
+        }],
+        labels: []
+      },
+      options: {
+        locale: 'de-DE',
+        scales: {
+          y: {
+            type: 'logarithmic'
+          },
+          y1: {
+            position: 'right',
+            type: 'logarithmic'
+          }
+        }
+      }
+    });
+
+    expect(chart.scales.y.getLabelForValue(10.25)).toBe('10,25');
+  });
+
   describe('when', function() {
     var data = [
       {

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout bbf298f4614c058e2ec86329566a56bfcd8bc685 test/specs/scale.linear.tests.js test/specs/scale.logarithmic.tests.js
