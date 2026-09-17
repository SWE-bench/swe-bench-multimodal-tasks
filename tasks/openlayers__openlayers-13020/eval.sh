#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff d95e507af3fbc2ee52cfd91d3b728352e875e88b
rm -f test/rendering/cases/cog-style/expected.png test/rendering/cases/cog-style/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/cog-style/main.js b/test/rendering/cases/cog-style/main.js
new file mode 100644
index 00000000000..80c5cbf872f
--- /dev/null
+++ b/test/rendering/cases/cog-style/main.js
@@ -0,0 +1,45 @@
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
+  transition: 0,
+});
+
+const layer = new TileLayer({
+  source: source,
+});
+
+new Map({
+  layers: [layer],
+  target: 'map',
+  view: source.getView(),
+});
+
+layer.setStyle({
+  color: [
+    'interpolate',
+    ['linear'],
+    ['/', ['-', ['band', 2], ['band', 1]], ['+', ['band', 2], ['band', 1]]],
+    -0.2,
+    [200, 0, 0],
+    1,
+    [0, 255, 0],
+  ],
+});
+
+render({
+  message: 'update the layer style',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:cog\\-style|icon\\-opacity)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/cog-style/expected.png test/rendering/cases/cog-style/main.js
