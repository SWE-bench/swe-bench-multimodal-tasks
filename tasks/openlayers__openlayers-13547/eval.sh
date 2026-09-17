#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c03f58fe5da15dca97f4231f12792d611f00b10c
rm -f test/rendering/cases/webgl-data-tile-interpolate-gutter/expected.png test/rendering/cases/webgl-data-tile-interpolate-gutter/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/webgl-data-tile-interpolate-gutter/main.js b/test/rendering/cases/webgl-data-tile-interpolate-gutter/main.js
new file mode 100644
index 00000000000..d294e8f3f36
--- /dev/null
+++ b/test/rendering/cases/webgl-data-tile-interpolate-gutter/main.js
@@ -0,0 +1,33 @@
+import DataTile from '../../../../src/ol/source/DataTile.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+
+const size = 260;
+
+const data = new Uint8Array(size * size);
+for (let row = 0; row < size; ++row) {
+  for (let col = 0; col < size; ++col) {
+    data[row * size + col] = (row + col) % 2 === 0 ? 255 : 0;
+  }
+}
+
+new Map({
+  target: 'map',
+  layers: [
+    new TileLayer({
+      source: new DataTile({
+        maxZoom: 1,
+        interpolate: true,
+        loader: () => data,
+        gutter: 2,
+      }),
+    }),
+  ],
+  view: new View({
+    center: [0, 0],
+    zoom: 5,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-data\\-tile\\-interpolate\\-gutter)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/webgl-data-tile-interpolate-gutter/expected.png test/rendering/cases/webgl-data-tile-interpolate-gutter/main.js
