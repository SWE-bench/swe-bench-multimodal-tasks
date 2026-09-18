#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3c90e8ef96b0a315bf78b25b29053abd87b57b27
git checkout 3c90e8ef96b0a315bf78b25b29053abd87b57b27 test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js b/test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js
index 051ddb06de..8d7691f1d7 100644
--- a/test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js
+++ b/test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js
@@ -1,8 +1,13 @@
 import {
   bootstrapModeler,
-  inject
+  inject,
+  getBpmnJS
 } from 'test/TestHelper';
 
+import {
+  query as domQuery
+} from 'min-dom';
+
 import selectionModule from 'diagram-js/lib/features/selection';
 import modelingModule from 'lib/features/modeling';
 import coreModule from 'lib/core';
@@ -42,12 +47,19 @@ describe('features/create-append-anything - editor actions', function() {
 
       // then
       expect(changedSpy).to.have.been.called;
+      expect(isMenu('bpmn-append')).to.be.true;
     }));
 
 
-    it('should not open append element if no selection', inject(function(editorActions, eventBus) {
+    it('should open create element if multiple elements selected', inject(function(elementRegistry, selection, editorActions, eventBus) {
 
       // given
+      var elementIds = [ 'StartEvent_1', 'UserTask_1' ];
+      var elements = elementIds.map(function(id) {
+        return elementRegistry.get(id);
+      });
+
+      selection.select(elements);
       var changedSpy = sinon.spy();
 
       // when
@@ -56,19 +68,33 @@ describe('features/create-append-anything - editor actions', function() {
       editorActions.trigger('appendElement', {});
 
       // then
-      expect(changedSpy).to.not.have.been.called;
+      expect(changedSpy).to.have.been.called;
+      expect(isMenu('bpmn-create')).to.be.true;
     }));
 
 
-    it('should not open append element if multiple elements selected', inject(function(elementRegistry, selection, editorActions, eventBus) {
+    it('should open create element if no selection', inject(function(elementRegistry, selection, editorActions, eventBus) {
 
       // given
-      var elementIds = [ 'StartEvent_1', 'UserTask_1' ];
-      var elements = elementIds.map(function(id) {
-        return elementRegistry.get(id);
-      });
+      var changedSpy = sinon.spy();
 
-      selection.select(elements);
+      // when
+      eventBus.once('popupMenu.open', changedSpy);
+
+      editorActions.trigger('appendElement', {});
+
+      // then
+      expect(changedSpy).to.have.been.called;
+      expect(isMenu('bpmn-create')).to.be.true;
+    }));
+
+
+    it('should open create element if append not allowed', inject(function(elementRegistry, selection, editorActions, eventBus) {
+
+      // given
+      const element = elementRegistry.get('EndEvent_1');
+
+      selection.select(element);
       var changedSpy = sinon.spy();
 
       // when
@@ -77,7 +103,8 @@ describe('features/create-append-anything - editor actions', function() {
       editorActions.trigger('appendElement', {});
 
       // then
-      expect(changedSpy).to.not.have.been.called;
+      expect(changedSpy).to.have.been.called;
+      expect(isMenu('bpmn-create')).to.be.true;
     }));
 
   });
@@ -112,3 +139,12 @@ describe('features/create-append-anything - editor actions', function() {
   });
 
 });
+
+
+// helpers //////////////////////
+function isMenu(menuId) {
+  const popup = getBpmnJS().get('popupMenu');
+  const popupElement = popup._current && domQuery('.djs-popup', popup._current.container);
+
+  return popupElement.classList.contains(menuId);
+}
\ No newline at end of file

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
git checkout 3c90e8ef96b0a315bf78b25b29053abd87b57b27 test/spec/features/create-append-anything/CreateAppendEditorActionsSpec.js
