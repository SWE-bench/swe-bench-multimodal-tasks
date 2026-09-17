#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f93b366fbe6238b0b27218fc659eb3c735c44e10
git checkout f93b366fbe6238b0b27218fc659eb3c735c44e10 test/tab/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/tab/index-spec.js b/test/tab/index-spec.js
index 2dc19c8176..7c8796bdfb 100644
--- a/test/tab/index-spec.js
+++ b/test/tab/index-spec.js
@@ -195,13 +195,12 @@ describe('Tab', () => {
 
         it('should support device', () => {
             wrapper = mount(<Tab>{panes}</Tab>);
-            assert(wrapper.find('.next-tabs-scrollable').length === 0);
+            assert(wrapper.find('.next-tabs-scrollable').length > 0);
             assert(wrapper.find(TabNav).prop('excessMode') === 'slide');
             wrapper.setProps({
-                device: 'phone'
+                excessMode: 'dropdown'
             });
             assert(wrapper.find('.next-tabs-scrollable').length > 0);
-            assert(wrapper.find(TabNav).prop('excessMode') === 'slide');
         })
     });
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test tab"'
: '>>>>> End Test Output'
git checkout f93b366fbe6238b0b27218fc659eb3c735c44e10 test/tab/index-spec.js
