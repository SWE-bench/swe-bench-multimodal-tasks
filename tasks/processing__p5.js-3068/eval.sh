#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 52151068bdc7e95150a189392fbd5ec0a48318f0
git checkout 52151068bdc7e95150a189392fbd5ec0a48318f0 test/unit/io/files_input.js && rm -f test/unit/assets/empty_lines.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/assets/empty_lines.txt b/test/unit/assets/empty_lines.txt
new file mode 100644
index 0000000000..5a3b131ad7
--- /dev/null
+++ b/test/unit/assets/empty_lines.txt
@@ -0,0 +1,5 @@
+some of these
+
+lines
+
+are empty
diff --git a/test/unit/io/files_input.js b/test/unit/io/files_input.js
index 9b596c5b00..a351a1db70 100644
--- a/test/unit/io/files_input.js
+++ b/test/unit/io/files_input.js
@@ -240,6 +240,15 @@ suite('Files', function() {
       });
     });
 
+    test('should include empty strings', function() {
+      return new Promise(function(resolve, reject) {
+        myp5.loadStrings('unit/assets/empty_lines.txt', resolve, reject);
+      }).then(function(data) {
+        assert.isArray(data, 'Array passed to callback function');
+        assert.lengthOf(data, 6, 'length of data is 6');
+      });
+    });
+
     test('should call error callback function if provided', function() {
       return new Promise(function(resolve, reject) {
         myp5.loadStrings(

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout 52151068bdc7e95150a189392fbd5ec0a48318f0 test/unit/io/files_input.js && rm -f test/unit/assets/empty_lines.txt
