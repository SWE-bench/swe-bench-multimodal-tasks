#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 61b12ba83ded1f6c67eb8238c6f91a884de7d0f1
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 61b12ba83ded1f6c67eb8238c6f91a884de7d0f1 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 427b1a424f33..abe9aa2622b8 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -146,6 +146,7 @@ Map {
   "Button" => Object {
     "$$typeof": Symbol(react.forward_ref),
     "defaultProps": Object {
+      "dangerDescription": "danger",
       "disabled": false,
       "kind": "primary",
       "size": "default",
@@ -178,6 +179,9 @@ Map {
       "className": Object {
         "type": "string",
       },
+      "dangerDescription": Object {
+        "type": "string",
+      },
       "disabled": Object {
         "type": "bool",
       },
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index e6bf3aeb0b12..4157a885f50a 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -1885,6 +1885,7 @@ exports[`DataTable should render 1`] = `
                   </TableToolbarAction>
                 </TableToolbarMenu>
                 <Button
+                  dangerDescription="danger"
                   disabled={false}
                   kind="primary"
                   onClick={[MockFunction]}
@@ -2044,6 +2045,7 @@ exports[`DataTable should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -2060,6 +2062,7 @@ exports[`DataTable should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -2121,6 +2124,7 @@ exports[`DataTable should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -2137,6 +2141,7 @@ exports[`DataTable should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -2198,6 +2203,7 @@ exports[`DataTable should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -2214,6 +2220,7 @@ exports[`DataTable should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -2267,6 +2274,7 @@ exports[`DataTable should render 1`] = `
                   </TableBatchAction>
                   <Button
                     className="bx--batch-summary__cancel"
+                    dangerDescription="danger"
                     disabled={false}
                     kind="primary"
                     onClick={[Function]}
@@ -2277,6 +2285,7 @@ exports[`DataTable should render 1`] = `
                     type="button"
                   >
                     <button
+                      aria-describedby={null}
                       aria-pressed={null}
                       className="bx--batch-summary__cancel bx--btn bx--btn--primary"
                       disabled={false}
@@ -2521,6 +2530,7 @@ exports[`DataTable should render 1`] = `
                 </ForwardRef(OverflowMenu)>
               </TableToolbarMenu>
               <Button
+                dangerDescription="danger"
                 disabled={false}
                 kind="primary"
                 onClick={[MockFunction]}
@@ -2531,6 +2541,7 @@ exports[`DataTable should render 1`] = `
                 type="button"
               >
                 <button
+                  aria-describedby={null}
                   aria-pressed={null}
                   className="bx--btn bx--btn--sm bx--btn--primary"
                   disabled={false}
@@ -2909,6 +2920,7 @@ exports[`DataTable sticky header should render 1`] = `
                   </TableToolbarAction>
                 </TableToolbarMenu>
                 <Button
+                  dangerDescription="danger"
                   disabled={false}
                   kind="primary"
                   onClick={[MockFunction]}
@@ -3071,6 +3083,7 @@ exports[`DataTable sticky header should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -3087,6 +3100,7 @@ exports[`DataTable sticky header should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -3148,6 +3162,7 @@ exports[`DataTable sticky header should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -3164,6 +3179,7 @@ exports[`DataTable sticky header should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -3225,6 +3241,7 @@ exports[`DataTable sticky header should render 1`] = `
                     }
                   >
                     <Button
+                      dangerDescription="danger"
                       disabled={false}
                       kind="primary"
                       onClick={[MockFunction]}
@@ -3241,6 +3258,7 @@ exports[`DataTable sticky header should render 1`] = `
                       type="button"
                     >
                       <button
+                        aria-describedby={null}
                         aria-pressed={null}
                         className="bx--btn bx--btn--primary"
                         disabled={false}
@@ -3294,6 +3312,7 @@ exports[`DataTable sticky header should render 1`] = `
                   </TableBatchAction>
                   <Button
                     className="bx--batch-summary__cancel"
+                    dangerDescription="danger"
                     disabled={false}
                     kind="primary"
                     onClick={[Function]}
@@ -3304,6 +3323,7 @@ exports[`DataTable sticky header should render 1`] = `
                     type="button"
                   >
                     <button
+                      aria-describedby={null}
                       aria-pressed={null}
                       className="bx--batch-summary__cancel bx--btn bx--btn--primary"
                       disabled={false}
@@ -3548,6 +3568,7 @@ exports[`DataTable sticky header should render 1`] = `
                 </ForwardRef(OverflowMenu)>
               </TableToolbarMenu>
               <Button
+                dangerDescription="danger"
                 disabled={false}
                 kind="primary"
                 onClick={[MockFunction]}
@@ -3558,6 +3579,7 @@ exports[`DataTable sticky header should render 1`] = `
                 type="button"
               >
                 <button
+                  aria-describedby={null}
                   aria-pressed={null}
                   className="bx--btn bx--btn--sm bx--btn--primary"
                   disabled={false}
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
index bdfd58f405c2..261da53ef488 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap
@@ -13,6 +13,7 @@ exports[`DataTable.TableBatchAction should render 1`] = `
 >
   <Button
     className="custom-class"
+    dangerDescription="danger"
     disabled={false}
     iconDescription="test"
     kind="primary"
@@ -29,6 +30,7 @@ exports[`DataTable.TableBatchAction should render 1`] = `
     type="button"
   >
     <button
+      aria-describedby={null}
       aria-pressed={null}
       className="custom-class bx--btn bx--btn--primary"
       disabled={false}
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
index 2791ba24bb6c..213f0c929f37 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap
@@ -29,6 +29,7 @@ exports[`DataTable.TableBatchActions should render 1`] = `
       >
         <Button
           className="bx--batch-summary__cancel"
+          dangerDescription="danger"
           disabled={false}
           kind="primary"
           onClick={[MockFunction]}
@@ -39,6 +40,7 @@ exports[`DataTable.TableBatchActions should render 1`] = `
           type="button"
         >
           <button
+            aria-describedby={null}
             aria-pressed={null}
             className="bx--batch-summary__cancel bx--btn bx--btn--primary"
             disabled={false}
@@ -88,6 +90,7 @@ exports[`DataTable.TableBatchActions should render 2`] = `
       >
         <Button
           className="bx--batch-summary__cancel"
+          dangerDescription="danger"
           disabled={false}
           kind="primary"
           onClick={[MockFunction]}
@@ -98,6 +101,7 @@ exports[`DataTable.TableBatchActions should render 2`] = `
           type="button"
         >
           <button
+            aria-describedby={null}
             aria-pressed={null}
             className="bx--batch-summary__cancel bx--btn bx--btn--primary"
             disabled={false}
diff --git a/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap b/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
index ded1f508d498..4d473e35903a 100644
--- a/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
+++ b/packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap
@@ -25,6 +25,7 @@ exports[`ModalWrapper should render 1`] = `
   >
     <Button
       className="btn-trigger"
+      dangerDescription="danger"
       disabled={false}
       iconDescription="Provide icon description if icon is used"
       kind="primary"
@@ -36,6 +37,7 @@ exports[`ModalWrapper should render 1`] = `
       type="button"
     >
       <button
+        aria-describedby={null}
         aria-pressed={null}
         className="btn-trigger bx--btn bx--btn--primary"
         disabled={false}
@@ -166,6 +168,7 @@ exports[`ModalWrapper should render 1`] = `
             >
               <SecondaryButtonSet>
                 <Button
+                  dangerDescription="danger"
                   disabled={false}
                   kind="secondary"
                   onClick={[Function]}
@@ -176,6 +179,7 @@ exports[`ModalWrapper should render 1`] = `
                   type="button"
                 >
                   <button
+                    aria-describedby={null}
                     aria-pressed={null}
                     className="bx--btn bx--btn--secondary"
                     disabled={false}
@@ -192,6 +196,7 @@ exports[`ModalWrapper should render 1`] = `
                 </Button>
               </SecondaryButtonSet>
               <Button
+                dangerDescription="danger"
                 disabled={false}
                 kind="primary"
                 onClick={[Function]}
@@ -202,6 +207,7 @@ exports[`ModalWrapper should render 1`] = `
                 type="button"
               >
                 <button
+                  aria-describedby={null}
                   aria-pressed={null}
                   className="bx--btn bx--btn--primary"
                   disabled={false}
diff --git a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
index 7e843cabee66..7b6de0846ef6 100644
--- a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
+++ b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
@@ -10,6 +10,7 @@ exports[`HeaderGlobalAction should render 1`] = `
   <Button
     aria-label="Accessibility label"
     className="custom-class bx--header__action"
+    dangerDescription="danger"
     disabled={false}
     hasIconOnly={true}
     iconDescription="Accessibility label"
@@ -22,6 +23,7 @@ exports[`HeaderGlobalAction should render 1`] = `
     type="button"
   >
     <button
+      aria-describedby={null}
       aria-label="Accessibility label"
       aria-pressed={null}
       className="custom-class bx--header__action bx--btn bx--btn--primary bx--btn--icon-only bx--tooltip__trigger bx--tooltip--a11y bx--tooltip--bottom bx--tooltip--align-center"

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/DataTable/ ; yarn test --maxWorkers=4 packages/react/src/components/ModalWrapper ; yarn test --maxWorkers=4 packages/react/src/components/UIShell/
: '>>>>> End Test Output'
git checkout 61b12ba83ded1f6c67eb8238c6f91a884de7d0f1 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchAction-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableBatchActions-test.js.snap packages/react/src/components/ModalWrapper/__snapshots__/ModalWrapper-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderGlobalAction-test.js.snap
