#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 0cf6487547791c9ef9519752f5b434abe27857b4
git checkout 0cf6487547791c9ef9519752f5b434abe27857b4 test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index dbecaee74f..e0eabf65b7 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -622,6 +622,19 @@ suite('p5.RendererGL', function() {
       );
       done();
     });
+
+    test('blendModes are applied to point drawing', function(done) {
+      myp5.createCanvas(32, 32, myp5.WEBGL);
+      myp5.background(0);
+      myp5.blendMode(myp5.ADD);
+      myp5.strokeWeight(32);
+      myp5.stroke(255, 0, 0);
+      myp5.point(0, 0, 0);
+      myp5.stroke(0, 0, 255);
+      myp5.point(0, 0, 0);
+      assert.deepEqual(myp5.get(16, 16), [255, 0, 255, 255]);
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
git checkout 0cf6487547791c9ef9519752f5b434abe27857b4 test/unit/webgl/p5.RendererGL.js
