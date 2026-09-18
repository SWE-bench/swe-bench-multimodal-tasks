#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 18207d18b14c00cb33d3e6090177851b3fa57109
git checkout 18207d18b14c00cb33d3e6090177851b3fa57109 test/specs/commonmark/commonmark.0.29.json test/specs/gfm/commonmark.0.29.json test/specs/new/list_item_text.md test/specs/original/literal_quotes_in_titles.md test/unit/Lexer-spec.js test/unit/marked-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/commonmark/commonmark.0.29.json b/test/specs/commonmark/commonmark.0.29.json
index 8399c10c35..2e47a39b95 100644
--- a/test/specs/commonmark/commonmark.0.29.json
+++ b/test/specs/commonmark/commonmark.0.29.json
@@ -1805,8 +1805,7 @@
     "example": 225,
     "start_line": 3834,
     "end_line": 3843,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": "- one\n\n  two\n",
@@ -1822,8 +1821,7 @@
     "example": 227,
     "start_line": 3860,
     "end_line": 3870,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": " -    one\n\n      two\n",
@@ -1979,8 +1977,7 @@
     "example": 246,
     "start_line": 4192,
     "end_line": 4201,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": "-  foo\n\n   bar\n",
@@ -2273,8 +2270,7 @@
     "example": 282,
     "start_line": 5177,
     "end_line": 5191,
