#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8196c63beb5a1c68950211e6313fc37f081f43f3
git checkout 8196c63beb5a1c68950211e6313fc37f081f43f3 test/number-picker/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/number-picker/index-spec.js b/test/number-picker/index-spec.js
index d71916d869..89f689eb6a 100644
--- a/test/number-picker/index-spec.js
+++ b/test/number-picker/index-spec.js
@@ -21,6 +21,14 @@ describe('number-picker', () => {
             const wrapper = mount(<NumberPicker type="inline" />);
             assert(wrapper.props().type === 'inline');
         });
+        it('should not tab trigger ', () => {
+            const wrapper = mount(<NumberPicker />);
+            const wrapper1 = mount(<NumberPicker type="inline" />);
+            assert(wrapper.find('button').at(0).prop("tabIndex") === -1);
+            assert(wrapper.find('button').at(1).prop("tabIndex") === -1);
+            assert(wrapper1.find('button').at(0).prop("tabIndex") === -1);
+            assert(wrapper1.find('button').at(1).prop("tabIndex") === -1);
+        });
     });
 
     describe('behavior', () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test number-picker"'
: '>>>>> End Test Output'
git checkout 8196c63beb5a1c68950211e6313fc37f081f43f3 test/number-picker/index-spec.js
