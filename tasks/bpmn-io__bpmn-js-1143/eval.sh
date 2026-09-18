#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f5d55fe5dda86c96fb99507efbf859d4b6406f66
git checkout f5d55fe5dda86c96fb99507efbf859d4b6406f66 test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js b/test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js
index d76a09a626..2bf284a708 100644
--- a/test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js
+++ b/test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js
@@ -342,6 +342,39 @@ describe('features/modeling - create participant', function() {
 
     });
 
+
+    describe('fitting participant (only groups)', function() {
+
+      var processDiagramXML = require('../../../../fixtures/bpmn/collaboration/process-empty.bpmn');
+
+      beforeEach(bootstrapModeler(processDiagramXML, { modules: testModules }));
+
+      it('should fit participant', inject(
+        function(canvas, create, dragging, elementFactory, modeling) {
+
+          // given
+          var process = canvas.getRootElement(),
+              processGfx = canvas.getGraphics(process),
+              participant = elementFactory.createParticipantShape(),
+              participantBo = participant.businessObject,
+              groupElement = elementFactory.createShape({ type: 'bpmn:Group' });
+
+          modeling.createShape(groupElement, { x: 100, y: 100 }, process);
+
+          // when
+          create.start(canvasEvent({ x: 100, y: 100 }), participant);
+          dragging.hover({ element: process, gfx: processGfx });
+
+          // then
+          var defaultSize = elementFactory._getDefaultSize(participantBo);
+
+          expect(participant.width).to.equal(defaultSize.width);
+          expect(participant.height).to.equal(defaultSize.height);
+        }
+      ));
+
+    });
+
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
git checkout f5d55fe5dda86c96fb99507efbf859d4b6406f66 test/spec/features/modeling/behavior/CreateParticipantBehaviorSpec.js
