#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff d8156577c941ab0d7f647e86dac1e7181db7e5f2
git checkout d8156577c941ab0d7f647e86dac1e7181db7e5f2 test/spec/ol/interaction/draw.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/interaction/draw.test.js b/test/spec/ol/interaction/draw.test.js
index cfc5f45a89c..1e934b5df57 100644
--- a/test/spec/ol/interaction/draw.test.js
+++ b/test/spec/ol/interaction/draw.test.js
@@ -4,7 +4,7 @@ import MapBrowserPointerEvent from '../../../../src/ol/MapBrowserPointerEvent.js
 import View from '../../../../src/ol/View.js';
 import {equals} from '../../../../src/ol/array.js';
 import {listen} from '../../../../src/ol/events.js';
-import {always} from '../../../../src/ol/events/condition.js';
+import {always, shiftKeyOnly, altKeyOnly} from '../../../../src/ol/events/condition.js';
 import Circle from '../../../../src/ol/geom/Circle.js';
 import LineString from '../../../../src/ol/geom/LineString.js';
 import MultiLineString from '../../../../src/ol/geom/MultiLineString.js';
@@ -492,6 +492,47 @@ describe('ol.interaction.Draw', function() {
 
   });
 
+  describe('drawing with a condition', function() {
+    let draw;
+    beforeEach(function() {
+      draw = new Draw({
+        source: source,
+        type: 'LineString',
+        condition: shiftKeyOnly,
+        freehandCondition: altKeyOnly
+      });
+      map.addInteraction(draw);
+    });
+
+    it('finishes draw sequence correctly', function() {
+      // first point
+      simulateEvent('pointermove', 10, 20, true);
+      simulateEvent('pointerdown', 10, 20, true);
+      simulateEvent('pointerup', 10, 20, true);
+
+      // second point
+      simulateEvent('pointermove', 30, 20, true);
+      simulateEvent('pointerdown', 30, 20, true);
+      simulateEvent('pointerup', 30, 20, true);
+
+      // finish on second point
+      simulateEvent('pointerdown', 30, 20, true);
+      simulateEvent('pointerup', 30, 20, true);
+
+      const features = source.getFeatures();
+      expect(features).to.have.length(1);
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(LineString);
+      expect(geometry.getCoordinates()).to.eql([[10, -20], [30, -20]]);
+
+      // without modifier, to be handled by the map's DragPan interaction
+      simulateEvent('pointermove', 20, 20);
+      simulateEvent('pointerdown', 20, 20);
+      simulateEvent('pointermove', 10, 30);
+      expect(draw.lastDragTime_).to.be(undefined);
+    });
+  });
+
   describe('drawing with a finishCondition', function() {
     beforeEach(function() {
       const draw = new Draw({

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/interaction/draw.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/interaction/draw.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout d8156577c941ab0d7f647e86dac1e7181db7e5f2 test/spec/ol/interaction/draw.test.js
