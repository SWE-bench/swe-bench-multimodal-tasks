#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 36e4f6113c5fc1e826894244c6da39636b75861c
git checkout 36e4f6113c5fc1e826894244c6da39636b75861c test/spec/features/rules/BpmnRules.boundaryEvent.bpmn test/spec/features/rules/BpmnRulesSpec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/features/rules/BpmnRules.boundaryEvent.bpmn b/test/spec/features/rules/BpmnRules.boundaryEvent.bpmn
index f736123557..192224ea93 100644
--- a/test/spec/features/rules/BpmnRules.boundaryEvent.bpmn
+++ b/test/spec/features/rules/BpmnRules.boundaryEvent.bpmn
@@ -18,6 +18,9 @@
     <bpmn:boundaryEvent id="BoundaryEvent_on_Task" attachedToRef="Task" />
     <bpmn:startEvent id="StartEvent_None" />
     <bpmn:exclusiveGateway id="ExclusiveGateway" />
+    <bpmn:boundaryEvent id="MessageBoundaryEvent_onSubProcess" attachedToRef="SubProcess">
+      <bpmn:messageEventDefinition id="MessageEventDefinition_1owasie" />
+    </bpmn:boundaryEvent>
   </bpmn:process>
   <bpmn:process id="OtherProcess">
     <bpmn:task id="Task_in_OtherProcess" name="3" />
@@ -88,6 +91,9 @@
           <dc:Bounds x="474" y="275" width="90" height="20" />
         </bpmndi:BPMNLabel>
       </bpmndi:BPMNShape>
+      <bpmndi:BPMNShape id="MessageBoundaryEvent_onSubProcess_di" bpmnElement="MessageBoundaryEvent_onSubProcess">
+        <dc:Bounds x="362" y="204" width="36" height="36" />
+      </bpmndi:BPMNShape>
     </bpmndi:BPMNPlane>
   </bpmndi:BPMNDiagram>
 </bpmn:definitions>
diff --git a/test/spec/features/rules/BpmnRulesSpec.js b/test/spec/features/rules/BpmnRulesSpec.js
index 3d4f9d7080..4d9000440f 100644
--- a/test/spec/features/rules/BpmnRulesSpec.js
+++ b/test/spec/features/rules/BpmnRulesSpec.js
@@ -663,6 +663,17 @@ describe('features/modeling/rules - BpmnRules', function() {
     }));
 
 
+    it('connect Task_in_OtherProcess -> MessageBoundaryEvent_onSubProcess', inject(function() {
+
+      expectCanConnect('Task_in_OtherProcess', 'MessageBoundaryEvent_onSubProcess', {
+        sequenceFlow: false,
+        messageFlow: true,
+        association: false,
+        dataAssociation: false
+      });
+    }));
+
+
     it('drop BoundaryEvent -> Task', function() {
       expectCanDrop('BoundaryEvent_on_SubProcess', 'Task_in_OtherProcess', false);
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
git checkout 36e4f6113c5fc1e826894244c6da39636b75861c test/spec/features/rules/BpmnRules.boundaryEvent.bpmn test/spec/features/rules/BpmnRulesSpec.js
