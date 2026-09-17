#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff fac5739c3311296963559053e6fb6a4ec43f7560
rm -f tests/docs/smoke-all/2023/04/04/5089.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/04/04/5089.qmd b/tests/docs/smoke-all/2023/04/04/5089.qmd
new file mode 100644
index 0000000000..a2b96b7bbf
--- /dev/null
+++ b/tests/docs/smoke-all/2023/04/04/5089.qmd
@@ -0,0 +1,13 @@
+---
+title: Simple Document
+format: pdf
+---
+
+## Url with encoding
+
+![](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F9b7345d9-5f62-46dc-8062-d704c2c014a5_289x174.jpeg)
+
+
+## Simple Url
+
+![](https://quarto.org/quarto.png)

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/04/04/5089.qmd
