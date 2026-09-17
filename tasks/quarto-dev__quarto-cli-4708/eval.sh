#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff ed1b05795d0a677f377b888a60a131c005dedd70
rm -f tests/docs/smoke-all/2023/03/08/revealjs-hash-number-pandoc-style.qmd tests/docs/smoke-all/2023/03/08/revealjs-hash-number.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/03/08/revealjs-hash-number-pandoc-style.qmd b/tests/docs/smoke-all/2023/03/08/revealjs-hash-number-pandoc-style.qmd
new file mode 100644
index 0000000000..1114ce8670
--- /dev/null
+++ b/tests/docs/smoke-all/2023/03/08/revealjs-hash-number-pandoc-style.qmd
@@ -0,0 +1,17 @@
+---
+title: Slide title
+format:
+  revealjs:
+    hash-type: number
+title-slide-style: pandoc
+_quarto:
+  tests:
+    revealjs:
+      ensureHtmlElements:
+        - ["div.reveal > div.slides > section.quarto-title-block" ]
+        - ["#title-slide"]
+---
+
+## slide 1
+
+Content
diff --git a/tests/docs/smoke-all/2023/03/08/revealjs-hash-number.qmd b/tests/docs/smoke-all/2023/03/08/revealjs-hash-number.qmd
new file mode 100644
index 0000000000..921b5b93d6
--- /dev/null
+++ b/tests/docs/smoke-all/2023/03/08/revealjs-hash-number.qmd
@@ -0,0 +1,16 @@
+---
+title: Slide title
+format:
+  revealjs:
+    hash-type: number
+_quarto:
+  tests:
+    revealjs:
+      ensureHtmlElements:
+        - ["div.reveal > div.slides > section.quarto-title-block" ]
+        - ["#title-slide"]
+---
+
+## slide 1
+
+Content

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/03/08/revealjs-hash-number-pandoc-style.qmd tests/docs/smoke-all/2023/03/08/revealjs-hash-number.qmd
