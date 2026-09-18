#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 05d3386995543ae9bef857f49a25a39bc7e6a3a4
git checkout 05d3386995543ae9bef857f49a25a39bc7e6a3a4 test/spec/ol/extent.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/extent.test.js b/test/spec/ol/extent.test.js
index eb59120a2e0..3e12639d19c 100644
--- a/test/spec/ol/extent.test.js
+++ b/test/spec/ol/extent.test.js
@@ -1,5 +1,6 @@
 import * as _ol_extent_ from '../../../src/ol/extent.js';
 import {getTransform} from '../../../src/ol/proj.js';
+import {register} from '../../../src/ol/proj/proj4.js';
 
 
 describe('ol.extent', function() {
@@ -783,6 +784,38 @@ describe('ol.extent', function() {
       expect(destinationExtent[3]).to.be(30);
     });
 
+    it('can use the stops option', function() {
+      proj4.defs('EPSG:32632', '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs');
+      register(proj4);
+      const transformFn = getTransform('EPSG:4326', 'EPSG:32632');
+      const sourceExtentN = [6, 0, 12, 84];
+      const destinationExtentN = _ol_extent_.applyTransform(
+        sourceExtentN, transformFn);
+      expect(destinationExtentN).not.to.be(undefined);
+      expect(destinationExtentN).not.to.be(null);
+      expect(destinationExtentN[0]).to.roughlyEqual(166021.44308053964, 1e-8);
+      expect(destinationExtentN[2]).to.roughlyEqual(833978.5569194605, 1e-8);
+      expect(destinationExtentN[1]).to.roughlyEqual(0, 1e-8);
+      expect(destinationExtentN[3]).to.roughlyEqual(9329005.182447437, 1e-8);
+      const sourceExtentNS = [6, -84, 12, 84];
+      const destinationExtentNS = _ol_extent_.applyTransform(
+        sourceExtentNS, transformFn);
+      expect(destinationExtentNS).not.to.be(undefined);
+      expect(destinationExtentNS).not.to.be(null);
+      expect(destinationExtentNS[0]).to.roughlyEqual(465005.34493886377, 1e-8);
+      expect(destinationExtentNS[2]).to.roughlyEqual(534994.6550611362, 1e-8);
+      expect(destinationExtentNS[1]).to.roughlyEqual(-destinationExtentN[3], 1e-8);
+      expect(destinationExtentNS[3]).to.roughlyEqual(destinationExtentN[3], 1e-8);
+      const destinationExtentNS2 = _ol_extent_.applyTransform(
+        sourceExtentNS, transformFn, undefined, 2);
+      expect(destinationExtentNS2).not.to.be(undefined);
+      expect(destinationExtentNS2).not.to.be(null);
+      expect(destinationExtentNS2[0]).to.roughlyEqual(destinationExtentN[0], 1e-8);
+      expect(destinationExtentNS2[2]).to.roughlyEqual(destinationExtentN[2], 1e-8);
+      expect(destinationExtentNS2[1]).to.roughlyEqual(-destinationExtentN[3], 1e-8);
+      expect(destinationExtentNS2[3]).to.roughlyEqual(destinationExtentN[3], 1e-8);
+    });
+
   });
 
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/extent.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' spec/ol/extent.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 05d3386995543ae9bef857f49a25a39bc7e6a3a4 test/spec/ol/extent.test.js
