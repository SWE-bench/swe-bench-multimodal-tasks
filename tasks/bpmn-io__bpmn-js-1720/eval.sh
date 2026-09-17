#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b791a8415a5d4c313d9b327cba283d25d5c22109
git checkout b791a8415a5d4c313d9b327cba283d25d5c22109 test/spec/features/replace/BpmnReplaceSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/replace/BpmnReplaceSpec.js b/test/spec/features/replace/BpmnReplaceSpec.js
index b9f7d345c0..bc2afc2815 100644
--- a/test/spec/features/replace/BpmnReplaceSpec.js
+++ b/test/spec/features/replace/BpmnReplaceSpec.js
@@ -28,6 +28,8 @@ import {
   hasErrorEventDefinition
 } from 'lib/util/DiUtil';
 
+import { getMid } from 'diagram-js/lib/layout/LayoutUtil';
+
 
 describe('features/replace - bpmn replace', function() {
 
@@ -575,6 +577,32 @@ describe('features/replace - bpmn replace', function() {
       expect(newElement.label.y).to.equal(label.y);
     }));
 
+
+    it('should assign default size when replacing task with expanded sub process', inject(
+      function(elementRegistry, bpmnReplace) {
+
+        // given
+        var task = elementRegistry.get('Task_1');
+
+        var mid = getMid(task);
+
+        var newElementData = {
+          type: 'bpmn:SubProcess',
+          isExpanded: true
+        };
+
+        // when
+        var newElement = bpmnReplace.replaceElement(task, newElementData);
+
+        // then
+        expect(newElement).to.exist;
+        expect(is(newElement, 'bpmn:SubProcess')).to.be.true;
+        expect(getMid(newElement)).to.eql(mid);
+        expect(newElement.width).to.equal(350);
+        expect(newElement.height).to.equal(200);
+      }
+    ));
+
   });
 
 
@@ -1176,6 +1204,7 @@ describe('features/replace - bpmn replace', function() {
         expect(is(newElement, 'bpmn:CallActivity')).to.be.true;
       }));
 
+
     it('should drop event type from start event after moving it into sub process',
       inject(function(bpmnReplace, elementRegistry, modeling) {
 
@@ -1195,6 +1224,7 @@ describe('features/replace - bpmn replace', function() {
       })
     );
 
+
     it('should not drop event type from start event after moving it into event sub process',
       inject(function(bpmnReplace, elementRegistry, modeling) {
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i "s|process.env.CHROME_BIN = require('puppeteer').executablePath();|process.env.CHROME_BIN = '/usr/bin/google-chrome-stable';|" test/config/karma.unit.js ; sed -i "/module.exports = function(karma) {/i \\
var customLaunchers = { \\
  ChromeNoSandbox: { \\
    base: 'ChromeHeadless', \\
    flags: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'] \\
  } \\
}; \\
browsers = ['ChromeNoSandbox']; \\
" test/config/karma.unit.js ; sed -i "/browsers,/a \\    customLaunchers," test/config/karma.unit.js ; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable su chromeuser -c "./node_modules/.bin/karma start test/config/karma.unit.js --no-colors"
: '>>>>> End Test Output'
git checkout b791a8415a5d4c313d9b327cba283d25d5c22109 test/spec/features/replace/BpmnReplaceSpec.js
