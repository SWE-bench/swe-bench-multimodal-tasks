#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 71bb7ddd61ff85386f600b87d93bd1cbcb370c77
git checkout 71bb7ddd61ff85386f600b87d93bd1cbcb370c77 tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/reveal/stretch.qmd b/tests/docs/reveal/stretch.qmd
index 6c42951cf6..d81abb2751 100644
--- a/tests/docs/reveal/stretch.qmd
+++ b/tests/docs/reveal/stretch.qmd
@@ -183,3 +183,55 @@ plot(cars)
 ## {#no-content-caption}
 
 ![A logo](https://revealjs.com/images/logo/reveal-black-text.svg)
+
+## No auto stretch if nested {#custom-divs-simple}
+
+::: {.custom-block}
+
+Some content with an image below
+
+![](https://revealjs.com/images/logo/reveal-black-text.svg)
+
+:::
+
+## No auto stretch if nested 2 {#custom-divs-caption}
+
+::: {.custom-block}
+
+Some content with an image below
+
+![A logo](https://revealjs.com/images/logo/reveal-black-text.svg)
+
+:::
+
+## No auto stretch if nested 3 {#custom-divs-knitr}
+
+::: {.custom-block}
+
+```{r, echo = FALSE}
+plot(cars)
+```
+
+:::
+
+## No auto stretch if nested 4 {#custom-divs-knitr-caption}
+
+::: {.custom-block}
+
+```{r, echo = FALSE, fig.cap = "Caption"}
+plot(cars)
+```
+
+:::
+
+## Nested in div supports opt-in  {#custom-divs-opt-in}
+
+::: {.custom-block .r-stretch}
+
+Some content
+
+```{r, echo = FALSE, fig.cap = "Caption"}
+plot(cars)
+```
+
+:::
\ No newline at end of file
diff --git a/tests/smoke/render/render-reveal.test.ts b/tests/smoke/render/render-reveal.test.ts
index 900e662e07..f2de8abaef 100644
--- a/tests/smoke/render/render-reveal.test.ts
+++ b/tests/smoke/render/render-reveal.test.ts
@@ -50,6 +50,7 @@ testRender(input, "revealjs", false, [
     "#knitr-no-caption-and-content > img.r-stretch + div.cell",
     "#no-content > img.r-stretch",
     "#no-content-caption > img.r-stretch + p.caption",
+    "#custom-divs-opt-in > div.custom-block:not(.r-stretch) + img.r-stretch + p.caption",
   ], [
     "#columns img.r-stretch",
     "#more-than-one img.r-stretch",
@@ -60,5 +61,10 @@ testRender(input, "revealjs", false, [
     "#block-layout img.r-stretch",
     "#block-layout2 img.r-stretch",
     "#fig-tab-layout img.r-stretch",
+    "#custom-divs-simple img.r-stretch",
+    "#custom-divs-caption img.r-stretch",
+    "#custom-divs-caption img.r-stretch",
+    "#custom-divs-knitr img.r-stretch",
+    "#custom-divs-knitr-caption img.r-stretch",
   ]),
 ]);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout 71bb7ddd61ff85386f600b87d93bd1cbcb370c77 tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
