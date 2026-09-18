#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff e021a77214daecbca0502da9d4245acbc2c46a1e
git checkout e021a77214daecbca0502da9d4245acbc2c46a1e test/specs/scale.linear.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/scale.linear.tests.js b/test/specs/scale.linear.tests.js
index 9ff00e7240f..c523afea9db 100644
--- a/test/specs/scale.linear.tests.js
+++ b/test/specs/scale.linear.tests.js
@@ -1220,4 +1220,31 @@ describe('Linear Scale', function() {
     expect(scale.getValueForPixel(end)).toBeCloseTo(min, 4);
     expect(scale.getValueForPixel(start)).toBeCloseTo(max, 4);
   });
+
+  it('should not throw errors when chart size is negative', function() {
+    function createChart() {
+      return window.acquireChart({
+        type: 'bar',
+        data: {
+          labels: [0, 1, 2, 3, 4, 5, 6, 7, '7+'],
+          datasets: [{
+            data: [29.05, 4, 15.69, 11.69, 2.84, 4, 0, 3.84, 4],
+          }],
+        },
+        options: {
+          plugins: false,
+          layout: {
+            padding: {top: 30, left: 1, right: 1, bottom: 1}
+          }
+        }
+      }, {
+        canvas: {
+          height: 0,
+          width: 0
+        }
+      });
+    }
+
+    expect(createChart).not.toThrow();
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout e021a77214daecbca0502da9d4245acbc2c46a1e test/specs/scale.linear.tests.js