-    "section": "Lists",
-    "shouldFail": true
+    "section": "Lists"
   },
   {
     "markdown": "1. a\n\n  2. b\n\n    3. c\n",
@@ -2282,8 +2278,7 @@
     "example": 283,
     "start_line": 5197,
     "end_line": 5214,
-    "section": "Lists",
-    "shouldFail": true
+    "section": "Lists"
   },
   {
     "markdown": "- a\n- b\n\n- c\n",
diff --git a/test/specs/gfm/commonmark.0.29.json b/test/specs/gfm/commonmark.0.29.json
index 36394f5277..a412d89779 100644
--- a/test/specs/gfm/commonmark.0.29.json
+++ b/test/specs/gfm/commonmark.0.29.json
@@ -1805,8 +1805,7 @@
     "example": 225,
     "start_line": 3834,
     "end_line": 3843,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": "- one\n\n  two\n",
@@ -1822,8 +1821,7 @@
     "example": 227,
     "start_line": 3860,
     "end_line": 3870,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": " -    one\n\n      two\n",
@@ -1979,8 +1977,7 @@
     "example": 246,
     "start_line": 4192,
     "end_line": 4201,
-    "section": "List items",
-    "shouldFail": true
+    "section": "List items"
   },
   {
     "markdown": "-  foo\n\n   bar\n",
@@ -2273,8 +2270,7 @@
     "example": 282,
     "start_line": 5177,
     "end_line": 5191,
-    "section": "Lists",
-    "shouldFail": true
+    "section": "Lists"
   },
   {
     "markdown": "1. a\n\n  2. b\n\n    3. c\n",
@@ -2282,8 +2278,7 @@
     "example": 283,
     "start_line": 5197,
     "end_line": 5214,
-    "section": "Lists",
-    "shouldFail": true
+    "section": "Lists"
   },
   {
     "markdown": "- a\n- b\n\n- c\n",
diff --git a/test/specs/new/list_item_text.md b/test/specs/new/list_item_text.md
index a8f81b1404..f022f1eb24 100644
--- a/test/specs/new/list_item_text.md
+++ b/test/specs/new/list_item_text.md
@@ -1,3 +1,6 @@
+---
+pedantic: true
+---
   * item1
 
     * item2
diff --git a/test/specs/original/literal_quotes_in_titles.md b/test/specs/original/literal_quotes_in_titles.md
index 74de60d8fd..43b70b7d02 100644
--- a/test/specs/original/literal_quotes_in_titles.md
+++ b/test/specs/original/literal_quotes_in_titles.md
@@ -8,4 +8,3 @@ Foo [bar](/url/ "Title with "quotes" inside").
 
 
   [bar]: /url/ "Title with "quotes" inside"
-
diff --git a/test/unit/Lexer-spec.js b/test/unit/Lexer-spec.js
index 3a507f010a..f8361ace77 100644
--- a/test/unit/Lexer-spec.js
+++ b/test/unit/Lexer-spec.js
@@ -308,7 +308,7 @@ a | b
             items: [
               {
                 type: 'list_item',
-                raw: '- item 1',
+                raw: '- item 1\n',
                 task: false,
                 checked: undefined,
                 loose: false,
@@ -326,7 +326,7 @@ a | b
                 task: false,
                 checked: undefined,
                 loose: false,
-                text: 'item 2\n',
+                text: 'item 2',
                 tokens: [{
                   type: 'text',
                   raw: 'item 2',
@@ -354,7 +354,7 @@ a | b
             start: 1,
             items: [
               jasmine.objectContaining({
-                raw: '1. item 1'
+                raw: '1. item 1\n'
               }),
               jasmine.objectContaining({
                 raw: '2. item 2\n'
@@ -379,7 +379,7 @@ a | b
             start: 1,
             items: [
               jasmine.objectContaining({
-                raw: '1) item 1'
+                raw: '1) item 1\n'
               }),
               jasmine.objectContaining({
                 raw: '2) item 2\n'
@@ -390,6 +390,66 @@ a | b
       });
     });
 
+    it('space after list', () => {
+      expectTokens({
+        md: `
+- item 1
+- item 2
+
+paragraph
+`,
+        tokens: [
+          {
+            type: 'list',
+            raw: '- item 1\n- item 2\n\n',
+            ordered: false,
+            start: '',
+            loose: false,
+            items: [
+              {
+                type: 'list_item',
+                raw: '- item 1\n',
+                task: false,
+                checked: undefined,
+                loose: false,
+                text: 'item 1',
+                tokens: [{
+                  type: 'text',
+                  raw: 'item 1',
+                  text: 'item 1',
+                  tokens: [{ type: 'text', raw: 'item 1', text: 'item 1' }]
+                }]
+              },
+              {
+                type: 'list_item',
+                raw: '- item 2\n\n',
+                task: false,
+                checked: undefined,
+                loose: false,
+                text: 'item 2',
+                tokens: [{
+                  type: 'text',
+                  raw: 'item 2',
+                  text: 'item 2',
+                  tokens: [{ type: 'text', raw: 'item 2', text: 'item 2' }]
+                }]
+              }
+            ]
+          },
+          {
+            type: 'paragraph',
+            raw: 'paragraph',
+            text: 'paragraph',
+            tokens: [{
+              type: 'text',
+              raw: 'paragraph',
+              text: 'paragraph'
+            }]
+          }
+        ]
+      });
+    });
+
     it('start', () => {
       expectTokens({
         md: `
@@ -404,7 +464,7 @@ a | b
             start: 2,
             items: [
               jasmine.objectContaining({
-                raw: '2. item 1'
+                raw: '2. item 1\n'
               }),
               jasmine.objectContaining({
                 raw: '3. item 2\n'
@@ -426,7 +486,15 @@ a | b
           jasmine.objectContaining({
             type: 'list',
             raw: '- item 1\n\n- item 2\n',
-            loose: true
+            loose: true,
+            items: [
+              jasmine.objectContaining({
+                raw: '- item 1\n\n'
+              }),
+              jasmine.objectContaining({
+                raw: '- item 2\n'
+              })
+            ]
           })
         ])
       });
@@ -444,7 +512,7 @@ a | b
             raw: '- [ ] item 1\n- [x] item 2\n',
             items: [
               jasmine.objectContaining({
-                raw: '- [ ] item 1',
+                raw: '- [ ] item 1\n',
                 task: true,
                 checked: false
               }),
diff --git a/test/unit/marked-spec.js b/test/unit/marked-spec.js
index 7d81117288..c0bcd4027e 100644
--- a/test/unit/marked-spec.js
+++ b/test/unit/marked-spec.js
@@ -465,7 +465,6 @@ br
       ['list_item', '- list'],
       ['text', 'list'],
       ['text', 'list'],
-      ['space', ''],
       ['html', '<div>html</div>'],
       ['paragraph', '[link](https://example.com)'],
       ['link', '[link](https://example.com)'],

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout 18207d18b14c00cb33d3e6090177851b3fa57109 test/specs/commonmark/commonmark.0.29.json test/specs/gfm/commonmark.0.29.json test/specs/new/list_item_text.md test/specs/original/literal_quotes_in_titles.md test/unit/Lexer-spec.js test/unit/marked-spec.js
