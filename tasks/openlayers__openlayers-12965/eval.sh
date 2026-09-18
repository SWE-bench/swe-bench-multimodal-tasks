#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a1b8f08bca483c856bd6fe3de08e0e333145a757
git checkout a1b8f08bca483c856bd6fe3de08e0e333145a757 test/browser/spec/ol/renderer/webgl/Layer.test.js && rm -f test/rendering/cases/webgl-mixed-layers/expected.png test/rendering/cases/webgl-mixed-layers/main.js test/rendering/cases/webgl-multiple-layers/expected.png test/rendering/cases/webgl-multiple-layers/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/renderer/webgl/layer.test.js b/test/browser/spec/ol/renderer/webgl/Layer.test.js
similarity index 54%
rename from test/browser/spec/ol/renderer/webgl/layer.test.js
rename to test/browser/spec/ol/renderer/webgl/Layer.test.js
index 1828b96d52f..4189c08182b 100644
--- a/test/browser/spec/ol/renderer/webgl/layer.test.js
+++ b/test/browser/spec/ol/renderer/webgl/Layer.test.js
@@ -1,12 +1,19 @@
+import DataTileSource from '../../../../../../src/ol/source/DataTile.js';
 import Layer from '../../../../../../src/ol/layer/Layer.js';
+import Map from '../../../../../../src/ol/Map.js';
+import TileLayer from '../../../../../../src/ol/layer/WebGLTile.js';
+import VectorLayer from '../../../../../../src/ol/layer/Vector.js';
+import VectorSource from '../../../../../../src/ol/source/Vector.js';
+import View from '../../../../../../src/ol/View.js';
 import WebGLLayerRenderer, {
   colorDecodeId,
   colorEncodeId,
   getBlankImageData,
   writePointFeatureToBuffers,
 } from '../../../../../../src/ol/renderer/webgl/Layer.js';
+import {getUid} from '../../../../../../src/ol/util.js';
 
