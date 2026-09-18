#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 6eb9aceb843a43ff6ae6d6d640d22ae84c508315
git checkout 6eb9aceb843a43ff6ae6d6d640d22ae84c508315 test/spec/features/popup-menu/ReplaceMenuProviderSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/popup-menu/ReplaceMenuProviderSpec.js b/test/spec/features/popup-menu/ReplaceMenuProviderSpec.js
index c40cd8a923..eb30cf114e 100644
--- a/test/spec/features/popup-menu/ReplaceMenuProviderSpec.js
+++ b/test/spec/features/popup-menu/ReplaceMenuProviderSpec.js
@@ -511,6 +511,25 @@ describe('features/popup-menu - replace menu provider', function() {
       }));
 
 
+      it('should set loop characteristics type', inject(function(bpmnReplace, elementRegistry) {
+
+        // given
+        var task = elementRegistry.get('LoopTask'),
+            businessObject = getBusinessObject(task);
+
+        openPopup(task);
+
+        // when
+        triggerAction('toggle-parallel-mi');
+
+        // then
+        var newLoopCharacteristics = businessObject.loopCharacteristics;
+
+        expect(is(newLoopCharacteristics, 'bpmn:MultiInstanceLoopCharacteristics')).to.be.true;
+        expect(newLoopCharacteristics.isSequential).to.be.false;
+      }));
+
+
       it('should keep sequential properties', inject(function(elementRegistry) {
 
         // given
@@ -617,6 +636,25 @@ describe('features/popup-menu - replace menu provider', function() {
       }));
 
 
+      it('should set loop characteristics type', inject(function(bpmnReplace, elementRegistry) {
+
+        // given
+        var task = elementRegistry.get('LoopTask'),
+            businessObject = getBusinessObject(task);
+
+        openPopup(task);
+
+        // when
+        triggerAction('toggle-sequential-mi');
+
+        // then
+        var newLoopCharacteristics = businessObject.loopCharacteristics;
+
+        expect(is(newLoopCharacteristics, 'bpmn:MultiInstanceLoopCharacteristics')).to.be.true;
+        expect(newLoopCharacteristics.isSequential).to.be.true;
+      }));
+
+
       it('should keep parallel properties', inject(function(elementRegistry) {
 
         // given
@@ -720,6 +758,25 @@ describe('features/popup-menu - replace menu provider', function() {
         // then
         expect(domClasses(parallelEntry).has('active')).to.be.false;
       }));
+
+
+      it('should set loop characteristics type', inject(function(bpmnReplace, elementRegistry) {
+
+        // given
+        var task = elementRegistry.get('SequentialTask'),
+            businessObject = getBusinessObject(task);
+
+        openPopup(task);
+
+        // when
+        triggerAction('toggle-loop');
+
+        // then
+        var newLoopCharacteristics = businessObject.loopCharacteristics;
+
+        expect(is(newLoopCharacteristics, 'bpmn:StandardLoopCharacteristics')).to.be.true;
+        expect(newLoopCharacteristics.isSequential).to.be.undefined;
+      }));
     });
 
   });

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
git checkout 6eb9aceb843a43ff6ae6d6d640d22ae84c508315 test/spec/features/popup-menu/ReplaceMenuProviderSpec.js
