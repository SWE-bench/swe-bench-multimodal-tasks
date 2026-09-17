#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c8783a3c1087c5a899ea6c1b96eb8a8e89fcd739
git checkout c8783a3c1087c5a899ea6c1b96eb8a8e89fcd739 test/specs/new/code_compensation_indent.html test/specs/new/code_consistent_newline.html test/unit/marked-spec.js && rm -f test/specs/new/whiltespace_lines.html test/specs/new/whiltespace_lines.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/code_compensation_indent.html b/test/specs/new/code_compensation_indent.html
index b6b7d227b4..4c2ebefb8a 100644
--- a/test/specs/new/code_compensation_indent.html
+++ b/test/specs/new/code_compensation_indent.html
@@ -2,6 +2,7 @@
 <ol>
 <li><p>This is a list element.</p>
 <pre><code>const x = 5;
-const y = x + 5;</code></pre>
+const y = x + 5;
+</code></pre>
 </li>
 </ol>
diff --git a/test/specs/new/code_consistent_newline.html b/test/specs/new/code_consistent_newline.html
index f1ebc6fc8d..41a15c4ee8 100644
--- a/test/specs/new/code_consistent_newline.html
+++ b/test/specs/new/code_consistent_newline.html
@@ -1,3 +1,5 @@
-<pre><code class="language-js">const value = 42;</code></pre>
-<pre><code>const value = 42;</code></pre>
+<pre><code class="language-js">const value = 42;
+</code></pre>
+<pre><code>const value = 42;
+</code></pre>
 <p>Code blocks contain trailing new line.</p>
diff --git a/test/specs/new/whiltespace_lines.html b/test/specs/new/whiltespace_lines.html
new file mode 100644
index 0000000000..97931fe26a
--- /dev/null
+++ b/test/specs/new/whiltespace_lines.html
@@ -0,0 +1,12 @@
+<p>paragraph</p>
+<p>test</p>
+<pre><code>a
+  
+b
+
+c
+</code></pre>
+<pre><code>a
+  
+b
+</code></pre>
diff --git a/test/specs/new/whiltespace_lines.md b/test/specs/new/whiltespace_lines.md
new file mode 100644
index 0000000000..ff645b3842
--- /dev/null
+++ b/test/specs/new/whiltespace_lines.md
@@ -0,0 +1,18 @@
+---
+renderExact: true
+---
+paragraph
+  
+test
+
+    a
+      
+    b
+  
+    c
+
+```
+a
+  
+b
+```
diff --git a/test/unit/marked-spec.js b/test/unit/marked-spec.js
index fcee51a3eb..7d81117288 100644
--- a/test/unit/marked-spec.js
+++ b/test/unit/marked-spec.js
@@ -335,12 +335,15 @@ text 1
         fail(err);
       }
 
-      expect(html).toBe(`<pre><code class="language-lang1">async text 1</code></pre>
+      expect(html).toBe(`<pre><code class="language-lang1">async text 1
+</code></pre>
 <blockquote>
-<pre><code class="language-lang2">async text 2</code></pre>
+<pre><code class="language-lang2">async text 2
+</code></pre>
 </blockquote>
 <ul>
-<li><pre><code class="language-lang3">async text 3</code></pre>
+<li><pre><code class="language-lang3">async text 3
+</code></pre>
 </li>
 </ul>
 `);
@@ -378,12 +381,15 @@ text 1
         fail(err);
       }
 
-      expect(html).toBe(`<pre><code class="language-lang1">async text 1</code></pre>
+      expect(html).toBe(`<pre><code class="language-lang1">async text 1
+</code></pre>
 <blockquote>
-<pre><code class="language-lang2">async text 2</code></pre>
+<pre><code class="language-lang2">async text 2
+</code></pre>
 </blockquote>
 <ul>
-<li><pre><code class="language-lang3">async text 3</code></pre>
+<li><pre><code class="language-lang3">async text 3
+</code></pre>
 </li>
 </ul>
 `);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout c8783a3c1087c5a899ea6c1b96eb8a8e89fcd739 test/specs/new/code_compensation_indent.html test/specs/new/code_consistent_newline.html test/unit/marked-spec.js && rm -f test/specs/new/whiltespace_lines.html test/specs/new/whiltespace_lines.md
