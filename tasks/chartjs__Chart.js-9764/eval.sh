#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 12c5f9a8396f2a472f331ef772d6c7ba5cd62513
git checkout 12c5f9a8396f2a472f331ef772d6c7ba5cd62513 test/fixtures/controller.bubble/clip.png test/fixtures/controller.bubble/padding.png test/fixtures/controller.bubble/point-style.png test/fixtures/controller.bubble/radius-data.png test/fixtures/core.scale/border-behind-elements.png && rm -f test/fixtures/controller.bubble/hover-radius-zero.js test/fixtures/controller.bubble/hover-radius-zero.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/controller.bubble/hover-radius-zero.js b/test/fixtures/controller.bubble/hover-radius-zero.js
new file mode 100644
index 00000000000..3628577710b
--- /dev/null
+++ b/test/fixtures/controller.bubble/hover-radius-zero.js
@@ -0,0 +1,48 @@
+module.exports = {
+  config: {
+    type: 'bubble',
+    data: {
+      labels: [2, 2, 2, 2],
+      datasets: [{
+        data: [
+          [1, 1],
+          [1, 2],
+          [1, 3, 20],
+          [1, 4, 20]
+        ]
+      }, {
+        data: [1, 2, 3, 4]
+      }, {
+        data: [{x: 3, y: 1}, {x: 3, y: 2}, {x: 3, y: 3, r: 15}, {x: 3, y: 4, r: 15}]
+      }]
+    },
+    options: {
+      events: [],
+      radius: 10,
+      hoverRadius: 0,
+      backgroundColor: 'blue',
+      hoverBackgroundColor: 'red',
+      scales: {
+        x: {display: false, bounds: 'data'},
+        y: {display: false}
+      },
+      layout: {
+        padding: 24
+      }
+    }
+  },
+  options: {
+    canvas: {
+      height: 256,
+      width: 256
+    },
+    run(chart) {
+      chart.setActiveElements([
+        {datasetIndex: 0, index: 1}, {datasetIndex: 0, index: 2},
+        {datasetIndex: 1, index: 1}, {datasetIndex: 1, index: 2},
+        {datasetIndex: 2, index: 1}, {datasetIndex: 2, index: 2},
+      ]);
+      chart.update();
+    }
+  }
+};
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 12c5f9a8396f2a472f331ef772d6c7ba5cd62513 test/fixtures/controller.bubble/clip.png test/fixtures/controller.bubble/padding.png test/fixtures/controller.bubble/point-style.png test/fixtures/controller.bubble/radius-data.png test/fixtures/core.scale/border-behind-elements.png && rm -f test/fixtures/controller.bubble/hover-radius-zero.js test/fixtures/controller.bubble/hover-radius-zero.png
