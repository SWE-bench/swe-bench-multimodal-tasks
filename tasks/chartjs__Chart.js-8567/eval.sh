#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 91628c144944029505de093c43733961ab4f420f
git checkout 91628c144944029505de093c43733961ab4f420f test/fixtures/core.layouts/long-labels.png test/fixtures/scale.time/invalid-data.png test/specs/core.controller.tests.js && rm -f test/fixtures/core.layouts/refit-vertical-boxes.js test/fixtures/core.layouts/refit-vertical-boxes.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/core.layouts/refit-vertical-boxes.js b/test/fixtures/core.layouts/refit-vertical-boxes.js
new file mode 100644
index 00000000000..b49d7885bdc
--- /dev/null
+++ b/test/fixtures/core.layouts/refit-vertical-boxes.js
@@ -0,0 +1,52 @@
+module.exports = {
+  config: {
+    type: 'line',
+    data: {
+      labels: [
+        'Aaron',
+        'Adam',
+        'Albert',
+        'Alex',
+        'Allan',
+        'Aman',
+        'Anthony',
+        'Autoenrolment',
+        'Avril',
+        'Bernard'
+      ],
+      datasets: [{
+        backgroundColor: 'rgba(252,233,79,0.5)',
+        borderColor: 'rgba(252,233,79,1)',
+        borderWidth: 1,
+        data: [101,
+          185,
+          24,
+          311,
+          17,
+          21,
+          462,
+          340,
+          140,
+          24
+        ]
+      }]
+    },
+    options: {
+      maintainAspectRatio: false,
+      plugins: {
+        legend: true,
+        title: {
+          display: true,
+          text: 'test'
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      height: 185,
+      width: 185
+    }
+  }
+};
diff --git a/test/specs/core.controller.tests.js b/test/specs/core.controller.tests.js
index 2fb13eb4bae..c0f1b2ba850 100644
--- a/test/specs/core.controller.tests.js
+++ b/test/specs/core.controller.tests.js
@@ -1430,14 +1430,16 @@ describe('Chart', function() {
       update: [
         'beforeUpdate',
         'beforeLayout',
-        'beforeDataLimits',
+        'beforeDataLimits', // y-axis fit
         'afterDataLimits',
         'beforeBuildTicks',
         'afterBuildTicks',
-        'beforeDataLimits',
+        'beforeDataLimits', // x-axis fit
         'afterDataLimits',
         'beforeBuildTicks',
         'afterBuildTicks',
+        'beforeBuildTicks', // y-axis re-fit
+        'afterBuildTicks',
         'afterLayout',
         'beforeDatasetsUpdate',
         'beforeDatasetUpdate',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 91628c144944029505de093c43733961ab4f420f test/fixtures/core.layouts/long-labels.png test/fixtures/scale.time/invalid-data.png test/specs/core.controller.tests.js && rm -f test/fixtures/core.layouts/refit-vertical-boxes.js test/fixtures/core.layouts/refit-vertical-boxes.png
