#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 14041e490f81796bc75cdaea07d7521f786611bd
git checkout 14041e490f81796bc75cdaea07d7521f786611bd test/node/ol/format/GeoJSON.test.js test/node/ol/geom/MultiPolygon.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/node/ol/format/GeoJSON.test.js b/test/node/ol/format/GeoJSON.test.js
index 16522d4aebd..7c127006baf 100644
--- a/test/node/ol/format/GeoJSON.test.js
+++ b/test/node/ol/format/GeoJSON.test.js
@@ -516,6 +516,26 @@ describe('ol/format/GeoJSON.js', function () {
       expect(array[1]).to.be.a(LineString);
       expect(array[1].getLayout()).to.eql('XY');
     });
+
+    it('works with empty coordinate arrays', function () {
+      const coordinates = [
+        [
+          [
+            [1, 2],
+            [3, 4],
+            [5, 6],
+            [1, 2],
+          ],
+        ],
+        [],
+      ];
+      const geojson = {
+        type: 'MultiPolygon',
+        coordinates: coordinates,
+      };
+      const geometry = format.readGeometry(geojson);
+      expect(geometry.getCoordinates()).to.eql(coordinates);
+    });
   });
 
   describe('#readProjection', function () {
@@ -1025,5 +1045,28 @@ describe('ol/format/GeoJSON.js', function () {
         [43, 39],
       ]);
     });
+
+    it('works with empty coordinate arrays', function () {
+      const coordinates = [
+        [
+          [
+            [1, 2],
+            [3, 4],
+            [5, 6],
+            [1, 2],
+          ],
+        ],
+        [],
+      ];
+      const geometry = new MultiPolygon([
+        new Polygon(coordinates[0]),
+        new Polygon(coordinates[1]),
+      ]);
+      const geojson = format.writeGeometryObject(geometry);
+      expect(geojson).to.eql({
+        type: 'MultiPolygon',
+        coordinates: coordinates,
+      });
+    });
   });
 });
diff --git a/test/node/ol/geom/MultiPolygon.test.js b/test/node/ol/geom/MultiPolygon.test.js
index 722da6c7081..0f12ac80e04 100644
--- a/test/node/ol/geom/MultiPolygon.test.js
+++ b/test/node/ol/geom/MultiPolygon.test.js
@@ -322,6 +322,7 @@ describe('ol/geom/MultiPolygon.js', function () {
         [cw, ccw],
         [cw2, ccw2],
       ]);
+      const withEmptyPolygon = new MultiPolygon([[ccw], []]);
 
       it('returns coordinates as they were constructed', function () {
         expect(right.getCoordinates()).to.eql([
@@ -332,6 +333,7 @@ describe('ol/geom/MultiPolygon.js', function () {
           [cw, ccw],
           [cw2, ccw2],
         ]);
+        expect(withEmptyPolygon.getCoordinates()).to.eql([[ccw], []]);
       });
 
       it('can return coordinates with right-hand orientation', function () {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run test-node
: '>>>>> End Test Output'
git checkout 14041e490f81796bc75cdaea07d7521f786611bd test/node/ol/format/GeoJSON.test.js test/node/ol/geom/MultiPolygon.test.js
