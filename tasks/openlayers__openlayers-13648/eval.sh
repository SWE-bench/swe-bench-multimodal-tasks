#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 71f37802aef8ae303f8afbec458fcee72cac8dd3
git checkout 71f37802aef8ae303f8afbec458fcee72cac8dd3 test/browser/spec/ol/DataTile.test.js test/browser/spec/ol/layer/WebGLTile.test.js test/browser/spec/ol/source/DataTile.test.js test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js && rm -f test/rendering/cases/webgl-tile-aspect-ratio/expected.png test/rendering/cases/webgl-tile-aspect-ratio/main.js test/rendering/data/raster/non-square-pixels.tif
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/DataTile.test.js b/test/browser/spec/ol/DataTile.test.js
index 76c696653e8..1926de55a4c 100644
--- a/test/browser/spec/ol/DataTile.test.js
+++ b/test/browser/spec/ol/DataTile.test.js
@@ -33,6 +33,28 @@ describe('ol/DataTile', function () {
     });
   });
 
+  describe('#getSize()', function () {
+    it('returns [256, 256] by default', function () {
+      const tileCoord = [0, 0, 0];
+      const tile = new DataTile({
+        tileCoord: tileCoord,
+        loader: loader,
+      });
+      expect(tile.getSize()).to.eql([256, 256]);
+    });
+
+    it('respects what is provided in the constructor', function () {
+      const size = [123, 456];
+      const tileCoord = [0, 0, 0];
+      const tile = new DataTile({
+        size: size,
+        tileCoord: tileCoord,
+        loader: loader,
+      });
+      expect(tile.getSize()).to.eql(size);
+    });
+  });
+
   describe('#load()', function () {
     it('handles loading states correctly', function (done) {
       const tileCoord = [0, 0, 0];
diff --git a/test/browser/spec/ol/layer/WebGLTile.test.js b/test/browser/spec/ol/layer/WebGLTile.test.js
index a8458f41ce7..d8d5a638408 100644
--- a/test/browser/spec/ol/layer/WebGLTile.test.js
+++ b/test/browser/spec/ol/layer/WebGLTile.test.js
@@ -5,6 +5,7 @@ import View from '../../../../../src/ol/View.js';
 import WebGLHelper from '../../../../../src/ol/webgl/Helper.js';
 import WebGLTileLayer from '../../../../../src/ol/layer/WebGLTile.js';
 import {createCanvasContext2D} from '../../../../../src/ol/dom.js';
+import {createXYZ} from '../../../../../src/ol/tilegrid.js';
 import {getForViewAndSize} from '../../../../../src/ol/extent.js';
 import {getRenderPixel} from '../../../../../src/ol/render.js';
 
@@ -81,7 +82,8 @@ describe('ol/layer/WebGLTile', function () {
     it('retrieves pixel data', (done) => {
       const layer = new WebGLTileLayer({
         source: new DataTileSource({
-          tilePixelRatio: 1 / 256,
+          tileSize: 1,
+          tileGrid: createXYZ(),
           loader(z, x, y) {
             return new Uint8Array([5, 4, 3, 2, 1]);
           },
@@ -106,7 +108,8 @@ describe('ol/layer/WebGLTile', function () {
     it('preserves the original data type', (done) => {
       const layer = new WebGLTileLayer({
         source: new DataTileSource({
-          tilePixelRatio: 1 / 256,
+          tileSize: 1,
+          tileGrid: createXYZ(),
           loader(z, x, y) {
             return new Float32Array([1.11, 2.22, 3.33, 4.44, 5.55]);
           },
diff --git a/test/browser/spec/ol/source/DataTile.test.js b/test/browser/spec/ol/source/DataTile.test.js
index 94beefc6169..e7f0689880d 100644
--- a/test/browser/spec/ol/source/DataTile.test.js
+++ b/test/browser/spec/ol/source/DataTile.test.js
@@ -40,6 +40,30 @@ describe('ol/source/DataTile', function () {
     });
   });
 
+  describe('#getTileSize()', function () {
+    it('returns [256, 256] by default', function () {
+      const source = new DataTileSource({});
+      expect(source.getTileSize(0)).to.eql([256, 256]);
+    });
+
+    it('respects a tileSize passed to the constructor', function () {
+      const size = [1234, 5678];
+      const source = new DataTileSource({tileSize: size});
+      expect(source.getTileSize(0)).to.eql(size);
+    });
+
+    it('picks from an array of sizes passed to setTileSizes()', function () {
+      const sizes = [
+        [123, 456],
+        [234, 567],
+        [345, 678],
+      ];
+      const source = new DataTileSource({});
+      source.setTileSizes(sizes);
+      expect(source.getTileSize(1)).to.eql(sizes[1]);
+    });
+  });
+
   describe('#getInterpolate()', function () {
     it('is false by default', function () {
       const source = new DataTileSource({loader: () => {}});
diff --git a/test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js b/test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js
index 32b0c30e4d7..258c2922c07 100644
--- a/test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js
+++ b/test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js
@@ -2,6 +2,7 @@ import DataTile from '../../../../src/ol/source/DataTile.js';
 import Map from '../../../../src/ol/Map.js';
 import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
 import View from '../../../../src/ol/View.js';
+// import {createXYZ} from '../../../../src/ol/tilegrid.js';
 
 const size = 512;
 
@@ -17,9 +18,14 @@ new Map({
   layers: [
     new TileLayer({
       source: new DataTile({
+        // remove this in the next major release
+        tilePixelRatio: 2,
+
+        // instead use an explicit source and render tile size
+        // tileSize: size,
+        // tileGrid: createXYZ({maxZoom: 0}),
         maxZoom: 0,
         loader: () => data,
-        tilePixelRatio: 2,
       }),
     }),
   ],
diff --git a/test/rendering/cases/webgl-tile-aspect-ratio/main.js b/test/rendering/cases/webgl-tile-aspect-ratio/main.js
new file mode 100644
index 00000000000..7aa783795a4
--- /dev/null
+++ b/test/rendering/cases/webgl-tile-aspect-ratio/main.js
@@ -0,0 +1,21 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  convertToRGB: true,
+  sources: [{url: '/data/raster/non-square-pixels.tif'}],
+});
+
+new Map({
+  target: 'map',
+  layers: [new TileLayer({source})],
+  view: source.getView().then((config) => ({
+    ...config,
+    rotation: Math.PI / 6,
+  })),
+});
+
+render({
+  message: 'properly renders rotated non-square pixels',
+});
EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-data\\-tile\\-tilepixelratio2|webgl\\-tile\\-aspect\\-ratio)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/DataTile.test.js'"'"');' 'require('"'"'./browser/spec/ol/layer/WebGLTile.test.js'"'"');' 'require('"'"'./browser/spec/ol/source/DataTile.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{spec/ol/DataTile.test.js,spec/ol/layer/WebGLTile.test.js,spec/ol/source/DataTile.test.js}' '{browser/spec/ol/DataTile.test.js,browser/spec/ol/layer/WebGLTile.test.js,browser/spec/ol/source/DataTile.test.js}'; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 71f37802aef8ae303f8afbec458fcee72cac8dd3 test/browser/spec/ol/DataTile.test.js test/browser/spec/ol/layer/WebGLTile.test.js test/browser/spec/ol/source/DataTile.test.js test/rendering/cases/webgl-data-tile-tilepixelratio2/main.js && rm -f test/rendering/cases/webgl-tile-aspect-ratio/expected.png test/rendering/cases/webgl-tile-aspect-ratio/main.js test/rendering/data/raster/non-square-pixels.tif
