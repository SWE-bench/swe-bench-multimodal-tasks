#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9f6ccdfb2d14465f466af8ac7b44f8503fb306a8
git checkout 9f6ccdfb2d14465f466af8ac7b44f8503fb306a8 test/browser/spec/ol/graticule.test.js test/node/ol/coordinate.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/graticule.test.js b/test/browser/spec/ol/graticule.test.js
index 2f3642dd79e..64cbb5a9d81 100644
--- a/test/browser/spec/ol/graticule.test.js
+++ b/test/browser/spec/ol/graticule.test.js
@@ -65,23 +65,19 @@ describe('ol.layer.Graticule', function () {
       };
       graticule.drawLabels_(event);
       expect(graticule.meridiansLabels_.length).to.be(13);
-      expect(graticule.meridiansLabels_[0].text).to.be('0° 00′ 00″');
+      expect(graticule.meridiansLabels_[0].text).to.be('0°');
       expect(
         graticule.meridiansLabels_[0].geom.getCoordinates()[0]
       ).to.roughlyEqual(0, 1e-9);
       expect(graticule.parallelsLabels_.length).to.be(3);
-      expect(graticule.parallelsLabels_[0].text).to.be('0° 00′ 00″');
+      expect(graticule.parallelsLabels_[0].text).to.be('0°');
       expect(
         graticule.parallelsLabels_[0].geom.getCoordinates()[1]
       ).to.roughlyEqual(0, 1e-9);
       feature.set('graticule_label', graticule.meridiansLabels_[0].text);
-      expect(graticule.lonLabelStyle_(feature).getText().getText()).to.be(
-        '0° 00′ 00″'
-      );
+      expect(graticule.lonLabelStyle_(feature).getText().getText()).to.be('0°');
       feature.set('graticule_label', graticule.parallelsLabels_[0].text);
-      expect(graticule.latLabelStyle_(feature).getText().getText()).to.be(
-        '0° 00′ 00″'
-      );
+      expect(graticule.latLabelStyle_(feature).getText().getText()).to.be('0°');
     });
 
     it('creates a graticule with wrapped world labels', function () {
@@ -115,24 +111,20 @@ describe('ol.layer.Graticule', function () {
       };
       graticule.drawLabels_(event);
       expect(graticule.meridiansLabels_.length).to.be(13);
-      expect(graticule.meridiansLabels_[0].text).to.be('0° 00′ 00″');
+      expect(graticule.meridiansLabels_[0].text).to.be('0°');
       const coordinates = fromLonLat([360, 0]);
       expect(
         graticule.meridiansLabels_[0].geom.getCoordinates()[0]
       ).to.roughlyEqual(coordinates[0], 1e-9);
       expect(graticule.parallelsLabels_.length).to.be(3);
-      expect(graticule.parallelsLabels_[0].text).to.be('0° 00′ 00″');
+      expect(graticule.parallelsLabels_[0].text).to.be('0°');
       expect(
         graticule.parallelsLabels_[0].geom.getCoordinates()[1]
       ).to.roughlyEqual(0, 1e-9);
       feature.set('graticule_label', graticule.meridiansLabels_[0].text);
-      expect(graticule.lonLabelStyle_(feature).getText().getText()).to.be(
-        '0° 00′ 00″'
-      );
+      expect(graticule.lonLabelStyle_(feature).getText().getText()).to.be('0°');
       feature.set('graticule_label', graticule.parallelsLabels_[0].text);
-      expect(graticule.latLabelStyle_(feature).getText().getText()).to.be(
-        '0° 00′ 00″'
-      );
+      expect(graticule.latLabelStyle_(feature).getText().getText()).to.be('0°');
     });
 
     it('has a default stroke style', function () {
diff --git a/test/node/ol/coordinate.test.js b/test/node/ol/coordinate.test.js
index 2260acf3111..fc0455717da 100644
--- a/test/node/ol/coordinate.test.js
+++ b/test/node/ol/coordinate.test.js
@@ -7,6 +7,7 @@ import {
   closestOnSegment,
   equals as coordinatesEqual,
   createStringXY,
+  degreesToStringHDMS,
   format as formatCoordinate,
   rotate as rotateCoordinate,
   scale as scaleCoordinate,
@@ -216,6 +217,26 @@ describe('ol/coordinate.js', function () {
     });
   });
 
+  describe('degreesToStringHDMS', () => {
+    it('includes minutes and seconds if non-zero', () => {
+      expect(degreesToStringHDMS('NS', 10 + 30 / 60 + 30 / 3600)).to.be(
+        '10° 30′ 30″ N'
+      );
+    });
+
+    it('omits minutes if zero', () => {
+      expect(degreesToStringHDMS('NS', 10)).to.be('10° N');
+    });
+
+    it('includes minutes if seconds are non-zero', () => {
+      expect(degreesToStringHDMS('NS', 10 + 30 / 3600)).to.be('10° 00′ 30″ N');
+    });
+
+    it('omits seconds if zero', () => {
+      expect(degreesToStringHDMS('NS', 10.5)).to.be('10° 30′ N');
+    });
+  });
+
   describe('#toStringHDMS', function () {
     it('returns the empty string on undefined input', function () {
       const got = toStringHDMS();
@@ -225,13 +246,16 @@ describe('ol/coordinate.js', function () {
     it('formats with zero fractional digits as default', function () {
       const coord = [7.85, 47.983333];
       const got = toStringHDMS(coord);
-      const expected = '47° 59′ 00″ N 7° 51′ 00″ E';
+      const expected = '47° 59′ N 7° 51′ E';
       expect(got).to.be(expected);
     });
     it('formats with given fractional digits, if passed', function () {
-      const coord = [7.85, 47.983333];
+      const coord = [
+        10 + 20 / 60 + 0.3456 / 3600,
+        20 + 30 / 60 + 0.4321 / 3600,
+      ];
       const got = toStringHDMS(coord, 3);
-      const expected = '47° 58′ 59.999″ N 7° 51′ 00.000″ E';
+      const expected = '20° 30′ 00.432″ N 10° 20′ 00.346″ E';
       expect(got).to.be(expected);
     });
   });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/graticule.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/graticule.test.js browser/spec/ol/graticule.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi ; npm run test-node
: '>>>>> End Test Output'
git checkout 9f6ccdfb2d14465f466af8ac7b44f8503fb306a8 test/browser/spec/ol/graticule.test.js test/node/ol/coordinate.test.js
