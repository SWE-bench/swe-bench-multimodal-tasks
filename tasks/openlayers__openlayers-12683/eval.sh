#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 706955dfd99294e1edfe9b95652dd8492674f20a
git checkout 706955dfd99294e1edfe9b95652dd8492674f20a test/rendering/webpack.config.js && rm -f test/rendering/cases/icon-sprite/expected.png test/rendering/cases/icon-sprite/main.js test/rendering/data/sprites/gis_symbols.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/icon-sprite/main.js b/test/rendering/cases/icon-sprite/main.js
new file mode 100644
index 00000000000..1bc07961e72
--- /dev/null
+++ b/test/rendering/cases/icon-sprite/main.js
@@ -0,0 +1,37 @@
+import Feature from '../../../../src/ol/Feature.js';
+import Map from '../../../../src/ol/Map.js';
+import Point from '../../../../src/ol/geom/Point.js';
+import View from '../../../../src/ol/View.js';
+import {Icon, Style} from '../../../../src/ol/style.js';
+import {Vector as VectorLayer} from '../../../../src/ol/layer.js';
+import {Vector as VectorSource} from '../../../../src/ol/source.js';
+
+const center = [0, 0];
+
+new Map({
+  pixelRatio: 2,
+  layers: [
+    new VectorLayer({
+      style: function () {
+        return new Style({
+          image: new Icon({
+            src: '/data/sprites/gis_symbols.png',
+            color: [255, 0, 0, 1],
+            offset: [32, 0],
+            size: [32, 32],
+          }),
+        });
+      },
+      source: new VectorSource({
+        features: [new Feature(new Point(center))],
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: center,
+    zoom: 2,
+  }),
+});
+
+render();
diff --git a/test/rendering/webpack.config.js b/test/rendering/webpack.config.js
index 278434bd45a..88127d5ba44 100644
--- a/test/rendering/webpack.config.js
+++ b/test/rendering/webpack.config.js
@@ -42,6 +42,11 @@ export default {
     ],
   },
   resolve: {
+    fallback: {
+      fs: false,
+      http: false,
+      https: false,
+    },
     alias: {
       // ol-mapbox-style imports ol/style/Style etc
       ol: path.join(baseDir, '..', '..', 'src', 'ol'),

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS=--openssl-legacy-provider CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|icon\\-sprite)/main\\.js$"
: '>>>>> End Test Output'
git checkout 706955dfd99294e1edfe9b95652dd8492674f20a test/rendering/webpack.config.js && rm -f test/rendering/cases/icon-sprite/expected.png test/rendering/cases/icon-sprite/main.js test/rendering/data/sprites/gis_symbols.png
