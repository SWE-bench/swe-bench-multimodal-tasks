#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3291733ab38a9f6af642ef9fe5fb0ca237cccdc9
rm -f test/rendering/cases/reproj-tile-4326-debug/expected.png test/rendering/cases/reproj-tile-4326-debug/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/reproj-tile-4326-debug/main.js b/test/rendering/cases/reproj-tile-4326-debug/main.js
new file mode 100644
index 00000000000..d9447b275ab
--- /dev/null
+++ b/test/rendering/cases/reproj-tile-4326-debug/main.js
@@ -0,0 +1,49 @@
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/Tile.js';
+import View from '../../../../src/ol/View.js';
+import {TileDebug, XYZ} from '../../../../src/ol/source.js';
+import {createForProjection, createXYZ} from '../../../../src/ol/tilegrid.js';
+import {get, toLonLat} from '../../../../src/ol/proj.js';
+
+const tileGrid = createXYZ();
+const extent = tileGrid.getTileCoordExtent([5, 5, 12]);
+const center = [(extent[0] + extent[2]) / 2, extent[1]];
+
+const source = new XYZ({
+  transition: 0,
+  minZoom: 5,
+  maxZoom: 5,
+  url: '/data/tiles/osm/{z}/{x}/{y}.png',
+});
+
+const sourceDebug = new TileDebug({tileGrid: source.getTileGrid()});
+
+source.setTileGridForProjection(
+  get('EPSG:4326'),
+  createForProjection(get('EPSG:4326'), 7, [64, 64])
+);
+
+sourceDebug.setTileGridForProjection(
+  get('EPSG:4326'),
+  createForProjection(get('EPSG:4326'), 7, [64, 64])
+);
+
+new Map({
+  pixelRatio: 1,
+  target: 'map',
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+    new TileLayer({
+      source: sourceDebug,
+    }),
+  ],
+  view: new View({
+    projection: 'EPSG:4326',
+    center: toLonLat(center),
+    zoom: 5,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS=--openssl-legacy-provider CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|reproj\\-tile\\-4326\\-debug)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/reproj-tile-4326-debug/expected.png test/rendering/cases/reproj-tile-4326-debug/main.js
