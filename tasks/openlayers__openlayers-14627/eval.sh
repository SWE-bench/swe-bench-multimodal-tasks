#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 309ca077a36338c8bfc4874b437ce794afd48dcb
git checkout 309ca077a36338c8bfc4874b437ce794afd48dcb test/node/ol/extent.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/node/ol/extent.test.js b/test/node/ol/extent.test.js
index 6313c2c0581..b9812ef1ff6 100644
--- a/test/node/ol/extent.test.js
+++ b/test/node/ol/extent.test.js
@@ -781,6 +781,27 @@ describe('ol/extent.js', function () {
   });
 
   describe('#applyTransform()', function () {
+    it('returns empty for empty extents', function () {
+      const transformFn = getTransform('EPSG:4326', 'EPSG:3857');
+      const emptyExtent = _ol_extent_.createEmpty();
+      const destEmpty = _ol_extent_.applyTransform(emptyExtent, transformFn);
+      expect(destEmpty).to.eql(emptyExtent);
+
+      const extentDeltaXNeg = [45, 67, 44, 78];
+      const destDeltaXNeg = _ol_extent_.applyTransform(
+        extentDeltaXNeg,
+        transformFn
+      );
+      expect(destDeltaXNeg).to.eql(emptyExtent);
+
+      const extentDeltaYNeg = [11, 67, 44, 66];
+      const destDeltaYNeg = _ol_extent_.applyTransform(
+        extentDeltaYNeg,
+        transformFn
+      );
+      expect(destDeltaYNeg).to.eql(emptyExtent);
+    });
+
     it('does transform', function () {
       const transformFn = getTransform('EPSG:4326', 'EPSG:3857');
       const sourceExtent = [-15, -30, 45, 60];
@@ -797,6 +818,21 @@ describe('ol/extent.js', function () {
       expect(destinationExtent[3]).to.roughlyEqual(8399737.889818361, 1e-8);
     });
 
+    it('does not treat a single point as empty', function () {
+      const transformFn = getTransform('EPSG:4326', 'EPSG:3857');
+      const sourceExtent = _ol_extent_.boundingExtent([[45, 60]]);
+      const destinationExtent = _ol_extent_.applyTransform(
+        sourceExtent,
+        transformFn
+      );
+      expect(destinationExtent).not.to.be(undefined);
+      expect(destinationExtent).not.to.be(null);
+      expect(destinationExtent[0]).to.roughlyEqual(5009377.085697311, 1e-9);
+      expect(destinationExtent[2]).to.eql(destinationExtent[0]);
+      expect(destinationExtent[1]).to.roughlyEqual(8399737.889818361, 1e-8);
+      expect(destinationExtent[3]).to.eql(destinationExtent[1]);
+    });
+
     it('takes arbitrary function', function () {
       const transformFn = function (input, output, opt_dimension) {
         const dimension = opt_dimension !== undefined ? opt_dimension : 2;

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run test-node
: '>>>>> End Test Output'
git checkout 309ca077a36338c8bfc4874b437ce794afd48dcb test/node/ol/extent.test.js
