#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8fee4db7a285cdbbd7637e373d6c712ebba40afe
rm -f test/rendering/cases/source-raster-webgl-alpha/expected.png test/rendering/cases/source-raster-webgl-alpha/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/source-raster-webgl-alpha/main.js b/test/rendering/cases/source-raster-webgl-alpha/main.js
new file mode 100644
index 00000000000..256b69cc2e9
--- /dev/null
+++ b/test/rendering/cases/source-raster-webgl-alpha/main.js
@@ -0,0 +1,59 @@
+import DataTile from '../../../../src/ol/source/DataTile.js';
+import ImageLayer from '../../../../src/ol/layer/Image.js';
+import Map from '../../../../src/ol/Map.js';
+import RasterSource from '../../../../src/ol/source/Raster.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+
+const size = 256;
+const data0 = new Uint8Array(size * size * 4);
+const data1 = new Uint8Array(size * size * 4);
+const data2 = new Uint8Array(size * size * 4);
+
+for (let row = 0; row < size; ++row) {
+  for (let col = 0; col < size; ++col) {
+    data0[(row * size + col) * 4 + 3] = (row + col) % 3 === 0 ? 255 : 0;
+    data1[(row * size + col) * 4 + 3] = (row + col) % 3 === 1 ? 255 : 0;
+    data2[(row * size + col) * 4 + 3] = (row + col) % 3 === 2 ? 255 : 0;
+  }
+}
+
+const raster = new RasterSource({
+  sources: [
+    new TileLayer({
+      source: new DataTile({
+        maxZoom: 0,
+        loader: () => data0,
+      }),
+    }),
+    new TileLayer({
+      source: new DataTile({
+        maxZoom: 0,
+        loader: () => data1,
+      }),
+    }),
+    new TileLayer({
+      source: new DataTile({
+        maxZoom: 0,
+        loader: () => data2,
+      }),
+    }),
+  ],
+  resolutions: null,
+  threads: 0, // Avoid using workers to work with puppeteer
+  operation: function (pixels) {
+    return [pixels[0][3], pixels[1][3], pixels[2][3], 255];
+  },
+});
+
+const map = new Map({
+  target: 'map',
+  layers: [new ImageLayer({source: raster})],
+  view: new View({
+    center: [0, 0],
+    zoom: 4,
+  }),
+});
+map.renderSync();
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|source\\-raster\\-webgl\\-alpha)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/source-raster-webgl-alpha/expected.png test/rendering/cases/source-raster-webgl-alpha/main.js
