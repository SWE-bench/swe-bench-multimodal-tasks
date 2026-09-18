#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b439bf2fd866c0c0a4d62043e959555d432d2c52
git checkout b439bf2fd866c0c0a4d62043e959555d432d2c52 lighthouse-core/test/lib/minification-estimator-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/lib/minification-estimator-test.js b/lighthouse-core/test/lib/minification-estimator-test.js
index 1ea303a6d339..bc6ea7877fa5 100644
--- a/lighthouse-core/test/lib/minification-estimator-test.js
+++ b/lighthouse-core/test/lib/minification-estimator-test.js
@@ -214,6 +214,15 @@ describe('minification estimator', () => {
       assert.equal(computeJSTokenLength(js), 9);
     });
 
+    it('should handle regex as switch case clause edge cases', () => {
+      const js = `
+        switch(true){case/^hello!/.test("hello!"):"///123456789"}
+      `;
+
+      assert.equal(computeJSTokenLength(js), 57);
+      assert.equal(computeJSTokenLength(js), js.trim().length);
+    });
+
     it('should handle large, real, unminified javscript files', () => {
       assert.equal(angularJs.length, 1374505);
       const minificationPct = 1 - computeJSTokenLength(angularJs) / angularJs.length;

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/lib/minification-estimator-test.js
: '>>>>> End Test Output'
git checkout b439bf2fd866c0c0a4d62043e959555d432d2c52 lighthouse-core/test/lib/minification-estimator-test.js
