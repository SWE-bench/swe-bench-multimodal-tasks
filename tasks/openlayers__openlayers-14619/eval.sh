#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f03524afc4f13303eb814d6aced0448dc0c5a96b
git checkout f03524afc4f13303eb814d6aced0448dc0c5a96b test/browser/spec/ol/style/icon.test.js && rm -f test/rendering/cases/icon-symbol-width-height/expected.png test/rendering/cases/icon-symbol-width-height/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/style/icon.test.js b/test/browser/spec/ol/style/icon.test.js
index 2516763a1d4..d34b0ee672f 100644
--- a/test/browser/spec/ol/style/icon.test.js
+++ b/test/browser/spec/ol/style/icon.test.js
@@ -131,6 +131,37 @@ describe('ol.style.Icon', function () {
       });
     });
 
+    it('preserves the scale', (done) => {
+      const original = new Icon({
+        src: 'spec/ol/data/dot.png',
+      });
+      original.setScale(2);
+      expect(original.getScale()).to.be(2);
+      const clone = original.clone();
+      expect(original.getScale()).to.eql(clone.getScale());
+      original.load();
+      original.getImage(1).addEventListener('load', () => {
+        const clone = original.clone();
+        expect(original.getScale()).to.eql(clone.getScale());
+        done();
+      });
+    });
+
+    it('preserves width and height', (done) => {
+      const original = new Icon({
+        src: 'spec/ol/data/dot.png',
+        width: 42,
+        height: 24,
+      });
+      const clone = original.clone();
+      clone.listenImageChange(() => {
+        expect(clone.getWidth()).to.eql(42);
+        expect(clone.getHeight()).to.eql(24);
+        done();
+      });
+      clone.load();
+    });
+
     it('the clone does not reference the same objects as the original', function () {
       const original = new Icon({
         anchor: [1, 0],
@@ -372,36 +403,36 @@ describe('ol.style.Icon', function () {
 
   describe('#width/height', function () {
     // 3px * 4px sized white gif
-    const img =
+    const src =
       'data:image/gif;base64,' +
       'R0lGODlhAwAEAIABAP7+/vDy9SH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAAEALAAAAAADAAQAAAIDhI9WADs=';
     it('scale is set correctly if configured with width only', function (done) {
       const iconStyle = new Icon({
-        src: img,
+        src,
         width: 6,
       });
       const iconImage = iconStyle.iconImage_;
       iconImage.addEventListener('change', function () {
-        expect(iconStyle.getScale()).to.eql([2, 2]);
+        expect(iconStyle.getScale()).to.eql(2);
         done();
       });
       iconStyle.load();
     });
     it('scale is set correctly if configured with height only', function (done) {
       const iconStyle = new Icon({
-        src: img,
+        src,
         height: 12,
       });
       const iconImage = iconStyle.iconImage_;
       iconImage.addEventListener('change', function () {
-        expect(iconStyle.getScale()).to.eql([3, 3]);
+        expect(iconStyle.getScale()).to.eql(3);
         done();
       });
       iconStyle.load();
     });
     it('scale is set correctly if used with width and height', function (done) {
       const iconStyle = new Icon({
-        src: img,
+        src,
         width: 6,
         height: 12,
       });
@@ -412,41 +443,31 @@ describe('ol.style.Icon', function () {
       });
       iconStyle.load();
     });
-    it('getWidth returns the expected value', function () {
+    it('getWidth returns the expected value', function (done) {
       const iconStyle = new Icon({
         src,
         width: 10,
       });
-      expect(iconStyle.getWidth()).to.eql(10);
-    });
-    it('setWidth updates the width', function () {
-      const iconStyle = new Icon({
-        src,
-        width: 10,
+      iconStyle.listenImageChange(() => {
+        expect(iconStyle.getWidth()).to.eql(10);
+        done();
       });
-      expect(iconStyle.getWidth()).to.eql(10);
-      iconStyle.setWidth(30);
-      expect(iconStyle.getWidth()).to.eql(30);
+      iconStyle.load();
     });
-    it('getHeight returns the expected value', function () {
+    it('getHeight returns the expected value', function (done) {
       const iconStyle = new Icon({
         src,
         height: 20,
       });
-      expect(iconStyle.getHeight()).to.eql(20);
-    });
-    it('setHeight updates the height', function () {
-      const iconStyle = new Icon({
-        src,
-        height: 20,
+      iconStyle.listenImageChange(() => {
+        expect(iconStyle.getHeight()).to.eql(20);
+        done();
       });
-      expect(iconStyle.getHeight()).to.eql(20);
-      iconStyle.setHeight(200);
-      expect(iconStyle.getHeight()).to.eql(200);
+      iconStyle.load();
     });
     it('setScale updates the width and height', function (done) {
       const iconStyle = new Icon({
-        src: img,
+        src,
       });
       const iconImage = iconStyle.iconImage_;
       iconImage.addEventListener('change', function () {
@@ -459,7 +480,7 @@ describe('ol.style.Icon', function () {
     });
     it('setScale with array updates the width and height', function (done) {
       const iconStyle = new Icon({
-        src: img,
+        src,
       });
       const iconImage = iconStyle.iconImage_;
       iconImage.addEventListener('change', function () {
@@ -470,5 +491,24 @@ describe('ol.style.Icon', function () {
       });
       iconStyle.load();
     });
+    it('setScale overrides initial width and height', function (done) {
+      const iconStyle = new Icon({
+        src,
+        width: 42,
+        height: 24,
+      });
+      iconStyle.setScale(1);
+      iconStyle.listenImageChange(() => {
+        try {
+          expect(iconStyle.getWidth()).to.eql(3);
+          expect(iconStyle.getHeight()).to.eql(4);
+          expect(iconStyle.getScale()).to.eql(1);
+          done();
+        } catch (e) {
+          done(e);
+        }
+      });
+      iconStyle.load();
+    });
   });
 });
diff --git a/test/rendering/cases/icon-symbol-width-height/main.js b/test/rendering/cases/icon-symbol-width-height/main.js
new file mode 100644
index 00000000000..e59b5bdf100
--- /dev/null
+++ b/test/rendering/cases/icon-symbol-width-height/main.js
@@ -0,0 +1,42 @@
+import Feature from '../../../../src/ol/Feature.js';
+import Map from '../../../../src/ol/Map.js';
+import Point from '../../../../src/ol/geom/Point.js';
+import View from '../../../../src/ol/View.js';
+import {
+  Tile as TileLayer,
+  Vector as VectorLayer,
+} from '../../../../src/ol/layer.js';
+import {Vector as VectorSource, XYZ} from '../../../../src/ol/source.js';
+import {fromLonLat} from '../../../../src/ol/proj.js';
+
+const center = fromLonLat([8.6, 50.1]);
+
+new Map({
+  layers: [
+    new TileLayer({
+      source: new XYZ({
+        url: '/data/tiles/satellite/{z}/{x}/{y}.jpg',
+      }),
+    }),
+    new VectorLayer({
+      style: {
+        'icon-src': '/data/icon.png',
+        'icon-anchor': [0.5, 46],
+        'icon-anchor-x-units': 'fraction',
+        'icon-anchor-y-units': 'pixels',
+        'icon-width': 40,
+        'icon-height': 40,
+      },
+      source: new VectorSource({
+        features: [new Feature(new Point(center))],
+      }),
+    }),
+  ],
+  target: 'map',
+  view: new View({
+    center: center,
+    zoom: 3,
+  }),
+});
+
+render();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:full\\-build|icon\\-symbol\\-width\\-height)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/style/icon.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/style/icon.test.js browser/spec/ol/style/icon.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout f03524afc4f13303eb814d6aced0448dc0c5a96b test/browser/spec/ol/style/icon.test.js && rm -f test/rendering/cases/icon-symbol-width-height/expected.png test/rendering/cases/icon-symbol-width-height/main.js
