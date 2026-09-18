#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 9372b29ee28c35a44ca26e66551a0c9b03c02601
rm -f test/manual-test-examples/webgl/immediateMode/customShapes/index.html test/manual-test-examples/webgl/immediateMode/customShapes/sketch.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/manual-test-examples/webgl/immediateMode/customShapes/index.html b/test/manual-test-examples/webgl/immediateMode/customShapes/index.html
new file mode 100644
index 0000000000..ef2cf9f556
--- /dev/null
+++ b/test/manual-test-examples/webgl/immediateMode/customShapes/index.html
@@ -0,0 +1,17 @@
+<!DOCTYPE html>
+<html>
+
+<head>
+  <meta charset="utf-8">
+  <meta http-equiv="X-UA-Compatible" content="IE=edge">
+  <title></title>
+  <link rel="stylesheet" href="../../../styles.css">
+  <script language="javascript" type="text/javascript" src="../../../../../lib/p5.js"></script>
+  <script language="javascript" type="text/javascript" src="sketch.js"></script>
+  <script src="../../stats.js"></script>
+</head>
+
+<body>
+</body>
+
+</html>
\ No newline at end of file
diff --git a/test/manual-test-examples/webgl/immediateMode/customShapes/sketch.js b/test/manual-test-examples/webgl/immediateMode/customShapes/sketch.js
new file mode 100644
index 0000000000..366d43ee09
--- /dev/null
+++ b/test/manual-test-examples/webgl/immediateMode/customShapes/sketch.js
@@ -0,0 +1,39 @@
+var angle, px, py;
+
+function setup() {
+  createCanvas(600, 600, WEBGL);
+  setAttributes('antialias', true);
+  fill(63, 81, 181);
+  strokeWeight(2);
+}
+
+function ngon(n, x, y, d) {
+  beginShape();
+  for (var i = 0; i < n + 1; i++) {
+    angle = TWO_PI / n * i;
+    px = x + sin(angle) * d / 2;
+    py = y - cos(angle) * d / 2;
+    vertex(px, py);
+  }
+  for (i = 0; i < n + 1; i++) {
+    angle = TWO_PI / n * i;
+    px = x + sin(angle) * d / 4;
+    py = y - cos(angle) * d / 4;
+    vertex(px, py);
+  }
+  endShape();
+}
+
+function draw() {
+  background(250);
+
+  ngon(3, -200, -180, 120);
+  ngon(4, -200, 0, 120);
+  ngon(5, -200, 180, 120);
+  ngon(6, 0, -180, 120);
+  ngon(7, 0, 0, 120);
+  ngon(8, 0, 180, 120);
+  ngon(9, 200, -180, 120);
+  ngon(10, 200, 0, 120);
+  ngon(11, 200, 180, 120);
+}

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
rm -f test/manual-test-examples/webgl/immediateMode/customShapes/index.html test/manual-test-examples/webgl/immediateMode/customShapes/sketch.js
