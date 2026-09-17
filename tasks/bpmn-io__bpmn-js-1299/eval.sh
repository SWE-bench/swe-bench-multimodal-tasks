#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9c114de26a5cb8eec3470cf1da1d00362d3d79f9
git checkout 9c114de26a5cb8eec3470cf1da1d00362d3d79f9 test/spec/features/modeling/UpdateLabelSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/modeling/UpdateLabelSpec.js b/test/spec/features/modeling/UpdateLabelSpec.js
index 6f8259d4a3..8c39be936e 100644
--- a/test/spec/features/modeling/UpdateLabelSpec.js
+++ b/test/spec/features/modeling/UpdateLabelSpec.js
@@ -50,6 +50,27 @@ describe('features/modeling - update label', function() {
   ));
 
 
+  it('should not create label on empty text', inject(
+    function(modeling, elementRegistry) {
+
+      // given
+      var startEvent_2 = elementRegistry.get('StartEvent_2');
+
+      // when
+      modeling.updateLabel(startEvent_2, '');
+
+      // then
+      expect(startEvent_2.businessObject.name).to.equal('');
+      expect(startEvent_2.label).not.to.exist;
+
+      expect(startEvent_2).to.have.dimensions({
+        width: 36,
+        height: 36
+      });
+    }
+  ));
+
+
   describe('should delete label', function() {
 
     it('when setting null', inject(

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
git checkout 9c114de26a5cb8eec3470cf1da1d00362d3d79f9 test/spec/features/modeling/UpdateLabelSpec.js
