#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 84719c17a51d7bb045f2df441b9c00f871f7c063
git checkout 84719c17a51d7bb045f2df441b9c00f871f7c063 test/markup/javascript/class.expect.txt test/markup/javascript/class.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/javascript/class.expect.txt b/test/markup/javascript/class.expect.txt
index 3ef253c364..7e1dd67c80 100644
--- a/test/markup/javascript/class.expect.txt
+++ b/test/markup/javascript/class.expect.txt
@@ -33,3 +33,8 @@
 <span class="hljs-title class_">CSSParser</span>
 <span class="hljs-title class_">Float32Array</span>
 <span class="hljs-title class_">BigInt64Array</span>
+<span class="hljs-title class_">FPs</span>
+<span class="hljs-title class_">OutT</span>
+<span class="hljs-title class_">InT</span>
+<span class="hljs-title class_">CSSParserT</span>
+<span class="hljs-title class_">IResponseTsS</span>
diff --git a/test/markup/javascript/class.txt b/test/markup/javascript/class.txt
index bebfe77f90..4badef7377 100644
--- a/test/markup/javascript/class.txt
+++ b/test/markup/javascript/class.txt
@@ -33,3 +33,8 @@ SelfDrivingTruck
 CSSParser
 Float32Array
 BigInt64Array
+FPs
+OutT
+InT
+CSSParserT
+IResponseTsS

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 84719c17a51d7bb045f2df441b9c00f871f7c063 test/markup/javascript/class.expect.txt test/markup/javascript/class.txt
