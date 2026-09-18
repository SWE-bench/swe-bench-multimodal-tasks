#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c35d0c6e48ece06b2f420e3804c5f7267820d129
git checkout c35d0c6e48ece06b2f420e3804c5f7267820d129 test/fixtures/controller.doughnut/single-slice-circumference-405.png && rm -f test/fixtures/controller.doughnut/single-slice-offset.js test/fixtures/controller.doughnut/single-slice-offset.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/controller.doughnut/single-slice-offset.js b/test/fixtures/controller.doughnut/single-slice-offset.js
new file mode 100644
index 00000000000..d2a9ace0c27
--- /dev/null
+++ b/test/fixtures/controller.doughnut/single-slice-offset.js
@@ -0,0 +1,16 @@
+module.exports = {
+  config: {
+    type: 'doughnut',
+    data: {
+      labels: ['A'],
+      datasets: [{
+        data: [385],
+        backgroundColor: 'rgba(0,0,0,0.3)',
+        borderColor: 'rgba(0,0,0,0.5)',
+      }]
+    },
+    options: {
+      offset: 20
+    }
+  }
+};
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
pnpm install ; pnpm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.cjs ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.cjs --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout c35d0c6e48ece06b2f420e3804c5f7267820d129 test/fixtures/controller.doughnut/single-slice-circumference-405.png && rm -f test/fixtures/controller.doughnut/single-slice-offset.js test/fixtures/controller.doughnut/single-slice-offset.png
