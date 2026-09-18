#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff ce831a839b6ab8792adc31cdf1942ea89d69e29b
git checkout ce831a839b6ab8792adc31cdf1942ea89d69e29b test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 3e750e0597..a232a4ef70 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -338,7 +338,7 @@ suite('p5.RendererGL', function() {
       pg.clear();
       myp5.image(pg, -myp5.width / 2, -myp5.height / 2);
       pixel = myp5.get(0, 0);
-      assert.deepEqual(pixel, [0, 0, 0, 255]);
+      assert.deepEqual(pixel, [0, 255, 255, 255]);
       done();
     });
 
@@ -361,7 +361,7 @@ suite('p5.RendererGL', function() {
       pg.background(100, 100, 100, 100);
       myp5.image(pg, -myp5.width / 2, -myp5.height / 2);
       pixel = myp5.get(0, 0);
-      assert.deepEqual(pixel, [100, 100, 100, 255]);
+      assert.deepEqual(pixel, [39, 194, 194, 255]);
       done();
     });
 
@@ -383,7 +383,7 @@ suite('p5.RendererGL', function() {
       pg.clear();
       myp5.image(pg, 0, 0);
       pixel = myp5.get(0, 0);
-      assert.deepEqual(pixel, [0, 0, 0, 255]);
+      assert.deepEqual(pixel, [0, 255, 255, 255]);
       done();
     });
 
@@ -394,7 +394,7 @@ suite('p5.RendererGL', function() {
       pg.background(100, 100, 100, 100);
       myp5.image(pg, 0, 0);
       pixel = myp5.get(0, 0);
-      assert.deepEqual(pixel, [100, 100, 100, 255]);
+      assert.deepEqual(pixel, [39, 194, 194, 255]);
       done();
     });
   });
@@ -483,14 +483,14 @@ suite('p5.RendererGL', function() {
       myp5.createCanvas(10, 10, myp5.WEBGL);
       myp5.noStroke();
       assert.deepEqual([122, 0, 122, 255], mixAndReturn(myp5.ADD, 0));
-      assert.deepEqual([0, 0, 255, 255], mixAndReturn(myp5.REPLACE, 255));
+      assert.deepEqual([0, 0, 122, 122], mixAndReturn(myp5.REPLACE, 255));
       assert.deepEqual([133, 255, 133, 255], mixAndReturn(myp5.SUBTRACT, 255));
-      assert.deepEqual([255, 0, 255, 255], mixAndReturn(myp5.SCREEN, 0));
-      assert.deepEqual([0, 255, 0, 255], mixAndReturn(myp5.EXCLUSION, 255));
+      assert.deepEqual([122, 0, 122, 255], mixAndReturn(myp5.SCREEN, 0));
+      assert.deepEqual([133, 255, 133, 255], mixAndReturn(myp5.EXCLUSION, 255));
       // Note that in 2D mode, this would just return black, because 2D mode
       // ignores alpha in this case.
-      assert.deepEqual([133, 69, 202, 255], mixAndReturn(myp5.MULTIPLY, 255));
-      assert.deepEqual([255, 0, 255, 255], mixAndReturn(myp5.LIGHTEST, 0));
+      assert.deepEqual([133, 69, 133, 255], mixAndReturn(myp5.MULTIPLY, 255));
+      assert.deepEqual([122, 0, 122, 255], mixAndReturn(myp5.LIGHTEST, 0));
       assert.deepEqual([0, 0, 0, 255], mixAndReturn(myp5.DARKEST, 255));
       done();
     });
@@ -517,15 +517,11 @@ suite('p5.RendererGL', function() {
       const assertSameIn2D = function(colorA, colorB, mode) {
         const refColor = testBlend(myp5, colorA, colorB, mode);
         const webglColor = testBlend(ref, colorA, colorB, mode);
-        if (refColor[3] === 0) {
-          assert.equal(webglColor[3], 0);
-        } else {
-          assert.deepEqual(
-            refColor,
-            webglColor,
-            `Blending ${colorA} with ${colorB} using ${mode}`
-          );
-        }
+        assert.deepEqual(
+          refColor,
+          webglColor,
+          `Blending ${colorA} with ${colorB} using ${mode}`
+        );
       };
 
       for (const alpha of [255, 200]) {

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout ce831a839b6ab8792adc31cdf1942ea89d69e29b test/unit/webgl/p5.RendererGL.js
