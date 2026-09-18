#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 4364d604c4cd527b39449c07febc76dde1a4fab6
git checkout 4364d604c4cd527b39449c07febc76dde1a4fab6 test/unit/core/error_helpers.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/core/error_helpers.js b/test/unit/core/error_helpers.js
index 97f2678d26..9582cd95ec 100644
--- a/test/unit/core/error_helpers.js
+++ b/test/unit/core/error_helpers.js
@@ -5,6 +5,7 @@ suite('Error Helpers', function() {
     new p5(function(p) {
       p.setup = function() {
         myp5 = p;
+        p5._clearValidateParamsCache();
         done();
       };
     });
@@ -122,6 +123,76 @@ suite('Error Helpers', function() {
     }
   );
 
+  suite('validateParameters: argument tree', function() {
+    // should not throw a validation error for the same kind of wrong args
+    // more than once. This prevents repetetive validation logs for a
+    // function that is called in a loop or draw()
+    testUnMinified(
+      'no repeated validation error for the same wrong arguments',
+      function() {
+        assert.validationError(function() {
+          myp5.color();
+        });
+
+        assert.doesNotThrow(
+          function() {
+            myp5.color(); // Same type of wrong arguments as above
+          },
+          p5.ValidationError,
+          'got unwanted ValidationError'
+        );
+      }
+    );
+
+    testUnMinified(
+      'should throw validation errors for different wrong args',
+      function() {
+        assert.validationError(function() {
+          myp5.color();
+        });
+
+        assert.validationError(function() {
+          myp5.color(false);
+        });
+      }
+    );
+
+    testUnMinified('arg tree is built properly', function() {
+      let myArgTree = p5._getValidateParamsArgTree();
+      myp5.random();
+      myp5.random(50);
+      myp5.random([50, 70, 10]);
+      assert.strictEqual(
+        myArgTree.random.seen,
+        true,
+        'tree built correctly for random()'
+      );
+      assert.strictEqual(
+        myArgTree.random.number.seen,
+        true,
+        'tree built correctly for random(min: Number)'
+      );
+      assert.strictEqual(
+        myArgTree.random.as.number.number.number.seen,
+        true,
+        'tree built correctly for random(choices: Array)'
+      );
+
+      let c = myp5.color(10);
+      myp5.alpha(c);
+      assert.strictEqual(
+        myArgTree.color.number.seen,
+        true,
+        'tree built correctly for color(gray: Number)'
+      );
+      assert.strictEqual(
+        myArgTree.alpha.Color.seen,
+        true,
+        'tree built correctly for alpha(color: p5.Color)'
+      );
+    });
+  });
+
   suite('validateParameters: multi-format', function() {
     test('color(): no friendly-err-msg', function() {
       assert.doesNotThrow(

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout 4364d604c4cd527b39449c07febc76dde1a4fab6 test/unit/core/error_helpers.js
