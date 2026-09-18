#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c80b1450f55189a03bf3781e04559eb9b68f2129
git checkout c80b1450f55189a03bf3781e04559eb9b68f2129 test/fixtures/controller.bar/minBarLength/horizontal-neg.png test/fixtures/controller.bar/minBarLength/horizontal-pos.png test/fixtures/controller.bar/minBarLength/vertical-neg.png test/fixtures/controller.bar/minBarLength/vertical-pos.png && rm -f test/fixtures/controller.bar/minBarLength/horizontal-stacked.js test/fixtures/controller.bar/minBarLength/horizontal-stacked.png test/fixtures/controller.bar/minBarLength/vertical-stacked.js test/fixtures/controller.bar/minBarLength/vertical-stacked.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/controller.bar/minBarLength/horizontal-stacked.js b/test/fixtures/controller.bar/minBarLength/horizontal-stacked.js
new file mode 100644
index 00000000000..8452ed6c8d6
--- /dev/null
+++ b/test/fixtures/controller.bar/minBarLength/horizontal-stacked.js
@@ -0,0 +1,43 @@
+module.exports = {
+  config: {
+    type: 'bar',
+    data: {
+      labels: [0, 1, 2, 3, 4],
+      datasets: [{
+        data: [0, 0.01, 30],
+        backgroundColor: '#00ff00',
+        borderColor: '#000',
+        borderWidth: 4,
+        minBarLength: 20,
+        xAxisID: 'x2',
+      }]
+    },
+    options: {
+      indexAxis: 'y',
+      scales: {
+        x: {
+          stack: 'demo',
+          ticks: {
+            display: false
+          }
+        },
+        x2: {
+          type: 'linear',
+          position: 'bottom',
+          stack: 'demo',
+          stackWeight: 1,
+          ticks: {
+            display: false
+          }
+        },
+        y: {display: false},
+      }
+    }
+  },
+  options: {
+    canvas: {
+      height: 512,
+      width: 512
+    }
+  }
+};
diff --git a/test/fixtures/controller.bar/minBarLength/vertical-stacked.js b/test/fixtures/controller.bar/minBarLength/vertical-stacked.js
new file mode 100644
index 00000000000..e09f12cd6ab
--- /dev/null
+++ b/test/fixtures/controller.bar/minBarLength/vertical-stacked.js
@@ -0,0 +1,42 @@
+module.exports = {
+  config: {
+    type: 'bar',
+    data: {
+      labels: [0, 1, 2, 3, 4],
+      datasets: [{
+        data: [0, 0.01, 30],
+        backgroundColor: '#00ff00',
+        borderColor: '#000',
+        borderWidth: 4,
+        minBarLength: 20,
+        yAxisID: 'y2',
+      }]
+    },
+    options: {
+      scales: {
+        x: {display: false},
+        y: {
+          stack: 'demo',
+          ticks: {
+            display: false
+          }
+        },
+        y2: {
+          type: 'linear',
+          position: 'left',
+          stack: 'demo',
+          stackWeight: 1,
+          ticks: {
+            display: false
+          }
+        }
+      }
+    }
+  },
+  options: {
+    canvas: {
+      height: 512,
+      width: 512
+    }
+  }
+};
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout c80b1450f55189a03bf3781e04559eb9b68f2129 test/fixtures/controller.bar/minBarLength/horizontal-neg.png test/fixtures/controller.bar/minBarLength/horizontal-pos.png test/fixtures/controller.bar/minBarLength/vertical-neg.png test/fixtures/controller.bar/minBarLength/vertical-pos.png && rm -f test/fixtures/controller.bar/minBarLength/horizontal-stacked.js test/fixtures/controller.bar/minBarLength/horizontal-stacked.png test/fixtures/controller.bar/minBarLength/vertical-stacked.js test/fixtures/controller.bar/minBarLength/vertical-stacked.png
