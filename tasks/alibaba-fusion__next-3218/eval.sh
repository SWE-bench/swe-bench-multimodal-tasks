#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 47fd0fc7bfd2472b48432b8fdda8c77c1f7dbac4
git checkout 47fd0fc7bfd2472b48432b8fdda8c77c1f7dbac4 test/input/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/input/index-spec.js b/test/input/index-spec.js
index a6b0958bc9..a1e512b0fd 100644
--- a/test/input/index-spec.js
+++ b/test/input/index-spec.js
@@ -108,6 +108,26 @@ describe('input', () => {
             assert(onCompositionEnd.calledOnce);
             assert(onChange.calledOnce);
         });
+
+        it('Navitve onCompositionStart/onCompositionUpdate/onCompositionEnd events', () => {
+            const onCompositionStart = sinon.spy();
+            const onCompositionUpdate = sinon.spy();
+            const onCompositionEnd = sinon.spy();
+            const wrapper = mount(
+                <Input
+                    onCompositionStart={onCompositionStart}
+                    onCompositionUpdate={onCompositionUpdate}
+                    onCompositionEnd={onCompositionEnd}
+                />
+            );
+            wrapper.find('input').simulate('compositionstart', { target: { value: 'zh' } });
+            assert(onCompositionStart.calledOnce);
+            wrapper.find('input').simulate('compositionupdate', { target: { value: 'zhon' } });
+            assert(onCompositionUpdate.calledOnce);
+            wrapper.find('input').simulate('compositionend', { target: { value: '中' } });
+            assert(onCompositionEnd.calledOnce);
+        });
+
         it('should support onChange', done => {
             let onChange = value => {
                     assert(value === '20');

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test input"'
: '>>>>> End Test Output'
git checkout 47fd0fc7bfd2472b48432b8fdda8c77c1f7dbac4 test/input/index-spec.js
