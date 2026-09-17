#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a52378e3a288ff5aba6ed1f85be03ed2a5d3f0a4
git checkout a52378e3a288ff5aba6ed1f85be03ed2a5d3f0a4 lighthouse-core/test/gather/gatherers/start-url-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/gather/gatherers/start-url-test.js b/lighthouse-core/test/gather/gatherers/start-url-test.js
index 6b2503bdf327..fb97d016460e 100644
--- a/lighthouse-core/test/gather/gatherers/start-url-test.js
+++ b/lighthouse-core/test/gather/gatherers/start-url-test.js
@@ -7,7 +7,6 @@
 
 /* eslint-env mocha */
 
-const URL = require('../../../lib/url-shim');
 const StartUrlGatherer = require('../../../gather/gatherers/start-url');
 const assert = require('assert');
 const tracingData = require('../../fixtures/traces/network-records.json');
@@ -24,37 +23,7 @@ const mockDriver = {
 
 const wrapSendCommand = (mockDriver, url) => {
   mockDriver = Object.assign({}, mockDriver);
-  mockDriver.evaluateAsync = () => {
-    url = new URL(url);
-    url.hash = '';
-
-    const record = findRequestByUrl(url.href);
-    if (!record) {
-      return Promise.reject(-1);
-    }
-
-    return Promise.resolve(record.statusCode);
-  };
-
-  mockDriver.on = (name, cb) => {
-    if (name === 'Network.requestWillBeSent') {
-      cb({
-        request: {
-          url,
-          requestId: 1,
-        },
-      });
-    }
-
-    if (name === 'Network.loadingFinished') {
-      cb({
-        request: {
-          url,
-          requestId: 1,
-        },
-      });
-    }
-  };
+  mockDriver.evaluateAsync = () => Promise.resolve();
 
   mockDriver.getAppManifest = () => {
     return Promise.resolve({
@@ -67,10 +36,6 @@ const wrapSendCommand = (mockDriver, url) => {
   return mockDriver;
 };
 
-const findRequestByUrl = (url) => {
-  return tracingData.networkRecords.find(record => record._url === url);
-};
-
 describe('Start-url gatherer', () => {
   it('returns an artifact set to -1 when offline loading fails', () => {
     const startUrlGatherer = new StartUrlGatherer();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/gather/gatherers/start-url-test.js
: '>>>>> End Test Output'
git checkout a52378e3a288ff5aba6ed1f85be03ed2a5d3f0a4 lighthouse-core/test/gather/gatherers/start-url-test.js
