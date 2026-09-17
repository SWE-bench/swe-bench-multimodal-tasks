#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 5c3dc932b615afa61580d06950712f79cfc7c4ef
git checkout 5c3dc932b615afa61580d06950712f79cfc7c4ef test/specs/plugin.legend.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/plugin.legend.tests.js b/test/specs/plugin.legend.tests.js
index b8d1fba6d84..9c7f340f13e 100644
--- a/test/specs/plugin.legend.tests.js
+++ b/test/specs/plugin.legend.tests.js
@@ -997,6 +997,46 @@ describe('Legend block tests', function() {
       expect(leaveItem).toBe(chart.legend.legendItems[0]);
     });
 
+    it('should call onLeave when the mouse leaves the canvas', async function() {
+      var hoverItem = null;
+      var leaveItem = null;
+
+      var chart = acquireChart({
+        type: 'line',
+        data: {
+          labels: ['A', 'B', 'C', 'D'],
+          datasets: [{
+            data: [10, 20, 30, 100]
+          }]
+        },
+        options: {
+          plugins: {
+            legend: {
+              onHover: function(_, item) {
+                hoverItem = item;
+              },
+              onLeave: function(_, item) {
+                leaveItem = item;
+              }
+            }
+          }
+        }
+      });
+
+      var hb = chart.legend.legendHitBoxes[0];
+      var el = {
+        x: hb.left + (hb.width / 2),
+        y: hb.top + (hb.height / 2)
+      };
+
+      await jasmine.triggerMouseEvent(chart, 'mousemove', el);
+      expect(hoverItem).toBe(chart.legend.legendItems[0]);
+
+      await jasmine.triggerMouseEvent(chart, 'mouseout');
+      expect(leaveItem).toBe(chart.legend.legendItems[0]);
+    });
+
+
     it('should call onClick for the correct item when in RTL mode', async function() {
       var clickItem = null;
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 5c3dc932b615afa61580d06950712f79cfc7c4ef test/specs/plugin.legend.tests.js
