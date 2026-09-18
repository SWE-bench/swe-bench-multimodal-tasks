#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2aa387dccf8ae20ede43ca98f6db6df3acbf20e4
rm -f test/markup/verilog/directives.expect.txt test/markup/verilog/directives.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/verilog/directives.expect.txt b/test/markup/verilog/directives.expect.txt
new file mode 100644
index 0000000000..c4e6b8fa70
--- /dev/null
+++ b/test/markup/verilog/directives.expect.txt
@@ -0,0 +1,2 @@
+<span class="hljs-meta">`<span class="hljs-keyword">define</span> CONSTANT value </span><span class="hljs-comment">// this is a comment</span>
+<span class="hljs-keyword">wire</span> result = `CONSTANT + variable; <span class="hljs-comment">// comment</span>
diff --git a/test/markup/verilog/directives.txt b/test/markup/verilog/directives.txt
new file mode 100644
index 0000000000..90b815672b
--- /dev/null
+++ b/test/markup/verilog/directives.txt
@@ -0,0 +1,2 @@
+`define CONSTANT value // this is a comment
+wire result = `CONSTANT + variable; // comment

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/verilog/directives.expect.txt test/markup/verilog/directives.txt
