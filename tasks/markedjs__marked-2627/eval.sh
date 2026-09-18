#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 2c9728da0c36ba30ac91362bdcd93bdc63a1bd35
git checkout 2c9728da0c36ba30ac91362bdcd93bdc63a1bd35 test/unit/Lexer-spec.js && rm -f test/specs/new/escape_within_emphasis.html test/specs/new/escape_within_emphasis.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/escape_within_emphasis.html b/test/specs/new/escape_within_emphasis.html
new file mode 100644
index 0000000000..c5885c607b
--- /dev/null
+++ b/test/specs/new/escape_within_emphasis.html
@@ -0,0 +1,7 @@
+<p><strong>strong text[</strong>]</p>
+
+<p><strong>strong text\[</strong>]</p>
+
+<p><em>em[pha](sis)</em></p>
+
+<p><em>\</em></p>
diff --git a/test/specs/new/escape_within_emphasis.md b/test/specs/new/escape_within_emphasis.md
new file mode 100644
index 0000000000..03a7295b85
--- /dev/null
+++ b/test/specs/new/escape_within_emphasis.md
@@ -0,0 +1,7 @@
+**strong text\[**\]
+
+**strong text\\\[**\]
+
+_em\[pha\]\(sis\)_
+
+_\\_
diff --git a/test/unit/Lexer-spec.js b/test/unit/Lexer-spec.js
index 23913b6e4a..8174d53139 100644
--- a/test/unit/Lexer-spec.js
+++ b/test/unit/Lexer-spec.js
@@ -776,6 +776,41 @@ paragraph
         });
       });
 
+      it('escaped punctuation inside emphasis', () => {
+        expectInlineTokens({
+          md: '**strong text\\[**\\]',
+          tokens: [
+            {
+              type: 'strong',
+              raw: '**strong text\\[**',
+              text: 'strong text\\[',
+              tokens: [
+                { type: 'text', raw: 'strong text', text: 'strong text' },
+                { type: 'escape', raw: '\\[', text: '[' }
+              ]
+            },
+            { type: 'escape', raw: '\\]', text: ']' }
+          ]
+        });
+        expectInlineTokens({
+          md: '_em\\<pha\\>sis_',
+          tokens: [
+            {
+              type: 'em',
+              raw: '_em\\<pha\\>sis_',
+              text: 'em\\<pha\\>sis',
+              tokens: [
+                { type: 'text', raw: 'em', text: 'em' },
+                { type: 'escape', raw: '\\<', text: '&lt;' },
+                { type: 'text', raw: 'pha', text: 'pha' },
+                { type: 'escape', raw: '\\>', text: '&gt;' },
+                { type: 'text', raw: 'sis', text: 'sis' }
+              ]
+            }
+          ]
+        });
+      });
+
       it('html', () => {
         expectInlineTokens({
           md: '<div>html</div>',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout 2c9728da0c36ba30ac91362bdcd93bdc63a1bd35 test/unit/Lexer-spec.js && rm -f test/specs/new/escape_within_emphasis.html test/specs/new/escape_within_emphasis.md
