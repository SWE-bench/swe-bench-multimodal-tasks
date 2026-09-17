#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 41db022ccd52995f2ea7553a9be4b6a6b2021980
rm -f tests/docs/smoke-all/2023/03/09/code.R tests/docs/smoke-all/2023/03/09/revealjs-knitr-embed-verbatim.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/03/09/code.R b/tests/docs/smoke-all/2023/03/09/code.R
new file mode 100644
index 0000000000..041a291f37
--- /dev/null
+++ b/tests/docs/smoke-all/2023/03/09/code.R
@@ -0,0 +1,1 @@
+cat("this is code.R\n")
\ No newline at end of file
diff --git a/tests/docs/smoke-all/2023/03/09/revealjs-knitr-embed-verbatim.qmd b/tests/docs/smoke-all/2023/03/09/revealjs-knitr-embed-verbatim.qmd
new file mode 100644
index 0000000000..e9bf9d1bf6
--- /dev/null
+++ b/tests/docs/smoke-all/2023/03/09/revealjs-knitr-embed-verbatim.qmd
@@ -0,0 +1,28 @@
+---
+format: 
+  revealjs: default
+engine: knitr
+_quarto:
+  tests:
+    revealjs:
+      ensureHtmlElements:
+        - ["#verbatim div.sourceCode pre code", "#embed div.sourceCode pre code"]
+        - ["#verbatim div.cell", "#embed div.cell"]
+      ensureFileRegexMatches:
+        - ["this is code\\.R"]
+        - []
+---
+
+From issue : https://github.com/quarto-dev/quarto-cli/issues/4712
+
+## Verbatim {#verbatim}
+
+````{verbatim}
+Some content
+````
+
+## Embed {#embed}
+
+````{embed, file = "code.R"}
+````
+

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/03/09/code.R tests/docs/smoke-all/2023/03/09/revealjs-knitr-embed-verbatim.qmd
