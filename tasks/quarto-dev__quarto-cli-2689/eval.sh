#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 397b81ed3d5f26cc59ae6c4ad3feeaa815bb3afb
rm -f tests/docs/smoke-all/2022/09/30/crossref-false/crossref-false.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2022/09/30/crossref-false/crossref-false.qmd b/tests/docs/smoke-all/2022/09/30/crossref-false/crossref-false.qmd
new file mode 100644
index 0000000000..78b43d8451
--- /dev/null
+++ b/tests/docs/smoke-all/2022/09/30/crossref-false/crossref-false.qmd
@@ -0,0 +1,7 @@
+---
+format:
+  html:
+    crossref: false
+---
+
+# A test

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2022/09/30/crossref-false/crossref-false.qmd
