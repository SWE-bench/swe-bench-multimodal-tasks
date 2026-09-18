#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff caa727cd577b71df22a4234aa62d3fa3de887655
git checkout caa727cd577b71df22a4234aa62d3fa3de887655 test/unit/webgl/p5.RendererGL.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/webgl/p5.RendererGL.js b/test/unit/webgl/p5.RendererGL.js
index 2ba5b41a3b..08d240cae3 100644
--- a/test/unit/webgl/p5.RendererGL.js
+++ b/test/unit/webgl/p5.RendererGL.js
@@ -1048,6 +1048,27 @@ suite('p5.RendererGL', function() {
         [-10, 0, 10]
       );
 
+      done();
+    });
+    test('strokes should interpolate colors between vertices', function(done) {
+      const renderer = myp5.createCanvas(512, 4, myp5.WEBGL);
+
+      // far left color: (242, 236, 40)
+      // far right color: (42, 36, 240)
+      // expected middle color: (142, 136, 140)
+
+      renderer.strokeWeight(4);
+      renderer.beginShape();
+      renderer.stroke(242, 236, 40);
+      renderer.vertex(-256, 0);
+      renderer.stroke(42, 36, 240);
+      renderer.vertex(256, 0);
+      renderer.endShape();
+
+      assert.deepEqual(myp5.get(0, 2), [242, 236, 40, 255]);
+      assert.deepEqual(myp5.get(256, 2), [142, 136, 140, 255]);
+      assert.deepEqual(myp5.get(511, 2), [42, 36, 240, 255]);
+
       done();
     });
   });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout caa727cd577b71df22a4234aa62d3fa3de887655 test/unit/webgl/p5.RendererGL.js
