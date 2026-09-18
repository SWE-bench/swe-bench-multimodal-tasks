#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c742fe965f99639ea79cca2c66a88851611b132f
git checkout c742fe965f99639ea79cca2c66a88851611b132f test/browser/spec/ol/source/GeoTIFF.test.js && rm -f test/rendering/cases/cog-rgb-auto/expected.png test/rendering/cases/cog-rgb-auto/main.js test/rendering/cases/cog-rgb-no-auto/expected.png test/rendering/cases/cog-rgb-no-auto/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/source/GeoTIFF.test.js b/test/browser/spec/ol/source/GeoTIFF.test.js
index 8db17f449ab..ba8cae8dc09 100644
--- a/test/browser/spec/ol/source/GeoTIFF.test.js
+++ b/test/browser/spec/ol/source/GeoTIFF.test.js
@@ -3,7 +3,7 @@ import TileState from '../../../../../src/ol/TileState.js';
 
 describe('ol/source/GeoTIFF', function () {
   describe('constructor', function () {
-    it('configures readMethod_ to read rasters', function () {
+    it('sets convertToRGB false by default', function () {
       const source = new GeoTIFFSource({
         sources: [
           {
@@ -11,10 +11,10 @@ describe('ol/source/GeoTIFF', function () {
           },
         ],
       });
-      expect(source.readMethod_).to.be('readRasters');
+      expect(source.convertToRGB_).to.be(false);
     });
 
-    it('configures readMethod_ to read RGB', function () {
+    it('respects the convertToRGB option', function () {
       const source = new GeoTIFFSource({
         convertToRGB: true,
         sources: [
@@ -23,7 +23,19 @@ describe('ol/source/GeoTIFF', function () {
           },
         ],
       });
-      expect(source.readMethod_).to.be('readRGB');
+      expect(source.convertToRGB_).to.be(true);
+    });
+
+    it('accepts auto convertToRGB', function () {
+      const source = new GeoTIFFSource({
+        convertToRGB: 'auto',
+        sources: [
+          {
+            url: 'spec/ol/source/images/0-0-0.tif',
+          },
+        ],
+      });
+      expect(source.convertToRGB_).to.be('auto');
     });
 
     it('defaults to wrapX: false', function () {
diff --git a/test/rendering/cases/cog-rgb-auto/main.js b/test/rendering/cases/cog-rgb-auto/main.js
new file mode 100644
index 00000000000..17e943198f6
--- /dev/null
+++ b/test/rendering/cases/cog-rgb-auto/main.js
@@ -0,0 +1,22 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  convertToRGB: 'auto',
+  sources: [{url: '/data/raster/masked.tif'}],
+});
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+  ],
+  target: 'map',
+  view: source.getView(),
+});
+
+render({
+  message: 'automatically converts to rgb',
+});
diff --git a/test/rendering/cases/cog-rgb-no-auto/main.js b/test/rendering/cases/cog-rgb-no-auto/main.js
new file mode 100644
index 00000000000..dc1c808cfe0
--- /dev/null
+++ b/test/rendering/cases/cog-rgb-no-auto/main.js
@@ -0,0 +1,22 @@
+import GeoTIFF from '../../../../src/ol/source/GeoTIFF.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+
+const source = new GeoTIFF({
+  convertToRGB: false,
+  sources: [{url: '/data/raster/masked.tif'}],
+});
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: source,
+    }),
+  ],
+  target: 'map',
+  view: source.getView(),
+});
+
+render({
+  message: 'can be overridden to read raw YCbCr',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:cog\\-rgb\\-auto|cog\\-rgb\\-no\\-auto|icon\\-opacity)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/source/GeoTIFF.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/source/GeoTIFF.test.js browser/spec/ol/source/GeoTIFF.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout c742fe965f99639ea79cca2c66a88851611b132f test/browser/spec/ol/source/GeoTIFF.test.js && rm -f test/rendering/cases/cog-rgb-auto/expected.png test/rendering/cases/cog-rgb-auto/main.js test/rendering/cases/cog-rgb-no-auto/expected.png test/rendering/cases/cog-rgb-no-auto/main.js
