#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e361391503ada8a9efdce2f3aa75e29d0351ab95
git checkout e361391503ada8a9efdce2f3aa75e29d0351ab95 test/spec/ol/interaction/draw.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/interaction/draw.test.js b/test/spec/ol/interaction/draw.test.js
index 5961ddb7008..7a12b66887c 100644
--- a/test/spec/ol/interaction/draw.test.js
+++ b/test/spec/ol/interaction/draw.test.js
@@ -17,6 +17,9 @@ import Interaction from '../../../../src/ol/interaction/Interaction.js';
 import VectorLayer from '../../../../src/ol/layer/Vector.js';
 import Event from '../../../../src/ol/events/Event.js';
 import VectorSource from '../../../../src/ol/source/Vector.js';
+import {clearUserProjection, setUserProjection, transform} from '../../../../src/ol/proj.js';
+import {register} from '../../../../src/ol/proj/proj4.js';
+import proj4 from 'proj4';
 
 
 describe('ol.interaction.Draw', function() {
@@ -53,6 +56,7 @@ describe('ol.interaction.Draw', function() {
   afterEach(function() {
     map.dispose();
     document.body.removeChild(target);
+    clearUserProjection();
   });
 
   /**
@@ -909,7 +913,7 @@ describe('ol.interaction.Draw', function() {
       map.addInteraction(draw);
     });
 
-    it('draws circle with clicks, finishing on second point', function() {
+    it('draws circle with clicks, finishing on second point along x axis', function() {
       // first point
       simulateEvent('pointermove', 10, 20);
       simulateEvent('pointerdown', 10, 20);
@@ -928,6 +932,73 @@ describe('ol.interaction.Draw', function() {
       expect(geometry.getRadius()).to.eql(20);
     });
 
+    it('draws circle with clicks, finishing on second point along y axis', function() {
+      // first point
+      simulateEvent('pointermove', 10, 20);
+      simulateEvent('pointerdown', 10, 20);
+      simulateEvent('pointerup', 10, 20);
+
+      // finish on second point
+      simulateEvent('pointermove', 10, 40);
+      simulateEvent('pointerdown', 10, 40);
+      simulateEvent('pointerup', 10, 40);
+
+      const features = source.getFeatures();
+      expect(features).to.have.length(1);
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(Circle);
+      expect(geometry.getCenter()).to.eql([10, -20]);
+      expect(geometry.getRadius()).to.eql(20);
+    });
+
+    it('draws circle with clicks in a user projection, finishing on second point along x axis', function() {
+      const userProjection = 'EPSG:3857';
+      setUserProjection(userProjection);
+
+      // first point
+      simulateEvent('pointermove', 10, 20);
+      simulateEvent('pointerdown', 10, 20);
+      simulateEvent('pointerup', 10, 20);
+
+      // finish on second point
+      simulateEvent('pointermove', 30, 20);
+      simulateEvent('pointerdown', 30, 20);
+      simulateEvent('pointerup', 30, 20);
+
+      const features = source.getFeatures();
+      expect(features).to.have.length(1);
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(Circle);
+      const viewProjection = map.getView().getProjection();
+      expect(geometry.getCenter()).to.eql(transform([10, -20], viewProjection, userProjection));
+      const radius = geometry.clone().transform(userProjection, viewProjection).getRadius();
+      expect(radius).to.roughlyEqual(20, 1e-9);
+    });
+
+    it('draws circle with clicks in a user projection, finishing on second point along y axis', function() {
+      const userProjection = 'EPSG:3857';
+      setUserProjection(userProjection);
+
+      // first point
+      simulateEvent('pointermove', 10, 20);
+      simulateEvent('pointerdown', 10, 20);
+      simulateEvent('pointerup', 10, 20);
+
+      // finish on second point
+      simulateEvent('pointermove', 10, 40);
+      simulateEvent('pointerdown', 10, 40);
+      simulateEvent('pointerup', 10, 40);
+
+      const features = source.getFeatures();
+      expect(features).to.have.length(1);
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(Circle);
+      const viewProjection = map.getView().getProjection();
+      expect(geometry.getCenter()).to.eql(transform([10, -20], viewProjection, userProjection));
+      const radius = geometry.clone().transform(userProjection, viewProjection).getRadius();
+      expect(radius).to.roughlyEqual(20, 1e-9);
+    });
+
     it('supports freehand drawing for circles', function() {
       draw.freehand_ = true;
       draw.freehandCondition_ = always;
@@ -1153,6 +1224,38 @@ describe('ol.interaction.Draw', function() {
       expect(coordinates[0][0][1]).to.roughlyEqual(20, 1e-9);
     });
 
+    it('creates a regular polygon in Circle mode in a user projection', function() {
+      const userProjection = 'EPSG:3857';
+      setUserProjection(userProjection);
+
+      const draw = new Draw({
+        source: source,
+        type: 'Circle',
+        geometryFunction: createRegularPolygon(4, Math.PI / 4)
+      });
+      map.addInteraction(draw);
+
+      // first point
+      simulateEvent('pointermove', 0, 0);
+      simulateEvent('pointerdown', 0, 0);
+      simulateEvent('pointerup', 0, 0);
+
+      // finish on second point
+      simulateEvent('pointermove', 20, 20);
+      simulateEvent('pointerdown', 20, 20);
+      simulateEvent('pointerup', 20, 20);
+
+      const features = source.getFeatures();
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(Polygon);
+      const coordinates = geometry.getCoordinates();
+      expect(coordinates[0].length).to.eql(5);
+      const viewProjection = map.getView().getProjection();
+      const coordinate = transform([20, 20], viewProjection, userProjection);
+      expect(coordinates[0][0][0]).to.roughlyEqual(coordinate[0], 1e-9);
+      expect(coordinates[0][0][1]).to.roughlyEqual(coordinate[1], 1e-9);
+    });
+
     it('sketch start point always matches the mouse point', function() {
       const draw = new Draw({
         source: source,
@@ -1227,6 +1330,44 @@ describe('ol.interaction.Draw', function() {
       expect(geometry.getArea()).to.equal(400);
       expect(geometry.getExtent()).to.eql([0, -20, 20, 0]);
     });
+
+    it('creates a box-shaped polygon in Circle mode in a user projection', function() {
+      proj4.defs('ESRI:54009', '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs');
+      register(proj4);
+      const userProjection = 'ESRI:54009';
+      setUserProjection(userProjection);
+
+      const draw = new Draw({
+        source: source,
+        type: 'Circle',
+        geometryFunction: createBox()
+      });
+      map.addInteraction(draw);
+
+      // first point
+      simulateEvent('pointermove', 0, 0);
+      simulateEvent('pointerdown', 0, 0);
+      simulateEvent('pointerup', 0, 0);
+
+      // finish on second point
+      simulateEvent('pointermove', 20, 20);
+      simulateEvent('pointerdown', 20, 20);
+      simulateEvent('pointerup', 20, 20);
+
+      const features = source.getFeatures();
+      const geometry = features[0].getGeometry();
+      expect(geometry).to.be.a(Polygon);
+      const coordinates = geometry.getCoordinates();
+      expect(coordinates[0]).to.have.length(5);
+      const viewProjection = map.getView().getProjection();
+      const area = geometry.clone().transform(userProjection, viewProjection).getArea();
+      expect(area).to.roughlyEqual(400, 1e-9);
+      const extent = geometry.clone().transform(userProjection, viewProjection).getExtent();
+      expect(extent[0]).to.roughlyEqual(0, 1e-9);
+      expect(extent[1]).to.roughlyEqual(-20, 1e-9);
+      expect(extent[2]).to.roughlyEqual(20, 1e-9);
+      expect(extent[3]).to.roughlyEqual(0, 1e-9);
+    });
   });
 
   describe('extend an existing feature', function() {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/interaction/draw.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/interaction/draw.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout e361391503ada8a9efdce2f3aa75e29d0351ab95 test/spec/ol/interaction/draw.test.js
