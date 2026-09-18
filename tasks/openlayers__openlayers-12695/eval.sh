#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3004f5707fc73365f7f50af13fa60c2599ef66b4
git checkout 3004f5707fc73365f7f50af13fa60c2599ef66b4 test/browser/spec/ol/format/kml.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/format/kml.test.js b/test/browser/spec/ol/format/kml.test.js
index a1115ae986e..fc44e393055 100644
--- a/test/browser/spec/ol/format/kml.test.js
+++ b/test/browser/spec/ol/format/kml.test.js
@@ -2299,6 +2299,56 @@ describe('ol.format.KML', function () {
           expect(style.getZIndex()).to.be(undefined);
         });
 
+        it("can read a feature's IconStyle, load the image and reset the scale", function (done) {
+          format = new KML({
+            iconUrlFunction: function (href) {
+              return href.replace('http://foo/', 'spec/ol/data/');
+            },
+          });
+          const text =
+            '<kml xmlns="http://earth.google.com/kml/2.2">' +
+            '  <Placemark>' +
+            '    <Style>' +
+            '      <IconStyle>' +
+            '        <Icon>' +
+            '          <href>http://foo/dot.png</href>' +
+            '        </Icon>' +
+            '      </IconStyle>' +
+            '    </Style>' +
+            '  </Placemark>' +
+            '</kml>';
+          const fs = format.readFeatures(text);
+          expect(fs).to.have.length(1);
+          const f = fs[0];
+          expect(f).to.be.an(Feature);
+          const styleFunction = f.getStyleFunction();
+          expect(styleFunction).not.to.be(undefined);
+          const styleArray = styleFunction(f, 0);
+          expect(styleArray).to.be.an(Array);
+          expect(styleArray).to.have.length(1);
+          const style = styleArray[0];
+          expect(style).to.be.an(Style);
+          expect(style.getFill()).to.be(getDefaultFillStyle());
+          expect(style.getStroke()).to.be(getDefaultStrokeStyle());
+          const imageStyle = style.getImage();
+          expect(imageStyle).to.be.an(Icon);
+          expect(imageStyle.getSrc()).to.eql('spec/ol/data/dot.png');
+          expect(imageStyle.getAnchor()).to.be(null);
+          expect(imageStyle.getOrigin()).to.be(null);
+          expect(imageStyle.getRotation()).to.eql(0);
+          expect(imageStyle.getSize()).to.be(null);
+          expect(imageStyle.getScale()).to.be(1);
+          expect(imageStyle.getImage().crossOrigin).to.eql('anonymous');
+          expect(style.getText()).to.be(getDefaultTextStyle());
+          expect(style.getZIndex()).to.be(undefined);
+
+          setTimeout(function () {
+            expect(imageStyle.getSize()).to.eql([20, 20]);
+            expect(imageStyle.getScale()).to.be(1.6); // 32 / 20
+            done();
+          }, 200);
+        });
+
         it("can read a IconStyle's hotspot", function () {
           const text =
             '<kml xmlns="http://earth.google.com/kml/2.2">' +
@@ -2446,7 +2496,7 @@ describe('ol.format.KML', function () {
           expect(imageStyle.getAnchor()).to.eql([24, 36]);
           expect(imageStyle.getOrigin()).to.eql([24, 108]);
           expect(imageStyle.getRotation()).to.eql(0);
-          expect(imageStyle.getScale()).to.eql(3.0);
+          expect(imageStyle.getScale()).to.eql(2.0); // 3.0 * 32 / 48
           expect(style.getText()).to.be(getDefaultTextStyle());
           expect(style.getZIndex()).to.be(undefined);
         });
@@ -3027,7 +3077,7 @@ describe('ol.format.KML', function () {
             '  <Placemark>' +
             '    <Style>' +
             '      <IconStyle>' +
-            '        <scale>0.5</scale>' +
+            '        <scale>0.75</scale>' + // 0.5 * 48 / 32
             '        <heading>45</heading>' +
             '        <Icon>' +
             '          <href>http://foo.png</href>' +

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/format/kml.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/format/kml.test.js browser/spec/ol/format/kml.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 3004f5707fc73365f7f50af13fa60c2599ef66b4 test/browser/spec/ol/format/kml.test.js
