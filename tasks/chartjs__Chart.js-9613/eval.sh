#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 8d68b119bcb95af182cc69d42acad8490af53d3e
git checkout 8d68b119bcb95af182cc69d42acad8490af53d3e test/specs/core.plugin.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/core.plugin.tests.js b/test/specs/core.plugin.tests.js
index 5c1c9cccb8d..285dbab5b54 100644
--- a/test/specs/core.plugin.tests.js
+++ b/test/specs/core.plugin.tests.js
@@ -398,10 +398,10 @@ describe('Chart.plugins', function() {
       const results = [];
       const chart = window.acquireChart({
         options: {
-          events: ['mousemove', 'test', 'test2'],
+          events: ['mousemove', 'test', 'test2', 'pointerleave'],
           plugins: {
             testPlugin: {
-              events: ['test']
+              events: ['test', 'pointerleave']
             }
           }
         },
@@ -418,7 +418,8 @@ describe('Chart.plugins', function() {
       await jasmine.triggerMouseEvent(chart, 'mousemove', {x: 0, y: 0});
       await jasmine.triggerMouseEvent(chart, 'test', {x: 0, y: 0});
       await jasmine.triggerMouseEvent(chart, 'test2', {x: 0, y: 0});
-      expect(results).toEqual(['beforetest', 'aftertest']);
+      await jasmine.triggerMouseEvent(chart, 'pointerleave', {x: 0, y: 0});
+      expect(results).toEqual(['beforetest', 'aftertest', 'beforemouseout', 'aftermouseout']);
     });
   });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 8d68b119bcb95af182cc69d42acad8490af53d3e test/specs/core.plugin.tests.js
