#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 23e8f7d378a84dddd17d958a888ffff7f120c38c
git checkout 23e8f7d378a84dddd17d958a888ffff7f120c38c test/specs/scale.linear.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/scale.linear.tests.js b/test/specs/scale.linear.tests.js
index 9fbe5467a2d..a8ad53995b1 100644
--- a/test/specs/scale.linear.tests.js
+++ b/test/specs/scale.linear.tests.js
@@ -684,6 +684,28 @@ describe('Linear Scale', function() {
     expect(getLabels(chart.scales.y)).toEqual(['1', '3', '5', '7', '9', '11']);
   });
 
+  it('Should not generate any ticks > max if max is specified', function() {
+    var chart = window.acquireChart({
+      type: 'line',
+      options: {
+        scales: {
+          x: {
+            type: 'linear',
+            min: 2.404e-8,
+            max: 2.4143e-8,
+            ticks: {
+              includeBounds: false,
+            },
+          },
+        },
+      },
+    });
+
+    expect(chart.scales.x.min).toBe(2.404e-8);
+    expect(chart.scales.x.max).toBe(2.4143e-8);
+    expect(chart.scales.x.ticks[chart.scales.x.ticks.length - 1].value).toBeLessThanOrEqual(2.4143e-8);
+  });
+
   it('Should not generate insane amounts of ticks with small stepSize and large range', function() {
     var chart = window.acquireChart({
       type: 'bar',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
pnpm install ; pnpm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.cjs ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.cjs --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 23e8f7d378a84dddd17d958a888ffff7f120c38c test/specs/scale.linear.tests.js
