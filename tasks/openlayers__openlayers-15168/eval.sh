#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 92b93740defba1d13dd173acf41257d884484f4e
git checkout 92b93740defba1d13dd173acf41257d884484f4e test/rendering/cases/reproj-image-stretched-interpolate-false/expected.png && rm -f test/rendering/cases/reproj-image-svg/expected.png test/rendering/cases/reproj-image-svg/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/reproj-image-svg/main.js b/test/rendering/cases/reproj-image-svg/main.js
new file mode 100644
index 00000000000..09eeaca58a1
--- /dev/null
+++ b/test/rendering/cases/reproj-image-svg/main.js
@@ -0,0 +1,35 @@
+import ImageLayer from '../../../../src/ol/layer/Image.js';
+import ImageSource from '../../../../src/ol/source/Image.js';
+import Map from '../../../../src/ol/Map.js';
+import View from '../../../../src/ol/View.js';
+import {createLoader} from '../../../../src/ol/source/static.js';
+import {fromLonLat} from '../../../../src/ol/proj.js';
+import {load} from '../../../../src/ol/Image.js';
+
+const source = new ImageSource({
+  loader: createLoader({
+    url: '/data/cross.svg',
+    crossOrigin: '',
+    imageExtent: [-10, 50, 10, 70],
+    load: load,
+  }),
+  projection: 'EPSG:4326',
+});
+
+new Map({
+  pixelRatio: 1,
+  target: 'map',
+  layers: [
+    new ImageLayer({
+      source: source,
+    }),
+  ],
+  view: new View({
+    center: fromLonLat([0, 60]),
+    zoom: 3,
+  }),
+});
+
+render({
+  tolerance: 0.001,
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|reproj\\-image\\-stretched\\-interpolate\\-false|reproj\\-image\\-svg)/main\\.js$"
: '>>>>> End Test Output'
git checkout 92b93740defba1d13dd173acf41257d884484f4e test/rendering/cases/reproj-image-stretched-interpolate-false/expected.png && rm -f test/rendering/cases/reproj-image-svg/expected.png test/rendering/cases/reproj-image-svg/main.js
