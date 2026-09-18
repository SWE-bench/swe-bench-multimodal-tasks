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
git checkout 435e0bb9e8c2975843212d382b032a1b00e962f7 test/browser/spec/ol/style/icon.test.js test/browser/spec/ol/style/regularshape.test.js test/rendering/cases/regularshape-style/expected.png test/rendering/cases/regularshape-style/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/style/icon.test.js b/test/browser/spec/ol/style/icon.test.js
index c319a494b6d..8c0714dbd4f 100644
--- a/test/browser/spec/ol/style/icon.test.js
+++ b/test/browser/spec/ol/style/icon.test.js
@@ -243,6 +243,32 @@ describe('ol.style.Icon', function () {
         size[1] / 2 + 20,
       ]);
     });
+
+    it('scale applies to image size, not offset', function () {
+      const scale = 4;
+      let anchorScaled, anchorBig;
+
+      const iconStyleScaled = new Icon({
+        src: 'test.png',
+        size: size,
+        displacement: [20, 10],
+        scale: scale,
+      });
+      const iconStyleBig = new Icon({
+        src: 'test.png',
+        size: [size[0] * scale, size[1] * scale],
+        displacement: [20, 10],
+      });
+      anchorScaled = iconStyleScaled.getAnchor();
+      anchorBig = iconStyleBig.getAnchor();
+      expect(anchorScaled).to.eql([anchorBig[0] / scale, anchorBig[1] / scale]);
+
+      iconStyleScaled.setDisplacement([10, 20]);
+      iconStyleBig.setDisplacement([10, 20]);
+      anchorScaled = iconStyleScaled.getAnchor();
+      anchorBig = iconStyleBig.getAnchor();
+      expect(anchorScaled).to.eql([anchorBig[0] / scale, anchorBig[1] / scale]);
+    });
   });
 
   describe('#setAnchor', function () {
diff --git a/test/browser/spec/ol/style/regularshape.test.js b/test/browser/spec/ol/style/regularshape.test.js
index dc9f4e05ba5..de1defe8c9d 100644
--- a/test/browser/spec/ol/style/regularshape.test.js
+++ b/test/browser/spec/ol/style/regularshape.test.js
@@ -117,6 +117,39 @@ describe('ol.style.RegularShape', function () {
       expect(style.getDisplacement()[1]).to.eql(10);
       expect(style.getAnchor()).to.eql([-15, 15]);
     });
+
+    it('scale applies to rendered radius, not offset', function () {
+      let style;
+
+      style = new RegularShape({
+        radius: 5,
+        displacement: [10, 20],
+        scale: 4,
+      });
+      expect(style.getDisplacement()).to.an('array');
+      expect(style.getDisplacement()[0]).to.eql(10);
+      expect(style.getDisplacement()[1]).to.eql(20);
+      expect(style.getAnchor()).to.eql([2.5, 10]);
+      style.setDisplacement([20, 10]);
+      expect(style.getDisplacement()).to.an('array');
+      expect(style.getDisplacement()[0]).to.eql(20);
+      expect(style.getDisplacement()[1]).to.eql(10);
+      expect(style.getAnchor()).to.eql([0, 7.5]);
+
+      style = new RegularShape({
+        radius: 20,
+        displacement: [10, 20],
+      });
+      expect(style.getDisplacement()).to.an('array');
+      expect(style.getDisplacement()[0]).to.eql(10);
+      expect(style.getDisplacement()[1]).to.eql(20);
+      expect(style.getAnchor()).to.eql([10, 40]);
+      style.setDisplacement([20, 10]);
+      expect(style.getDisplacement()).to.an('array');
+      expect(style.getDisplacement()[0]).to.eql(20);
+      expect(style.getDisplacement()[1]).to.eql(10);
+      expect(style.getAnchor()).to.eql([0, 30]);
+    });
   });
 
   describe('#clone', function () {
diff --git a/test/rendering/cases/regularshape-style/main.js b/test/rendering/cases/regularshape-style/main.js
index 261415b1ebc..8ff5f4159e5 100644
--- a/test/rendering/cases/regularshape-style/main.js
+++ b/test/rendering/cases/regularshape-style/main.js
@@ -11,7 +11,7 @@ import View from '../../../../src/ol/View.js';
 import {Icon} from '../../../../src/ol/style.js';
 
 const vectorSource = new VectorSource();
-function createFeatures(stroke, fill, offSet = [0, 0]) {
+function createFeatures(stroke, fill, offSet = [0, 0], scale = 1) {
   let feature;
   feature = new Feature({
     geometry: new Point([offSet[0], offSet[1]]),
@@ -26,6 +26,7 @@ function createFeatures(stroke, fill, offSet = [0, 0]) {
         radius: 10,
         angle: Math.PI / 4,
         displacement: [-15, 15],
+        scale: scale,
       }),
     }),
     new Style({
@@ -36,6 +37,7 @@ function createFeatures(stroke, fill, offSet = [0, 0]) {
         anchorXUnits: 'fraction',
         anchorYUnits: 'fraction',
         displacement: [-15, 15],
+        scale: scale,
       }),
     }),
   ]);
@@ -131,6 +133,14 @@ createFeatures(
   null,
   [-50, -50]
 );
+createFeatures(
+  new Stroke({
+    lineDash: [10, 5],
+  }),
+  null,
+  [-50, 50],
+  1.5
+);
 
 createFeatures(new Stroke(), new Fill(), [50, -50]);
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|regularshape\\-style)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/style/icon.test.js'"'"');' 'require('"'"'./browser/spec/ol/style/regularshape.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{spec/ol/style/icon.test.js,spec/ol/style/regularshape.test.js}' '{browser/spec/ol/style/icon.test.js,browser/spec/ol/style/regularshape.test.js}'; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 435e0bb9e8c2975843212d382b032a1b00e962f7 test/browser/spec/ol/style/icon.test.js test/browser/spec/ol/style/regularshape.test.js test/rendering/cases/regularshape-style/expected.png test/rendering/cases/regularshape-style/main.js
