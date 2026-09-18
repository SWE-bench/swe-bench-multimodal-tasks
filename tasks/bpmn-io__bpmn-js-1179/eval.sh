#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c9e9f002c9248c2b6fe2b3b1668447d01a69d054
git checkout c9e9f002c9248c2b6fe2b3b1668447d01a69d054 test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js b/test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js
index 4392f998a0..e98675d5e3 100644
--- a/test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js
+++ b/test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js
@@ -17,6 +17,8 @@ import {
   createCanvasEvent as canvasEvent
 } from '../../../../util/MockEvents';
 
+import { getMid } from 'diagram-js/lib/layout/LayoutUtil';
+
 
 describe('modeling/behavior - drop on connection', function() {
 
@@ -60,7 +62,6 @@ describe('modeling/behavior - drop on connection', function() {
           );
 
           // then
-
           var targetConnection = newShape.outgoing[0];
 
           // new incoming connection
@@ -215,6 +216,62 @@ describe('modeling/behavior - drop on connection', function() {
         }
       ));
 
+
+      it('should handle shape created with bounds', inject(
+        function(elementFactory, elementRegistry, modeling) {
+
+          // given
+          var intermediateThrowEvent = elementFactory.createShape({
+            type: 'bpmn:IntermediateThrowEvent'
+          });
+
+          var startEvent = elementRegistry.get('StartEvent'),
+              sequenceFlow = elementRegistry.get('SequenceFlow_1'),
+              task = elementRegistry.get('Task_1');
+
+          var originalWaypoints = sequenceFlow.waypoints;
+
+          var dropBounds = { x: 322, y: 102, width: 36, height: 36 }; // first bendpoint
+
+          // when
+          var newShape = modeling.createShape(
+            intermediateThrowEvent,
+            dropBounds,
+            sequenceFlow
+          );
+
+          // then
+          var targetConnection = newShape.outgoing[0];
+
+          // new incoming connection
+          expect(newShape.incoming.length).to.equal(1);
+          expect(newShape.incoming[0]).to.eql(sequenceFlow);
+
+          // new outgoing connection
+          expect(newShape.outgoing.length).to.equal(1);
+          expect(targetConnection).to.exist;
+          expect(targetConnection.type).to.equal('bpmn:SequenceFlow');
+
+          expect(startEvent.outgoing[0]).to.equal(newShape.incoming[0]);
+          expect(task.incoming[1]).to.equal(newShape.outgoing[0]);
+
+          // split target at insertion point
+          expect(sequenceFlow).to.have.waypoints(flatten([
+            originalWaypoints.slice(0, 1),
+            { x: 322, y: 120 }
+          ]));
+
+          expect(sequenceFlow).to.have.endDocking(getMid(dropBounds));
+
+          expect(targetConnection).to.have.waypoints(flatten([
+            { x: 340, y: 138 },
+            originalWaypoints.slice(2)
+          ]));
+
+          expect(targetConnection).to.have.startDocking(getMid(dropBounds));
+        }
+      ));
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
git checkout c9e9f002c9248c2b6fe2b3b1668447d01a69d054 test/spec/features/modeling/behavior/DropOnFlowBehaviorSpec.js
