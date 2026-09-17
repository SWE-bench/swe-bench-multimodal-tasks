#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c9fb107b94ffa5f2b905509a0407588b85476b02
git checkout c9fb107b94ffa5f2b905509a0407588b85476b02 test/manual-test-examples/webgl/geometryImmediate/sketch.js test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/manual-test-examples/webgl/geometryImmediate/sketch.js b/test/manual-test-examples/webgl/geometryImmediate/sketch.js
index df6dc05154..27ce74a562 100644
--- a/test/manual-test-examples/webgl/geometryImmediate/sketch.js
+++ b/test/manual-test-examples/webgl/geometryImmediate/sketch.js
@@ -56,7 +56,23 @@ function drawStrip(mode) {
   beginShape(mode);
   let vertexIndex = 0;
   for (let y = 0; y <= 500; y += 100) {
-    for (const side of [-1, 1]) {
+    let sides = [-1, 1];
+    if (mode === QUADS && y % 200 !== 0) {
+      // QUAD_STRIP and TRIANGLE_STRIP need the vertices of each shared side
+      // ordered in the same way:
+      // 0--2--4--6
+      // |  |  |  | ⬇️
+      // 1--3--5--7
+      //
+      // ...but QUADS orders vertices in a consisten CCW or CW manner around
+      // each quad, meaning each side will be in the reverse order of the
+      // previous:
+      // 0--3  4--7
+      // |  |  |  | 🔄
+      // 1--2  5--6
+      sides.reverse();
+    }
+    for (const side of sides) {
       fill(...stripColors[vertexIndex]);
       vertex(side * 40, y);
       vertexIndex++;
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 0eef35c050..330cf444bf 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -560,16 +560,16 @@ suite('p5.RendererGL', function() {
         [0, 1, 1],
         [1, 0, 2],
 
+        [0, 0, 0],
         [1, 0, 2],
-        [0, 1, 1],
         [1, 1, 3],
 
         [2, 0, 4],
         [2, 1, 5],
         [3, 0, 6],
 
+        [2, 0, 4],
         [3, 0, 6],
-        [2, 1, 5],
         [3, 1, 7]
       ];
       assert.equal(
@@ -587,16 +587,16 @@ suite('p5.RendererGL', function() {
         [0, 1],
         [1, 0],
 
+        [0, 0],
         [1, 0],
-        [0, 1],
         [1, 1],
 
         [0, 0],
         [0, 1],
         [1, 0],
 
+        [0, 0],
         [1, 0],
-        [0, 1],
         [1, 1]
       ].flat();
       assert.deepEqual(renderer.immediateMode.geometry.uvs, expectedUVs);
@@ -606,16 +606,16 @@ suite('p5.RendererGL', function() {
         [0, 1, 0, 1],
         [0, 0, 1, 1],
 
+        [1, 0, 0, 1],
         [0, 0, 1, 1],
-        [0, 1, 0, 1],
         [1, 0, 1, 1],
 
         [1, 0, 0, 1],
         [0, 1, 0, 1],
         [0, 0, 1, 1],
 
+        [1, 0, 0, 1],
         [0, 0, 1, 1],
-        [0, 1, 0, 1],
         [1, 0, 1, 1]
       ].flat();
       assert.deepEqual(
@@ -628,16 +628,16 @@ suite('p5.RendererGL', function() {
         [3, 4, 5],
         [6, 7, 8],
 
+        [0, 1, 2],
         [6, 7, 8],
-        [3, 4, 5],
         [9, 10, 11],
 
         [12, 13, 14],
         [15, 16, 17],
         [18, 19, 20],
 
+        [12, 13, 14],
         [18, 19, 20],
-        [15, 16, 17],
         [21, 22, 23]
       ];
       assert.equal(

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout c9fb107b94ffa5f2b905509a0407588b85476b02 test/manual-test-examples/webgl/geometryImmediate/sketch.js test/unit/webgl/p5.RendererGL.js
