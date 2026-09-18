#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b0e33f7df5df1b911bffcc82c1fb60bc54eeb00a
git checkout b0e33f7df5df1b911bffcc82c1fb60bc54eeb00a test/date-picker2/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/date-picker2/index-spec.js b/test/date-picker2/index-spec.js
index ecae6a46f9..e609356ef1 100644
--- a/test/date-picker2/index-spec.js
+++ b/test/date-picker2/index-spec.js
@@ -412,6 +412,55 @@ describe('Picker', () => {
             );
         });
 
+        it('format', () => {
+            wrapper = mount(
+                <DatePicker
+                    defaultValue={defaultVal}
+                    defaultVisible
+                    format={v => `Custom: ${v.format('YYYY/MM/DD')}`}
+                    onChange={(v, vStr) => assert(vStr === 'Custom: 2020/12/14')}
+                />
+            );
+            assert(getStrValue() === 'Custom: 2020/12/12');
+            clickDate('2020-12-14');
+            assert(getStrValue() === 'Custom: 2020/12/14');
+            wrapper.unmount();
+
+            // RangePicker
+            wrapper = mount(
+                <RangePicker
+                    defaultValue={defaultRangeVal}
+                    defaultVisible
+                    format="x"
+                    onChange={(v, strVal) =>
+                        assert.deepEqual(strVal, [dayjs('2020-12-12').format('x'), dayjs('2020-12-14').format('x')])
+                    }
+                />
+            );
+            clickDate('2020-12-12');
+            clickDate('2020-12-14');
+            assert.deepEqual(getStrValue(), [dayjs('2020-12-12').format('x'), dayjs('2020-12-14').format('x')]);
+            wrapper.unmount();
+
+            // RangePicker outputFormat array
+            wrapper = mount(
+                <RangePicker
+                    showTime
+                    defaultValue={defaultRangeVal}
+                    defaultVisible
+                    format={['YYYY', v => v.valueOf()]}
+                    onChange={(v, strVal) =>
+                        assert.deepEqual(strVal, [dayjs('2020-12-12').format('YYYY'), dayjs('2020-12-14').format('x')])
+                    }
+                />
+            );
+            clickDate('2020-12-12');
+            clickOk();
+            clickDate('2020-12-14');
+            clickOk();
+            wrapper.unmount();
+        });
+
         it('outputFormat', () => {
             wrapper = mount(
                 <DatePicker
@@ -434,7 +483,6 @@ describe('Picker', () => {
 
             clickDate('2020-12-12');
             clickOk();
-
             wrapper.unmount();
 
             // RangePicker
@@ -450,6 +498,24 @@ describe('Picker', () => {
             );
             clickDate('2020-12-12');
             clickDate('2020-12-14');
+            wrapper.unmount();
+
+            // RangePicker outputFormat array
+            wrapper = mount(
+                <RangePicker
+                    showTime
+                    defaultValue={defaultRangeVal}
+                    defaultVisible
+                    outputFormat={['YYYY', v => v.valueOf()]}
+                    onChange={v =>
+                        assert.deepEqual(v, [dayjs('2020-12-12').format('YYYY'), dayjs('2020-12-14').format('x')])
+                    }
+                />
+            );
+            clickDate('2020-12-12');
+            clickOk();
+            clickDate('2020-12-14');
+            clickOk();
         });
     });
 
@@ -903,6 +969,30 @@ describe('Picker', () => {
             clickOk();
             assert.deepEqual(getStrValue(), ['', '2021-01-12 09:00:00']);
         });
+
+        // https://github.com/alibaba-fusion/next/issues/3186
+        it('fix panelValue', () => {
+            wrapper = mount(<RangePicker visible defaultPanelValue={defaultVal} />);
+            findInput(0).simulate('focus');
+            findInput(1).simulate('focus');
+            assert(findDate('2021-01-31').length);
+        });
+
+        it('should support value empty when showTime', () => {
+            wrapper = mount(
+                <div>
+                    <RangePicker visible showTime defaultPanelValue={defaultVal} />
+                    <button id="test">Blank Area</button>
+                </div>
+            );
+            findDate('2020-12-12').simulate('click');
+            clickTime('12');
+            clickTime('12', 'minute');
+            clickTime('12', 'second');
+            clickOk();
+            wrapper.find('#test').simulate('click');
+            assert.deepEqual(getStrValue(), ['2020-12-12 12:12:12', '']);
+        });
     });
 });
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test date-picker2"'
: '>>>>> End Test Output'
git checkout b0e33f7df5df1b911bffcc82c1fb60bc54eeb00a test/date-picker2/index-spec.js
