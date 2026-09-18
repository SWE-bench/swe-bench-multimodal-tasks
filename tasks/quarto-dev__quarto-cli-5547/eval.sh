#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff fa057a6f3648aedf995952287449be08fb3bbdee
git checkout fa057a6f3648aedf995952287449be08fb3bbdee tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/reveal/stretch.qmd b/tests/docs/reveal/stretch.qmd
index 9a1f40a11a..504b1629dc 100644
--- a/tests/docs/reveal/stretch.qmd
+++ b/tests/docs/reveal/stretch.qmd
@@ -248,4 +248,8 @@ Something here as an aside
 
 See the feature https://quarto.org/docs/presentations/revealjs/advanced.html#absolute-position from
 
-![](https://quarto.org/quarto.png){.absolute width=500}
\ No newline at end of file
+![](https://quarto.org/quarto.png){.absolute width=500}
+
+## No auto stretch if image is inside linke {#link}
+
+[![](https://quarto.org/docs/blog/posts/2023-04-26-1.3-release/arthur-chauvineau-Dn7P1U26ZkE-unsplash.jpeg)](https://google.com)
\ No newline at end of file
diff --git a/tests/smoke/render/render-reveal.test.ts b/tests/smoke/render/render-reveal.test.ts
index e032ceba86..04ea3fbdcf 100644
--- a/tests/smoke/render/render-reveal.test.ts
+++ b/tests/smoke/render/render-reveal.test.ts
@@ -71,6 +71,7 @@ testRender(input, "revealjs", false, [
     "#custom-divs-knitr-caption img.r-stretch",
     "#aside img.r-stretch",
     "#absolute img.r-stretch",
+    "#link img.r-stretch",
   ]),
 ]);
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout fa057a6f3648aedf995952287449be08fb3bbdee tests/docs/reveal/stretch.qmd tests/smoke/render/render-reveal.test.ts
