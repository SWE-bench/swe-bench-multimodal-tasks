#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 61f05fae7464d3e91b7c233e031ec66eb075ce95
rm -f test/rendering/cases/heatmap-layer-opacity/expected.png test/rendering/cases/heatmap-layer-opacity/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/heatmap-layer-opacity/main.js b/test/rendering/cases/heatmap-layer-opacity/main.js
new file mode 100644
index 00000000000..9b8949ad803
--- /dev/null
+++ b/test/rendering/cases/heatmap-layer-opacity/main.js
@@ -0,0 +1,45 @@
+import KML from '../../../../src/ol/format/KML.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/Tile.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {Heatmap as HeatmapLayer} from '../../../../src/ol/layer.js';
+
+const vector = new HeatmapLayer({
+  source: new VectorSource({
+    url: '/data/2012_Earthquakes_Mag5.kml',
+    format: new KML({
+      extractStyles: false,
+    }),
+  }),
+  blur: 3,
+  radius: 3,
+  opacity: 0.5,
+});
+
+vector.getSource().on('addfeature', function (event) {
+  const name = event.feature.get('name');
+  const magnitude = parseFloat(name.substr(2));
+  event.feature.set('weight', magnitude - 5);
+});
+
+const raster = new TileLayer({
+  source: new XYZ({
+    url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+    transition: 0,
+  }),
+});
+
+new Map({
+  layers: [raster, vector],
+  target: 'map',
+  view: new View({
+    center: [0, 0],
+    zoom: 0,
+  }),
+});
+
+render({
+  message: 'Heatmap layer with opacity renders properly using webgl',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:heatmap\\-layer\\-opacity|icon\\-opacity)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/heatmap-layer-opacity/expected.png test/rendering/cases/heatmap-layer-opacity/main.js
