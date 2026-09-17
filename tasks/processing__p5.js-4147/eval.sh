#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c6d686ed53d9de61240939c7e5d85e1f3eb29072
git checkout c6d686ed53d9de61240939c7e5d85e1f3eb29072 test/manual-test-examples/webgl/geometryImmediate/sketch.js test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/manual-test-examples/webgl/geometryImmediate/sketch.js b/test/manual-test-examples/webgl/geometryImmediate/sketch.js
index 295e2b0188..f6404ea99f 100644
--- a/test/manual-test-examples/webgl/geometryImmediate/sketch.js
+++ b/test/manual-test-examples/webgl/geometryImmediate/sketch.js
@@ -27,7 +27,7 @@ function draw() {
 }
 
 function ngon(n, x, y, d) {
-  beginShape();
+  beginShape(TESS);
   for (let i = 0; i < n + 1; i++) {
     angle = TWO_PI / n * i;
     px = x + sin(angle) * d / 2;
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 82599db9a4..de324b6c96 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -445,7 +445,7 @@ suite('p5.RendererGL', function() {
       myp5.stroke(255);
       myp5.triangle(0, 0, 1, 0, 0, 1);
 
-      var buffers = renderer.gHash['tri'];
+      var buffers = renderer.retainedMode.geometry['tri'];
 
       assert.isObject(buffers);
       assert.isDefined(buffers.indexBuffer);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout c6d686ed53d9de61240939c7e5d85e1f3eb29072 test/manual-test-examples/webgl/geometryImmediate/sketch.js test/unit/webgl/p5.RendererGL.js
