#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 927f24a809834100c138dc70cffd9e9b920478a5
git checkout 927f24a809834100c138dc70cffd9e9b920478a5 test/specs/core.datasetController.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/core.datasetController.tests.js b/test/specs/core.datasetController.tests.js
index e89aa0bf98c..b0cc393981f 100644
--- a/test/specs/core.datasetController.tests.js
+++ b/test/specs/core.datasetController.tests.js
@@ -976,6 +976,59 @@ describe('Chart.DatasetController', function() {
         raw: {x: 1, y: 1},
         mode: 'datatest2'
       }));
+
+      chart.data.datasets[0].data.unshift({x: -1, y: -1});
+      chart.update();
+      expect(meta.controller.getContext(0, true, 'unshift')).toEqual(jasmine.objectContaining({
+        active: true,
+        datasetIndex: 0,
+        dataset: chart.data.datasets[0],
+        dataIndex: 0,
+        element: meta.data[0],
+        index: 0,
+        parsed: {x: -1, y: -1},
+        raw: {x: -1, y: -1},
+        mode: 'unshift'
+      }));
+      expect(meta.controller.getContext(2, true, 'unshift2')).toEqual(jasmine.objectContaining({
+        active: true,
+        datasetIndex: 0,
+        dataset: chart.data.datasets[0],
+        dataIndex: 2,
+        element: meta.data[2],
+        index: 2,
+        parsed: {x: 1, y: 1},
+        raw: {x: 1, y: 1},
+        mode: 'unshift2'
+      }));
+
+      chart.data.datasets.unshift({data: [{x: 10, y: 20}]});
+      chart.update();
+      meta = chart.getDatasetMeta(0);
+      expect(meta.controller.getContext(0, true, 'unshift3')).toEqual(jasmine.objectContaining({
+        active: true,
+        datasetIndex: 0,
+        dataset: chart.data.datasets[0],
+        dataIndex: 0,
+        element: meta.data[0],
+        index: 0,
+        parsed: {x: 10, y: 20},
+        raw: {x: 10, y: 20},
+        mode: 'unshift3'
+      }));
+
+      meta = chart.getDatasetMeta(1);
+      expect(meta.controller.getContext(2, true, 'unshift4')).toEqual(jasmine.objectContaining({
+        active: true,
+        datasetIndex: 1,
+        dataset: chart.data.datasets[1],
+        dataIndex: 2,
+        element: meta.data[2],
+        index: 2,
+        parsed: {x: 1, y: 1},
+        raw: {x: 1, y: 1},
+        mode: 'unshift4'
+      }));
     });
   });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 927f24a809834100c138dc70cffd9e9b920478a5 test/specs/core.datasetController.tests.js
