#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 840599637f2af797d42731ec27d91e0c82325134
git checkout 840599637f2af797d42731ec27d91e0c82325134 test/specs/plugin.decimation.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/plugin.decimation.tests.js b/test/specs/plugin.decimation.tests.js
index f9efbc29af7..9f8320b1e72 100644
--- a/test/specs/plugin.decimation.tests.js
+++ b/test/specs/plugin.decimation.tests.js
@@ -179,5 +179,41 @@ describe('Plugin.decimation', function() {
       expect(chart.data.datasets[0].data[3].x).toBe(originalData[5].x);
       expect(chart.data.datasets[0].data[4].x).toBe(originalData[6].x);
     });
+
+    it('should not crash with uneven points', function() {
+      const data = [];
+      for (let i = 0; i < 15552; i++) {
+        data.push({x: i, y: i});
+      }
+
+      function createChart() {
+        return window.acquireChart({
+          type: 'line',
+          data: {
+            datasets: [{
+              data
+            }]
+          },
+          options: {
+            devicePixelRatio: 1.25,
+            parsing: false,
+            scales: {
+              x: {
+                type: 'linear'
+              }
+            },
+            plugins: {
+              decimation: {
+                enabled: true,
+                algorithm: 'lttb'
+              }
+            }
+          }
+        }, {
+          canvas: {width: 511, height: 511},
+        });
+      }
+      expect(createChart).not.toThrow();
+    });
   });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 840599637f2af797d42731ec27d91e0c82325134 test/specs/plugin.decimation.tests.js
