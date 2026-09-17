#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 038aa67ae946822859166daeae187f735e23b03a
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 038aa67ae946822859166daeae187f735e23b03a packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 352849cc0e14..e09b4b5e77f7 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -3672,6 +3672,8 @@ Map {
       },
     },
     "defaultProps": Object {
+      "clearSelectionDescription": "Total items selected: ",
+      "clearSelectionText": "To clear selection, press Delete or Backspace,",
       "compareItems": [Function],
       "direction": "bottom",
       "disabled": false,
@@ -3687,6 +3689,12 @@ Map {
     },
     "displayName": "MultiSelect",
     "propTypes": Object {
+      "clearSelectionDescription": Object {
+        "type": "string",
+      },
+      "clearSelectionText": Object {
+        "type": "string",
+      },
       "compareItems": Object {
         "isRequired": true,
         "type": "func",
diff --git a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap
index a0408f6fe7b3..78f0165a05c6 100644
--- a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap
+++ b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap
@@ -14,6 +14,7 @@ exports[`ListBoxField should render 1`] = `
       translateWithId={[Function]}
     >
       <div
+        aria-hidden={true}
         aria-label="Clear selected item"
         className="bx--list-box__selection"
         onClick={[Function]}
diff --git a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap
index b45dd74ef280..f093eed8abb5 100644
--- a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap
+++ b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap
@@ -34,6 +34,7 @@ exports[`ListBoxSelection should render 1`] = `
   }
 >
   <div
+    aria-hidden={true}
     aria-label="translation"
     className="bx--list-box__selection"
     onClick={[Function]}
@@ -115,6 +116,7 @@ exports[`ListBoxSelection should render 2`] = `
       3
     </span>
     <div
+      aria-hidden={true}
       aria-label="translation"
       className="bx--tag__close-icon"
       onClick={[Function]}

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/ListBox/
: '>>>>> End Test Output'
git checkout 038aa67ae946822859166daeae187f735e23b03a packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxField-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxSelection-test.js.snap
