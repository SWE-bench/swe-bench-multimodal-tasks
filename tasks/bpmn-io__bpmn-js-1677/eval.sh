#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff ee75929dd1e9bbb5c6ba5ce5c4475008b354a825
git checkout ee75929dd1e9bbb5c6ba5ce5c4475008b354a825 test/spec/features/label-editing/LabelEditingProviderSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/label-editing/LabelEditingProviderSpec.js b/test/spec/features/label-editing/LabelEditingProviderSpec.js
index 4678b85299..37aaef0a5d 100644
--- a/test/spec/features/label-editing/LabelEditingProviderSpec.js
+++ b/test/spec/features/label-editing/LabelEditingProviderSpec.js
@@ -205,12 +205,33 @@ describe('features - label-editing', function() {
 
 
     it('should cancel on element deletion', inject(
+      function(elementRegistry, directEditing, modeling) {
+
+        // given
+        var shape = elementRegistry.get('Task_1'),
+            task = shape.businessObject;
+
+        directEditing.activate(shape);
+
+        directEditing._textbox.content.textContent = 'FOO BAR';
+
+        // when
+        modeling.removeElements([ shape ]);
+
+        // then
+        expect(task.name).not.to.equal('FOO BAR');
+      }
+    ));
+
+
+    it('should cancel on selected element deletion', inject(
       function(elementRegistry, directEditing, selection, modeling) {
 
         // given
         var shape = elementRegistry.get('Task_1'),
             task = shape.businessObject;
 
+        selection.select(shape);
         directEditing.activate(shape);
 
         directEditing._textbox.content.textContent = 'FOO BAR';

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
git checkout ee75929dd1e9bbb5c6ba5ce5c4475008b354a825 test/spec/features/label-editing/LabelEditingProviderSpec.js
