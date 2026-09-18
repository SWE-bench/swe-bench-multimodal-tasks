#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5b1670f520138ffbca7ce36e7bc9c6de9390d4f2
git checkout 5b1670f520138ffbca7ce36e7bc9c6de9390d4f2 test/unit/util/drag-recognizer.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/util/drag-recognizer.test.js b/test/unit/util/drag-recognizer.test.js
index 825917ba8ed..643ded52815 100644
--- a/test/unit/util/drag-recognizer.test.js
+++ b/test/unit/util/drag-recognizer.test.js
@@ -56,6 +56,17 @@ describe('DragRecognizer', () => {
         expect(onDrag).toHaveBeenCalledTimes(1); // Still 1
     });
 
+    test('start -> end calls dragEnd callback after resetting internal state', done => {
+        onDragEnd = () => {
+            expect(dragRecognizer.gestureInProgress()).toBe(false);
+            done();
+        };
+        dragRecognizer = new DragRecognizer({onDrag, onDragEnd});
+        dragRecognizer.start({clientX: 100, clientY: 100});
+        window.dispatchEvent(new MouseEvent('touchmove', {clientX: 150, clientY: 106}));
+        window.dispatchEvent(new MouseEvent('touchend', {clientX: 150, clientY: 106}));
+    });
+
     test('start -> reset unbinds', () => {
         dragRecognizer.start({clientX: 100, clientY: 100});
         window.dispatchEvent(new MouseEvent('touchmove', {clientX: 150, clientY: 106}));

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/util/drag-recognizer.test.js
: '>>>>> End Test Output'
git checkout 5b1670f520138ffbca7ce36e7bc9c6de9390d4f2 test/unit/util/drag-recognizer.test.js
