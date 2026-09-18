#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f6587851d834c9a61fed7b2be25dbd37f78fa11d
git checkout f6587851d834c9a61fed7b2be25dbd37f78fa11d test/number-picker/index-spec.js test/select/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/number-picker/index-spec.js b/test/number-picker/index-spec.js
index 6c13565775..ee196ba7f1 100644
--- a/test/number-picker/index-spec.js
+++ b/test/number-picker/index-spec.js
@@ -318,4 +318,24 @@ describe('number-picker', () => {
             done();
         });
     });
+    describe('chrome bug hack', () => {
+        it('0.28 + 0.01 should be 0.29 not 0.29000000000000004', (done) => {
+            let onChange = (value) => {
+                    assert(value === 0.29);
+                    done();
+                },
+                wrapper = mount(<NumberPicker defaultValue={0.28} onChange={onChange} step={0.01} precision={2}/>);
+
+            wrapper.find('button').at(0).simulate('click');
+        });
+        it('0.29 - 0.01 should be 0.28 not 0.27999999999999997', (done) => {
+            let onChange = (value) => {
+                    assert(value === 0.28);
+                    done();
+                },
+                wrapper = mount(<NumberPicker defaultValue={0.29} onChange={onChange} step={0.01} precision={2}/>);
+
+            wrapper.find('button').at(1).simulate('click');
+        });
+    });
 });
diff --git a/test/select/index-spec.js b/test/select/index-spec.js
index 0460fe01a8..1b642fe9f5 100644
--- a/test/select/index-spec.js
+++ b/test/select/index-spec.js
@@ -58,6 +58,25 @@ describe('Select', () => {
         assert(wrapper.find('span.next-select em').text() === 'empty');
     });
 
+    it('should support async dataSource', () => {
+        
+        const DATASOURCE = [
+            { label: 'TT1', value: 'test1' },
+            { label: 'TT2', value: 'test2' },
+            { label: 'TT3', value: 'test3' },
+        ]
+
+        const wrapper = mount(<Select defaultValue="test2"/>);
+
+        wrapper.setProps({
+            dataSource: DATASOURCE,
+        });
+        
+        wrapper.update();
+
+        assert(wrapper.find('.next-select em').text() === 'TT2');
+    });
+
     it('should support not string value', (done) => {
         const dataSource = [{ label: 'xxx', value: 123 }, { label: 'empty', value: false }];
         const onChange = (value) => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test number-picker"' ; timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test select"'
: '>>>>> End Test Output'
git checkout f6587851d834c9a61fed7b2be25dbd37f78fa11d test/number-picker/index-spec.js test/select/index-spec.js
