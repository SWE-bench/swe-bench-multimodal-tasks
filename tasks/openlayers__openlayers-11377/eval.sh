#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 302bc662af22bc353c87ae1a3700c6958c69b8e9
git checkout 302bc662af22bc353c87ae1a3700c6958c69b8e9 test/spec/ol/renderer/map.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/renderer/map.test.js b/test/spec/ol/renderer/map.test.js
index 37e60a8393b..92cad661236 100644
--- a/test/spec/ol/renderer/map.test.js
+++ b/test/spec/ol/renderer/map.test.js
@@ -5,6 +5,7 @@ import MapRenderer from '../../../../src/ol/renderer/Map.js';
 import VectorLayer from '../../../../src/ol/layer/Vector.js';
 import VectorSource from '../../../../src/ol/source/Vector.js';
 import View from '../../../../src/ol/View.js';
+import {Circle, Fill, Style} from '../../../../src/ol/style.js';
 import {Point} from '../../../../src/ol/geom.js';
 import {Projection} from '../../../../src/ol/proj.js';
 
@@ -21,7 +22,7 @@ describe('ol.renderer.Map', function () {
   });
 
   describe('#forEachFeatureAtCoordinate', function () {
-    let map;
+    let map, source;
     beforeEach(function () {
       const target = document.createElement('div');
       target.style.width = '100px';
@@ -31,13 +32,23 @@ describe('ol.renderer.Map', function () {
         code: 'EPSG:21781',
         units: 'm',
       });
+      source = new VectorSource({
+        projection: projection,
+        features: [new Feature(new Point([660000, 190000]))],
+      });
       map = new Map({
         target: target,
         layers: [
           new VectorLayer({
-            source: new VectorSource({
-              projection: projection,
-              features: [new Feature(new Point([660000, 190000]))],
+            source: source,
+            renderBuffer: 12,
+            style: new Style({
+              image: new Circle({
+                radius: 6,
+                fill: new Fill({
+                  color: 'fuchsia',
+                }),
+              }),
             }),
           }),
         ],
@@ -47,7 +58,6 @@ describe('ol.renderer.Map', function () {
           zoom: 9,
         }),
       });
-      map.renderSync();
     });
 
     afterEach(function () {
@@ -57,8 +67,25 @@ describe('ol.renderer.Map', function () {
     });
 
     it('works with custom projection', function () {
+      map.renderSync();
       const features = map.getFeaturesAtPixel([50, 50]);
       expect(features.length).to.be(1);
     });
+
+    it('only draws features that intersect the hit detection viewport', function () {
+      const resolution = map.getView().getResolution();
+      source.addFeature(
+        new Feature(new Point([660000 + resolution * 6, 190000]))
+      );
+      source.addFeature(
+        new Feature(new Point([660000 - resolution * 12, 190000]))
+      );
+      map.renderSync();
+      const spy = sinon.spy(CanvasRenderingContext2D.prototype, 'drawImage');
+      const features = map.getFeaturesAtPixel([50, 44]);
+      expect(features.length).to.be(1);
+      expect(spy.callCount).to.be(2);
+      spy.restore();
+    });
   });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/renderer/map.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/renderer/map.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 302bc662af22bc353c87ae1a3700c6958c69b8e9 test/spec/ol/renderer/map.test.js
