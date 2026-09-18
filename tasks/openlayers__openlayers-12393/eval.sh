#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 07227868571f35585d664cf185311b94405b85c1
git checkout 07227868571f35585d664cf185311b94405b85c1 test/browser/spec/ol/source/imagestatic.test.js test/rendering/cases/image-stretched-disable-smoothing/expected.png test/rendering/cases/reproj-image-stretched-disable-smoothing/expected.png test/rendering/cases/reproj-image/expected.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/source/imagestatic.test.js b/test/browser/spec/ol/source/imagestatic.test.js
index c7058008851..fb1c0dc4bc4 100644
--- a/test/browser/spec/ol/source/imagestatic.test.js
+++ b/test/browser/spec/ol/source/imagestatic.test.js
@@ -16,7 +16,7 @@ describe('ol.source.ImageStatic', function () {
   });
 
   describe('#getImage', function () {
-    it('scales image to fit imageExtent', function (done) {
+    it('scales image height to fit imageExtent', function (done) {
       const source = new Static({
         url: 'spec/ol/source/images/12-655-1583.png',
         imageExtent: [
@@ -31,7 +31,30 @@ describe('ol.source.ImageStatic', function () {
       const image = source.getImage(extent, resolution, pixelRatio, projection);
 
       source.on('imageloadend', function (event) {
-        expect(image.getImage().width).to.be(128);
+        expect(image.getImage().width).to.be(256);
+        expect(image.getImage().height).to.be(512);
+        done();
+      });
+
+      image.load();
+    });
+
+    it('scales image width to fit imageExtent', function (done) {
+      const source = new Static({
+        url: 'spec/ol/source/images/12-655-1583.png',
+        imageExtent: [
+          -13629027.891360067,
+          4539747.983913189,
+          -13609460.012119063,
+          4549531.923533691,
+        ],
+        projection: projection,
+      });
+
+      const image = source.getImage(extent, resolution, pixelRatio, projection);
+
+      source.on('imageloadend', function (event) {
+        expect(image.getImage().width).to.be(512);
         expect(image.getImage().height).to.be(256);
         done();
       });
@@ -55,8 +78,8 @@ describe('ol.source.ImageStatic', function () {
       const image = source.getImage(extent, resolution, pixelRatio, projection);
 
       source.on('imageloadend', function (event) {
-        expect(image.getImage().width).to.be(127);
-        expect(image.getImage().height).to.be(254);
+        expect(image.getImage().width).to.be(254);
+        expect(image.getImage().height).to.be(508);
         done();
       });
 
EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS=--openssl-legacy-provider CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|image\\-stretched\\-disable\\-smoothing|reproj\\-image|reproj\\-image\\-stretched\\-disable\\-smoothing)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/source/imagestatic.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/source/imagestatic.test.js browser/spec/ol/source/imagestatic.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 07227868571f35585d664cf185311b94405b85c1 test/browser/spec/ol/source/imagestatic.test.js test/rendering/cases/image-stretched-disable-smoothing/expected.png test/rendering/cases/reproj-image-stretched-disable-smoothing/expected.png test/rendering/cases/reproj-image/expected.png
