#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 7ffb922b1911e6db114f21d92f37a63f835ba3b7
rm -f lighthouse-core/test/lib/stack-collector-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/lib/stack-collector-test.js b/lighthouse-core/test/lib/stack-collector-test.js
new file mode 100644
index 000000000000..758593788210
--- /dev/null
+++ b/lighthouse-core/test/lib/stack-collector-test.js
@@ -0,0 +1,33 @@
+/**
+ * @license Copyright 2020 Google Inc. All Rights Reserved.
+ * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
+ * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
+ */
+'use strict';
+
+/* eslint-env jest */
+
+const collectStacks = require('../../lib/stack-collector.js');
+
+describe('stack collector', () => {
+  /** @type {{driver: {evaluateAsync: jest.Mock}}} */
+  let passContext;
+
+  beforeEach(() => {
+    passContext = {driver: {evaluateAsync: jest.fn()}};
+  });
+
+  it('returns the detected stacks', async () => {
+    passContext.driver.evaluateAsync.mockResolvedValue([
+      {id: 'jquery', name: 'jQuery', version: '2.1.0', npm: 'jquery'},
+      {id: 'angular', name: 'Angular', version: '', npm: ''},
+      {id: 'magento', name: 'Magento', version: 2},
+    ]);
+
+    expect(await collectStacks(passContext)).toEqual([
+      {detector: 'js', id: 'jquery', name: 'jQuery', npm: 'jquery', version: '2.1.0'},
+      {detector: 'js', id: 'angular', name: 'Angular', npm: undefined, version: undefined},
+      {detector: 'js', id: 'magento', name: 'Magento', npm: undefined, version: '2'},
+    ]);
+  });
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/lib/stack-collector-test.js
: '>>>>> End Test Output'
rm -f lighthouse-core/test/lib/stack-collector-test.js
