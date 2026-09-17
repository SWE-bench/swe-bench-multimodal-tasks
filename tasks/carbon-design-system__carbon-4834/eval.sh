#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff cc2b30c34d75f97bef254c40de511c3522070686
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout cc2b30c34d75f97bef254c40de511c3522070686 packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap
index afd8eff6dbb1..355e1b61050a 100644
--- a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap
+++ b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap
@@ -18,7 +18,6 @@ exports[`HeaderMenu should render 1`] = `
         className="bx--header__menu-item bx--header__menu-title"
         href="#"
         onKeyDown={[Function]}
-        role="menuitem"
         tabIndex={0}
       >
         <defaultRenderMenuContent>
@@ -72,13 +71,11 @@ exports[`HeaderMenu should render 1`] = `
               className="bx--header__menu-item"
               element="a"
               href="/a"
-              role="menuitem"
               tabIndex={0}
             >
               <a
                 className="bx--header__menu-item"
                 href="/a"
-                role="menuitem"
                 tabIndex={0}
               >
                 <span
@@ -102,13 +99,11 @@ exports[`HeaderMenu should render 1`] = `
               className="bx--header__menu-item"
               element="a"
               href="/b"
-              role="menuitem"
               tabIndex={0}
             >
               <a
                 className="bx--header__menu-item"
                 href="/b"
-                role="menuitem"
                 tabIndex={0}
               >
                 <span
@@ -132,13 +127,11 @@ exports[`HeaderMenu should render 1`] = `
               className="bx--header__menu-item"
               element="a"
               href="/c"
-              role="menuitem"
               tabIndex={0}
             >
               <a
                 className="bx--header__menu-item"
                 href="/c"
-                role="menuitem"
                 tabIndex={0}
               >
                 <span
diff --git a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap
index a417de41959e..aed4a4e59d32 100644
--- a/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap
+++ b/packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap
@@ -12,12 +12,10 @@ exports[`HeaderMenuItem should render 1`] = `
     <Link
       className="bx--header__menu-item"
       element="a"
-      role="menuitem"
       tabIndex={0}
     >
       <a
         className="bx--header__menu-item"
-        role="menuitem"
         tabIndex={0}
       >
         <span

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
yarn test --maxWorkers=4 packages/react/src/components/UIShell/
: '>>>>> End Test Output'
git checkout cc2b30c34d75f97bef254c40de511c3522070686 packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenu-test.js.snap packages/react/src/components/UIShell/__tests__/__snapshots__/HeaderMenuItem-test.js.snap
