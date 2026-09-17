#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 3bd13115d1ba73ba8edaccaa15f16558add88980
rm -f tests/docs/smoke-all/2023/09/19/issue-2492-b.qmd tests/docs/smoke-all/2023/09/19/issue-2492.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/09/19/issue-2492-b.qmd b/tests/docs/smoke-all/2023/09/19/issue-2492-b.qmd
new file mode 100644
index 0000000000..b53fa0c313
--- /dev/null
+++ b/tests/docs/smoke-all/2023/09/19/issue-2492-b.qmd
@@ -0,0 +1,26 @@
+---
+title: "MWE"
+format: latex
+_quarto:
+  tests:
+    latex:
+      ensureFileRegexMatches:
+        - 
+          - "\\\\label\\{fig-e1b\\}"
+          - "\\\\label\\{fig-e1a\\}"
+          - "\\\\subcaption\\{.*Surus\\}"
+          - "\\\\subcaption\\{.*Hanno\\}"
+        - []
+---
+
+Figures
+
+::: {#fig-elephants layout-ncol="2"}
+
+![Surus](elephant.jpg){#fig-e1a}
+
+![Hanno](elephant.jpg){#fig-e1b}
+
+Famous Elephants
+:::
+
diff --git a/tests/docs/smoke-all/2023/09/19/issue-2492.qmd b/tests/docs/smoke-all/2023/09/19/issue-2492.qmd
new file mode 100644
index 0000000000..0f7a45b3ff
--- /dev/null
+++ b/tests/docs/smoke-all/2023/09/19/issue-2492.qmd
@@ -0,0 +1,23 @@
+---
+title: "MWE"
+format: latex
+_quarto:
+  tests:
+    latex:
+      ensureFileRegexMatches:
+        - 
+          - "\\\\subcaption\\{.*Surus\\}"
+          - "\\\\subcaption\\{.*Hanno\\}"
+        - []
+---
+
+Figures
+
+::: {#fig-elephants layout-ncol="2"}
+
+![Surus](elephant.jpg)
+
+![Hanno](elephant.jpg)
+
+Famous Elephants
+:::

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/09/19/issue-2492-b.qmd tests/docs/smoke-all/2023/09/19/issue-2492.qmd
