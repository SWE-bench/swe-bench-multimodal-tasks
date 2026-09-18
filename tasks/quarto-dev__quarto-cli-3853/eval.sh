#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff fdfdd315475c4204c790be2ebe105ab4cfa15a34
git checkout fdfdd315475c4204c790be2ebe105ab4cfa15a34 tests/smoke/crossref/latex.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/smoke/crossref/latex.test.ts b/tests/smoke/crossref/latex.test.ts
index 0dcf7296c1..77d3df41f9 100644
--- a/tests/smoke/crossref/latex.test.ts
+++ b/tests/smoke/crossref/latex.test.ts
@@ -32,10 +32,14 @@ const subTableRegexes = [
 ];
 
 const theoremRegexes = [
-  /\\begin{theorem}[^]*?\\label{thm-line}[^]*?\\end{theorem}/,
+  /\\begin{theorem}[^]*?\\protect\\hypertarget{thm-line}{}\\label{thm-line}[^]*?\\end{theorem}/,
   /Theorem~\\ref{thm-line}/,
 ];
 
+const theoremRegexesNo = [
+  /\\leavevmode\\vadjust pre{\\hypertarget{thm-line}{}}%/,
+];
+
 testRender(allQmd.input, "latex", true, [
   ensureFileRegexMatches(allQmd.output.outputPath, [
     ...simpleFigRegexes,
@@ -43,5 +47,7 @@ testRender(allQmd.input, "latex", true, [
     ...simpleTableRegexes,
     ...subTableRegexes,
     ...theoremRegexes,
+  ], [
+    ...theoremRegexesNo,
   ]),
 ]);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout fdfdd315475c4204c790be2ebe105ab4cfa15a34 tests/smoke/crossref/latex.test.ts
