#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff ae9484d35939d2bf72e038c0977cb2eeab4495f7
git checkout ae9484d35939d2bf72e038c0977cb2eeab4495f7 test/specs/marked/marked.json
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/marked/marked.json b/test/specs/marked/marked.json
index 5f46f53640..5dd1a065c8 100644
--- a/test/specs/marked/marked.json
+++ b/test/specs/marked/marked.json
@@ -113,10 +113,16 @@
     "html": "<p><strong><a href=\"mailto:test@test.com\">test@test.com</a></strong></p>",
     "example": 1347
   },
-  {  
+  {
     "section": "Emphasis extra tests",
     "markdown": "_test_. _test_: _test_! _test_? _test_-",
     "html": "<p><em>test</em>. <em>test</em>: <em>test</em>! <em>test</em>? <em>test</em>-</p>",
     "example": 15
+  },
+  {
+    "section": "Links",
+    "markdown": "[One](https://example.com/1) ([Two](https://example.com/2)) [Three](https://example.com/3)",
+    "html": "<p><a href=\"https://example.com/1\">One</a> (<a href=\"https://example.com/2\">Two</a>) <a href=\"https://example.com/3\">Three</a></p>",
+    "example": 16
   }
 ]

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout ae9484d35939d2bf72e038c0977cb2eeab4495f7 test/specs/marked/marked.json
