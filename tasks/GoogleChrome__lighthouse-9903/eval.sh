#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3f74f33d89eae459ac0eac81b451e65ae24941c2
git checkout 3f74f33d89eae459ac0eac81b451e65ae24941c2 lighthouse-core/test/audits/uses-rel-preconnect-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/uses-rel-preconnect-test.js b/lighthouse-core/test/audits/uses-rel-preconnect-test.js
index 07322ce44339..073e805b4720 100644
--- a/lighthouse-core/test/audits/uses-rel-preconnect-test.js
+++ b/lighthouse-core/test/audits/uses-rel-preconnect-test.js
@@ -242,12 +242,48 @@ describe('Performance: uses-rel-preconnect audit', () => {
     };
 
     const context = {settings: {}, computedCache: new Map()};
-    const {numericValue, extendedInfo} = await UsesRelPreconnect.audit(artifacts, context);
+    const {
+      numericValue,
+      extendedInfo,
+      warnings,
+    } = await UsesRelPreconnect.audit(artifacts, context);
     assert.equal(numericValue, 300);
     assert.equal(extendedInfo.value.length, 2);
     assert.deepStrictEqual(extendedInfo.value, [
       {url: 'https://othercdn.example.com', wastedMs: 300},
       {url: 'http://cdn.example.com', wastedMs: 150},
     ]);
+    assert.equal(warnings.length, 0);
+  });
+
+  it('should pass with a warning if too many preconnects found', async () => {
+    const networkRecords = [
+      mainResource,
+      {
+        url: 'http://cdn.example.com/first',
+        initiator: {},
+        startTime: 2,
+        timing: {
+          dnsStart: 100,
+          connectStart: 250,
+          connectEnd: 300,
+          receiveHeadersEnd: 2.3,
+        },
+      },
+    ];
+    const artifacts = {
+      LinkElements: [
+        {rel: 'preconnect', href: 'https://cdn1.example.com/'},
+        {rel: 'preconnect', href: 'https://cdn2.example.com/'},
+        {rel: 'preconnect', href: 'https://cdn3.example.com/'},
+      ],
+      devtoolsLogs: {[UsesRelPreconnect.DEFAULT_PASS]: networkRecordsToDevtoolsLog(networkRecords)},
+      URL: {finalUrl: mainResource.url},
+    };
+
+    const context = {settings: {}, computedCache: new Map()};
+    const result = await UsesRelPreconnect.audit(artifacts, context);
+    assert.equal(result.score, 1);
+    assert.equal(result.warnings.length, 1);
   });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/audits/uses-rel-preconnect-test.js
: '>>>>> End Test Output'
git checkout 3f74f33d89eae459ac0eac81b451e65ae24941c2 lighthouse-core/test/audits/uses-rel-preconnect-test.js
