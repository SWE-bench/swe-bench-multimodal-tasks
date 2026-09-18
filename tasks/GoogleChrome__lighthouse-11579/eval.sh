#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 960d2e37a85e16462a00c0a3a596b86da3debb7a
git checkout 960d2e37a85e16462a00c0a3a596b86da3debb7a lighthouse-core/test/runner-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/runner-test.js b/lighthouse-core/test/runner-test.js
index 598c9f6c7d01..c4f98e8af070 100644
--- a/lighthouse-core/test/runner-test.js
+++ b/lighthouse-core/test/runner-test.js
@@ -786,7 +786,7 @@ describe('Runner', () => {
 
       // And it bubbled up to the runtimeError.
       expect(lhr.runtimeError.code).toEqual(NO_FCP.code);
-      expect(lhr.runtimeError.message).toBeDisplayString(/Something .*\(NO_FCP\)/);
+      expect(lhr.runtimeError.message).toBeDisplayString(/did not paint any content.*\(NO_FCP\)/);
     });
 
     it('includes a pageLoadError runtimeError over any gatherer runtimeErrors', async () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/runner-test.js
: '>>>>> End Test Output'
git checkout 960d2e37a85e16462a00c0a3a596b86da3debb7a lighthouse-core/test/runner-test.js
