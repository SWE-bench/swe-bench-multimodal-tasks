#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 88d5f23ed603c05bc26ef3245e5c0d051deb66e9
rm -f tests/docs/smoke-all/2022/10/06/issue-2228.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2022/10/06/issue-2228.qmd b/tests/docs/smoke-all/2022/10/06/issue-2228.qmd
new file mode 100644
index 0000000000..b38139b57f
--- /dev/null
+++ b/tests/docs/smoke-all/2022/10/06/issue-2228.qmd
@@ -0,0 +1,13 @@
+---
+format: html
+---
+
+::: {#thm-line}
+
+## Line (with or without the Lua filter error occurs)
+
+```
+1+1
+```
+
+:::
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2022/10/06/issue-2228.qmd
