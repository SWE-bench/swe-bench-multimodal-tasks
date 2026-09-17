#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 47c2bc5d96d87f121a0ada42ddf60090f98a6339
git checkout 47c2bc5d96d87f121a0ada42ddf60090f98a6339 lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js lighthouse-core/test/computed/load-simulator-test.js lighthouse-core/test/computed/resource-summary-test.js lighthouse-core/test/lib/network-request-test.js lighthouse-core/test/lib/url-shim-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js b/lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js
index b6573156989c..684bc5fccb31 100644
--- a/lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js
+++ b/lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js
@@ -97,13 +97,14 @@ describe('Render blocking resources audit', () => {
 
     beforeEach(() => {
       requestId = 1;
+      const scheme = 'http';
       const protocol = 'http';
       record = props => {
-        const parsedURL = {host: 'example.com', securityOrigin: 'http://example.com'};
+        const parsedURL = {host: 'example.com', scheme, securityOrigin: 'http://example.com'};
         return Object.assign({parsedURL, requestId: requestId++}, props, {protocol});
       };
       recordSlow = props => {
-        const parsedURL = {host: 'slow.com', securityOrigin: 'http://slow.com'};
+        const parsedURL = {host: 'slow.com', scheme, securityOrigin: 'http://slow.com'};
         return Object.assign({parsedURL, requestId: requestId++}, props, {protocol});
       };
     });
diff --git a/lighthouse-core/test/computed/load-simulator-test.js b/lighthouse-core/test/computed/load-simulator-test.js
index 9344223b1099..329b71b6d4b4 100644
--- a/lighthouse-core/test/computed/load-simulator-test.js
+++ b/lighthouse-core/test/computed/load-simulator-test.js
@@ -16,7 +16,7 @@ function createNetworkNode() {
   return new NetworkNode({
     requestId: '1',
     protocol: 'http',
-    parsedURL: {securityOrigin: 'https://pwa.rocks'},
+    parsedURL: {scheme: 'http', securityOrigin: 'https://pwa.rocks'},
   });
 }
 
diff --git a/lighthouse-core/test/computed/resource-summary-test.js b/lighthouse-core/test/computed/resource-summary-test.js
index 48e2eee2b12e..f5030d76a4c7 100644
--- a/lighthouse-core/test/computed/resource-summary-test.js
+++ b/lighthouse-core/test/computed/resource-summary-test.js
@@ -12,10 +12,6 @@ const networkRecordsToDevtoolsLog = require('../network-records-to-devtools-log.
 /* eslint-env jest */
 
 function mockArtifacts(networkRecords) {
-  for (const record of networkRecords) {
-    record.protocol = record.url.slice(0, record.url.indexOf(':'));
-  }
-
   return {
     devtoolsLog: networkRecordsToDevtoolsLog(networkRecords),
     URL: {requestedUrl: networkRecords[0].url, finalUrl: networkRecords[0].url},
@@ -54,18 +50,12 @@ describe('Resource summary computed', () => {
   });
 
   it('sets "other" resource metrics correctly', async () => {
-    // networkRecordsToDevToolsLog errors with an 'other' resource type, so this test does not use it
-    const networkRecords = [
+    artifacts = mockArtifacts([
       {url: 'http://example.com/file.html', resourceType: 'Document', transferSize: 30},
-      {url: 'http://third-party.com/another-file.html', resourceType: 'manifest', transferSize: 50},
-    ];
-
-    for (const record of networkRecords) {
-      record.protocol = record.url.slice(0, record.url.indexOf(':'));
-    }
+      {url: 'http://third-party.com/another-file.html', resourceType: 'Manifest', transferSize: 50},
+    ]);
+    const result = await ComputedResourceSummary.request(artifacts, context);
 
-    const result = ComputedResourceSummary.summarize(
-      networkRecords, networkRecords[0].url, artifacts.budgets);
     assert.equal(result.other.count, 1);
     assert.equal(result.other.transferSize, 50);
   });
diff --git a/lighthouse-core/test/lib/network-request-test.js b/lighthouse-core/test/lib/network-request-test.js
index 1c926f196f93..015c7df2f31e 100644
--- a/lighthouse-core/test/lib/network-request-test.js
+++ b/lighthouse-core/test/lib/network-request-test.js
@@ -346,4 +346,23 @@ describe('NetworkRequest', () => {
       })).toBe(true);
     });
   });
+
+  describe('#isNonNetworkRequest', () => {
+    const isNonNetworkRequest = NetworkRequest.isNonNetworkRequest;
+
+    it('correctly identifies non-network records', () => {
+      // data protocol
+      expect(isNonNetworkRequest({protocol: 'data'})).toBe(true);
+
+      // filesystem scheme
+      expect(isNonNetworkRequest({protocol: '', parsedURL: {scheme: 'file'}})).toBe(true);
+    });
+
+    it('correctly identifies network records', () => {
+      expect(isNonNetworkRequest({
+        protocol: 'h2',
+        parsedURL: {scheme: 'http', host: 'google.com'},
+      })).toBe(false);
+    });
+  });
 });
diff --git a/lighthouse-core/test/lib/url-shim-test.js b/lighthouse-core/test/lib/url-shim-test.js
index 258eb5b9526a..a5c1ad9fceb2 100644
--- a/lighthouse-core/test/lib/url-shim-test.js
+++ b/lighthouse-core/test/lib/url-shim-test.js
@@ -330,8 +330,11 @@ describe('URL Shim', () => {
     assert.ok(URL.isNonNetworkProtocol('data'));
     assert.ok(URL.isNonNetworkProtocol('data:'));
     assert.ok(URL.isNonNetworkProtocol('intent:'));
+    assert.ok(URL.isNonNetworkProtocol('file:'));
+    assert.ok(URL.isNonNetworkProtocol('filesystem:'));
+    assert.ok(URL.isNonNetworkProtocol('filesystem'));
 
-    assert.ok(!URL.isNonNetworkProtocol('filesystem'));
+    assert.ok(!URL.isNonNetworkProtocol('https:'));
     assert.ok(!URL.isNonNetworkProtocol('http'));
     assert.ok(!URL.isNonNetworkProtocol('ws'));
   });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js lighthouse-core/test/computed/load-simulator-test.js lighthouse-core/test/computed/resource-summary-test.js lighthouse-core/test/lib/network-request-test.js lighthouse-core/test/lib/url-shim-test.js
: '>>>>> End Test Output'
git checkout 47c2bc5d96d87f121a0ada42ddf60090f98a6339 lighthouse-core/test/audits/byte-efficiency/render-blocking-resources-test.js lighthouse-core/test/computed/load-simulator-test.js lighthouse-core/test/computed/resource-summary-test.js lighthouse-core/test/lib/network-request-test.js lighthouse-core/test/lib/url-shim-test.js