-describe('ol.renderer.webgl.Layer', function () {
+describe('ol/renderer/webgl/Layer', function () {
   describe('constructor', function () {
     let target;
 
@@ -226,4 +233,205 @@ describe('ol.renderer.webgl.Layer', function () {
       expect(decoded).to.eql(91612);
     });
   });
+
+  describe('context sharing', () => {
+    let target;
+    beforeEach(() => {
+      target = document.createElement('div');
+      target.style.width = '256px';
+      target.style.height = '256px';
+      document.body.appendChild(target);
+    });
+
+    afterEach(() => {
+      document.body.removeChild(target);
+    });
+
+    function getWebGLLayer(className) {
+      return new TileLayer({
+        className: className,
+        source: new DataTileSource({
+          loader(z, x, y) {
+            return Promise.resolve(new ImageData(256, 256));
+          },
+        }),
+      });
+    }
+
+    function getCanvasLayer(className) {
+      return new VectorLayer({
+        className: className,
+        source: new VectorSource(),
+      });
+    }
+
+    function expectCacheKeyMatches(layer, key) {
+      expect(layer.getRenderer().helper.canvasCacheKeyMatches(key)).to.be(true);
+    }
+
+    function dispose(map) {
+      map.setLayers([]);
+      map.setTarget(null);
+    }
+
+    it('allows sequences of WebGL layers to share a canvas', () => {
+      const layer1 = getWebGLLayer();
+      const layer2 = getWebGLLayer();
+      const layer3 = getWebGLLayer();
+      const layer4 = getCanvasLayer();
+      const layer5 = getCanvasLayer();
+      const layer6 = getWebGLLayer();
+
+      const map = new Map({
+        target: target,
+        layers: [layer1, layer2, layer3, layer4, layer5, layer6],
+        view: new View({
+          center: [0, 0],
+          zoom: 0,
+        }),
+      });
+
+      map.renderSync();
+
+      const mapId = getUid(map);
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/0`);
+      // layer4 and layer5 cannot be grouped
+      expectCacheKeyMatches(layer6, `map/${mapId}/group/1`);
+
+      dispose(map);
+    });
+
+    it('does not group layers with different className', () => {
+      const layer1 = getWebGLLayer();
+      const layer2 = getWebGLLayer();
+      const layer3 = getWebGLLayer('foo');
+      const layer4 = getWebGLLayer('foo');
+      const layer5 = getWebGLLayer();
+
+      const map = new Map({
+        target: target,
+        layers: [layer1, layer2, layer3, layer4, layer5],
+        view: new View({
+          center: [0, 0],
+          zoom: 0,
+        }),
+      });
+
+      map.renderSync();
+
+      const mapId = getUid(map);
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer4, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer5, `map/${mapId}/group/2`);
+
+      dispose(map);
+    });
+
+    it('collapses groups when a layer is removed', () => {
+      const layer1 = getWebGLLayer();
+      const layer2 = getWebGLLayer('foo');
+      const layer3 = getWebGLLayer();
+
+      const map = new Map({
+        target: target,
+        layers: [layer1, layer2, layer3],
+        view: new View({
+          center: [0, 0],
+          zoom: 0,
+        }),
+      });
+
+      map.renderSync();
+
+      const mapId = getUid(map);
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/2`);
+
+      map.removeLayer(layer2);
+      map.renderSync();
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expect(layer2.getRenderer().helper).to.be(undefined);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/0`);
+
+      dispose(map);
+    });
+
+    it('regroups when layer order changes', () => {
+      const layer1 = getWebGLLayer();
+      const layer2 = getWebGLLayer();
+      const layer3 = getCanvasLayer();
+      const layer4 = getWebGLLayer();
+
+      const map = new Map({
+        target: target,
+        layers: [layer1, layer2, layer3, layer4],
+        view: new View({
+          center: [0, 0],
+          zoom: 0,
+        }),
+      });
+
+      map.renderSync();
+
+      const mapId = getUid(map);
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/0`);
+      // layer3 cannot be grouped
+      expectCacheKeyMatches(layer4, `map/${mapId}/group/1`);
+
+      map.removeLayer(layer2);
+      map.addLayer(layer2);
+      map.renderSync();
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      // layer3 cannot be grouped
+      expectCacheKeyMatches(layer4, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/1`);
+
+      dispose(map);
+    });
+
+    it('changes groups based on z-index', () => {
+      const layer1 = getWebGLLayer();
+      const layer2 = getWebGLLayer('foo');
+      const layer3 = getWebGLLayer();
+
+      const map = new Map({
+        target: target,
+        layers: [layer1, layer2, layer3],
+        view: new View({
+          center: [0, 0],
+          zoom: 0,
+        }),
+      });
+
+      map.renderSync();
+
+      const mapId = getUid(map);
+
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/2`);
+
+      layer1.setZIndex(1);
+      map.renderSync();
+
+      expectCacheKeyMatches(layer2, `map/${mapId}/group/0`);
+      expectCacheKeyMatches(layer3, `map/${mapId}/group/1`);
+      expectCacheKeyMatches(layer1, `map/${mapId}/group/1`);
+
+      dispose(map);
+    });
+  });
 });
