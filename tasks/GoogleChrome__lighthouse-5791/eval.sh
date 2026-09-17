#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 06644520f862ce6cbdbf738b8242d8071e038d6f
git checkout 06644520f862ce6cbdbf738b8242d8071e038d6f lighthouse-core/test/results/sample_v2.json && rm -f lighthouse-core/test/config/default-config-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/config/default-config-test.js b/lighthouse-core/test/config/default-config-test.js
new file mode 100644
index 000000000000..6d33a51e520b
--- /dev/null
+++ b/lighthouse-core/test/config/default-config-test.js
@@ -0,0 +1,39 @@
+/**
+ * @license Copyright 2018 Google Inc. All Rights Reserved.
+ * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
+ * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
+ */
+'use strict';
+
+const assert = require('assert');
+const lighthouse = require('../../index.js');
+const defaultConfig = require('../../config/default-config.js');
+
+/* eslint-env jest */
+
+describe('Default Config', () => {
+  it('only has opportunity audits that return opportunities details', async () => {
+    const flags = {
+      auditMode: __dirname + '/../results/artifacts/',
+    };
+    const {lhr} = await lighthouse('', flags);
+
+    const opportunityResults = lhr.categories.performance.auditRefs
+      .filter(ref => ref.group === 'load-opportunities')
+      .map(ref => lhr.audits[ref.id]);
+
+    // Check all expected opportunities were found.
+    assert.strictEqual(opportunityResults.indexOf(undefined), -1);
+    const defaultCount = defaultConfig.categories.performance.auditRefs
+      .filter(ref => ref.group === 'load-opportunities').length;
+    assert.strictEqual(opportunityResults.length, defaultCount);
+
+    // And that they have the correct shape.
+    opportunityResults.forEach(auditResult => {
+      assert.strictEqual(auditResult.details.type, 'opportunity');
+      assert.ok(!auditResult.errorMessage, `${auditResult.id}: ${auditResult.errorMessage}`);
+      assert.ok(auditResult.details.overallSavingsMs !== undefined,
+          `${auditResult.id} has an undefined overallSavingsMs`);
+    });
+  });
+});
diff --git a/lighthouse-core/test/results/sample_v2.json b/lighthouse-core/test/results/sample_v2.json
index f43191715e37..e8c0852557a0 100644
--- a/lighthouse-core/test/results/sample_v2.json
+++ b/lighthouse-core/test/results/sample_v2.json
@@ -458,12 +458,10 @@
       "rawValue": 0,
       "displayValue": "",
       "details": {
-        "type": "table",
+        "type": "opportunity",
         "headings": [],
         "items": [],
-        "summary": {
-          "wastedMs": 0
-        }
+        "overallSavingsMs": 0
       }
     },
     "webapp-install-banner": {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/config/default-config-test.js
: '>>>>> End Test Output'
git checkout 06644520f862ce6cbdbf738b8242d8071e038d6f lighthouse-core/test/results/sample_v2.json && rm -f lighthouse-core/test/config/default-config-test.js
