#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6bc47d3cea5ac0f496dc1b6bd53ed2fa5e1446d1
git checkout 6bc47d3cea5ac0f496dc1b6bd53ed2fa5e1446d1 test/specs/element.arc.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/element.arc.tests.js b/test/specs/element.arc.tests.js
index 23380aa250d..e2ec0788b4b 100644
--- a/test/specs/element.arc.tests.js
+++ b/test/specs/element.arc.tests.js
@@ -23,6 +23,39 @@ describe('Arc element tests', function() {
     expect(arc.inRange(-1.0 * Math.sqrt(7), Math.sqrt(7))).toBe(false);
   });
 
+  it ('should determine if in range when full circle', function() {
+    // Mock out the arc as if the controller put it there
+    var arc = new Chart.elements.ArcElement({
+      startAngle: 0,
+      endAngle: Math.PI * 2,
+      x: 0,
+      y: 0,
+      innerRadius: 5,
+      outerRadius: 10,
+      options: {
+        spacing: 0,
+        offset: 0,
+      }
+    });
+
+    for (const radius of [5, 7.5, 10]) {
+      for (let angle = 0; angle <= 360; angle += 22.5) {
+        const rad = angle / 180 * Math.PI;
+        const x = Math.sin(rad) * radius;
+        const y = Math.cos(rad) * radius;
+        expect(arc.inRange(x, y)).withContext(`radius: ${radius}, angle: ${angle}`).toBeTrue();
+      }
+    }
+    for (const radius of [4, 11]) {
+      for (let angle = 0; angle <= 360; angle += 22.5) {
+        const rad = angle / 180 * Math.PI;
+        const x = Math.sin(rad) * radius;
+        const y = Math.cos(rad) * radius;
+        expect(arc.inRange(x, y)).withContext(`radius: ${radius}, angle: ${angle}`).toBeFalse();
+      }
+    }
+  });
+
   it ('should include spacing for in range check', function() {
     // Mock out the arc as if the controller put it there
     var arc = new Chart.elements.ArcElement({

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 6bc47d3cea5ac0f496dc1b6bd53ed2fa5e1446d1 test/specs/element.arc.tests.js
