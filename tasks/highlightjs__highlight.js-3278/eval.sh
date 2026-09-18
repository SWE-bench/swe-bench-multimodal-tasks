#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 0f70132be18769c36b33740c99276e355b0b8702
git checkout 0f70132be18769c36b33740c99276e355b0b8702 test/markup/javascript/jsx.expect.txt test/markup/javascript/jsx.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/javascript/jsx.expect.txt b/test/markup/javascript/jsx.expect.txt
index 41e17403a3..c10ef1add8 100644
--- a/test/markup/javascript/jsx.expect.txt
+++ b/test/markup/javascript/jsx.expect.txt
@@ -25,3 +25,21 @@
 }
 
 <span class="hljs-keyword">var</span> x = <span class="hljs-number">5</span>;
+
+<span class="hljs-comment">// this is NOT JSX and should not trigger the rule</span>
+interface <span class="hljs-title class_">Prefixer</span>&lt;<span class="hljs-title class_">Something</span> <span class="hljs-keyword">extends</span> string&gt; {
+  (): <span class="hljs-string">`other__<span class="hljs-subst">${Something}</span>`</span>;
+
+  <span class="hljs-attr">parse</span>: &lt;<span class="hljs-title class_">From</span> <span class="hljs-keyword">extends</span> string&gt;<span class="hljs-function">(<span class="hljs-params">
+    value: From
+  </span>) =&gt;</span> number;
+}
+
+<span class="hljs-keyword">const</span> cloneWith = &lt;T, A <span class="hljs-keyword">extends</span> keyof T, V&gt;(
+  <span class="hljs-attr">i</span>: T,
+  <span class="hljs-attr">a</span>: A,
+  <span class="hljs-attr">value</span>: V
+): <span class="hljs-title class_">Omit</span>&lt;T, A&gt; &amp; {[K <span class="hljs-keyword">in</span> A]: V} =&gt; ({
+  ...i,
+  [a]: value,
+});
\ No newline at end of file
diff --git a/test/markup/javascript/jsx.txt b/test/markup/javascript/jsx.txt
index a76ef8eecd..4cb3104d10 100644
--- a/test/markup/javascript/jsx.txt
+++ b/test/markup/javascript/jsx.txt
@@ -25,3 +25,21 @@ class App extends Component {
 }
 
 var x = 5;
+
+// this is NOT JSX and should not trigger the rule
+interface Prefixer<Something extends string> {
+  (): `other__${Something}`;
+
+  parse: <From extends string>(
+    value: From
+  ) => number;
+}
+
+const cloneWith = <T, A extends keyof T, V>(
+  i: T,
+  a: A,
+  value: V
+): Omit<T, A> & {[K in A]: V} => ({
+  ...i,
+  [a]: value,
+});
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 0f70132be18769c36b33740c99276e355b0b8702 test/markup/javascript/jsx.expect.txt test/markup/javascript/jsx.txt
