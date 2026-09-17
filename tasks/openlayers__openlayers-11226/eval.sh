#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4621496d44792cabc04935b9090d543c037bc471
git checkout 4621496d44792cabc04935b9090d543c037bc471 examples/modify-test.js test/spec/ol/interaction/modify.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/examples/modify-test.js b/examples/modify-test.js
index ef141d096ee..13f6b173841 100644
--- a/examples/modify-test.js
+++ b/examples/modify-test.js
@@ -212,10 +212,21 @@ const geojsonObject = {
             'type': 'Polygon',
             'coordinates': [
               [
-                [1e6, -6e6],
-                [2e6, -4e6],
-                [3e6, -6e6],
-                [1e6, -6e6],
+                [1e6, -5e6],
+                [2e6, -3.5e6],
+                [3e6, -5e6],
+                [1e6, -5e6],
+              ],
+            ],
+          },
+          {
+            'type': 'Polygon',
+            'coordinates': [
+              [
+                [1e6, -5e6],
+                [2e6, -6.5e6],
+                [3e6, -5e6],
+                [1e6, -5e6],
               ],
             ],
           },
diff --git a/test/spec/ol/interaction/modify.test.js b/test/spec/ol/interaction/modify.test.js
index af4efd9aca5..26e74ade28b 100644
--- a/test/spec/ol/interaction/modify.test.js
+++ b/test/spec/ol/interaction/modify.test.js
@@ -2,6 +2,7 @@ import Circle from '../../../../src/ol/geom/Circle.js';
 import Collection from '../../../../src/ol/Collection.js';
 import Event from '../../../../src/ol/events/Event.js';
 import Feature from '../../../../src/ol/Feature.js';
+import GeometryCollection from '../../../../src/ol/geom/GeometryCollection.js';
 import LineString from '../../../../src/ol/geom/LineString.js';
 import Map from '../../../../src/ol/Map.js';
 import MapBrowserEvent from '../../../../src/ol/MapBrowserEvent.js';
@@ -602,6 +603,89 @@ describe('ol.interaction.Modify', function () {
     });
   });
 
+  describe('geometry collection modification', function () {
+    it('all geometries should be modified', function () {
+      const firstPolygon = new Polygon([
+        [
+          [0, 0],
+          [1, 0],
+          [1, 1],
+          [0, 1],
+          [0, 0],
+        ],
+      ]);
+      const secondPolygon = firstPolygon.clone();
+
+      const firstLineString = new LineString([
+        [-2, 0],
+        [0, 0],
+        [2, 0],
+      ]);
+      const secondLineString = new LineString([
+        [0, 2],
+        [0, 0],
+        [0, -2],
+      ]);
+
+      const point = new Point([0, 0]);
+
+      const circle = new Circle([0, 0], 1);
+
+      const geometryCollection = new GeometryCollection([
+        firstPolygon,
+        secondPolygon,
+        firstLineString,
+        secondLineString,
+        point,
+        circle,
+      ]);
+
+      const feature = new Feature({
+        geometry: geometryCollection,
+      });
+
+      features.length = 0;
+      features.push(feature);
+
+      const modify = new Modify({
+        features: new Collection(features),
+      });
+      map.addInteraction(modify);
+
+      // Move vertex
+      simulateEvent('pointermove', 0, 0, null, 0);
+      simulateEvent('pointerdown', 0, 0, null, 0);
+      simulateEvent('pointermove', -1, 0, null, 0);
+      simulateEvent('pointerdrag', -1, 0, null, 0);
+      simulateEvent('pointerup', -1, 0, null, 0);
+
+      let geomCoords;
+      geomCoords = firstPolygon.getCoordinates()[0];
+      expect(geomCoords[0][0]).to.equal(-1);
+      expect(geomCoords[0][1]).to.equal(0);
+
+      geomCoords = secondPolygon.getCoordinates()[0];
+      expect(geomCoords[0][0]).to.equal(-1);
+      expect(geomCoords[0][1]).to.equal(0);
+
+      geomCoords = firstLineString.getCoordinates();
+      expect(geomCoords[1][0]).to.equal(-1);
+      expect(geomCoords[1][1]).to.equal(0);
+
+      geomCoords = secondLineString.getCoordinates();
+      expect(geomCoords[1][0]).to.equal(-1);
+      expect(geomCoords[1][1]).to.equal(0);
+
+      geomCoords = point.getCoordinates();
+      expect(geomCoords[0]).to.equal(-1);
+      expect(geomCoords[1]).to.equal(0);
+
+      geomCoords = circle.getCenter();
+      expect(geomCoords[0]).to.equal(-1);
+      expect(geomCoords[1]).to.equal(0);
+    });
+  });
+
   describe('double click deleteCondition', function () {
     let modify, feature, events;
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/interaction/modify.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/interaction/modify.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 4621496d44792cabc04935b9090d543c037bc471 examples/modify-test.js test/spec/ol/interaction/modify.test.js
