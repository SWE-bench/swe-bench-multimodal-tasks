#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 014359523071b86f885e87e4204f92686b55b3d6
git checkout 014359523071b86f885e87e4204f92686b55b3d6 test/spec/features/copy-paste/BpmnCopyPasteSpec.js test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js test/spec/features/rules/BpmnRulesSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/copy-paste/BpmnCopyPasteSpec.js b/test/spec/features/copy-paste/BpmnCopyPasteSpec.js
index 398fea4f15..4edfb84edb 100644
--- a/test/spec/features/copy-paste/BpmnCopyPasteSpec.js
+++ b/test/spec/features/copy-paste/BpmnCopyPasteSpec.js
@@ -71,6 +71,75 @@ describe('features/copy-paste', function() {
       }));
 
 
+      describe('should copy boundary events without host', function() {
+
+        it('should copy/paste', inject(function(elementRegistry, canvas, copyPaste) {
+
+          // given
+          var boundaryEvent = elementRegistry.get('BoundaryEvent_1'),
+              rootElement = canvas.getRootElement();
+
+          // when
+          copyPaste.copy(boundaryEvent);
+
+          var copiedElements = copyPaste.paste({
+            element: rootElement,
+            point: {
+              x: 1000,
+              y: 1000
+            }
+          });
+
+          // then
+          expect(rootElement.children).to.have.length(2);
+
+          expect(copiedElements).to.have.length(1);
+
+          expect(copiedElements[0].type).to.equal('bpmn:IntermediateCatchEvent');
+
+          expect(copiedElements[0].id).not.to.equal(boundaryEvent.id);
+        }));
+
+
+        it('should copy/paste and reattach', inject(function(elementRegistry, canvas, copyPaste) {
+
+          // given
+          var boundaryEvent = elementRegistry.get('BoundaryEvent_1'),
+              task = elementRegistry.get('Task_1'),
+              rootElement = canvas.getRootElement();
+
+          // when
+          copyPaste.copy(boundaryEvent);
+
+          var copiedElement = copyPaste.paste({
+            element: rootElement,
+            point: {
+              x: 1000,
+              y: 1000
+            }
+          })[0];
+
+          copyPaste.copy(copiedElement);
+
+          var attachedBoundaryEvent = copyPaste.paste({
+            element: task,
+            point: {
+              x: task.x,
+              y: task.y
+            },
+            hints: {
+              attach: 'attach'
+            }
+          })[0].businessObject;
+
+          // then
+          expect(attachedBoundaryEvent.attachedToRef).to.eql(task.businessObject);
+
+        }));
+
+      });
+
+
       it('should NOT override type property of descriptor', inject(function(elementRegistry) {
 
         // given
@@ -277,7 +346,7 @@ describe('features/copy-paste', function() {
 
     describe('rules', function() {
 
-      it('should NOT allow copying boundary event without host', inject(function(elementRegistry) {
+      it('should allow copying boundary event without host', inject(function(elementRegistry) {
 
         var boundaryEvent1 = elementRegistry.get('BoundaryEvent_1'),
             boundaryEvent2 = elementRegistry.get('BoundaryEvent_2');
@@ -285,7 +354,7 @@ describe('features/copy-paste', function() {
         // when
         var tree = copy([ boundaryEvent1, boundaryEvent2 ]);
 
-        expect(keys(tree)).to.have.length(0);
+        expect(keys(tree)).to.have.length(1);
       }));
 
     });
diff --git a/test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js b/test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js
index d6fc2d473f..839041591c 100644
--- a/test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js
+++ b/test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js
@@ -6,12 +6,13 @@ import {
 } from 'test/TestHelper';
 
 import modelingModule from 'lib/features/modeling';
+import copyPasteModule from 'diagram-js/lib/features/copy-paste';
 import coreModule from 'lib/core';
 
 
 describe('features/modeling/behavior - detach events', function() {
 
-  var testModules = [ coreModule, modelingModule ];
+  var testModules = [ coreModule, modelingModule, copyPasteModule ];
 
   var processDiagramXML = require('test/spec/features/rules/BpmnRules.detaching.bpmn');
 
@@ -61,6 +62,29 @@ describe('features/modeling/behavior - detach events', function() {
       expect(boundaryEvent.type).to.equal('bpmn:BoundaryEvent');
       expect(boundaryEvent.businessObject.attachedToRef).to.equal(subProcess.businessObject);
     }));
+
+
+    it('should execute on pasting a BoundaryEvent outside', inject(function(canvas, elementRegistry, copyPaste) {
+
+      // given
+      var boundaryEvent = elementRegistry.get('BoundaryEvent'),
+          root = canvas.getRootElement();
+
+      copyPaste.copy(boundaryEvent);
+
+      // when
+      var pastedElement = copyPaste.paste({
+        element: root,
+        point: {
+          x: 450,
+          y: 450
+        }
+      })[0];
+
+      // then
+      expect(pastedElement.type).to.eql('bpmn:IntermediateThrowEvent');
+    }));
+
   });
 
 
diff --git a/test/spec/features/rules/BpmnRulesSpec.js b/test/spec/features/rules/BpmnRulesSpec.js
index 40cb6473ed..55941133fa 100644
--- a/test/spec/features/rules/BpmnRulesSpec.js
+++ b/test/spec/features/rules/BpmnRulesSpec.js
@@ -183,7 +183,7 @@ describe('features/modeling/rules - BpmnRules', function() {
           boundaryEvent = elementFactory.createShape({ type: 'bpmn:BoundaryEvent', host: task });
 
       // then
-      expectCanCopy(boundaryEvent, [], false);
+      expectCanCopy(boundaryEvent, [ boundaryEvent ], true);
     }));
 
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
" test/config/karma.unit.js ; sed -i "/browsers,/a \\    customLaunchers," test/config/karma.unit.js ; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable su chromeuser -c "./node_modules/.bin/karma start test/config/karma.unit.js --no-colors"
: '>>>>> End Test Output'
git checkout 014359523071b86f885e87e4204f92686b55b3d6 test/spec/features/copy-paste/BpmnCopyPasteSpec.js test/spec/features/modeling/behavior/DetachEventBehaviorSpec.js test/spec/features/rules/BpmnRulesSpec.js
