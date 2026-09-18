#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff d4ce437830efcfe44b57a1fac53b727a1eed2f0e
git checkout d4ce437830efcfe44b57a1fac53b727a1eed2f0e test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js && rm -f test/rendering/cases/webgl-holes/expected.png test/rendering/cases/webgl-holes/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js b/test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js
index f0b3812d36d..005eadd7ddc 100644
--- a/test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js
+++ b/test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js
@@ -998,30 +998,30 @@ describe('MixedGeometryBatch', function () {
             [0, 1],
             [2, 3],
             [4, 5],
-            [6, 7],
+            [-6, 7],
           ],
           [
             [20, 21],
             [22, 23],
-            [24, 25],
+            [24, -25],
           ],
         ],
         [
           [
             [8, 9],
             [10, 11],
-            [12, 13],
+            [-12, 13],
           ],
           [
             [30, 31],
             [32, 33],
-            [34, 35],
+            [34, -35],
           ],
           [
             [40, 41],
             [42, 43],
             [44, 45],
-            [46, 47],
+            [46, -47],
           ],
         ],
       ]);
@@ -1071,10 +1071,10 @@ describe('MixedGeometryBatch', function () {
         expect(mixedBatch.polygonBatch.entries[uid2]).to.eql({
           feature: feature2,
           flatCoordss: [
-            [0, 1, 2, 3, 4, 5, 6, 7, 20, 21, 22, 23, 24, 25],
+            [0, 1, 2, 3, 4, 5, -6, 7, 20, 21, 22, 23, 24, -25],
             [
-              8, 9, 10, 11, 12, 13, 30, 31, 32, 33, 34, 35, 40, 41, 42, 43, 44,
-              45, 46, 47,
+              8, 9, 10, 11, -12, 13, 30, 31, 32, 33, 34, -35, 40, 41, 42, 43,
+              44, 45, 46, -47,
             ],
           ],
           verticesCount: 17,
@@ -1097,11 +1097,11 @@ describe('MixedGeometryBatch', function () {
         expect(mixedBatch.lineStringBatch.entries[uid2]).to.eql({
           feature: feature2,
           flatCoordss: [
-            [0, 1, 2, 3, 4, 5, 6, 7],
-            [20, 21, 22, 23, 24, 25],
-            [8, 9, 10, 11, 12, 13],
-            [30, 31, 32, 33, 34, 35],
-            [40, 41, 42, 43, 44, 45, 46, 47],
+            [0, 1, 2, 3, 4, 5, -6, 7],
+            [20, 21, 22, 23, 24, -25],
+            [8, 9, 10, 11, -12, 13],
+            [30, 31, 32, 33, 34, -35],
+            [40, 41, 42, 43, 44, 45, 46, -47],
           ],
           verticesCount: 17,
         });
diff --git a/test/rendering/cases/webgl-holes/main.js b/test/rendering/cases/webgl-holes/main.js
new file mode 100644
index 00000000000..d28c86f0cbe
--- /dev/null
+++ b/test/rendering/cases/webgl-holes/main.js
@@ -0,0 +1,70 @@
+import GeoJSON from '../../../../src/ol/format/GeoJSON.js';
+import Layer from '../../../../src/ol/layer/Layer.js';
+import Map from '../../../../src/ol/Map.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import WebGLVectorLayerRenderer from '../../../../src/ol/renderer/webgl/VectorLayer.js';
+
+/**
+ * This is a properly oriented polygon.  The exterior ring is oriented counterclockwise
+ * and the interior rings (holes) are oriented clockwise.  This follows the "Right Hand Rule."
+ */
+const data = {
+  type: 'Polygon',
+  coordinates: [
+    [
+      [-170, -80],
+      [170, -80],
+      [170, 80],
+      [-170, 80],
+      [-170, -80],
+    ],
+    [
+      [-150, -60],
+      [-150, 60],
+      [-30, 60],
+      [-30, -60],
+      [-150, -60],
+    ],
+    [
+      [30, -60],
+      [30, 60],
+      [150, 60],
+      [150, -60],
+      [30, -60],
+    ],
+  ],
+};
+
+const format = new GeoJSON({featureProjection: 'EPSG:3857'});
+
+class WebGLLayer extends Layer {
+  createRenderer() {
+    return new WebGLVectorLayerRenderer(this, {
+      style: {
+        'fill-color': '#ddd',
+        'stroke-color': 'red',
+        'stroke-width': 3,
+      },
+    });
+  }
+}
+
+new Map({
+  layers: [
+    new WebGLLayer({
+      source: new VectorSource({
+        features: format.readFeatures(data),
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [0, 0],
+    zoom: 0,
+  }),
+});
+
+render({
+  message: 'Holes are properly rendered',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|webgl\\-holes)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/render/webgl/MixedGeometryBatch.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/render/webgl/MixedGeometryBatch.test.js browser/spec/ol/render/webgl/MixedGeometryBatch.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout d4ce437830efcfe44b57a1fac53b727a1eed2f0e test/browser/spec/ol/render/webgl/MixedGeometryBatch.test.js && rm -f test/rendering/cases/webgl-holes/expected.png test/rendering/cases/webgl-holes/main.js
