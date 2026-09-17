#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 75a918c3f986f121720064f73ec779868cfa9940
rm -f test/rendering/cases/immediate-geographic-feature/expected.png test/rendering/cases/immediate-geographic-feature/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/immediate-geographic-feature/main.js b/test/rendering/cases/immediate-geographic-feature/main.js
new file mode 100644
index 00000000000..76b170aa608
--- /dev/null
+++ b/test/rendering/cases/immediate-geographic-feature/main.js
@@ -0,0 +1,41 @@
+import TileLayer from '../../../../src/ol/layer/Tile.js';
+import XYZ from '../../../../src/ol/source/XYZ.js';
+import {Circle} from '../../../../src/ol/geom.js';
+import {Feature, Map, View} from '../../../../src/ol/index.js';
+import {Stroke, Style} from '../../../../src/ol/style.js';
+import {getVectorContext} from '../../../../src/ol/render.js';
+import {useGeographic} from '../../../../src/ol/proj.js';
+
+useGeographic();
+
+const center = [8.6, 50.1];
+
+const layer = new TileLayer({
+  source: new XYZ({
+    url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+    transition: 0,
+  }),
+});
+
+layer.on('postrender', (event) => {
+  const context = getVectorContext(event);
+  const style = new Style({
+    stroke: new Stroke({
+      width: 5,
+      color: 'red',
+    }),
+  });
+  const feature = new Feature(new Circle(center, 5));
+  context.drawFeature(feature, style);
+});
+
+new Map({
+  target: 'map',
+  layers: [layer],
+  view: new View({
+    center: center,
+    zoom: 3,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|immediate\\-geographic\\-feature)/main\\.js$"
: '>>>>> End Test Output'
rm -f test/rendering/cases/immediate-geographic-feature/expected.png test/rendering/cases/immediate-geographic-feature/main.js
