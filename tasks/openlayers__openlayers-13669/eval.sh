#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 6341ed3a643c0c98fba2d1abfc007b0b87c0d659
rm -f test/rendering/cases/cog-f32-nodata-explicit-nan/expected.png test/rendering/cases/cog-f32-nodata-explicit-nan/main.js test/rendering/cases/cog-f32-nodata/expected.png test/rendering/cases/cog-f32-nodata/main.js test/rendering/cases/cog-i16-nodata/expected.png test/rendering/cases/cog-i16-nodata/main.js test/rendering/data/raster/elevation-f32.tif test/rendering/data/raster/elevation-i16.tif
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/cog-f32-nodata-explicit-nan/main.js b/test/rendering/cases/cog-f32-nodata-explicit-nan/main.js
new file mode 100644
index 00000000000..d5836a52262
--- /dev/null
+++ b/test/rendering/cases/cog-f32-nodata-explicit-nan/main.js
@@ -0,0 +1,21 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  sources: [{url: '/data/raster/elevation-f32.tif', nodata: NaN}],
+});
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+  ],
+  target: 'map',
+  view: source.getView(),
+});
+
+render({
+  message: 'normalize i16 data with nan nodata based on GDAL stats',
+});
diff --git a/test/rendering/cases/cog-f32-nodata/main.js b/test/rendering/cases/cog-f32-nodata/main.js
new file mode 100644
index 00000000000..6b01ea419ef
--- /dev/null
+++ b/test/rendering/cases/cog-f32-nodata/main.js
@@ -0,0 +1,21 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  sources: [{url: '/data/raster/elevation-f32.tif'}],
+});
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+  ],
+  target: 'map',
+  view: source.getView(),
+});
+
+render({
+  message: 'normalize i16 data with nan nodata based on GDAL stats',
+});
diff --git a/test/rendering/cases/cog-i16-nodata/main.js b/test/rendering/cases/cog-i16-nodata/main.js
new file mode 100644
index 00000000000..433a851f775
--- /dev/null
+++ b/test/rendering/cases/cog-i16-nodata/main.js
@@ -0,0 +1,21 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  sources: [{url: '/data/raster/elevation-i16.tif'}],
+});
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+  ],
+  target: 'map',
+  view: source.getView(),
+});
+
+render({
+  message: 'normalize i16 data with -9999 nodata based on GDAL stats',
+});
EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:cog\\-f32\\-nodata|cog\\-f32\\-nodata\\-explicit\\-nan|cog\\-i16\\-nodata|icon\\-opacity)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/cog-f32-nodata-explicit-nan/expected.png test/rendering/cases/cog-f32-nodata-explicit-nan/main.js test/rendering/cases/cog-f32-nodata/expected.png test/rendering/cases/cog-f32-nodata/main.js test/rendering/cases/cog-i16-nodata/expected.png test/rendering/cases/cog-i16-nodata/main.js test/rendering/data/raster/elevation-f32.tif test/rendering/data/raster/elevation-i16.tif
