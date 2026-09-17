#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff ba84cc5c2aaf500739b202702fac24da74ede50d
git checkout ba84cc5c2aaf500739b202702fac24da74ede50d test/fixtures/core.scale/ticks-mirror.png && rm -f test/fixtures/core.scale/ticks-mirror-x.js test/fixtures/core.scale/ticks-mirror-x.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/core.scale/ticks-mirror-x.js b/test/fixtures/core.scale/ticks-mirror-x.js
new file mode 100644
index 00000000000..ec151e58031
--- /dev/null
+++ b/test/fixtures/core.scale/ticks-mirror-x.js
@@ -0,0 +1,30 @@
+module.exports = {
+  config: {
+    type: 'line',
+    data: {
+      datasets: [{
+        data: [1, -1, 3],
+      }],
+      labels: ['Label1', 'Label2', 'Label3']
+    },
+    options: {
+      scales: {
+        x: {
+          ticks: {
+            mirror: true
+          }
+        },
+        y: {
+          display: false
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      height: 256,
+      width: 512
+    }
+  }
+};
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout ba84cc5c2aaf500739b202702fac24da74ede50d test/fixtures/core.scale/ticks-mirror.png && rm -f test/fixtures/core.scale/ticks-mirror-x.js test/fixtures/core.scale/ticks-mirror-x.png
