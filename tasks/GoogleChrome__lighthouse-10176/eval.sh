#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a5dbdd2eff4238213dcaad404d0e06d8d5d2489b
git checkout a5dbdd2eff4238213dcaad404d0e06d8d5d2489b lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js lighthouse-core/test/audits/dobetterweb/js-libraries-test.js lighthouse-core/test/results/artifacts/artifacts.json lighthouse-core/test/results/sample_v2.json
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js b/lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js
index d40c2a7d806e..5889a1a872d1 100644
--- a/lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js
+++ b/lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js
@@ -377,9 +377,6 @@ const expectations = [
             items: [{
               name: 'jQuery',
             },
-            {
-              name: 'jQuery (Fast path)',
-            },
             {
               name: 'WordPress',
             }],
diff --git a/lighthouse-core/test/audits/dobetterweb/js-libraries-test.js b/lighthouse-core/test/audits/dobetterweb/js-libraries-test.js
index 52958dcbefcd..374a461f369b 100644
--- a/lighthouse-core/test/audits/dobetterweb/js-libraries-test.js
+++ b/lighthouse-core/test/audits/dobetterweb/js-libraries-test.js
@@ -20,8 +20,8 @@ describe('Returns detected front-end JavaScript libraries', () => {
     // duplicates. TODO: consider failing in this case
     const auditResult2 = JsLibrariesAudit.audit({
       Stacks: [
-        {detector: 'js', name: 'lib1', version: '3.10.1', npm: 'lib1'},
-        {detector: 'js', name: 'lib2', version: undefined, npm: 'lib2'},
+        {detector: 'js', id: 'lib1', name: 'lib1', version: '3.10.1', npm: 'lib1'},
+        {detector: 'js', id: 'lib2', name: 'lib2', version: undefined, npm: 'lib2'},
       ],
     });
     assert.equal(auditResult2.score, 1);
@@ -29,11 +29,11 @@ describe('Returns detected front-end JavaScript libraries', () => {
     // LOTS of frontend libs
     const auditResult3 = JsLibrariesAudit.audit({
       Stacks: [
-        {detector: 'js', name: 'React', version: undefined, npm: 'react'},
-        {detector: 'js', name: 'Polymer', version: undefined, npm: 'polymer-core'},
-        {detector: 'js', name: 'Preact', version: undefined, npm: 'preact'},
-        {detector: 'js', name: 'Angular', version: undefined, npm: 'angular'},
-        {detector: 'js', name: 'jQuery', version: undefined, npm: 'jquery'},
+        {detector: 'js', id: 'react', name: 'React', version: undefined, npm: 'react'},
+        {detector: 'js', id: 'polymer', name: 'Polymer', version: undefined, npm: 'polymer-core'},
+        {detector: 'js', id: 'preact', name: 'Preact', version: undefined, npm: 'preact'},
+        {detector: 'js', id: 'angular', name: 'Angular', version: undefined, npm: 'angular'},
+        {detector: 'js', id: 'jquery', name: 'jQuery', version: undefined, npm: 'jquery'},
       ],
     });
     assert.equal(auditResult3.score, 1);
@@ -42,8 +42,9 @@ describe('Returns detected front-end JavaScript libraries', () => {
   it('generates expected details', () => {
     const auditResult = JsLibrariesAudit.audit({
       Stacks: [
-        {detector: 'js', name: 'lib1', version: '3.10.1', npm: 'lib1'},
-        {detector: 'js', name: 'lib2', version: undefined, npm: 'lib2'},
+        {detector: 'js', id: 'lib1', name: 'lib1', version: '3.10.1', npm: 'lib1'},
+        {detector: 'js', id: 'lib2', name: 'lib2', version: undefined, npm: 'lib2'},
+        {detector: 'js', id: 'lib2-fast', name: 'lib2', version: undefined, npm: 'lib2'},
       ],
     });
     const expected = [
@@ -60,5 +61,9 @@ describe('Returns detected front-end JavaScript libraries', () => {
     ];
     assert.equal(auditResult.score, 1);
     assert.deepStrictEqual(auditResult.details.items, expected);
+    assert.deepStrictEqual(auditResult.details.debugData.stacks[2], {
+      id: 'lib2-fast',
+      version: undefined,
+    });
   });
 });
diff --git a/lighthouse-core/test/results/artifacts/artifacts.json b/lighthouse-core/test/results/artifacts/artifacts.json
index 94d4a323ee5b..23e6702e3c3a 100644
--- a/lighthouse-core/test/results/artifacts/artifacts.json
+++ b/lighthouse-core/test/results/artifacts/artifacts.json
@@ -1840,7 +1840,7 @@
     },
     {
       "detector": "js",
-      "id": "jquery",
+      "id": "jquery-fast",
       "name": "jQuery (Fast path)",
       "npm": "jquery"
     },
diff --git a/lighthouse-core/test/results/sample_v2.json b/lighthouse-core/test/results/sample_v2.json
index b8713c091f3a..bafb171f09ca 100644
--- a/lighthouse-core/test/results/sample_v2.json
+++ b/lighthouse-core/test/results/sample_v2.json
@@ -2989,15 +2989,26 @@
             "version": "2.1.1",
             "npm": "jquery"
           },
-          {
-            "name": "jQuery (Fast path)",
-            "npm": "jquery"
-          },
           {
             "name": "WordPress"
           }
         ],
-        "summary": {}
+        "summary": {},
+        "debugData": {
+          "type": "debugdata",
+          "stacks": [
+            {
+              "id": "jquery",
+              "version": "2.1.1"
+            },
+            {
+              "id": "jquery-fast"
+            },
+            {
+              "id": "wordpress"
+            }
+          ]
+        }
       }
     },
     "notification-on-start": {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/audits/dobetterweb/js-libraries-test.js
: '>>>>> End Test Output'
git checkout a5dbdd2eff4238213dcaad404d0e06d8d5d2489b lighthouse-cli/test/smokehouse/test-definitions/dobetterweb/dbw-expectations.js lighthouse-core/test/audits/dobetterweb/js-libraries-test.js lighthouse-core/test/results/artifacts/artifacts.json lighthouse-core/test/results/sample_v2.json
