#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff d89383b3c0d930f5d10de128e57ff9074cea68e9
rm -f tests/docs/code-tools/code-tools-activated.qmd tests/docs/code-tools/code-tools-external-source.qmd tests/docs/code-tools/code-tools-toggle.qmd tests/smoke/render/render-code-tools.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/code-tools/code-tools-activated.qmd b/tests/docs/code-tools/code-tools-activated.qmd
new file mode 100644
index 0000000000..f5f72ae35e
--- /dev/null
+++ b/tests/docs/code-tools/code-tools-activated.qmd
@@ -0,0 +1,10 @@
+---
+title: "with code tools"
+format: 
+  html:
+    code-tools: true
+---
+
+```{r}
+1 + 2
+```
\ No newline at end of file
diff --git a/tests/docs/code-tools/code-tools-external-source.qmd b/tests/docs/code-tools/code-tools-external-source.qmd
new file mode 100644
index 0000000000..933fdd040c
--- /dev/null
+++ b/tests/docs/code-tools/code-tools-external-source.qmd
@@ -0,0 +1,11 @@
+---
+title: "with code tools"
+format: 
+  html:
+    code-tools: 
+      source: https://github.com/quarto-dev/quarto-web/blob/main/index.qmd
+---
+
+```{r}
+1 + 2
+```
\ No newline at end of file
diff --git a/tests/docs/code-tools/code-tools-toggle.qmd b/tests/docs/code-tools/code-tools-toggle.qmd
new file mode 100644
index 0000000000..a3815b8020
--- /dev/null
+++ b/tests/docs/code-tools/code-tools-toggle.qmd
@@ -0,0 +1,12 @@
+---
+title: "with code tools"
+format: 
+  html:
+    code-fold: true
+    code-tools:
+      toggle: true
+---
+
+```{r}
+1 + 2
+```
\ No newline at end of file
diff --git a/tests/smoke/render/render-code-tools.test.ts b/tests/smoke/render/render-code-tools.test.ts
new file mode 100644
index 0000000000..90ed54fddb
--- /dev/null
+++ b/tests/smoke/render/render-code-tools.test.ts
@@ -0,0 +1,36 @@
+/*
+* render-r.test.ts
+*
+* Copyright (C) 2020 by RStudio, PBC
+*
+*/
+
+import { fileLoader } from "../../utils.ts";
+import { ensureHtmlElements } from "../../verify.ts";
+import { testRender } from "./render.ts";
+
+let doc = fileLoader("code-tools")(
+  "code-tools-activated.qmd",
+  "html",
+);
+testRender(doc.input, "html", false, [
+  ensureHtmlElements(doc.output.outputPath, [
+    "div.quarto-title-block button#quarto-code-tools-source",
+    "div#quarto-embedded-source-code-modal",
+  ]),
+]);
+
+doc = fileLoader("code-tools")("code-tools-toggle.qmd", "html");
+testRender(doc.input, "html", false, [
+  ensureHtmlElements(doc.output.outputPath, [
+    "div.quarto-title-block button#quarto-code-tools-menu",
+    "div.cell > details",
+  ]),
+]);
+
+doc = fileLoader("code-tools")("code-tools-external-source.qmd", "html");
+testRender(doc.input, "html", false, [
+  ensureHtmlElements(doc.output.outputPath, [
+    "div.quarto-title-block button#quarto-code-tools-source[data-quarto-source-url]",
+  ]),
+]);
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/code-tools/code-tools-activated.qmd tests/docs/code-tools/code-tools-external-source.qmd tests/docs/code-tools/code-tools-toggle.qmd tests/smoke/render/render-code-tools.test.ts
