#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c6ddb3e1897f7c2ab14102143a9474364ef7c1d8
rm -f test/rendering/cases/cog-palette-add-remove/expected.png test/rendering/cases/cog-palette-add-remove/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/cog-palette-add-remove/main.js b/test/rendering/cases/cog-palette-add-remove/main.js
new file mode 100644
index 00000000000..bed2fffccff
--- /dev/null
+++ b/test/rendering/cases/cog-palette-add-remove/main.js
@@ -0,0 +1,49 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  sources: [
+    {
+      url: '/data/raster/sentinel-b04.tif',
+      min: 0,
+      max: 10000,
+    },
+    {
+      url: '/data/raster/sentinel-b08.tif',
+      min: 0,
+      max: 10000,
+    },
+  ],
+  transition: 100,
+});
+
+const nir = ['band', 2];
+const red = ['band', 1];
+const ndvi = ['/', ['-', nir, red], ['+', nir, red]];
+
+const layer = new TileLayer({
+  source: source,
+  style: {
+    color: [
+      'palette',
+      ['interpolate', ['linear'], ndvi, -0.2, 0, 0.65, 4],
+      ['#440154', '#3b528b', '#21918c', '#5ec962', '#fde725'],
+    ],
+  },
+});
+
+const map = new Map({
+  layers: [layer],
+  target: 'map',
+  view: source.getView(),
+});
+
+// regression test for https://github.com/openlayers/openlayers/issues/15786
+map.once('rendercomplete', () => {
+  map.removeLayer(layer);
+  map.addLayer(layer);
+  render({
+    message: 'palette still works after adding and removing layer',
+  });
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:cog\\-palette\\-add\\-remove|full\\-build)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/cog-palette-add-remove/expected.png test/rendering/cases/cog-palette-add-remove/main.js
