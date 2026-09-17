#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c53e70818d9d01cb2e386c4e15c86d4371743141
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout c53e70818d9d01cb2e386c4e15c86d4371743141 packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap packages/styles/scss/__tests__/theme-test.js packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap
index 8d62e1a6b1db..875bace53a77 100644
--- a/packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -318,6 +318,7 @@ Array [
   "scale",
   "selectedLightUI",
   "selectedUI",
+  "shadow",
   "size2XLarge",
   "sizeLarge",
   "sizeMedium",
diff --git a/packages/styles/scss/__tests__/theme-test.js b/packages/styles/scss/__tests__/theme-test.js
index 244b21093666..c31873150bcd 100644
--- a/packages/styles/scss/__tests__/theme-test.js
+++ b/packages/styles/scss/__tests__/theme-test.js
@@ -126,6 +126,7 @@ Array [
   "highlight",
   "overlay",
   "toggle-off",
+  "shadow",
   "focus",
   "focus-inset",
   "focus-inverse",
diff --git a/packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap b/packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap
index 181d9068e21e..ff737aea4135 100644
--- a/packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap
+++ b/packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap
@@ -233,6 +233,7 @@ Array [
   "highlight",
   "overlay",
   "toggle-off",
+  "shadow",
   "focus",
   "focus-inset",
   "focus-inverse",

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
yarn test --maxWorkers=4 packages/elements/src/ ; yarn test --maxWorkers=4 packages/styles/scss/ ; yarn test --maxWorkers=4 packages/themes/src/next/tokens/
: '>>>>> End Test Output'
git checkout c53e70818d9d01cb2e386c4e15c86d4371743141 packages/elements/src/__tests__/__snapshots__/PublicAPI-test.js.snap packages/styles/scss/__tests__/theme-test.js packages/themes/src/next/tokens/__tests__/__snapshots__/v11-test.js.snap
