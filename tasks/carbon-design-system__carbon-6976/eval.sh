#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b162614a9a7ec1930c7a92ece398bf8690d5e39f
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout b162614a9a7ec1930c7a92ece398bf8690d5e39f packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap packages/react/src/components/OverflowMenu/OverflowMenu-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index d72b44f0bdef..1ddd10e12918 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -2439,7 +2439,6 @@ exports[`DataTable should render 1`] = `
                       }
                     }
                     selectorPrimaryFocus="[data-overflow-menu-primary-focus]"
-                    tabIndex={0}
                     title="Settings"
                   >
                     <ClickListener
@@ -2454,14 +2453,12 @@ exports[`DataTable should render 1`] = `
                         onClose={[Function]}
                         onKeyDown={[Function]}
                         open={false}
-                        tabIndex={0}
                         title="Settings"
                         type="button"
                       >
                         <ForwardRef(Settings16)
                           aria-label="Settings"
                           className="bx--overflow-menu__icon"
-                          focusable="false"
                           onClick={[Function]}
                           onKeyDown={[Function]}
                         >
@@ -2469,7 +2466,6 @@ exports[`DataTable should render 1`] = `
                             aria-label="Settings"
                             className="bx--overflow-menu__icon"
                             fill="currentColor"
-                            focusable="false"
                             height={16}
                             onClick={[Function]}
                             onKeyDown={[Function]}
@@ -3450,7 +3446,6 @@ exports[`DataTable sticky header should render 1`] = `
                       }
                     }
                     selectorPrimaryFocus="[data-overflow-menu-primary-focus]"
-                    tabIndex={0}
                     title="Settings"
                   >
                     <ClickListener
@@ -3465,14 +3460,12 @@ exports[`DataTable sticky header should render 1`] = `
                         onClose={[Function]}
                         onKeyDown={[Function]}
                         open={false}
-                        tabIndex={0}
                         title="Settings"
                         type="button"
                       >
                         <ForwardRef(Settings16)
                           aria-label="Settings"
                           className="bx--overflow-menu__icon"
-                          focusable="false"
                           onClick={[Function]}
                           onKeyDown={[Function]}
                         >
@@ -3480,7 +3473,6 @@ exports[`DataTable sticky header should render 1`] = `
                             aria-label="Settings"
                             className="bx--overflow-menu__icon"
                             fill="currentColor"
-                            focusable="false"
                             height={16}
                             onClick={[Function]}
                             onKeyDown={[Function]}
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap
index 155359bd9317..38a6659d0222 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap
@@ -46,7 +46,6 @@ exports[`DataTable.TableToolbarMenu should render 1`] = `
         }
       }
       selectorPrimaryFocus="[data-overflow-menu-primary-focus]"
-      tabIndex={0}
       title="Add"
     >
       <ClickListener
@@ -61,14 +60,12 @@ exports[`DataTable.TableToolbarMenu should render 1`] = `
           onClose={[Function]}
           onKeyDown={[Function]}
           open={false}
-          tabIndex={0}
           title="Add"
           type="button"
         >
           <ForwardRef(Download16)
             aria-label="Add"
             className="bx--overflow-menu__icon"
-            focusable="false"
             onClick={[Function]}
             onKeyDown={[Function]}
           >
@@ -76,7 +73,6 @@ exports[`DataTable.TableToolbarMenu should render 1`] = `
               aria-label="Add"
               className="bx--overflow-menu__icon"
               fill="currentColor"
-              focusable="false"
               height={16}
               onClick={[Function]}
               onKeyDown={[Function]}
diff --git a/packages/react/src/components/OverflowMenu/OverflowMenu-test.js b/packages/react/src/components/OverflowMenu/OverflowMenu-test.js
index b827536d2c16..526524fb6f56 100644
--- a/packages/react/src/components/OverflowMenu/OverflowMenu-test.js
+++ b/packages/react/src/components/OverflowMenu/OverflowMenu-test.js
@@ -72,17 +72,6 @@ describe('OverflowMenu', () => {
       ).toEqual('uniqueId');
     });
 
-    it('should apply a tabindex to the menu', () => {
-      const defaultMenu = mount(
-        <OverflowMenu>
-          <div>Child</div>
-        </OverflowMenu>
-      ).childAt(0);
-      // Enzyme doesn't seem to allow props() in a forwardRef-wrapped class component
-      expect(defaultMenu.find('OverflowMenu').instance().props.tabIndex).toBe(
-        0
-      );
-    });
     it('should specify light version as expected', () => {
       rootWrapper.setProps({ light: true });
       expect(rootWrapper.props().light).toEqual(true);

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
yarn test --maxWorkers=1 packages/react/src/components/DataTable/ ; yarn test --maxWorkers=1 packages/react/src/components/OverflowMenu/OverflowMenu-test.js
: '>>>>> End Test Output'
git checkout b162614a9a7ec1930c7a92ece398bf8690d5e39f packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap packages/react/src/components/DataTable/__tests__/__snapshots__/TableToolbarMenu-test.js.snap packages/react/src/components/OverflowMenu/OverflowMenu-test.js
