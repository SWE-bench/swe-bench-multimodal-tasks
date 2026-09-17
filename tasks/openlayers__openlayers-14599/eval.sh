#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b7b14a86da4792739a3de49c9a5fbb42147178b4
git checkout b7b14a86da4792739a3de49c9a5fbb42147178b4 test/browser/spec/ol/layer/Layer.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/layer/Layer.test.js b/test/browser/spec/ol/layer/Layer.test.js
index 7ff79d6fb58..b18c718def4 100644
--- a/test/browser/spec/ol/layer/Layer.test.js
+++ b/test/browser/spec/ol/layer/Layer.test.js
@@ -491,11 +491,26 @@ describe('ol/layer/Layer', function () {
       layer.setMinZoom(2);
       expect(layer.isVisible(view)).to.be(false);
     });
+
+    it('works without arguments on layers that are in a map', function () {
+      new Map({
+        view: view,
+        layers: [layer],
+      });
+      expect(layer.isVisible()).to.be(true);
+    });
+
+    it('throws when called without arguments', function () {
+      expect(() => layer.isVisible()).to.throwException();
+    });
   });
 
   describe('#getAttributions', function () {
     const attributions = ['foo'];
-    let layer, view;
+    /** @type {Layer} */
+    let layer;
+    /** @type {View} */
+    let view;
 
     beforeEach(function () {
       layer = new Layer({
@@ -519,6 +534,14 @@ describe('ol/layer/Layer', function () {
       layer.setVisible(false);
       expect(layer.getAttributions(view)).to.eql([]);
     });
+
+    it('returns an empty array when the layer is in a hidden group', function () {
+      new Map({
+        layers: [new Group({layers: [layer], visible: false})],
+        view: view,
+      });
+      expect(layer.getAttributions()).to.eql([]);
+    });
   });
 
   describe('#getSource', function () {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/layer/Layer.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/layer/Layer.test.js browser/spec/ol/layer/Layer.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout b7b14a86da4792739a3de49c9a5fbb42147178b4 test/browser/spec/ol/layer/Layer.test.js
