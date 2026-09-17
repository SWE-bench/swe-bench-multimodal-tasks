#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 04abd786b732ffde9ed5a847a2abd00d94aea86c
git checkout 04abd786b732ffde9ed5a847a2abd00d94aea86c test/tree-select/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/tree-select/index-spec.js b/test/tree-select/index-spec.js
index cf300eb31e..8b26a474e6 100644
--- a/test/tree-select/index-spec.js
+++ b/test/tree-select/index-spec.js
@@ -730,6 +730,21 @@ describe('TreeSelect', () => {
         }, 2000);
     });
 
+    it('should support single line display', () => {
+        wrapper = mount(
+            <TreeSelect
+                dataSource={dataSource}
+                treeCheckable
+                treeCheckStrictly
+                treeCheckedStrategy="all"
+                tagInline
+                value={['1', '2', '3']}
+            />
+        )
+
+        assert(wrapper.find('.next-select-tag-compact').length > 0);
+        assert(wrapper.find('.next-select-tag-compact').text().includes('3/6'));
+    })
 });
 
 function cloneData(data, valueMap = {}) {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test tree-select"'
: '>>>>> End Test Output'
git checkout 04abd786b732ffde9ed5a847a2abd00d94aea86c test/tree-select/index-spec.js
