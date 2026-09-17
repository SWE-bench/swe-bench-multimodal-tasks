#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 28c4728b620d0a44bd61a33fc28f726b2efdf650
rm -f test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/expected.png test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/main.js test/rendering/cases/layer-vectortile-opacity-layergroup/expected.png test/rendering/cases/layer-vectortile-opacity-layergroup/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/main.js b/test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/main.js
new file mode 100644
index 00000000000..f3d88b8ac6d
--- /dev/null
+++ b/test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/main.js
@@ -0,0 +1,47 @@
+import MVT from '../../../../src/ol/format/MVT.js';
+import Map from '../../../../src/ol/Map.js';
+import VectorTileLayer from '../../../../src/ol/layer/VectorTile.js';
+import VectorTileSource from '../../../../src/ol/source/VectorTile.js';
+import View from '../../../../src/ol/View.js';
+import {Group} from '../../../../src/ol/layer.js';
+import {createXYZ} from '../../../../src/ol/tilegrid.js';
+
+new Map({
+  layers: [
+    new Group({
+      opacity: 0.3,
+      layers: [
+        new VectorTileLayer({
+          renderMode: 'vector',
+          declutter: true,
+          source: new VectorTileSource({
+            format: new MVT(),
+            tileGrid: createXYZ(),
+            url: '/data/tiles/mapbox-streets-v6/{z}/{x}/{y}.vector.pbf',
+            transition: 0,
+          }),
+          style: {
+            'stroke-color': 'rgba(0, 0, 255, 0.3)',
+            'text-value': [
+              'match',
+              ['!', ['get', 'name_en']],
+              true,
+              '',
+              ['get', 'name_en'],
+            ],
+          },
+        }),
+      ],
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [1825927.7316762917, 6143091.089223046],
+    zoom: 14,
+  }),
+});
+
+render({
+  message: 'Vector tile layer renders',
+  tolerance: 0.02,
+});
diff --git a/test/rendering/cases/layer-vectortile-opacity-layergroup/main.js b/test/rendering/cases/layer-vectortile-opacity-layergroup/main.js
new file mode 100644
index 00000000000..04c4a8c4c87
--- /dev/null
+++ b/test/rendering/cases/layer-vectortile-opacity-layergroup/main.js
@@ -0,0 +1,46 @@
+import MVT from '../../../../src/ol/format/MVT.js';
+import Map from '../../../../src/ol/Map.js';
+import VectorTileLayer from '../../../../src/ol/layer/VectorTile.js';
+import VectorTileSource from '../../../../src/ol/source/VectorTile.js';
+import View from '../../../../src/ol/View.js';
+import {Group} from '../../../../src/ol/layer.js';
+import {createXYZ} from '../../../../src/ol/tilegrid.js';
+
+new Map({
+  layers: [
+    new Group({
+      opacity: 0.3,
+      layers: [
+        new VectorTileLayer({
+          declutter: true,
+          source: new VectorTileSource({
+            format: new MVT(),
+            tileGrid: createXYZ(),
+            url: '/data/tiles/mapbox-streets-v6/{z}/{x}/{y}.vector.pbf',
+            transition: 0,
+          }),
+          style: {
+            'stroke-color': 'rgba(0, 0, 255, 0.3)',
+            'text-value': [
+              'match',
+              ['!', ['get', 'name_en']],
+              true,
+              '',
+              ['get', 'name_en'],
+            ],
+          },
+        }),
+      ],
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: [1825927.7316762917, 6143091.089223046],
+    zoom: 14,
+  }),
+});
+
+render({
+  message: 'Vector tile layer renders',
+  tolerance: 0.02,
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|layer\\-vectortile\\-opacity\\-layergroup|layer\\-vectortile\\-opacity\\-layergroup\\-rendermode\\-vector)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/expected.png test/rendering/cases/layer-vectortile-opacity-layergroup-rendermode-vector/main.js test/rendering/cases/layer-vectortile-opacity-layergroup/expected.png test/rendering/cases/layer-vectortile-opacity-layergroup/main.js
