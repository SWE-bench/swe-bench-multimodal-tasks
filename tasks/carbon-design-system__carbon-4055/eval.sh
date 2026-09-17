#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a1a564eb39927460dc3ec5a5f3129519d5d73519
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout a1a564eb39927460dc3ec5a5f3129519d5d73519 packages/react/src/components/Tile/Tile-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/Tile/Tile-test.js b/packages/react/src/components/Tile/Tile-test.js
index 60d2ba279a32..4c5fcae8d346 100644
--- a/packages/react/src/components/Tile/Tile-test.js
+++ b/packages/react/src/components/Tile/Tile-test.js
@@ -6,7 +6,6 @@
  */
 
 import React from 'react';
-import { ChevronDown16 } from '@carbon/icons-react';
 import {
   Tile,
   ClickableTile,
@@ -230,13 +229,13 @@ describe('Tile', () => {
       expect(wrapper.state().expanded).toEqual(false);
     });
 
-    it('displays the default tooltip for the chevron depending on state', () => {
-      const defaultExpandedIconText = 'Collapse';
-      const defaultCollapsedIconText = 'Expand';
+    it('displays the default tooltip for the button depending on state', () => {
+      const defaultExpandedIconText = 'Interact to collapse Tile';
+      const defaultCollapsedIconText = 'Interact to expand Tile';
 
       // Force the expanded tile to be collapsed.
       wrapper.setState({ expanded: false });
-      const collapsedDescription = wrapper.find(ChevronDown16).getElements()[0]
+      const collapsedDescription = wrapper.find('button').getElements()[0]
         .props['aria-label'];
       expect(collapsedDescription).toEqual(defaultCollapsedIconText);
 
@@ -244,12 +243,13 @@ describe('Tile', () => {
       wrapper.simulate('click');
 
       // Validate the description change
-      const expandedDescription = wrapper.find(ChevronDown16).getElements()[0]
-        .props['aria-label'];
+      const expandedDescription = wrapper.find('button').getElements()[0].props[
+        'aria-label'
+      ];
       expect(expandedDescription).toEqual(defaultExpandedIconText);
     });
 
-    it('displays the custom tooltips for the chevron depending on state', () => {
+    it('displays the custom tooltips for the button depending on state', () => {
       const tileExpandedIconText = 'Click To Collapse';
       const tileCollapsedIconText = 'Click To Expand';
 
@@ -258,7 +258,7 @@ describe('Tile', () => {
 
       // Force the expanded tile to be collapsed.
       wrapper.setState({ expanded: false });
-      const collapsedDescription = wrapper.find(ChevronDown16).getElements()[0]
+      const collapsedDescription = wrapper.find('button').getElements()[0]
         .props['aria-label'];
       expect(collapsedDescription).toEqual(tileCollapsedIconText);
 
@@ -266,8 +266,9 @@ describe('Tile', () => {
       wrapper.simulate('click');
 
       // Validate the description change
-      const expandedDescription = wrapper.find(ChevronDown16).getElements()[0]
-        .props['aria-label'];
+      const expandedDescription = wrapper.find('button').getElements()[0].props[
+        'aria-label'
+      ];
       expect(expandedDescription).toEqual(tileExpandedIconText);
     });
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
rm -rf -- .achecker.yml .aat.yml && cp /opt/achecker-offline/.achecker.yml .achecker.yml && cp /opt/achecker-offline/.achecker.yml .aat.yml
for checker_dir in node_modules/@ibma/aat node_modules/accessibility-checker config/jest-config-carbon/node_modules/@ibma/aat config/jest-config-carbon/node_modules/accessibility-checker; do if [ -d "$checker_dir" ]; then find "$checker_dir" -type f \( -name AATMetricsLogger.js -o -name ACMetricsLogger.js \) -exec sed -i -e 's#http:/[/]ibmac96.austin.ibm.com/cgi-bin/log-cio/log.py#http://127.0.0.1:18080/tools/api/pub/meter/v2#g' -e 's#https:/[/]able.ibm.com/tools#http://127.0.0.1:18080/tools#g' {} +; fi; done
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost" no_proxy="${no_proxy:+$no_proxy,}127.0.0.1,localhost"
node -e 'var fs=require("fs"),http=require("http"),path=require("path"),url=require("url");var root="/opt/achecker-offline",port=18080,engineBase="/archives/2020.10.07/js/";http.createServer(function(request,response){response.setHeader("Access-Control-Allow-Origin","*");var pathname=decodeURIComponent(url.parse(request.url).pathname);if(pathname==="/tools/api/pub/meter/v2"){response.statusCode=204;response.end();return;}var legacyBrowserEngine=false;if(pathname===engineBase+"awe-node.js"){pathname=engineBase+"ace-node.js";}else if(pathname===engineBase+"awe.js"){pathname=engineBase+"ace.js";legacyBrowserEngine=true;}var filename=path.resolve(root,"."+pathname);if(filename.indexOf(root+path.sep)!==0){response.statusCode=403;response.end("forbidden");return;}if(/\.json$/.test(filename)){response.setHeader("Content-Type","application/json");}else if(/\.js$/.test(filename)){response.setHeader("Content-Type","application/javascript");}if(legacyBrowserEngine){fs.readFile(filename,function(error,contents){if(error){response.statusCode=404;response.end("not found");return;}response.end(Buffer.concat([contents,Buffer.from("\n;window.IBMAwe=ace;\n")]));});return;}var stream=fs.createReadStream(filename);stream.on("error",function(){if(!response.headersSent){response.statusCode=404;}response.end("not found");});stream.pipe(response);}).listen(port,"127.0.0.1");' > /tmp/achecker-offline-server.log 2>&1 &
ACHECKER_OFFLINE_PID=$!
trap 'kill $ACHECKER_OFFLINE_PID 2>/dev/null || true' EXIT
ACHECKER_OFFLINE_READY=0
for _ in {1..50}; do if curl --noproxy '*' -fsS http://127.0.0.1:18080/archives.json > /dev/null 2>&1; then ACHECKER_OFFLINE_READY=1; break; fi; sleep 0.1; done
[ "$ACHECKER_OFFLINE_READY" -eq 1 ] || { cat /tmp/achecker-offline-server.log; exit 1; }
: '>>>>> Start Test Output'
yarn test --maxWorkers=4 packages/react/src/components/Tile/Tile-test.js
: '>>>>> End Test Output'
git checkout a1a564eb39927460dc3ec5a5f3129519d5d73519 packages/react/src/components/Tile/Tile-test.js
