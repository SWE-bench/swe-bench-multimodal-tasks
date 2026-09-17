#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 334dd62c99d69d8c612b20db8641e4023a7bc04a
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 334dd62c99d69d8c612b20db8641e4023a7bc04a packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index 70426f89177f..f2d7d5787248 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -142,11 +142,11 @@ exports[`DataTable selection -- radio buttons should not have select-all checkbo
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field A
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                   <TableHeader
@@ -161,11 +161,11 @@ exports[`DataTable selection -- radio buttons should not have select-all checkbo
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field B
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                 </tr>
@@ -489,11 +489,11 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field A
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                   <TableHeader
@@ -508,11 +508,11 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field B
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                 </tr>
@@ -539,7 +539,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     radio={true}
                   >
                     <td
-                      className="bx--table-column-checkbox"
+                      className="bx--table-column-checkbox bx--table-column-radio"
                     >
                       <ForwardRef(RadioButton)
                         checked={false}
@@ -625,7 +625,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     radio={true}
                   >
                     <td
-                      className="bx--table-column-checkbox"
+                      className="bx--table-column-checkbox bx--table-column-radio"
                     >
                       <ForwardRef(RadioButton)
                         checked={false}
@@ -711,7 +711,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     radio={true}
                   >
                     <td
-                      className="bx--table-column-checkbox"
+                      className="bx--table-column-checkbox bx--table-column-radio"
                     >
                       <ForwardRef(RadioButton)
                         checked={false}
@@ -989,11 +989,11 @@ exports[`DataTable selection should have select-all default to un-checked if no
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field A
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                   <TableHeader
@@ -1008,11 +1008,11 @@ exports[`DataTable selection should have select-all default to un-checked if no
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field B
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                 </tr>
@@ -1391,11 +1391,11 @@ exports[`DataTable selection should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field A
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                   <TableHeader
@@ -1410,11 +1410,11 @@ exports[`DataTable selection should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field B
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                 </tr>
@@ -2523,11 +2523,11 @@ exports[`DataTable should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field A
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                   <TableHeader
@@ -2542,11 +2542,11 @@ exports[`DataTable should render 1`] = `
                     <th
                       scope="col"
                     >
-                      <span
+                      <div
                         className="bx--table-header-label"
                       >
                         Field B
-                      </span>
+                      </div>
                     </th>
                   </TableHeader>
                 </tr>
@@ -3516,11 +3516,11 @@ exports[`DataTable sticky header should render 1`] = `
                       <th
                         scope="col"
                       >
-                        <span
+                        <div
                           className="bx--table-header-label"
                         >
                           Field A
-                        </span>
+                        </div>
                       </th>
                     </TableHeader>
                     <TableHeader
@@ -3535,11 +3535,11 @@ exports[`DataTable sticky header should render 1`] = `
                       <th
                         scope="col"
                       >
-                        <span
+                        <div
                           className="bx--table-header-label"
                         >
                           Field B
-                        </span>
+                        </div>
                       </th>
                     </TableHeader>
                   </tr>
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap
index 2d6fbe65c8f4..cc8696fce703 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap
@@ -23,11 +23,11 @@ exports[`DataTable.TableHeader should have an active and ascending class if sort
               <th
                 scope="col"
               >
-                <span
+                <div
                   className="bx--table-header-label"
                 >
                   Header
-                </span>
+                </div>
               </th>
             </TableHeader>
           </tr>
@@ -61,11 +61,11 @@ exports[`DataTable.TableHeader should have an active class if it is the sort hea
               <th
                 scope="col"
               >
-                <span
+                <div
                   className="bx--table-header-label"
                 >
                   Header
-                </span>
+                </div>
               </th>
             </TableHeader>
           </tr>
@@ -99,11 +99,11 @@ exports[`DataTable.TableHeader should render 1`] = `
               <th
                 scope="col"
               >
-                <span
+                <div
                   className="bx--table-header-label"
                 >
                   Header
-                </span>
+                </div>
               </th>
             </TableHeader>
           </tr>
@@ -137,11 +137,11 @@ exports[`DataTable.TableHeader should render 2`] = `
               <th
                 scope="col"
               >
-                <span
+                <div
                   className="bx--table-header-label"
                 >
                   Header
-                </span>
+                </div>
               </th>
             </TableHeader>
           </tr>

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
yarn test --maxWorkers=1 packages/react/src/components/DataTable/
: '>>>>> End Test Output'
git checkout 334dd62c99d69d8c612b20db8641e4023a7bc04a packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableHeader-test.js.snap
