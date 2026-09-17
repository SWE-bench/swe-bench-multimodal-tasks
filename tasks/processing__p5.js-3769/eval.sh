#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff f310e50d8b94ade1ed6b5759b0713d3a67301517
git checkout f310e50d8b94ade1ed6b5759b0713d3a67301517 test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 7659a70426..dff7ada827 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -285,4 +285,28 @@ suite('p5.RendererGL', function() {
       done();
     });
   });
+
+  suite('BufferDef', function() {
+    test('render buffer properties are correctly set', function(done) {
+      var renderer = myp5.createCanvas(10, 10, myp5.WEBGL);
+
+      myp5.fill(255);
+      myp5.stroke(255);
+      myp5.triangle(0, 0, 1, 0, 0, 1);
+
+      var buffers = renderer.gHash['tri'];
+
+      assert.isObject(buffers);
+      assert.isDefined(buffers.indexBuffer);
+      assert.isDefined(buffers.vertexBuffer);
+      assert.isDefined(buffers.lineNormalBuffer);
+      assert.isDefined(buffers.lineVertexBuffer);
+      assert.isDefined(buffers.vertexBuffer);
+
+      assert.equal(buffers.vertexCount, 3);
+      assert.equal(buffers.lineVertexCount, 18);
+
+      done();
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
git checkout f310e50d8b94ade1ed6b5759b0713d3a67301517 test/unit/webgl/p5.RendererGL.js
