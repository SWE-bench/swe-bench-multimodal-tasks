#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 25dd12a5324f3554a2ec30116789861ec318ed5f
rm -f test/markup/javascript/comments.expect.txt test/markup/javascript/comments.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/javascript/comments.expect.txt b/test/markup/javascript/comments.expect.txt
new file mode 100644
index 0000000000..0a0ba7b512
--- /dev/null
+++ b/test/markup/javascript/comments.expect.txt
@@ -0,0 +1,6 @@
+f = <span class="hljs-function">(<span class="hljs-params">                <span class="hljs-comment">// f is a recursive function taking:</span>
+  [c,                <span class="hljs-comment">//   c   = next digit character</span>
+      ...a],         <span class="hljs-comment">//   a[] = array of remaining digits</span>
+  o = b,            <span class="hljs-comment">//   o   = output string</span>
+  S = s        <span class="hljs-comment">//   S   = set of solutions</span>
+</span>) =&gt;</span>  {}
diff --git a/test/markup/javascript/comments.txt b/test/markup/javascript/comments.txt
new file mode 100644
index 0000000000..f533306251
--- /dev/null
+++ b/test/markup/javascript/comments.txt
@@ -0,0 +1,6 @@
+f = (                // f is a recursive function taking:
+  [c,                //   c   = next digit character
+      ...a],         //   a[] = array of remaining digits
+  o = b,            //   o   = output string
+  S = s        //   S   = set of solutions
+) =>  {}

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/javascript/comments.expect.txt test/markup/javascript/comments.txt