diff --git a/test/rendering/cases/webgl-mixed-layers/main.js b/test/rendering/cases/webgl-mixed-layers/main.js
new file mode 100644
index 00000000000..1c4ba1f44d5
--- /dev/null
+++ b/test/rendering/cases/webgl-mixed-layers/main.js
@@ -0,0 +1,84 @@
+import DataTile from '../../../../src/ol/source/DataTile.js';
+import KML from '../../../../src/ol/format/KML.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import VectorLayer from '../../../../src/ol/layer/Vector.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {Circle as CircleStyle, Fill, Style} from '../../../../src/ol/style.js';
+
+const labelCanvasSize = 256;
+
+const labelCanvas = document.createElement('canvas');
+labelCanvas.width = labelCanvasSize;
+labelCanvas.height = labelCanvasSize;
+
+const labelContext = labelCanvas.getContext('2d');
+labelContext.textAlign = 'center';
+labelContext.font = '16px sans-serif';
+const labelLineHeight = 16;
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+        transition: 0,
+      }),
+    }),
+    new VectorLayer({
+      opacity: 0.5,
+      source: new VectorSource({
+        url: '/data/2012_Earthquakes_Mag5.kml',
+        format: new KML({
+          extractStyles: false,
+        }),
+      }),
+      style: new Style({
+        image: new CircleStyle({
+          radius: 3,
+          fill: new Fill({
+            color: 'orange',
+          }),
+        }),
+      }),
+    }),
+    new TileLayer({
+      source: new DataTile({
+        loader: function (z, x, y) {
+          const half = labelCanvasSize / 2;
+
+          labelContext.clearRect(0, 0, labelCanvasSize, labelCanvasSize);
+
+          labelContext.fillStyle = 'white';
+          labelContext.fillText(`z: ${z}`, half, half - labelLineHeight);
+          labelContext.fillText(`x: ${x}`, half, half);
+          labelContext.fillText(`y: ${y}`, half, half + labelLineHeight);
+
+          labelContext.strokeStyle = 'white';
+          labelContext.lineWidth = 2;
+          labelContext.strokeRect(0, 0, labelCanvasSize, labelCanvasSize);
+
+          const data = labelContext.getImageData(
+            0,
+            0,
+            labelCanvasSize,
+            labelCanvasSize
+          ).data;
+          return Promise.resolve(new Uint8Array(data.buffer));
+        },
+        transition: 0,
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [15180597.9736, 2700366.3807],
+    zoom: 2,
+  }),
+});
+
+render({
+  message: 'a mix of WebGL and Canvas layers are rendered',
+});
diff --git a/test/rendering/cases/webgl-multiple-layers/main.js b/test/rendering/cases/webgl-multiple-layers/main.js
new file mode 100644
index 00000000000..304b5805d98
--- /dev/null
+++ b/test/rendering/cases/webgl-multiple-layers/main.js
@@ -0,0 +1,82 @@
+import DataTile from '../../../../src/ol/source/DataTile.js';
+import KML from '../../../../src/ol/format/KML.js';
+import Map from '../../../../src/ol/Map.js';
+import PointsLayer from '../../../../src/ol/layer/WebGLPoints.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+
+const labelCanvasSize = 256;
+
+const labelCanvas = document.createElement('canvas');
+labelCanvas.width = labelCanvasSize;
+labelCanvas.height = labelCanvasSize;
+
+const labelContext = labelCanvas.getContext('2d');
+labelContext.textAlign = 'center';
+labelContext.font = '16px sans-serif';
+const labelLineHeight = 16;
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+        transition: 0,
+      }),
+    }),
+    new PointsLayer({
+      opacity: 0.5,
+      source: new VectorSource({
+        url: '/data/2012_Earthquakes_Mag5.kml',
+        format: new KML({
+          extractStyles: false,
+        }),
+      }),
+      style: {
+        symbol: {
+          symbolType: 'circle',
+          size: 6,
+          color: 'orange',
+        },
+      },
+    }),
+    new TileLayer({
+      source: new DataTile({
+        loader: function (z, x, y) {
+          const half = labelCanvasSize / 2;
+
+          labelContext.clearRect(0, 0, labelCanvasSize, labelCanvasSize);
+
+          labelContext.fillStyle = 'white';
+          labelContext.fillText(`z: ${z}`, half, half - labelLineHeight);
+          labelContext.fillText(`x: ${x}`, half, half);
+          labelContext.fillText(`y: ${y}`, half, half + labelLineHeight);
+
+          labelContext.strokeStyle = 'white';
+          labelContext.lineWidth = 2;
+          labelContext.strokeRect(0, 0, labelCanvasSize, labelCanvasSize);
+
+          const data = labelContext.getImageData(
+            0,
+            0,
+            labelCanvasSize,
+            labelCanvasSize
+          ).data;
+          return Promise.resolve(new Uint8Array(data.buffer));
+        },
+        transition: 0,
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [15180597.9736, 2700366.3807],
+    zoom: 2,
+  }),
+});
+
+render({
+  message: 'multiple WebGL layers are rendered',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-mixed\\-layers|webgl\\-multiple\\-layers)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/renderer/webgl/Layer.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/renderer/webgl/Layer.test.js browser/spec/ol/renderer/webgl/Layer.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout a1b8f08bca483c856bd6fe3de08e0e333145a757 test/browser/spec/ol/renderer/webgl/Layer.test.js && rm -f test/rendering/cases/webgl-mixed-layers/expected.png test/rendering/cases/webgl-mixed-layers/main.js test/rendering/cases/webgl-multiple-layers/expected.png test/rendering/cases/webgl-multiple-layers/main.js
