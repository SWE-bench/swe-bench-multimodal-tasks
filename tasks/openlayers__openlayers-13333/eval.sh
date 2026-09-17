#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 459cd51ae2ae7fded1f1ede5215248f9537f4e7c
git checkout 459cd51ae2ae7fded1f1ede5215248f9537f4e7c test/browser/spec/ol/layer/WebGLTile.test.js && rm -f test/rendering/cases/webgl-layer-extent/expected.png test/rendering/cases/webgl-layer-extent/main.js test/rendering/cases/webgl-source-extent/expected.png test/rendering/cases/webgl-source-extent/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/layer/WebGLTile.test.js b/test/browser/spec/ol/layer/WebGLTile.test.js
index 5b5a8b81ea1..9d84c3f4050 100644
--- a/test/browser/spec/ol/layer/WebGLTile.test.js
+++ b/test/browser/spec/ol/layer/WebGLTile.test.js
@@ -87,7 +87,11 @@ describe('ol/layer/WebGLTile', function () {
       #else
       precision mediump float;
       #endif
+
       varying vec2 v_textureCoord;
+      varying vec2 v_mapCoord;
+
+      uniform vec4 u_renderExtent;
       uniform float u_transitionAlpha;
       uniform float u_texturePixelWidth;
       uniform float u_texturePixelHeight;
@@ -97,7 +101,16 @@ describe('ol/layer/WebGLTile', function () {
       uniform float u_var_g;
       uniform float u_var_b;
       uniform sampler2D u_tileTextures[1];
+
       void main() {
+        if (
+          v_mapCoord[0] < u_renderExtent[0] ||
+          v_mapCoord[1] < u_renderExtent[1] ||
+          v_mapCoord[0] > u_renderExtent[2] ||
+          v_mapCoord[1] > u_renderExtent[3]
+        ) {
+          discard;
+        }
         vec4 color = texture2D(u_tileTextures[0], v_textureCoord);
         color = vec4(u_var_r / 255.0, u_var_g / 255.0, u_var_b / 255.0, 1.0);
         if (color.a == 0.0) {
@@ -112,12 +125,24 @@ describe('ol/layer/WebGLTile', function () {
     expect(compileShaderSpy.getCall(1).args[0].replace(/[ \n]+/g, ' ')).to.be(
       `
       attribute vec2 a_textureCoord;
+
       uniform mat4 u_tileTransform;
+      uniform float u_texturePixelWidth; 
+      uniform float u_texturePixelHeight; 
+      uniform float u_textureResolution; 
+      uniform float u_textureOriginX; 
+      uniform float u_textureOriginY; 
       uniform float u_depth;
 
       varying vec2 v_textureCoord;
+      varying vec2 v_mapCoord; 
+
       void main() {
         v_textureCoord = a_textureCoord;
+        v_mapCoord = vec2(
+          u_textureOriginX + u_textureResolution * u_texturePixelWidth * v_textureCoord[0],
+          u_textureOriginY - u_textureResolution * u_texturePixelHeight * v_textureCoord[1]
+        );
         gl_Position = u_tileTransform * vec4(a_textureCoord, u_depth, 1.0);
       }
       `.replace(/[ \n]+/g, ' ')
@@ -163,6 +188,10 @@ describe('ol/layer/WebGLTile', function () {
       #else
       precision mediump float;
       #endif varying vec2 v_textureCoord;
+
+      varying vec2 v_mapCoord;
+
+      uniform vec4 u_renderExtent;
       uniform float u_transitionAlpha;
       uniform float u_texturePixelWidth;
       uniform float u_texturePixelHeight;
@@ -188,6 +217,14 @@ describe('ol/layer/WebGLTile', function () {
       }
 
       void main() {
+        if (
+          v_mapCoord[0] < u_renderExtent[0] ||
+          v_mapCoord[1] < u_renderExtent[1] ||
+          v_mapCoord[0] > u_renderExtent[2] ||
+          v_mapCoord[1] > u_renderExtent[3]
+        ) {
+          discard;
+        }
         vec4 color = texture2D(u_tileTextures[0], v_textureCoord);
         color = vec4((getBandValue(4.0, 0.0, 0.0) / 3000.0), (getBandValue(1.0, 0.0, 0.0) / 3000.0), (getBandValue(2.0, 0.0, 0.0) / 3000.0), 1.0);
         if (color.a == 0.0) {
diff --git a/test/rendering/cases/webgl-layer-extent/main.js b/test/rendering/cases/webgl-layer-extent/main.js
new file mode 100644
index 00000000000..5e0aa810d61
--- /dev/null
+++ b/test/rendering/cases/webgl-layer-extent/main.js
@@ -0,0 +1,28 @@
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {useGeographic} from '../../../../src/ol/proj.js';
+useGeographic();
+
+new Map({
+  layers: [
+    new TileLayer({
+      extent: [-100, -30, 50, 50],
+      source: new XYZ({
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+        transition: 0,
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [0, 0],
+    zoom: 0,
+    rotation: Math.PI / 5,
+  }),
+});
+
+render({
+  message: 'data outside the layer extent is not rendered',
+});
diff --git a/test/rendering/cases/webgl-source-extent/main.js b/test/rendering/cases/webgl-source-extent/main.js
new file mode 100644
index 00000000000..43bfb34ee9d
--- /dev/null
+++ b/test/rendering/cases/webgl-source-extent/main.js
@@ -0,0 +1,58 @@
+import Map from '../../../../src/ol/Map.js';
+import TileGrid from '../../../../src/ol/tilegrid/TileGrid.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {getHeight, getWidth} from '../../../../src/ol/extent.js';
+import {get as getProjection} from '../../../../src/ol/proj.js';
+
+const fullExtent = getProjection('EPSG:3857').getExtent();
+const width = getWidth(fullExtent);
+const height = getHeight(fullExtent);
+
+const partialExtent = [
+  fullExtent[0],
+  fullExtent[1] + 0.4 * height,
+  fullExtent[2] - 0.4 * width,
+  fullExtent[3],
+];
+
+function resolutionsFromExtent(extent, maxZoom) {
+  const height = getHeight(extent);
+  const width = getWidth(extent);
+
+  const maxResolution = Math.max(width / 256, height / 256);
+
+  const length = maxZoom + 1;
+  const resolutions = new Array(length);
+  for (let z = 0; z < length; ++z) {
+    resolutions[z] = maxResolution / Math.pow(2, z);
+  }
+  return resolutions;
+}
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        wrapX: false,
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+        transition: 0,
+        tileGrid: new TileGrid({
+          extent: partialExtent,
+          resolutions: resolutionsFromExtent(fullExtent, 10),
+        }),
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [0, 0],
+    zoom: 0,
+    rotation: -Math.PI / 8,
+  }),
+});
+
+render({
+  message: 'data outside the source tile grid extent is not rendered',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-layer\\-extent|webgl\\-source\\-extent)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/layer/WebGLTile.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/layer/WebGLTile.test.js browser/spec/ol/layer/WebGLTile.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 459cd51ae2ae7fded1f1ede5215248f9537f4e7c test/browser/spec/ol/layer/WebGLTile.test.js && rm -f test/rendering/cases/webgl-layer-extent/expected.png test/rendering/cases/webgl-layer-extent/main.js test/rendering/cases/webgl-source-extent/expected.png test/rendering/cases/webgl-source-extent/main.js
