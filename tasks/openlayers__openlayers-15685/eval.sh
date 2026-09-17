#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 7a88544d0f02253088bedaf8c0adf3a73d24739b
rm -f test/rendering/cases/layer-vectortile-overlap-declutter/expected.png test/rendering/cases/layer-vectortile-overlap-declutter/main.js test/rendering/cases/layer-vectortile-overlap-no-declutter/expected.png test/rendering/cases/layer-vectortile-overlap-no-declutter/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/layer-vectortile-overlap-declutter/main.js b/test/rendering/cases/layer-vectortile-overlap-declutter/main.js
new file mode 100644
index 00000000000..b2923402ba5
--- /dev/null
+++ b/test/rendering/cases/layer-vectortile-overlap-declutter/main.js
@@ -0,0 +1,59 @@
+import Feature from '../../../../src/ol/Feature.js';
+import Map from '../../../../src/ol/Map.js';
+import VectorTileLayer from '../../../../src/ol/layer/VectorTile.js';
+import VectorTileSource from '../../../../src/ol/source/VectorTile.js';
+import View from '../../../../src/ol/View.js';
+import {Fill, Stroke, Style, Text} from '../../../../src/ol/style.js';
+import {fromExtent} from '../../../../src/ol/geom/Polygon.js';
+
+const vectorTileSource = new VectorTileSource({
+  tileSize: 64,
+  tileUrlFunction: (tileCoord) => tileCoord,
+  tileLoadFunction(tile, tileCoord) {
+    const polygon = new Feature({
+      geometry: fromExtent(
+        vectorTileSource.getTileGrid().getTileCoordExtent(tileCoord),
+      ),
+    });
+    tile.setFeatures([polygon]);
+  },
+});
+
+const vectorTileLayer = new VectorTileLayer({
+  declutter: true,
+  renderMode: 'vector',
+  source: vectorTileSource,
+  style: new Style({
+    text: new Text({
+      overflow: true,
+      font: '32px ubuntu',
+      offsetX: 10,
+      text: '-W',
+      fill: new Fill({
+        color: 'rgba(0, 0, 0, 1)',
+      }),
+      stroke: new Stroke({
+        width: 35,
+        color: 'red',
+      }),
+    }),
+    fill: new Fill({
+      color: 'rgba(0, 0, 255, 0.3)',
+    }),
+  }),
+});
+
+new Map({
+  target: 'map',
+  layers: [vectorTileLayer],
+  view: new View({
+    center: [0, 0],
+    zoom: 1,
+    multiWorld: true,
+  }),
+});
+
+render({
+  message: 'Text is rendered above polygons, even when from different tiles',
+  tolerance: 0.001,
+});
diff --git a/test/rendering/cases/layer-vectortile-overlap-no-declutter/main.js b/test/rendering/cases/layer-vectortile-overlap-no-declutter/main.js
new file mode 100644
index 00000000000..19fd1768297
--- /dev/null
+++ b/test/rendering/cases/layer-vectortile-overlap-no-declutter/main.js
@@ -0,0 +1,58 @@
+import Feature from '../../../../src/ol/Feature.js';
+import Map from '../../../../src/ol/Map.js';
+import VectorTileLayer from '../../../../src/ol/layer/VectorTile.js';
+import VectorTileSource from '../../../../src/ol/source/VectorTile.js';
+import View from '../../../../src/ol/View.js';
+import {Fill, Stroke, Style, Text} from '../../../../src/ol/style.js';
+import {fromExtent} from '../../../../src/ol/geom/Polygon.js';
+
+const vectorTileSource = new VectorTileSource({
+  tileSize: 64,
+  tileUrlFunction: (tileCoord) => tileCoord,
+  tileLoadFunction(tile, tileCoord) {
+    const polygon = new Feature({
+      geometry: fromExtent(
+        vectorTileSource.getTileGrid().getTileCoordExtent(tileCoord),
+      ),
+    });
+    tile.setFeatures([polygon]);
+  },
+});
+
+const vectorTileLayer = new VectorTileLayer({
+  renderMode: 'vector',
+  source: vectorTileSource,
+  style: new Style({
+    text: new Text({
+      overflow: true,
+      font: '32px ubuntu',
+      offsetX: -10,
+      text: 'W-',
+      fill: new Fill({
+        color: 'rgba(0, 0, 0, 1)',
+      }),
+      stroke: new Stroke({
+        width: 35,
+        color: 'red',
+      }),
+    }),
+    fill: new Fill({
+      color: 'rgba(0, 0, 255, 0.3)',
+    }),
+  }),
+});
+
+new Map({
+  target: 'map',
+  layers: [vectorTileLayer],
+  view: new View({
+    center: [0, 0],
+    zoom: 1,
+    multiWorld: true,
+  }),
+});
+
+render({
+  message: 'Text is rendered above polygons, even when from different tiles',
+  tolerance: 0.001,
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|layer\\-vectortile\\-overlap\\-declutter|layer\\-vectortile\\-overlap\\-no\\-declutter)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/layer-vectortile-overlap-declutter/expected.png test/rendering/cases/layer-vectortile-overlap-declutter/main.js test/rendering/cases/layer-vectortile-overlap-no-declutter/expected.png test/rendering/cases/layer-vectortile-overlap-no-declutter/main.js
