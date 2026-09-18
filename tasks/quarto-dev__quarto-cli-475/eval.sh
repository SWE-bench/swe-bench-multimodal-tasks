#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 336f7e96b00626b79138938ac22d27ba1d764034
git checkout 336f7e96b00626b79138938ac22d27ba1d764034 tests/docs/callouts.qmd tests/smoke/render/render-callout.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/callouts.qmd b/tests/docs/callouts.qmd
index 9141f321eb..bdb1eabedb 100644
--- a/tests/docs/callouts.qmd
+++ b/tests/docs/callouts.qmd
@@ -24,6 +24,12 @@ Note that there are five types of callouts, including: `note`, `tip`, `warning`,
 This is an example of a callout with a caption.
 :::
 
+::: {.callout-tip}
+## Caption with **formatted** text, like `function_name()`
+
+This is an example of a callout with a caption containing special formatting and characters.
+:::
+
 ::: {.callout-caution collapse="true"}
 ## Expand To Learn About Collapse
 
diff --git a/tests/smoke/render/render-callout.test.ts b/tests/smoke/render/render-callout.test.ts
index a74f1b5c29..77ad2978ad 100644
--- a/tests/smoke/render/render-callout.test.ts
+++ b/tests/smoke/render/render-callout.test.ts
@@ -19,12 +19,16 @@ const htmlOutput = outputForInput(input, "html");
 
 testRender(input, "html", false, [
   ensureHtmlElements(htmlOutput.outputPath, [
+    // callout environments are created
     "div.callout-warning",
     "div.callout-important",
     "div.callout-note",
     "div.callout-tip",
     "div.callout-caution",
     "div.callout.no-icon",
+    // formatting is kept in caption
+    "div.callout-tip > div.callout-header > div.callout-caption-container > strong",
+    "div.callout-tip > div.callout-header > div.callout-caption-container > code"
   ]),
 ]);
 
@@ -33,21 +37,27 @@ testRender(input, "latex", true, [
   ensureFileRegexMatches(teXOutput.outputPath, [
     requireLatexPackage("fontawesome5"),
     requireLatexPackage("tcolorbox", "many"),
+    // callout environments are created
     /quarto-callout-warning/,
     /quarto-callout-important/,
     /quarto-callout-note/,
     /quarto-callout-tip/,
     /quarto-callout-caution/,
+    // formatting is kept in caption,
+    /{Caption with \\textbf{formatted} text, like \\texttt{function\\_name\(\)}/,
   ]),
 ]);
 
 const docXoutput = outputForInput(input, "docx");
 testRender(input, "docx", true, [
   ensureDocxRegexMatches(docXoutput.outputPath, [
+    // callout environments are created
     /<pic:cNvPr.*warning\.png".*?\/>/,
     /<pic:cNvPr.*important\.png".*?\/>/,
     /<pic:cNvPr.*note\.png".*?\/>/,
     /<pic:cNvPr.*tip\.png".*?\/>/,
     /<pic:cNvPr.*caution\.png".*?\/>/,
+    // formatting is kept in caption,
+    /Caption with.*<w:bCs.*formatted.*text, like.*<w:rStyle w:val="VerbatimChar".*function_name\(\)/
   ]),
 ]);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout 336f7e96b00626b79138938ac22d27ba1d764034 tests/docs/callouts.qmd tests/smoke/render/render-callout.test.ts
