#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 599f7c1e4633f747de0aabd12dfb9635fa0ebfb4
git checkout 599f7c1e4633f747de0aabd12dfb9635fa0ebfb4 test/message/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/message/index-spec.js b/test/message/index-spec.js
index 058ffa4e44..065f20787b 100644
--- a/test/message/index-spec.js
+++ b/test/message/index-spec.js
@@ -144,7 +144,21 @@ describe('Message', () => {
 });
 
 describe('toast', done => {
-    it('should render message when only pass content string', () => {
+    it('should render nowrap message when content too long[Overlay case]', (done) => {
+        const content = 'content content content content content content content content content content content content content content content content content content content content';
+        Message.show(content);
+
+        const dom = document.querySelector('.next-overlay-wrapper .next-message');
+
+        assert(dom.innerText.trim() === content);
+        assert(dom.offsetWidth > 200);
+
+        Message.hide();
+
+        setTimeout(done, 500);
+    });
+
+    it('should render message when only pass content string', (done) => {
         Message.show('content');
         assert(
             document
@@ -152,14 +166,11 @@ describe('toast', done => {
                 .innerText.trim() === 'content'
         );
 
-        setTimeout(() => {
-            Message.hide();
-        }, 500);
-
-        setTimeout(done, 1000);
+        Message.hide();
+        setTimeout(done, 500);
     });
 
-    it('should render message when only pass content react element', () => {
+    it('should render message when only pass content react element', (done) => {
         Message.show(<i>content</i>);
         assert(
             document
@@ -167,14 +178,12 @@ describe('toast', done => {
                 .innerText.trim() === 'content'
         );
 
-        setTimeout(() => {
-            Message.hide();
-        }, 500);
+        Message.hide();
 
-        setTimeout(done, 1000);
+        setTimeout(done, 500);
     });
 
-    it('should render message when pass config object', () => {
+    it('should render message when pass config object', (done) => {
         Message.show({
             type: 'warning',
             content: 'content',
@@ -187,11 +196,8 @@ describe('toast', done => {
                 .innerText.trim() === 'content'
         );
 
-        setTimeout(() => {
-            Message.hide();
-        }, 500);
-
-        setTimeout(done, 1000);
+        Message.hide();
+        setTimeout(done, 500);
     });
 
     it('should close message after duration and call afterClose method', done => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test message"'
: '>>>>> End Test Output'
git checkout 599f7c1e4633f747de0aabd12dfb9635fa0ebfb4 test/message/index-spec.js
