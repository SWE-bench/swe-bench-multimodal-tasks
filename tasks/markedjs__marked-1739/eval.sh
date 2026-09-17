#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff a9384eea7ae8bea6ef8a95470b315c73fdb3c189
git checkout a9384eea7ae8bea6ef8a95470b315c73fdb3c189 test/helpers/html-differ.js test/specs/new/html_comments.html test/specs/new/html_comments.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/helpers/html-differ.js b/test/helpers/html-differ.js
index 1d92b7d84b..91e781845b 100644
--- a/test/helpers/html-differ.js
+++ b/test/helpers/html-differ.js
@@ -1,5 +1,8 @@
 const HtmlDiffer = require('@markedjs/html-differ').HtmlDiffer;
-const htmlDiffer = new HtmlDiffer({ ignoreSelfClosingSlash: true });
+const htmlDiffer = new HtmlDiffer({
+  ignoreSelfClosingSlash: true,
+  ignoreComments: false
+});
 
 module.exports = {
   isEqual: htmlDiffer.isEqual.bind(htmlDiffer),
diff --git a/test/specs/new/html_comments.html b/test/specs/new/html_comments.html
index 872b45f6ae..745d823b7e 100644
--- a/test/specs/new/html_comments.html
+++ b/test/specs/new/html_comments.html
@@ -55,3 +55,9 @@ <h3 id="example-12">Example 12</h3>
 <p>&lt;!---&gt; not a comment --&gt;</p>
 
 <!-- <!-- not a comment? --> -->
+
+<h3 id="example-13">Example 13</h3>
+
+<!-- block ends at the end of the document since --!>
+
+*is not a valid comment ending*
diff --git a/test/specs/new/html_comments.md b/test/specs/new/html_comments.md
index 06aff02e1d..9a4947b2ae 100644
--- a/test/specs/new/html_comments.md
+++ b/test/specs/new/html_comments.md
@@ -53,4 +53,10 @@ comment
 
 <!---> not a comment -->
 
-<!-- <!-- not a comment? --> -->
\ No newline at end of file
+<!-- <!-- not a comment? --> -->
+
+### Example 13
+
+<!-- block ends at the end of the document since --!>
+
+*is not a valid comment ending*

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout a9384eea7ae8bea6ef8a95470b315c73fdb3c189 test/helpers/html-differ.js test/specs/new/html_comments.html test/specs/new/html_comments.md
