#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 1f9250c0f7223dbf7c4f128d28649a9c534fbf33
git checkout 1f9250c0f7223dbf7c4f128d28649a9c534fbf33 test/browser/spec/ol/webgl/shaderbuilder.test.js && rm -f test/rendering/cases/webgl-points-rotation/expected.png test/rendering/cases/webgl-points-rotation/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/webgl/shaderbuilder.test.js b/test/browser/spec/ol/webgl/shaderbuilder.test.js
index a95ea50b9d0..50edd71c9aa 100644
--- a/test/browser/spec/ol/webgl/shaderbuilder.test.js
+++ b/test/browser/spec/ol/webgl/shaderbuilder.test.js
@@ -55,7 +55,6 @@ varying vec3 v_test;
 
 vec2 pxToScreen(vec2 coordPx) {
   vec2 scaled = coordPx / u_viewportSizePx / 0.5;
-  
   return scaled;
 }
 
@@ -78,6 +77,7 @@ void main(void) {
     offsetPx += halfSizePx * vec2(-1., 1.);
   }
   float angle = 0.0;
+  
   float c = cos(-angle);
   float s = sin(-angle);
   offsetPx = vec2(c * offsetPx.x - s * offsetPx.y, s * offsetPx.x + c * offsetPx.y);
@@ -89,7 +89,6 @@ void main(void) {
   v_texCoord = vec2(u, v);
   v_hitColor = a_hitColor;
   v_angle = angle;
-  
   c = cos(-v_angle);
   s = sin(-v_angle);
   centerOffsetPx = vec2(c * centerOffsetPx.x - s * centerOffsetPx.y, s * centerOffsetPx.x + c * centerOffsetPx.y); 
@@ -144,7 +143,6 @@ varying vec2 v_quadSizePx;
 
 vec2 pxToScreen(vec2 coordPx) {
   vec2 scaled = coordPx / u_viewportSizePx / 0.5;
-  
   return scaled;
 }
 
@@ -167,6 +165,7 @@ void main(void) {
     offsetPx += halfSizePx * vec2(-1., 1.);
   }
   float angle = 0.0;
+  
   float c = cos(-angle);
   float s = sin(-angle);
   offsetPx = vec2(c * offsetPx.x - s * offsetPx.y, s * offsetPx.x + c * offsetPx.y);
@@ -178,7 +177,6 @@ void main(void) {
   v_texCoord = vec2(u, v);
   v_hitColor = a_hitColor;
   v_angle = angle;
-  
   c = cos(-v_angle);
   s = sin(-v_angle);
   centerOffsetPx = vec2(c * centerOffsetPx.x - s * centerOffsetPx.y, s * centerOffsetPx.x + c * centerOffsetPx.y); 
@@ -231,7 +229,6 @@ varying vec2 v_quadSizePx;
 
 vec2 pxToScreen(vec2 coordPx) {
   vec2 scaled = coordPx / u_viewportSizePx / 0.5;
-  scaled = vec2(scaled.x * cos(-u_rotation) - scaled.y * sin(-u_rotation), scaled.x * sin(-u_rotation) + scaled.y * cos(-u_rotation));
   return scaled;
 }
 
@@ -254,6 +251,7 @@ void main(void) {
     offsetPx += halfSizePx * vec2(-1., 1.);
   }
   float angle = 0.0;
+  angle += u_rotation;
   float c = cos(-angle);
   float s = sin(-angle);
   offsetPx = vec2(c * offsetPx.x - s * offsetPx.y, s * offsetPx.x + c * offsetPx.y);
@@ -265,7 +263,6 @@ void main(void) {
   v_texCoord = vec2(u, v);
   v_hitColor = a_hitColor;
   v_angle = angle;
-  v_angle += u_rotation;
   c = cos(-v_angle);
   s = sin(-v_angle);
   centerOffsetPx = vec2(c * centerOffsetPx.x - s * centerOffsetPx.y, s * centerOffsetPx.x + c * centerOffsetPx.y); 
@@ -317,7 +314,6 @@ varying vec2 v_quadSizePx;
 
 vec2 pxToScreen(vec2 coordPx) {
   vec2 scaled = coordPx / u_viewportSizePx / 0.5;
-  
   return scaled;
 }
 
@@ -340,6 +336,7 @@ void main(void) {
     offsetPx += halfSizePx * vec2(-1., 1.);
   }
   float angle = u_time * 0.2;
+  
   float c = cos(-angle);
   float s = sin(-angle);
   offsetPx = vec2(c * offsetPx.x - s * offsetPx.y, s * offsetPx.x + c * offsetPx.y);
@@ -351,7 +348,6 @@ void main(void) {
   v_texCoord = vec2(u, v);
   v_hitColor = a_hitColor;
   v_angle = angle;
-  
   c = cos(-v_angle);
   s = sin(-v_angle);
   centerOffsetPx = vec2(c * centerOffsetPx.x - s * centerOffsetPx.y, s * centerOffsetPx.x + c * centerOffsetPx.y); 
diff --git a/test/rendering/cases/webgl-points-rotation/main.js b/test/rendering/cases/webgl-points-rotation/main.js
new file mode 100644
index 00000000000..16c49cb39f9
--- /dev/null
+++ b/test/rendering/cases/webgl-points-rotation/main.js
@@ -0,0 +1,47 @@
+import KML from '../../../../src/ol/format/KML.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/Tile.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import WebGLPointsLayer from '../../../../src/ol/layer/WebGLPoints.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+
+const vector = new WebGLPointsLayer({
+  source: new VectorSource({
+    url: '/data/2012_Earthquakes_Mag5.kml',
+    format: new KML({
+      extractStyles: false,
+    }),
+  }),
+  style: {
+    'icon-src': '/data/icon.png',
+    'icon-rotation': Math.PI / 8,
+    'icon-rotate-with-view': true,
+  },
+});
+
+const raster = new TileLayer({
+  source: new XYZ({
+    url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+    transition: 0,
+  }),
+});
+
+// Make a canvas non-squared
+const obj = document.getElementById('map');
+obj.style.paddingTop = '64px';
+obj.style.height = '128px';
+
+new Map({
+  layers: [raster, vector],
+  target: 'map',
+  view: new View({
+    center: [15180597.9736, 2700366.3807],
+    zoom: 2,
+    rotation: Math.PI / 8,
+  }),
+});
+
+render({
+  message: 'Points are rendered as rotated icon within narrow view',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|webgl\\-points\\-rotation)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/webgl/shaderbuilder.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/webgl/shaderbuilder.test.js browser/spec/ol/webgl/shaderbuilder.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 1f9250c0f7223dbf7c4f128d28649a9c534fbf33 test/browser/spec/ol/webgl/shaderbuilder.test.js && rm -f test/rendering/cases/webgl-points-rotation/expected.png test/rendering/cases/webgl-points-rotation/main.js
