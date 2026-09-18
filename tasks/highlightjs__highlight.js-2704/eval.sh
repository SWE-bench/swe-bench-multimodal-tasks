#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5b87cc4d106059bee1c30f123e5a4053e0af9de4
rm -f test/markup/fsharp/comments.expect.txt test/markup/fsharp/comments.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/fsharp/comments.expect.txt b/test/markup/fsharp/comments.expect.txt
new file mode 100644
index 0000000000..66c6723163
--- /dev/null
+++ b/test/markup/fsharp/comments.expect.txt
@@ -0,0 +1,14 @@
+<span class="hljs-comment">(* here is a multi-line comment on one line *)</span>
+
+<span class="hljs-comment">(*
+    here is a multi-line comment on
+    multiple lines
+*)</span>
+
+<span class="hljs-keyword">let</span> index =
+    len
+    |&gt; float
+    |&gt; Operators.(*) <span class="hljs-number">0.1</span>      <span class="hljs-comment">// (*) here is not comment</span>
+    |&gt; Operators.(+) <span class="hljs-number">1</span>        <span class="hljs-comment">// (+) here is not comment</span>
+    |&gt; Operators.(-) len      <span class="hljs-comment">// (-) here is not comment</span>
+;;
diff --git a/test/markup/fsharp/comments.txt b/test/markup/fsharp/comments.txt
new file mode 100644
index 0000000000..1834138f10
--- /dev/null
+++ b/test/markup/fsharp/comments.txt
@@ -0,0 +1,14 @@
+(* here is a multi-line comment on one line *)
+
+(*
+    here is a multi-line comment on
+    multiple lines
+*)
+
+let index =
+    len
+    |> float
+    |> Operators.(*) 0.1      // (*) here is not comment
+    |> Operators.(+) 1        // (+) here is not comment
+    |> Operators.(-) len      // (-) here is not comment
+;;

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/fsharp/comments.expect.txt test/markup/fsharp/comments.txt
