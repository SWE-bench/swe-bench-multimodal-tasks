#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e0aa1613022455c519df811de4152cd527ddfa47
rm -f test/rendering/cases/layer-vector-background-over/expected.png test/rendering/cases/layer-vector-background-over/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/layer-vector-background-over/main.js b/test/rendering/cases/layer-vector-background-over/main.js
new file mode 100644
index 00000000000..1a7c4ce369e
--- /dev/null
+++ b/test/rendering/cases/layer-vector-background-over/main.js
@@ -0,0 +1,41 @@
+import GeoJSON from '../../../../src/ol/format/GeoJSON.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/Tile.js';
+import VectorLayer from '../../../../src/ol/layer/Vector.js';
+import VectorSource from '../../../../src/ol/source/Vector.js';
+import View from '../../../../src/ol/View.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {Fill, Stroke, Style} from '../../../../src/ol/style.js';
+
+new Map({
+  target: 'map',
+  view: new View({
+    center: [0, 0],
+    zoom: 1,
+  }),
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+        transition: 0,
+      }),
+    }),
+    new VectorLayer({
+      background: '#a9d3df',
+      source: new VectorSource({
+        url: '/data/countries.json',
+        format: new GeoJSON(),
+      }),
+      style: new Style({
+        stroke: new Stroke({
+          color: '#ccc',
+        }),
+        fill: new Fill({
+          color: 'white',
+        }),
+      }),
+    }),
+  ],
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|layer\\-vector\\-background\\-over)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/layer-vector-background-over/expected.png test/rendering/cases/layer-vector-background-over/main.js
