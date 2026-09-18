#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5efe02801f673579d1213909c3713a44870d46ca
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 5efe02801f673579d1213909c3713a44870d46ca packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 6d9b62cf41ad..33d423097682 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -207,6 +207,18 @@ Map {
         "isRequired": true,
         "type": "oneOf",
       },
+      "onBlur": Object {
+        "type": "func",
+      },
+      "onFocus": Object {
+        "type": "func",
+      },
+      "onMouseEnter": Object {
+        "type": "func",
+      },
+      "onMouseLeave": Object {
+        "type": "func",
+      },
       "renderIcon": Object {
         "args": Array [
           Array [
@@ -6351,12 +6363,18 @@ Map {
       "id": Object {
         "type": "string",
       },
+      "onBlur": Object {
+        "type": "func",
+      },
       "onFocus": Object {
         "type": "func",
       },
       "onMouseEnter": Object {
         "type": "func",
       },
+      "onMouseLeave": Object {
+        "type": "func",
+      },
       "tooltipText": Object {
         "isRequired": true,
         "type": "string",
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index f917629852bf..538983cbb103 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -2063,7 +2063,11 @@ exports[`DataTable should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -2136,7 +2140,11 @@ exports[`DataTable should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -2209,7 +2217,11 @@ exports[`DataTable should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -2268,7 +2280,11 @@ exports[`DataTable should render 1`] = `
                       aria-pressed={null}
                       className="bx--batch-summary__cancel bx--btn bx--btn--primary"
                       disabled={false}
+                      onBlur={[Function]}
                       onClick={[Function]}
+                      onFocus={[Function]}
+                      onMouseEnter={[Function]}
+                      onMouseLeave={[Function]}
                       tabIndex={-1}
                       type="button"
                     >
@@ -2522,7 +2538,11 @@ exports[`DataTable should render 1`] = `
                   aria-pressed={null}
                   className="bx--btn bx--btn--sm bx--btn--primary"
                   disabled={false}
+                  onBlur={[Function]}
                   onClick={[MockFunction]}
+                  onFocus={[Function]}
+                  onMouseEnter={[Function]}
+                  onMouseLeave={[Function]}
                   tabIndex={0}
                   type="button"
                 >
@@ -3074,7 +3094,11 @@ exports[`DataTable sticky header should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -3147,7 +3171,11 @@ exports[`DataTable sticky header should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -3220,7 +3248,11 @@ exports[`DataTable sticky header should render 1`] = `
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
+                        onBlur={[Function]}
                         onClick={[MockFunction]}
+                        onFocus={[Function]}
+                        onMouseEnter={[Function]}
+                        onMouseLeave={[Function]}
                         tabIndex={0}
                         type="button"
                       >
@@ -3279,7 +3311,11 @@ exports[`DataTable sticky header should render 1`] = `
                       aria-pressed={null}
                       className="bx--batch-summary__cancel bx--btn bx--btn--primary"
                       disabled={false}
+                      onBlur={[Function]}
                       onClick={[Function]}
+                      onFocus={[Function]}
+                      onMouseEnter={[Function]}
+                      onMouseLeave={[Function]}
                       tabIndex={-1}
                       type="button"
                     >
@@ -3533,7 +3569,11 @@ exports[`DataTable sticky header should render 1`] = `
                   aria-pressed={null}
                   className="bx--btn bx--btn--sm bx--btn--primary"
                   disabled={false}
+                  onBlur={[Function]}
                   onClick={[MockFunction]}
+                  onFocus={[Function]}
+                  onMouseEnter={[Function]}
+                  onMouseLeave={[Function]}
                   tabIndex={0}
                   type="button"
                 >
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
index 4d398c882fea..bdfd58f405c2 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
@@ -32,6 +32,10 @@ exports[`DataTable.TableBatchAction should render 1`] = `
       aria-pressed={null}
       className="custom-class bx--btn bx--btn--primary"
       disabled={false}
+      onBlur={[Function]}
+      onFocus={[Function]}
+      onMouseEnter={[Function]}
+      onMouseLeave={[Function]}
       tabIndex={0}
       type="button"
     >
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
index 8d58bca90557..2791ba24bb6c 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
@@ -42,7 +42,11 @@ exports[`DataTable.TableBatchActions should render 1`] = `
             aria-pressed={null}
             className="bx--batch-summary__cancel bx--btn bx--btn--primary"
             disabled={false}
+            onBlur={[Function]}
             onClick={[MockFunction]}
+            onFocus={[Function]}
+            onMouseEnter={[Function]}
+            onMouseLeave={[Function]}
             tabIndex={-1}
             type="button"
           >
@@ -97,7 +101,11 @@ exports[`DataTable.TableBatchActions should render 2`] = `
             aria-pressed={null}
             className="bx--batch-summary__cancel bx--btn bx--btn--primary"
             disabled={false}
+            onBlur={[Function]}
             onClick={[MockFunction]}
+            onFocus={[Function]}
+            onMouseEnter={[Function]}
+            onMouseLeave={[Function]}
             tabIndex={0}
             type="button"
           >
diff --git a/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap b/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
index 6c191edfa692..ded1f508d498 100644
--- a/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
+++ b/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
@@ -39,7 +39,11 @@ exports[`ModalWrapper should render 1`] = `
         aria-pressed={null}
         className="btn-trigger bx--btn bx--btn--primary"
         disabled={false}
+        onBlur={[Function]}
         onClick={[Function]}
+        onFocus={[Function]}
+        onMouseEnter={[Function]}
+        onMouseLeave={[Function]}
         tabIndex={0}
         type="button"
       >
@@ -175,7 +179,11 @@ exports[`ModalWrapper should render 1`] = `
                     aria-pressed={null}
                     className="bx--btn bx--btn--secondary"
                     disabled={false}
+                    onBlur={[Function]}
                     onClick={[Function]}
+                    onFocus={[Function]}
+                    onMouseEnter={[Function]}
+                    onMouseLeave={[Function]}
                     tabIndex={0}
                     type="button"
                   >
@@ -197,7 +205,11 @@ exports[`ModalWrapper should render 1`] = `
                   aria-pressed={null}
                   className="bx--btn bx--btn--primary"
                   disabled={false}
+                  onBlur={[Function]}
                   onClick={[Function]}
+                  onFocus={[Function]}
+                  onMouseEnter={[Function]}
+                  onMouseLeave={[Function]}
                   tabIndex={0}
                   type="button"
                 >
diff --git a/packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap b/packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap
index 351021445b7e..7f102fddb30b 100644
--- a/packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap
+++ b/packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap
@@ -10,13 +10,16 @@ exports[`TooltipIcon should allow the user to specify the direction 1`] = `
   <button
     aria-describedby="icon-tooltip-4"
     className="bx--tooltip__trigger bx--tooltip--a11y custom-class bx--tooltip--top bx--tooltip--align-center"
+    onBlur={[Function]}
     onFocus={[Function]}
     onMouseEnter={[Function]}
+    onMouseLeave={[Function]}
     type="button"
   >
     <span
       className="bx--assistive-text"
       id="icon-tooltip-4"
+      onMouseEnter={[Function]}
     >
       tooltip text
     </span>
@@ -35,13 +38,16 @@ exports[`TooltipIcon should render 1`] = `
   <button
     aria-describedby="icon-tooltip-1"
     className="bx--tooltip__trigger bx--tooltip--a11y custom-class bx--tooltip--bottom bx--tooltip--align-center"
+    onBlur={[Function]}
     onFocus={[Function]}
     onMouseEnter={[Function]}
+    onMouseLeave={[Function]}
     type="button"
   >
     <span
       className="bx--assistive-text"
       id="icon-tooltip-1"
+      onMouseEnter={[Function]}
     >
       tooltip text
     </span>
diff --git a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
index 27883cdcea1b..7e843cabee66 100644
--- a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
+++ b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
@@ -26,15 +26,20 @@ exports[`HeaderGlobalAction should render 1`] = `
       aria-pressed={null}
       className="custom-class bx--header__action bx--btn bx--btn--primary bx--btn--icon-only bx--tooltip__trigger bx--tooltip--a11y bx--tooltip--bottom bx--tooltip--align-center"
       disabled={false}
+      onBlur={[Function]}
       onClick={[MockFunction]}
+      onFocus={[Function]}
+      onMouseEnter={[Function]}
+      onMouseLeave={[Function]}
       tabIndex={0}
       type="button"
     >
-      <span
+      <div
         className="bx--assistive-text"
+        onMouseEnter={[Function]}
       >
         Accessibility label
-      </span>
+      </div>
       <ForwardRef(Fade32)>
         <Icon
           fill="currentColor"

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/DataTable/ ; yarn test --maxWorkers=4 packages/react/src/components/ModalWrapper ; yarn test --maxWorkers=4 packages/react/src/components/TooltipIcon ; yarn test --maxWorkers=4 packages/react/src/components/UIShell/
: '>>>>> End Test Output'
git checkout 5efe02801f673579d1213909c3713a44870d46ca packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap packages/react/src/components/TooltipIcon/__snapshots__/TooltipIcon-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
