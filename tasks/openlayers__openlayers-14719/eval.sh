#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b1b0c08f1bdf74dac98b432e15a7b756377297ac
git checkout b1b0c08f1bdf74dac98b432e15a7b756377297ac test/browser/spec/ol/source/ImageWMS.test.js && rm -f test/rendering/cases/source-imagewms-blurry/expected.png test/rendering/cases/source-imagewms-blurry/main.js test/rendering/data/tiles/wms/epsg2056.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/source/ImageWMS.test.js b/test/browser/spec/ol/source/ImageWMS.test.js
index db8c44aa5a2..69340005cc1 100644
--- a/test/browser/spec/ol/source/ImageWMS.test.js
+++ b/test/browser/spec/ol/source/ImageWMS.test.js
@@ -55,8 +55,19 @@ describe('ol/source/ImageWMS', function () {
         const bbox = queryData.get('BBOX').split(',').map(Number);
         const bboxAspectRatio = (bbox[3] - bbox[1]) / (bbox[2] - bbox[0]);
         const imageAspectRatio = imageWidth / imageHeight;
-        expect(imageWidth).to.be(Math.ceil((viewWidth / resolution) * ratio));
-        expect(imageHeight).to.be(Math.ceil((viewHeight / resolution) * ratio));
+        const marginWidth = Math.ceil(
+          ((ratio - 1) * viewWidth) / resolution / 2
+        );
+        const marginHeight = Math.ceil(
+          ((ratio - 1) * viewHeight) / resolution / 2
+        );
+
+        expect(imageWidth).to.be(
+          Math.round(viewWidth / resolution) + 2 * marginWidth
+        );
+        expect(imageHeight).to.be(
+          Math.round(viewHeight / resolution) + 2 * marginHeight
+        );
         expect(bboxAspectRatio).to.roughlyEqual(imageAspectRatio, 1e-12);
       });
     });
diff --git a/test/rendering/cases/source-imagewms-blurry/main.js b/test/rendering/cases/source-imagewms-blurry/main.js
new file mode 100644
index 00000000000..1ad2a9a6b39
--- /dev/null
+++ b/test/rendering/cases/source-imagewms-blurry/main.js
@@ -0,0 +1,35 @@
+import ImageLayer from '../../../../src/ol/layer/Image.js';
+import ImageWMS from '../../../../src/ol/source/ImageWMS.js';
+import Map from '../../../../src/ol/Map.js';
+import View from '../../../../src/ol/View.js';
+import proj4 from 'proj4';
+import {register} from '../../../../src/ol/proj/proj4.js';
+
+proj4.defs(
+  'EPSG:2056',
+  '+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333' +
+    ' +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel ' +
+    '+towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs'
+);
+register(proj4);
+
+const imageWms = new ImageWMS({
+  params: {
+    'LAYERS': 'post_office',
+  },
+  url: '/data/tiles/wms/epsg2056.png',
+  ratio: 767 / 256,
+});
+
+new Map({
+  pixelRatio: 1,
+  layers: [new ImageLayer({source: imageWms})],
+  target: 'map',
+  view: new View({
+    center: [2535000, 1153000],
+    resolution: 2,
+    projection: 'EPSG:2056',
+  }),
+});
+
+render();
EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|source\\-imagewms\\-blurry)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/source/ImageWMS.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/source/ImageWMS.test.js browser/spec/ol/source/ImageWMS.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout b1b0c08f1bdf74dac98b432e15a7b756377297ac test/browser/spec/ol/source/ImageWMS.test.js && rm -f test/rendering/cases/source-imagewms-blurry/expected.png test/rendering/cases/source-imagewms-blurry/main.js test/rendering/data/tiles/wms/epsg2056.png
