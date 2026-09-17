#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff fcc451dc9bbfb99fc31e00329deac454b5b47a87
git checkout fcc451dc9bbfb99fc31e00329deac454b5b47a87 test/transfer/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/transfer/index-spec.js b/test/transfer/index-spec.js
index b7ca4061e2..7a96c9b75a 100644
--- a/test/transfer/index-spec.js
+++ b/test/transfer/index-spec.js
@@ -153,6 +153,42 @@ describe('Transfer', () => {
         assert(findItemText(wrapper, 0, 1) === 'abc');
     });
 
+    it('should render search box when set showSearch（array）', () => {
+        const dataSource = [
+            { label: 'a', value: '0' },
+            { label: 'b', value: '1' },
+            { label: <i>abc</i>, value: '2' },
+        ];
+
+        wrapper = mount(
+            <Transfer
+                showSearch={[true, false]}
+                searchProps={[
+                    {
+                        hasClear: true
+                    },
+                    {
+                        size: 'large'
+                    }
+                ]}
+                searchPlaceholder="input something..."
+                dataSource={dataSource}
+            />
+        );
+
+        assert(wrapper.find('span.next-search').length === 1);
+        const search = findPanel(wrapper, 0).find('span.next-search');
+        const input = search.find('input');
+        if (input.instance().placeholder) {
+            assert(input.instance().placeholder === 'input something...');
+        }
+        input.simulate('change', { target: { value: 'a' } });
+
+        assert(findItems(wrapper, 0).length === 2);
+        assert(findItemText(wrapper, 0, 0) === 'a');
+        assert(findItemText(wrapper, 0, 1) === 'abc');
+    });
+
     it('should custom style and text', () => {
         const dataSource = [
             {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test transfer"'
: '>>>>> End Test Output'
git checkout fcc451dc9bbfb99fc31e00329deac454b5b47a87 test/transfer/index-spec.js
