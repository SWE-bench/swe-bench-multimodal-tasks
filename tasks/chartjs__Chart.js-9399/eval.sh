#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 31be6100015fbca3b639bcd63f9d03b52f21e171
git checkout 31be6100015fbca3b639bcd63f9d03b52f21e171 test/fixtures/controller.bar/bar-base-value.png test/fixtures/controller.bar/baseLine/bottom.png test/fixtures/controller.bar/baseLine/left.png test/fixtures/controller.bar/baseLine/mid-x.png test/fixtures/controller.bar/baseLine/mid-y.png test/fixtures/controller.bar/baseLine/right.png test/fixtures/controller.bar/baseLine/top.png test/fixtures/controller.bar/baseLine/value-x.png test/fixtures/controller.bar/baseLine/value-y.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number-mixed-chart.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number-with-order.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number.png test/fixtures/controller.bar/borderRadius/border-radius.png test/fixtures/controller.bar/borderWidth/indexable.png test/fixtures/controller.bar/borderWidth/object.png test/fixtures/controller.bar/borderWidth/value.png test/fixtures/controller.bar/horizontal-borders.png test/fixtures/scale.category/ticks-from-data.js test/fixtures/scale.category/ticks-from-data.png && rm -f test/fixtures/controller.bar/borderColor/border+dpr.js test/fixtures/controller.bar/borderColor/border+dpr.png test/fixtures/controller.bar/borderRadius/no-spacing.js test/fixtures/controller.bar/borderRadius/no-spacing.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/controller.bar/borderColor/border+dpr.js b/test/fixtures/controller.bar/borderColor/border+dpr.js
new file mode 100644
index 00000000000..3fa0b53c017
--- /dev/null
+++ b/test/fixtures/controller.bar/borderColor/border+dpr.js
@@ -0,0 +1,35 @@
+module.exports = {
+  threshold: 0,
+  tolerance: 0,
+  config: {
+    type: 'bar',
+    data: {
+      labels: [0, 1, 2, 3, 4, 5, 6],
+      datasets: [
+        {
+          // option in dataset
+          data: [5, 4, 3, 2, 3, 4, 5],
+        },
+      ]
+    },
+    options: {
+      events: [],
+      devicePixelRatio: 1.5,
+      barPercentage: 1,
+      categoryPercentage: 1,
+      backgroundColor: 'black',
+      borderColor: 'black',
+      borderWidth: 8,
+      scales: {
+        x: {display: false},
+        y: {display: false}
+      }
+    }
+  },
+  options: {
+    canvas: {
+      height: 256,
+      width: 501
+    }
+  }
+};
diff --git a/test/fixtures/controller.bar/borderRadius/no-spacing.js b/test/fixtures/controller.bar/borderRadius/no-spacing.js
new file mode 100644
index 00000000000..53a0fc47fbe
--- /dev/null
+++ b/test/fixtures/controller.bar/borderRadius/no-spacing.js
@@ -0,0 +1,33 @@
+module.exports = {
+  threshold: 0.01,
+  config: {
+    type: 'bar',
+    data: {
+      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
+      datasets: [
+        {
+          data: [9, 25, 13, 17, 12, 21, 20, 19, 6, 12, 14, 20],
+          categoryPercentage: 1,
+          barPercentage: 1,
+          backgroundColor: '#2E5C76',
+          borderWidth: 2,
+          borderColor: '#377395',
+          borderRadius: 5,
+        },
+      ]
+    },
+    options: {
+      devicePixelRatio: 1.25,
+      scales: {
+        x: {display: false},
+        y: {display: false}
+      }
+    }
+  },
+  options: {
+    canvas: {
+      height: 256,
+      width: 512
+    }
+  }
+};
diff --git a/test/fixtures/scale.category/ticks-from-data.js b/test/fixtures/scale.category/ticks-from-data.js
index d002927420d..a82f643a332 100644
--- a/test/fixtures/scale.category/ticks-from-data.js
+++ b/test/fixtures/scale.category/ticks-from-data.js
@@ -4,19 +4,13 @@ module.exports = {
     type: 'bar',
     data: {
       datasets: [{
-        data: [10, 5, 0, 25, 78]
+        data: [10, 5, 0, 25, 78],
+        backgroundColor: 'transparent'
       }],
       labels: ['tick1', 'tick2', 'tick3', 'tick4', 'tick5']
     },
     options: {
       indexAxis: 'y',
-      elements: {
-        bar: {
-          backgroundColor: '#AAAAAA80',
-          borderColor: '#80808080',
-          borderWidth: {bottom: 6, left: 15, top: 6, right: 15}
-        }
-      },
       scales: {
         x: {display: false},
         y: {display: true}
@@ -24,6 +18,10 @@ module.exports = {
     }
   },
   options: {
-    spriteText: true
+    spriteText: true,
+    canvas: {
+      width: 128,
+      height: 256
+    }
   }
 };
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 31be6100015fbca3b639bcd63f9d03b52f21e171 test/fixtures/controller.bar/bar-base-value.png test/fixtures/controller.bar/baseLine/bottom.png test/fixtures/controller.bar/baseLine/left.png test/fixtures/controller.bar/baseLine/mid-x.png test/fixtures/controller.bar/baseLine/mid-y.png test/fixtures/controller.bar/baseLine/right.png test/fixtures/controller.bar/baseLine/top.png test/fixtures/controller.bar/baseLine/value-x.png test/fixtures/controller.bar/baseLine/value-y.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number-mixed-chart.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number-with-order.png test/fixtures/controller.bar/borderRadius/border-radius-stacked-number.png test/fixtures/controller.bar/borderRadius/border-radius.png test/fixtures/controller.bar/borderWidth/indexable.png test/fixtures/controller.bar/borderWidth/object.png test/fixtures/controller.bar/borderWidth/value.png test/fixtures/controller.bar/horizontal-borders.png test/fixtures/scale.category/ticks-from-data.js test/fixtures/scale.category/ticks-from-data.png && rm -f test/fixtures/controller.bar/borderColor/border+dpr.js test/fixtures/controller.bar/borderColor/border+dpr.png test/fixtures/controller.bar/borderRadius/no-spacing.js test/fixtures/controller.bar/borderRadius/no-spacing.png
