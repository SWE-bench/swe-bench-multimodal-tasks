#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9afc294d57eb304da711dfe8aa211d26b72ce471
git checkout 9afc294d57eb304da711dfe8aa211d26b72ce471 test/browser/spec/ol/render/canvas/immediate.test.js && rm -f test/rendering/cases/immediate-pixel-ratio/expected.png test/rendering/cases/immediate-pixel-ratio/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/render/canvas/immediate.test.js b/test/browser/spec/ol/render/canvas/immediate.test.js
index 9c3e2540258..5fa1ef227d9 100644
--- a/test/browser/spec/ol/render/canvas/immediate.test.js
+++ b/test/browser/spec/ol/render/canvas/immediate.test.js
@@ -325,7 +325,7 @@ describe('ol.render.canvas.Immediate', function () {
         ],
       ]).transform('EPSG:4326', 'EPSG:3857');
 
-      canvas.drawMultiPolygon(multiPolygonGeometry, null);
+      canvas.drawMultiPolygon(multiPolygonGeometry);
 
       const expected = [
         // first polygon
diff --git a/test/rendering/cases/immediate-pixel-ratio/main.js b/test/rendering/cases/immediate-pixel-ratio/main.js
new file mode 100644
index 00000000000..773bd351f5d
--- /dev/null
+++ b/test/rendering/cases/immediate-pixel-ratio/main.js
@@ -0,0 +1,76 @@
+import VectorLayer from '../../../../src/ol/layer/Vector.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import {Feature, Map, View} from '../../../../src/ol/index.js';
+import {Fill, Icon, Stroke, Style, Text} from '../../../../src/ol/style.js';
+import {LineString, MultiPoint, Point} from '../../../../src/ol/geom.js';
+import {getVectorContext} from '../../../../src/ol/render.js';
+
+const coordinates = [
+  [50, -200, 0],
+  [200, -200, 0],
+  [100, -50, 0],
+];
+const img = new Image();
+img.src =
+  'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgdmlld0JveD0iMCAwIDIwIDIwIiBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogZ3JlZW47Ij48cGF0aCBkPSJtIDEwIDEwIDEwdiAtMTBoIiAvPjwvc3ZnPg==';
+const point = new MultiPoint(coordinates);
+const pointStyle = new Style({
+  image: new Icon({
+    img: img,
+    size: [10, 10],
+    imgSize: [10, 10],
+  }),
+});
+const line = new LineString(coordinates);
+const lineStyle = new Style({
+  stroke: new Stroke({
+    color: 'red',
+    width: 40,
+    lineCap: 'square',
+    lineJoin: 'round',
+    lineDash: [30, 100],
+    lineDashOffset: 5,
+  }),
+  text: new Text({
+    text: '--- T e s t ___',
+    placement: 'point',
+    fill: new Fill({
+      color: 'green',
+    }),
+    font: '50px Ubuntu',
+    stroke: new Stroke({
+      color: 'blue',
+      width: 10,
+      lineCap: 'butt',
+      lineDash: [10, 5],
+      lineDashOffset: 4,
+    }),
+  }),
+});
+
+const vector = new VectorLayer({
+  source: new VectorSource({
+    features: [new Feature(new Point([-20, -20]))],
+  }),
+});
+
+vector.on('postrender', function (evt) {
+  const context = getVectorContext(evt);
+  context.setStyle(lineStyle);
+  context.drawGeometry(line);
+
+  context.setStyle(pointStyle);
+  context.drawGeometry(point);
+});
+
+new Map({
+  target: 'map',
+  layers: [vector],
+  view: new View({
+    center: [256 / 2, -256 / 2],
+    resolution: 1,
+    devicePixelRatio: 2,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS=--openssl-legacy-provider CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|immediate\\-pixel\\-ratio)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/render/canvas/immediate.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/render/canvas/immediate.test.js browser/spec/ol/render/canvas/immediate.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 9afc294d57eb304da711dfe8aa211d26b72ce471 test/browser/spec/ol/render/canvas/immediate.test.js && rm -f test/rendering/cases/immediate-pixel-ratio/expected.png test/rendering/cases/immediate-pixel-ratio/main.js
