#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff ffcca4128a98557e1202323146361e11e851537d
rm -f test/specs/new/unicode_punctuation.html test/specs/new/unicode_punctuation.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/unicode_punctuation.html b/test/specs/new/unicode_punctuation.html
new file mode 100644
index 0000000000..f59ff116fd
--- /dev/null
+++ b/test/specs/new/unicode_punctuation.html
@@ -0,0 +1,28 @@
+<p>Ideographic comma:</p>
+
+<ul>
+  <li>
+    <p>
+      ×: あれ、<strong><code>foo</code>これ</strong>、それ
+    </p>
+  </li>
+  <li>
+    <p>
+      ○: あれ、 <strong><code>foo</code>これ</strong>、それ
+    </p>
+  </li>
+  <li>
+    <p>
+      ×: あれ、<strong><code>foo</code>これ</strong> 、それ
+    </p>
+  </li>
+  <li><p>○: あれ、<strong>fooこれ</strong>、それ</p></li>
+  <li>
+    <p>○: あれ、 <strong>fooこれ</strong>、それ</p>
+  </li>
+  <li>
+    <p>○: あれ、<strong>fooこれ</strong> 、それ</p>
+  </li>
+</ul>
+
+<p><strong>Fullwidth colon</strong>：\uFF1A</p>
diff --git a/test/specs/new/unicode_punctuation.md b/test/specs/new/unicode_punctuation.md
new file mode 100644
index 0000000000..502843b5c8
--- /dev/null
+++ b/test/specs/new/unicode_punctuation.md
@@ -0,0 +1,11 @@
+Ideographic comma:
+
+* ×: あれ、**`foo`これ**、それ
+* ○: あれ、 **`foo`これ**、それ
+* ×: あれ、**`foo`これ** 、それ
+
+* ○: あれ、**fooこれ**、それ
+* ○: あれ、 **fooこれ**、それ
+* ○: あれ、**fooこれ** 、それ
+
+__Fullwidth colon__：\uFF1A

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/specs/new/unicode_punctuation.html test/specs/new/unicode_punctuation.md
