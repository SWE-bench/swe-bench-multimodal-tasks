#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 435e0bb9e8c2975843212d382b032a1b00e962f7
rm -f test/rendering/cases/webgl-data-tile-6-band/expected.png test/rendering/cases/webgl-data-tile-6-band/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/webgl-data-tile-6-band/main.js b/test/rendering/cases/webgl-data-tile-6-band/main.js
new file mode 100644
index 00000000000..490e4eae9b5
--- /dev/null
+++ b/test/rendering/cases/webgl-data-tile-6-band/main.js
@@ -0,0 +1,59 @@
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
+new Map({
+  target: 'map',
+  layers: [
+    new TileLayer({
+      source: new DataTile({
+        tileSize: size,
+        bandCount: 6,
+        loader: function (z, x, y) {
+          const halfWidth = size[0] / 2;
+          const halfHeight = size[1] / 2;
+          context.fillStyle = '#00AAFF';
+          context.fillRect(0, 0, size[0], size[1]);
+          context.fillStyle = 'white';
+          context.fillText(`z: ${z}`, halfWidth, halfHeight - lineHeight);
+          context.fillText(`x: ${x}`, halfWidth, halfHeight);
+          context.fillText(`y: ${y}`, halfWidth, halfHeight + lineHeight);
+          context.strokeRect(0, 0, size[0], size[1]);
+          const input = context.getImageData(0, 0, size[0], size[1]).data;
+          const length = input.length;
+          const output = new Uint8Array(length * 1.5);
+          for (let i = 0, j = 1; i < length; i += 4) {
+            output[j] = input[i];
+            output[j + 1] = input[i + 1];
+            output[j + 2] = input[i + 2];
+            output[j + 4] = input[i + 3];
+            j += 6;
+          }
+          return output;
+        },
+      }),
+      style: {
+        color: ['array', ['band', 2], ['band', 3], ['band', 4], ['band', 6]],
+      },
+    }),
+  ],
+  view: new View({
+    center: [0, 0],
+    zoom: 4,
+  }),
+});
+
+render({tolerance: 0.03});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-data\\-tile\\-6\\-band)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/webgl-data-tile-6-band/expected.png test/rendering/cases/webgl-data-tile-6-band/main.js
