#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2665552ba0057e8603f9fbece0fd236f189f5cf3
git checkout 2665552ba0057e8603f9fbece0fd236f189f5cf3 tests/fixtures/code-path-analysis/assignment--nested-and-3.js tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js && rm -f tests/fixtures/code-path-analysis/logical--and-qq.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/fixtures/code-path-analysis/assignment--nested-and-3.js b/tests/fixtures/code-path-analysis/assignment--nested-and-3.js
index 8bb52f02239..09ca58fade5 100644
--- a/tests/fixtures/code-path-analysis/assignment--nested-and-3.js
+++ b/tests/fixtures/code-path-analysis/assignment--nested-and-3.js
@@ -1,7 +1,8 @@
 /*expected
 initial->s1_1->s1_2->s1_3->s1_4;
-s1_1->s1_4;
-s1_2->s1_4->final;
+s1_1->s1_3;
+s1_2->s1_4;
+s1_1->s1_4->final;
 */
 (a &&= b) ?? c;
 
@@ -15,7 +16,8 @@ digraph {
     s1_3[label="Identifier (c)"];
     s1_4[label="LogicalExpression:exit\nExpressionStatement:exit\nProgram:exit"];
     initial->s1_1->s1_2->s1_3->s1_4;
-    s1_1->s1_4;
-    s1_2->s1_4->final;
+    s1_1->s1_3;
+    s1_2->s1_4;
+    s1_1->s1_4->final;
 }
 */
diff --git a/tests/fixtures/code-path-analysis/logical--and-qq.js b/tests/fixtures/code-path-analysis/logical--and-qq.js
new file mode 100644
index 00000000000..5ce3853a240
--- /dev/null
+++ b/tests/fixtures/code-path-analysis/logical--and-qq.js
@@ -0,0 +1,22 @@
+/*expected
+initial->s1_1->s1_2->s1_3->s1_4;
+s1_1->s1_3;
+s1_2->s1_4;
+s1_1->s1_4->final;
+*/
+(a && b) ?? c;
+
+/*DOT
+digraph {
+    node[shape=box,style="rounded,filled",fillcolor=white];
+    initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
+    final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
+    s1_1[label="Program:enter\nExpressionStatement:enter\nLogicalExpression:enter\nLogicalExpression:enter\nIdentifier (a)"];
+    s1_2[label="Identifier (b)\nLogicalExpression:exit"];
+    s1_3[label="Identifier (c)"];
+    s1_4[label="LogicalExpression:exit\nExpressionStatement:exit\nProgram:exit"];
+    initial->s1_1->s1_2->s1_3->s1_4;
+    s1_1->s1_3;
+    s1_2->s1_4;
+    s1_1->s1_4->final;
+}*/
diff --git a/tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js b/tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js
index 4863ac81db3..427cc22ec5a 100644
--- a/tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js
+++ b/tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js
@@ -1,8 +1,9 @@
 /*expected
 initial->s1_1->s1_2->s1_3->s1_4->s1_6;
-s1_1->s1_5->s1_6;
+s1_1->s1_3;
 s1_2->s1_4;
-s1_3->s1_5;
+s1_3->s1_5->s1_6;
+s1_1->s1_5;
 s1_2->s1_5;
 s1_6->final;
 */
@@ -24,9 +25,10 @@ digraph {
     s1_6[label="IfStatement:exit\nProgram:exit"];
     s1_5[label="BlockStatement\nExpressionStatement\nCallExpression\nIdentifier (bar)\nIdentifier:exit (bar)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit"];
     initial->s1_1->s1_2->s1_3->s1_4->s1_6;
-    s1_1->s1_5->s1_6;
+    s1_1->s1_3;
     s1_2->s1_4;
-    s1_3->s1_5;
+    s1_3->s1_5->s1_6;
+    s1_1->s1_5;
     s1_2->s1_5;
     s1_6->final;
 }

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"
: '>>>>> End Test Output'
git checkout 2665552ba0057e8603f9fbece0fd236f189f5cf3 tests/fixtures/code-path-analysis/assignment--nested-and-3.js tests/fixtures/code-path-analysis/logical--if-mix-and-qq-1.js && rm -f tests/fixtures/code-path-analysis/logical--and-qq.js
