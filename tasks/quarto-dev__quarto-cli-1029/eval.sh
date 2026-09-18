#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff d3a64180bdbfd5e69d01d38eff4581d739f6b73a
git checkout d3a64180bdbfd5e69d01d38eff4581d739f6b73a tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/reveal/stretch.qmd b/tests/docs/reveal/stretch.qmd
index d81abb2751..65f191e877 100644
--- a/tests/docs/reveal/stretch.qmd
+++ b/tests/docs/reveal/stretch.qmd
@@ -234,4 +234,12 @@ Some content
 plot(cars)
 ```
 
+:::
+
+## With aside on slide  {#aside}
+
+![Caption](https://revealjs.com/images/logo/reveal-black-text.svg)
+
+::: {.aside}
+Something here as an aside
 :::
\ No newline at end of file
diff --git a/tests/smoke/render/render-reveal.test.ts b/tests/smoke/render/render-reveal.test.ts
index f2de8abaef..724f296fea 100644
--- a/tests/smoke/render/render-reveal.test.ts
+++ b/tests/smoke/render/render-reveal.test.ts
@@ -66,5 +66,6 @@ testRender(input, "revealjs", false, [
     "#custom-divs-caption img.r-stretch",
     "#custom-divs-knitr img.r-stretch",
     "#custom-divs-knitr-caption img.r-stretch",
+    "#aside img.r-stretch",
   ]),
 ]);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout d3a64180bdbfd5e69d01d38eff4581d739f6b73a tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
