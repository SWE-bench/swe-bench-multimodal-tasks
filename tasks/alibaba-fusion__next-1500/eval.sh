#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2a59086de41e312a5ce65deb4685625116b641f0
git checkout 2a59086de41e312a5ce65deb4685625116b641f0 test/overlay/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/overlay/index-spec.js b/test/overlay/index-spec.js
index e3eb7afc21..a27ada1578 100644
--- a/test/overlay/index-spec.js
+++ b/test/overlay/index-spec.js
@@ -414,6 +414,35 @@ describe('Overlay', () => {
         assert(content.textContent.trim() === 'content');
     });
 
+    it('should support autoFit', () => {
+        wrapper = render(
+            <div style={{width: 300, height: 100, position: 'relative', overflow: 'auto'}}>
+                <div style={{height: 200, width: 500}}>
+                    <Popup animation={false} container={node => node.parentNode} autoFit trigger={<button id="overlay-autofit-btn" style={{margin: 220, marginRight: 0, height: 25}}>Use Down Arrow to open</button>} triggerType="click" triggerClickKeycode={40}>
+                        <span id="overlay-autofit-wrapper" style={{width: 120, height: 70, background: 'purple'}}>
+                            Hello
+                        </span>
+                    </Popup>
+                    <div style={{height: 50, width: 10}}/>
+                </div>
+            </div>
+        );
+
+        wrapper.instance().scrollTop = 220;
+        document.getElementById('overlay-autofit-btn').click();
+        assert(document.getElementById('overlay-autofit-wrapper').style.top === '245px');
+
+        document.body.click();
+        wrapper.instance().scrollTop = 140;
+        document.getElementById('overlay-autofit-btn').click();
+        assert(document.getElementById('overlay-autofit-wrapper').style.top === '150px');
+
+        document.body.click();
+        wrapper.instance().scrollTop = 170;
+        document.getElementById('overlay-autofit-btn').click();
+        assert(document.getElementById('overlay-autofit-wrapper').style.top === '170px');
+    });
+
     it('should support onClick', (done) => {
         const handleClick = (e) => {
             assert('target' in e);
@@ -446,7 +475,7 @@ describe('Overlay', () => {
         );
 
         simulateEvent.simulate(document.querySelector('.content'), 'click');
-        
+
         setTimeout(() => {
             done();
         }, 1000);
@@ -638,6 +667,37 @@ describe('Popup', () => {
         });
     });
 
+    it('should support setting custom container', () => {
+        return co(function*() {
+            wrapper = render(
+                <div id="myContainer">
+                    <Popup
+                        trigger={<button>Open</button>}
+                        triggerType="click"
+                        container={'myContainer'}
+                        canCloseByTrigger={false}
+                    >
+                        <span className="content">Hello World From Popup!</span>
+                    </Popup>
+                </div>
+            );
+
+            const btn = document.querySelector('button');
+
+            ReactTestUtils.Simulate.click(btn);
+            yield delay(300);
+
+            assert(
+                document.querySelector('.next-overlay-wrapper').parentElement
+                    .id === 'myContainer'
+            );
+
+            ReactTestUtils.Simulate.click(btn);
+            yield delay(300);
+            assert(document.querySelector('.next-overlay-wrapper'));
+        });
+    });
+
     it('should support controling', () => {
         return co(function*() {
             wrapper = render(<PopupControlDemo />);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test overlay"'
: '>>>>> End Test Output'
git checkout 2a59086de41e312a5ce65deb4685625116b641f0 test/overlay/index-spec.js
