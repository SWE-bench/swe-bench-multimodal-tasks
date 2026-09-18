#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff ba60c3ba4a1f7cef4da84ec30f05b506197fb28a
rm -f test/rendering/cases/webgl-data-tile-reset-source/expected.png test/rendering/cases/webgl-data-tile-reset-source/main.js test/rendering/cases/webgl-tile-reset-projection/expected.png test/rendering/cases/webgl-tile-reset-projection/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/webgl-data-tile-reset-source/main.js b/test/rendering/cases/webgl-data-tile-reset-source/main.js
new file mode 100644
index 00000000000..bc217d77d6a
--- /dev/null
+++ b/test/rendering/cases/webgl-data-tile-reset-source/main.js
@@ -0,0 +1,66 @@
+import DataTile from '../../../../src/ol/source/DataTile.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+
+const size = [81, 99];
+
+const canvas = document.createElement('canvas');
+canvas.width = size[0];
+canvas.height = size[1];
+
+const context = canvas.getContext('2d');
+context.strokeStyle = 'white';
+context.textAlign = 'center';
+const lineHeight = 16;
+context.font = `${lineHeight}px sans-serif`;
+
+const sourceRed = new DataTile({
+  loader: function (z, x, y) {
+    const halfWidth = size[0] / 2;
+    const halfHeight = size[1] / 2;
+    context.fillStyle = '#FF0000';
+    context.fillRect(0, 0, size[0], size[1]);
+    context.fillStyle = 'white';
+    context.fillText(`z: ${z}`, halfWidth, halfHeight - lineHeight);
+    context.fillText(`x: ${x}`, halfWidth, halfHeight);
+    context.fillText(`y: ${y}`, halfWidth, halfHeight + lineHeight);
+    context.strokeRect(0, 0, size[0], size[1]);
+    return context.getImageData(0, 0, size[0], size[1]).data;
+  },
+  tileSize: size,
+});
+
+const sourceBlue = new DataTile({
+  loader: function (z, x, y) {
+    const halfWidth = size[0] / 2;
+    const halfHeight = size[1] / 2;
+    context.fillStyle = '#00AAFF';
+    context.fillRect(0, 0, size[0], size[1]);
+    context.fillStyle = 'white';
+    context.fillText(`z: ${z}`, halfWidth, halfHeight - lineHeight);
+    context.fillText(`x: ${x}`, halfWidth, halfHeight);
+    context.fillText(`y: ${y}`, halfWidth, halfHeight + lineHeight);
+    context.strokeRect(0, 0, size[0], size[1]);
+    return context.getImageData(0, 0, size[0], size[1]).data;
+  },
+  tileSize: size,
+});
+
+const layer = new TileLayer({
+  source: sourceRed,
+});
+
+const map = new Map({
+  target: 'map',
+  layers: [layer],
+  view: new View({
+    center: [0, 0],
+    zoom: 4,
+  }),
+});
+
+map.once(`rendercomplete`, function () {
+  layer.setSource(sourceBlue);
+  render({tolerance: 0.03});
+});
diff --git a/test/rendering/cases/webgl-tile-reset-projection/main.js b/test/rendering/cases/webgl-tile-reset-projection/main.js
new file mode 100644
index 00000000000..bcc823d9ee4
--- /dev/null
+++ b/test/rendering/cases/webgl-tile-reset-projection/main.js
@@ -0,0 +1,35 @@
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+
+const map = new Map({
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        minZoom: 0,
+        maxZoom: 0,
+        url: '/data/tiles/osm/{z}/{x}/{y}.png',
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    projection: 'EPSG:4326',
+    center: [0, 0],
+    zoom: 0,
+    multiWorld: true,
+  }),
+});
+
+map.once('rendercomplete', function () {
+  map.setView(
+    new View({
+      projection: 'EPSG:3857',
+      center: [0, 0],
+      zoom: 0,
+      multiWorld: true,
+    })
+  );
+  render({tolerance: 0.03});
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-data\\-tile\\-reset\\-source|webgl\\-tile\\-reset\\-projection)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/webgl-data-tile-reset-source/expected.png test/rendering/cases/webgl-data-tile-reset-source/main.js test/rendering/cases/webgl-tile-reset-projection/expected.png test/rendering/cases/webgl-tile-reset-projection/main.js
