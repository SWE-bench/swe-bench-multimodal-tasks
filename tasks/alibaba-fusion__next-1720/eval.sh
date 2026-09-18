#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4117dadf3858a64fb23d0020d3f468afa1d7fc87
git checkout 4117dadf3858a64fb23d0020d3f468afa1d7fc87 test/search/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/search/index-spec.js b/test/search/index-spec.js
index 53b8b03729..bce0973d90 100644
--- a/test/search/index-spec.js
+++ b/test/search/index-spec.js
@@ -140,6 +140,42 @@ describe('Search', () => {
             done();
         });
 
+        it('should support onChange/onSearch ', done => {
+            let dataSource = [
+                {
+                    label: 'AAAAA',
+                    value: 'AAAAA',
+                },
+                {
+                    label: 'AAAAA12345',
+                    value: 'AAAAA12345',
+                },
+                {
+                    label: 'CCCC',
+                    value: 'CCCC',
+                },
+            ];
+
+            const FILTER_INDEX = 1;
+            const onSearch = value => {
+                assert(value === 'AAAAA');
+                done();
+            };
+
+            wrapper = mount(
+                <Search
+                    dataSource={dataSource}
+                    onSearch={onSearch}
+                />
+            );
+            // 点击
+            wrapper.find('.next-search input').simulate('click');
+            wrapper.find('.next-search input').simulate('change', { target: { value: 'A' } });
+            wrapper.update();
+            
+            wrapper.find('input').simulate('keydown', { keyCode: 13 });
+        });
+
         it('should support filter ', done => {
             let filter = [
                 {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test search"'
: '>>>>> End Test Output'
git checkout 4117dadf3858a64fb23d0020d3f468afa1d7fc87 test/search/index-spec.js
