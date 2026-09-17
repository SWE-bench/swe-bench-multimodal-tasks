#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 5561fd0b2c378132fc3cc6705fc3f72463a0e03c
git checkout 5561fd0b2c378132fc3cc6705fc3f72463a0e03c test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index dff7ada827..9f678de94e 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -309,4 +309,53 @@ suite('p5.RendererGL', function() {
       done();
     });
   });
+
+  suite('tint() in WEBGL mode', function() {
+    test('default tint value is set and not null', function() {
+      myp5.createCanvas(100, 100, myp5.WEBGL);
+      assert.deepEqual(myp5._renderer._tint, [255, 255, 255, 255]);
+    });
+
+    test('tint value is modified correctly when tint() is called', function() {
+      myp5.createCanvas(100, 100, myp5.WEBGL);
+      myp5.tint(0, 153, 204, 126);
+      assert.deepEqual(myp5._renderer._tint, [0, 153, 204, 126]);
+      myp5.tint(100, 120, 140);
+      assert.deepEqual(myp5._renderer._tint, [100, 120, 140, 255]);
+      myp5.tint('violet');
+      assert.deepEqual(myp5._renderer._tint, [238, 130, 238, 255]);
+      myp5.tint(100);
+      assert.deepEqual(myp5._renderer._tint, [100, 100, 100, 255]);
+      myp5.tint(100, 126);
+      assert.deepEqual(myp5._renderer._tint, [100, 100, 100, 126]);
+      myp5.tint([100, 126, 0, 200]);
+      assert.deepEqual(myp5._renderer._tint, [100, 126, 0, 200]);
+      myp5.tint([100, 126, 0]);
+      assert.deepEqual(myp5._renderer._tint, [100, 126, 0, 255]);
+      myp5.tint([100]);
+      assert.deepEqual(myp5._renderer._tint, [100, 100, 100, 255]);
+      myp5.tint([100, 126]);
+      assert.deepEqual(myp5._renderer._tint, [100, 100, 100, 126]);
+      myp5.tint(myp5.color(255, 204, 0));
+      assert.deepEqual(myp5._renderer._tint, [255, 204, 0, 255]);
+    });
+
+    test('tint should be reset after draw loop', function() {
+      return new Promise(function(resolve, reject) {
+        new p5(function(p) {
+          p.setup = function() {
+            p.createCanvas(100, 100, myp5.WEBGL);
+          };
+          p.draw = function() {
+            if (p.frameCount === 2) {
+              resolve(p._renderer._tint);
+            }
+            p.tint(0, 153, 204, 126);
+          };
+        });
+      }).then(function(_tint) {
+        assert.deepEqual(_tint, [255, 255, 255, 255]);
+      });
+    });
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout 5561fd0b2c378132fc3cc6705fc3f72463a0e03c test/unit/webgl/p5.RendererGL.js
