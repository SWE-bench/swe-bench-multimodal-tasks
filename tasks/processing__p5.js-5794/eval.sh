#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff aeda6d2f54b8567bababa6a01676e613e3513088
git checkout aeda6d2f54b8567bababa6a01676e613e3513088 test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 330cf444bf..822c3013f8 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -437,7 +437,7 @@ suite('p5.RendererGL', function() {
     test('blendModes change pixel colors as expected', function(done) {
       myp5.createCanvas(10, 10, myp5.WEBGL);
       myp5.noStroke();
-      assert.deepEqual([133, 69, 191, 255], mixAndReturn(myp5.ADD, 255));
+      assert.deepEqual([122, 0, 122, 255], mixAndReturn(myp5.ADD, 0));
       assert.deepEqual([0, 0, 255, 255], mixAndReturn(myp5.REPLACE, 255));
       assert.deepEqual([133, 255, 133, 255], mixAndReturn(myp5.SUBTRACT, 255));
       assert.deepEqual([255, 0, 255, 255], mixAndReturn(myp5.SCREEN, 0));
@@ -447,6 +447,68 @@ suite('p5.RendererGL', function() {
       assert.deepEqual([0, 0, 0, 255], mixAndReturn(myp5.DARKEST, 255));
       done();
     });
+
+    test('blendModes match 2D mode', function(done) {
+      myp5.createCanvas(10, 10, myp5.WEBGL);
+      myp5.setAttributes({ alpha: true });
+      const ref = myp5.createGraphics(myp5.width, myp5.height);
+      ref.translate(ref.width / 2, ref.height / 2); // Match WebGL mode
+
+      const testBlend = function(target, colorA, colorB, mode) {
+        target.clear();
+        target.push();
+        target.background(colorA);
+        target.blendMode(mode);
+        target.noStroke();
+        target.fill(colorB);
+        target.rectMode(target.CENTER);
+        target.rect(0, 0, target.width, target.height);
+        target.pop();
+        return target.get(0, 0);
+      };
+
+      const assertSameIn2D = function(colorA, colorB, mode) {
+        const refColor = testBlend(myp5, colorA, colorB, mode);
+        const webglColor = testBlend(ref, colorA, colorB, mode);
+        if (refColor[3] === 0) {
+          assert.equal(webglColor[3], 0);
+        } else {
+          assert.deepEqual(
+            refColor,
+            webglColor,
+            `Blending ${colorA} with ${colorB} using ${mode}`
+          );
+        }
+      };
+
+      const red = '#F53';
+      const blue = '#13F';
+      assertSameIn2D(red, blue, myp5.BLEND);
+      assertSameIn2D(red, blue, myp5.ADD);
+      assertSameIn2D(red, blue, myp5.DARKEST);
+      assertSameIn2D(red, blue, myp5.LIGHTEST);
+      assertSameIn2D(red, blue, myp5.EXCLUSION);
+      assertSameIn2D(red, blue, myp5.MULTIPLY);
+      assertSameIn2D(red, blue, myp5.SCREEN);
+      assertSameIn2D(red, blue, myp5.REPLACE);
+      assertSameIn2D(red, blue, myp5.REMOVE);
+      done();
+    });
+
+    test('blendModes are included in push/pop', function(done) {
+      myp5.createCanvas(10, 10, myp5.WEBGL);
+      myp5.blendMode(myp5.MULTIPLY);
+      myp5.push();
+      myp5.blendMode(myp5.ADD);
+      assert.equal(myp5._renderer.curBlendMode, myp5.ADD, 'Changed to ADD');
+      myp5.pop();
+      assert.equal(
+        myp5._renderer.curBlendMode,
+        myp5.MULTIPLY,
+        'Resets to MULTIPLY'
+      );
+      done();
+    });
   });
 
   suite('BufferDef', function() {

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout aeda6d2f54b8567bababa6a01676e613e3513088 test/unit/webgl/p5.RendererGL.js
