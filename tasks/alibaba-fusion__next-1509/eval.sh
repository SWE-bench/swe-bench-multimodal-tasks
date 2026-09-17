#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2471fee5c1fbf3d6172ae699f1d33a28ddf74892
git checkout 2471fee5c1fbf3d6172ae699f1d33a28ddf74892 test/dialog/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/dialog/index-spec.js b/test/dialog/index-spec.js
index 28af09cc60..103fa72bdc 100644
--- a/test/dialog/index-spec.js
+++ b/test/dialog/index-spec.js
@@ -431,6 +431,22 @@ describe('inner', () => {
         }, 1000);
     });
 
+    it('should work when set <ConfigProvider popupContainer/> ', () => {
+
+        wrapper = render(<ConfigProvider popupContainer={"dialog-popupcontainer"}>
+        <div id="dialog-popupcontainer" style={{height: 300, overflow: 'auto'}}>
+            <Dialog
+                title="Welcome to Alibaba.com"
+                visible>
+                Start your business here by searching a popular product
+            </Dialog>
+        </div>
+        </ConfigProvider>);
+
+        const overlay = document.querySelector('#dialog-popupcontainer > .next-overlay-wrapper');
+        assert(overlay);
+    });
+
     it('should not close dialog if onOk return promise and reject', done => {
         const { hide } = Dialog.show({
             title: 'Title',

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test dialog"'
: '>>>>> End Test Output'
git checkout 2471fee5c1fbf3d6172ae699f1d33a28ddf74892 test/dialog/index-spec.js
