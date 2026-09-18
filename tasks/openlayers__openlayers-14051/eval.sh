#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 08ad881d5e50aa752c694b91d1eba290d832867c
git checkout 08ad881d5e50aa752c694b91d1eba290d832867c test/browser/spec/ol/renderer/webgl/TileLayer.test.js && rm -f test/rendering/cases/webgl-tile-preload/expected.png test/rendering/cases/webgl-tile-preload/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/renderer/webgl/TileLayer.test.js b/test/browser/spec/ol/renderer/webgl/TileLayer.test.js
index 4d8af2618b0..6f5f555b6ef 100644
--- a/test/browser/spec/ol/renderer/webgl/TileLayer.test.js
+++ b/test/browser/spec/ol/renderer/webgl/TileLayer.test.js
@@ -1,5 +1,7 @@
+import Map from '../../../../../../src/ol/Map.js';
 import TileQueue from '../../../../../../src/ol/TileQueue.js';
 import TileState from '../../../../../../src/ol/TileState.js';
+import View from '../../../../../../src/ol/View.js';
 import WebGLTileLayer from '../../../../../../src/ol/layer/WebGLTile.js';
 import {DataTile} from '../../../../../../src/ol/source.js';
 import {VOID} from '../../../../../../src/ol/functions.js';
@@ -15,6 +17,8 @@ describe('ol/renderer/webgl/TileLayer', function () {
   let tileLayer;
   /** @type {import('../../../../../../src/ol/Map.js').FrameState} */
   let frameState;
+  /** @type {Map} */
+  let map;
   beforeEach(function () {
     const size = 256;
     const context = createCanvasContext2D(size, size);
@@ -54,10 +58,16 @@ describe('ol/renderer/webgl/TileLayer', function () {
       tileQueue: new TileQueue(VOID, VOID),
       renderTargets: {},
     };
+
+    map = new Map({
+      view: new View(),
+    });
+    tileLayer.set('map', map, true);
   });
 
   afterEach(function () {
     tileLayer.dispose();
+    map.dispose();
   });
 
   it('maintains a cache on the renderer instead of the source', function () {
@@ -111,7 +121,7 @@ describe('ol/renderer/webgl/TileLayer', function () {
     it('enqueues tiles at a single zoom level (preload: 0)', () => {
       renderer.prepareFrame(frameState);
       const extent = [-1, -1, 1, 1];
-      renderer.enqueueTiles(frameState, extent, 10, {});
+      renderer.enqueueTiles(frameState, extent, 10, {}, tileLayer.getPreload());
 
       const source = tileLayer.getSource();
       const sourceKey = getUid(source);
@@ -132,7 +142,7 @@ describe('ol/renderer/webgl/TileLayer', function () {
       tileLayer.setPreload(2);
       renderer.prepareFrame(frameState);
       const extent = [-1, -1, 1, 1];
-      renderer.enqueueTiles(frameState, extent, 10, {});
+      renderer.enqueueTiles(frameState, extent, 10, {}, tileLayer.getPreload());
 
       const source = tileLayer.getSource();
       const sourceKey = getUid(source);
@@ -162,7 +172,36 @@ describe('ol/renderer/webgl/TileLayer', function () {
       tileLayer.setMinZoom(9);
       renderer.prepareFrame(frameState);
       const extent = [-1, -1, 1, 1];
-      renderer.enqueueTiles(frameState, extent, 10, {});
+      renderer.enqueueTiles(frameState, extent, 10, {}, tileLayer.getPreload());
+
+      const source = tileLayer.getSource();
+      const sourceKey = getUid(source);
+      expect(frameState.wantedTiles[sourceKey]).to.be.an(Object);
+
+      const wantedTiles = frameState.wantedTiles[sourceKey];
+
+      const expected = {
+        '/10,511,511': true,
+        '/10,511,512': true,
+        '/10,512,511': true,
+        '/10,512,512': true,
+        '/9,255,255': true,
+        '/9,255,256': true,
+        '/9,256,255': true,
+        '/9,256,256': true,
+      };
+      expect(wantedTiles).to.eql(expected);
+    });
+
+    it('layer min zoom relates to view zoom levels', () => {
+      map.setView(
+        new View({maxResolution: map.getView().getMaxResolution() * 2})
+      );
+      tileLayer.setPreload(Infinity);
+      tileLayer.setMinZoom(9);
+      renderer.prepareFrame(frameState);
+      const extent = [-1, -1, 1, 1];
+      renderer.enqueueTiles(frameState, extent, 10, {}, tileLayer.getPreload());
 
       const source = tileLayer.getSource();
       const sourceKey = getUid(source);
@@ -179,6 +218,10 @@ describe('ol/renderer/webgl/TileLayer', function () {
         '/9,255,256': true,
         '/9,256,255': true,
         '/9,256,256': true,
+        '/8,127,127': true,
+        '/8,127,128': true,
+        '/8,128,127': true,
+        '/8,128,128': true,
       };
       expect(wantedTiles).to.eql(expected);
     });
diff --git a/test/rendering/cases/webgl-tile-preload/main.js b/test/rendering/cases/webgl-tile-preload/main.js
new file mode 100644
index 00000000000..3b3c67172ac
--- /dev/null
+++ b/test/rendering/cases/webgl-tile-preload/main.js
@@ -0,0 +1,20 @@
+import Map from '../../../../src/ol/Map.js';
+import TileDebug from '../../../../src/ol/source/TileDebug.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+
+new Map({
+  target: 'map',
+  layers: [
+    new TileLayer({
+      source: new TileDebug(),
+      preload: Infinity,
+    }),
+  ],
+  view: new View({
+    center: [0, 0],
+    zoom: 0.5,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-tile\\-preload)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/renderer/webgl/TileLayer.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/renderer/webgl/TileLayer.test.js browser/spec/ol/renderer/webgl/TileLayer.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 08ad881d5e50aa752c694b91d1eba290d832867c test/browser/spec/ol/renderer/webgl/TileLayer.test.js && rm -f test/rendering/cases/webgl-tile-preload/expected.png test/rendering/cases/webgl-tile-preload/main.js
