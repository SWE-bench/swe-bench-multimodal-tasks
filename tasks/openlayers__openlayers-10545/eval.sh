#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2f094978ca934fe2d165abfa7272987a0ab0d4c8
git checkout 2f094978ca934fe2d165abfa7272987a0ab0d4c8 test/spec/ol/format/kml.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/format/kml.test.js b/test/spec/ol/format/kml.test.js
index 3109c682805..6f4e2fe2d6c 100644
--- a/test/spec/ol/format/kml.test.js
+++ b/test/spec/ol/format/kml.test.js
@@ -2238,7 +2238,7 @@ describe('ol.format.KML', function() {
             expect(style.getZIndex()).to.be(undefined);
           });
 
-        it('can create text style for named point placemarks', function() {
+        it('can create text style for named point placemarks (including html character codes)', function() {
           const text =
               '<kml xmlns="http://www.opengis.net/kml/2.2"' +
               ' xmlns:gx="http://www.google.com/kml/ext/2.2"' +
@@ -2266,7 +2266,7 @@ describe('ol.format.KML', function() {
               '    </Pair>' +
               '  </StyleMap>' +
               '  <Placemark>' +
-              '    <name>Test</name>' +
+              '    <name>Joe&apos;s Test</name>' +
               '    <styleUrl>#msn_ylw-pushpin0</styleUrl>' +
               '    <Point>' +
               '      <coordinates>1,2</coordinates>' +
@@ -2279,61 +2279,9 @@ describe('ol.format.KML', function() {
           expect(f).to.be.an(Feature);
           const styleFunction = f.getStyleFunction();
           expect(styleFunction).not.to.be(undefined);
-          const styleArray = styleFunction(f, 0);
-          expect(styleArray).to.be.an(Array);
-          expect(styleArray).to.have.length(2);
-          const style = styleArray[1];
-          expect(style).to.be.an(Style);
-          expect(style.getText().getText()).to.eql(f.getProperties()['name']);
-        });
-
-        it('can create text style for named point placemarks', function() {
-          const text =
-              '<kml xmlns="http://www.opengis.net/kml/2.2"' +
-              ' xmlns:gx="http://www.google.com/kml/ext/2.2"' +
-              ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
-              ' xsi:schemaLocation="http://www.opengis.net/kml/2.2' +
-              ' https://developers.google.com/kml/schema/kml22gx.xsd">' +
-              '  <Style id="sh_ylw-pushpin">' +
-              '    <IconStyle>' +
-              '      <scale>0.3</scale>' +
-              '      <Icon>' +
-              '        <href>http://maps.google.com/mapfiles/kml/pushpin/' +
-              'ylw-pushpin.png</href>' +
-              '      </Icon>' +
-              '      <hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>' +
-              '    </IconStyle>' +
-              '  </Style>' +
-              '  <StyleMap id="msn_ylw-pushpin0">' +
-              '    <Pair>' +
-              '      <key>normal</key>' +
-              '      <styleUrl>#sn_ylw-pushpin</styleUrl>' +
-              '    </Pair>' +
-              '    <Pair>' +
-              '      <key>highlight</key>' +
-              '      <styleUrl>#sh_ylw-pushpin</styleUrl>' +
-              '    </Pair>' +
-              '  </StyleMap>' +
-              '  <Placemark>' +
-              '    <name>Test</name>' +
-              '    <styleUrl>#msn_ylw-pushpin0</styleUrl>' +
-              '    <Point>' +
-              '      <coordinates>1,2</coordinates>' +
-              '    </Point>' +
-              '  </Placemark>' +
-              '</kml>';
-          const fs = format.readFeatures(text);
-          expect(fs).to.have.length(1);
-          const f = fs[0];
-          expect(f).to.be.an(Feature);
-          const styleFunction = f.getStyleFunction();
-          expect(styleFunction).not.to.be(undefined);
-          const styleArray = styleFunction(f, 0);
-          expect(styleArray).to.be.an(Array);
-          expect(styleArray).to.have.length(2);
-          const style = styleArray[1];
+          const style = styleFunction(f, 0);
           expect(style).to.be.an(Style);
-          expect(style.getText().getText()).to.eql(f.getProperties()['name']);
+          expect(style.getText().getText()).to.eql('Joe\'s Test');
         });
 
         it('can write an feature\'s icon style', function() {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/format/kml.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/format/kml.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 2f094978ca934fe2d165abfa7272987a0ab0d4c8 test/spec/ol/format/kml.test.js
