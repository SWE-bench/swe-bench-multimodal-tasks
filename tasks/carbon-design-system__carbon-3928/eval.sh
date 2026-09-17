#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4c0675682975e944254c23be7f9e6d8a63e605a9
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 4c0675682975e944254c23be7f9e6d8a63e605a9 packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index 0fab26769346..a60363f67f20 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -1764,7 +1764,6 @@ exports[`DataTable should render 1`] = `
                 translateWithId={[Function]}
               >
                 <TableBatchAction
-                  iconDescription="Add"
                   onClick={[MockFunction]}
                   renderIcon={
                     Object {
@@ -1776,7 +1775,6 @@ exports[`DataTable should render 1`] = `
                   Ghost
                 </TableBatchAction>
                 <TableBatchAction
-                  iconDescription="Add"
                   onClick={[MockFunction]}
                   renderIcon={
                     Object {
@@ -1788,7 +1786,6 @@ exports[`DataTable should render 1`] = `
                   Ghost
                 </TableBatchAction>
                 <TableBatchAction
-                  iconDescription="Add"
                   onClick={[MockFunction]}
                   renderIcon={
                     Object {
@@ -1965,7 +1962,6 @@ exports[`DataTable should render 1`] = `
                   className="bx--action-list"
                 >
                   <TableBatchAction
-                    iconDescription="Add"
                     onClick={[MockFunction]}
                     renderIcon={
                       Object {
@@ -1976,7 +1972,6 @@ exports[`DataTable should render 1`] = `
                   >
                     <ForwardRef(Button)
                       disabled={false}
-                      iconDescription="Add"
                       kind="primary"
                       onClick={[MockFunction]}
                       renderIcon={
@@ -1998,12 +1993,10 @@ exports[`DataTable should render 1`] = `
                         Ghost
                         <ForwardRef(AddFilled16)
                           aria-hidden="true"
-                          aria-label="Add"
                           className="bx--btn__icon"
                         >
                           <Icon
                             aria-hidden="true"
-                            aria-label="Add"
                             className="bx--btn__icon"
                             height={16}
                             preserveAspectRatio="xMidYMid meet"
@@ -2012,13 +2005,11 @@ exports[`DataTable should render 1`] = `
                             xmlns="http://www.w3.org/2000/svg"
                           >
                             <svg
-                              aria-hidden="true"
-                              aria-label="Add"
+                              aria-hidden={true}
                               className="bx--btn__icon"
                               focusable="false"
                               height={16}
                               preserveAspectRatio="xMidYMid meet"
-                              role="img"
                               style={
                                 Object {
                                   "willChange": "transform",
@@ -2038,7 +2029,6 @@ exports[`DataTable should render 1`] = `
                     </ForwardRef(Button)>
                   </TableBatchAction>
                   <TableBatchAction
-                    iconDescription="Add"
                     onClick={[MockFunction]}
                     renderIcon={
                       Object {
@@ -2049,7 +2039,6 @@ exports[`DataTable should render 1`] = `
                   >
                     <ForwardRef(Button)
                       disabled={false}
-                      iconDescription="Add"
                       kind="primary"
                       onClick={[MockFunction]}
                       renderIcon={
@@ -2071,12 +2060,10 @@ exports[`DataTable should render 1`] = `
                         Ghost
                         <ForwardRef(AddFilled16)
                           aria-hidden="true"
-                          aria-label="Add"
                           className="bx--btn__icon"
                         >
                           <Icon
                             aria-hidden="true"
-                            aria-label="Add"
                             className="bx--btn__icon"
                             height={16}
                             preserveAspectRatio="xMidYMid meet"
@@ -2085,13 +2072,11 @@ exports[`DataTable should render 1`] = `
                             xmlns="http://www.w3.org/2000/svg"
                           >
                             <svg
-                              aria-hidden="true"
-                              aria-label="Add"
+                              aria-hidden={true}
                               className="bx--btn__icon"
                               focusable="false"
                               height={16}
                               preserveAspectRatio="xMidYMid meet"
-                              role="img"
                               style={
                                 Object {
                                   "willChange": "transform",
@@ -2111,7 +2096,6 @@ exports[`DataTable should render 1`] = `
                     </ForwardRef(Button)>
                   </TableBatchAction>
                   <TableBatchAction
-                    iconDescription="Add"
                     onClick={[MockFunction]}
                     renderIcon={
                       Object {
@@ -2122,7 +2106,6 @@ exports[`DataTable should render 1`] = `
                   >
                     <ForwardRef(Button)
                       disabled={false}
-                      iconDescription="Add"
                       kind="primary"
                       onClick={[MockFunction]}
                       renderIcon={
@@ -2144,12 +2127,10 @@ exports[`DataTable should render 1`] = `
                         Ghost
                         <ForwardRef(AddFilled16)
                           aria-hidden="true"
-                          aria-label="Add"
                           className="bx--btn__icon"
                         >
                           <Icon
                             aria-hidden="true"
-                            aria-label="Add"
                             className="bx--btn__icon"
                             height={16}
                             preserveAspectRatio="xMidYMid meet"
@@ -2158,13 +2139,11 @@ exports[`DataTable should render 1`] = `
                             xmlns="http://www.w3.org/2000/svg"
                           >
                             <svg
-                              aria-hidden="true"
-                              aria-label="Add"
+                              aria-hidden={true}
                               className="bx--btn__icon"
                               focusable="false"
                               height={16}
                               preserveAspectRatio="xMidYMid meet"
-                              role="img"
                               style={
                                 Object {
                                   "willChange": "transform",
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
index 6027b4b33056..b55e669258ff 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
@@ -3,7 +3,6 @@
 exports[`DataTable.TableBatchAction should render 1`] = `
 <TableBatchAction
   className="custom-class"
-  iconDescription="Add"
   renderIcon={
     Object {
       "$$typeof": Symbol(react.forward_ref),
@@ -14,7 +13,6 @@ exports[`DataTable.TableBatchAction should render 1`] = `
   <ForwardRef(Button)
     className="custom-class"
     disabled={false}
-    iconDescription="Add"
     kind="primary"
     renderIcon={
       Object {
@@ -33,12 +31,10 @@ exports[`DataTable.TableBatchAction should render 1`] = `
     >
       <ForwardRef(AddFilled16)
         aria-hidden="true"
-        aria-label="Add"
         className="bx--btn__icon"
       >
         <Icon
           aria-hidden="true"
-          aria-label="Add"
           className="bx--btn__icon"
           height={16}
           preserveAspectRatio="xMidYMid meet"
@@ -47,13 +43,11 @@ exports[`DataTable.TableBatchAction should render 1`] = `
           xmlns="http://www.w3.org/2000/svg"
         >
           <svg
-            aria-hidden="true"
-            aria-label="Add"
+            aria-hidden={true}
             className="bx--btn__icon"
             focusable="false"
             height={16}
             preserveAspectRatio="xMidYMid meet"
-            role="img"
             style={
               Object {
                 "willChange": "transform",

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
yarn test --maxWorkers=4 packages/react/src/components/DataTable/
: '>>>>> End Test Output'
git checkout 4c0675682975e944254c23be7f9e6d8a63e605a9 packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
