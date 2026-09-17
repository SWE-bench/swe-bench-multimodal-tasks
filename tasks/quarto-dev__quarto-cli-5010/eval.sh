#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 7f8bc06d2ddbc5ddd1b8ae21e63d4ed5ee0c5861
git checkout 7f8bc06d2ddbc5ddd1b8ae21e63d4ed5ee0c5861 tests/smoke/site/render-blog.test.ts && rm -f tests/docs/blog-grid/posts/remote-img/index.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/blog-grid/posts/remote-img/index.qmd b/tests/docs/blog-grid/posts/remote-img/index.qmd
new file mode 100644
index 0000000000..43e09dd595
--- /dev/null
+++ b/tests/docs/blog-grid/posts/remote-img/index.qmd
@@ -0,0 +1,10 @@
+---
+title: "This has remote"
+author: "Tristan O'Malley"
+date: 10-10-2019
+categories: [news]
+---
+
+This post should have a remote preview image.
+
+![](https://www.charlesteague.com/blog/writing-style/west.jpg)
diff --git a/tests/smoke/site/render-blog.test.ts b/tests/smoke/site/render-blog.test.ts
index a0e33c8cc8..810581a748 100644
--- a/tests/smoke/site/render-blog.test.ts
+++ b/tests/smoke/site/render-blog.test.ts
@@ -23,5 +23,6 @@ testSite(docs("blog-grid/index.qmd"), docs("blog-grid"), [
   "div.list.grid.quarto-listing-cols-3 > div:nth-child(1) div.listing-item-img-placeholder.card-img-top", // Placeholder structure correct
   "div.list.grid.quarto-listing-cols-3 > div:nth-child(2) p.card-img-top > img", // The grid image structure is correct
   "div.list.grid.quarto-listing-cols-3 > div:nth-child(3) p.card-img-top > img", // The grid image structure is correct
+  "div.list.grid.quarto-listing-cols-3 > div:nth-child(4) p.card-img-top > img[src ^= 'https://www.charlesteague.com/blog/writing-style/west.jpg']" // The image path isn't mangled
 ], []);
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout 7f8bc06d2ddbc5ddd1b8ae21e63d4ed5ee0c5861 tests/smoke/site/render-blog.test.ts && rm -f tests/docs/blog-grid/posts/remote-img/index.qmd
