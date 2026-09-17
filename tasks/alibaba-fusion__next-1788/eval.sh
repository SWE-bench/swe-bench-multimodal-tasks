#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 167adb2904f5be7111e0ab1360c03db54f74c972
git checkout 167adb2904f5be7111e0ab1360c03db54f74c972 test/select/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/select/index-spec.js b/test/select/index-spec.js
index 23e7dedafa..5fe9748344 100644
--- a/test/select/index-spec.js
+++ b/test/select/index-spec.js
@@ -88,6 +88,29 @@ describe('Select', () => {
         assert(wrapper.find('.next-select em').text() === 'TT2');
     });
 
+    it('should support custom title', () => {
+        const dataSource = [
+            { label: 'xxx', value: 'yyy', title: "abc" },
+            { label: 'empty ', value: ' ', title: "" },
+            { label: 'empty undefined', value: 'undefined', title: undefined },
+            { label: 'empty null', value: 'null', title: null },
+        ];
+        wrapper.setProps({
+            dataSource,
+            visible: true,
+        });
+        assert(document.querySelectorAll('.next-menu-item').length === 4);
+        ReactTestUtils.Simulate.click(
+            document.querySelectorAll('.next-menu-item')[0]
+        );
+        wrapper.update();
+
+        assert(wrapper.find('ul li').at(0).instance().title === 'abc');
+        assert(wrapper.find('ul li').at(1).instance().title === '');
+        assert(wrapper.find('ul li').at(2).instance().title === '');
+        assert(wrapper.find('ul li').at(3).instance().title === '');
+    });
+
     it('should change display text while choose item and change dataSource', () => {
         const dataSource = ['abc', 'bbb'];
         class App extends React.Component {
@@ -455,7 +478,7 @@ describe('Select', () => {
 
         wrapper.find('div.next-tag .next-tag-close-btn').first().simulate('click');
     });
-    
+
     it('should support mode=tag with visible=false', done => {
         wrapper.setProps({
             mode: 'tag',

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test select"'
: '>>>>> End Test Output'
git checkout 167adb2904f5be7111e0ab1360c03db54f74c972 test/select/index-spec.js
