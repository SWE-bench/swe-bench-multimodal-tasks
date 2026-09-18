#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 420aa027b305c91380d96d05e39db2767ec1333a
git checkout 420aa027b305c91380d96d05e39db2767ec1333a test/fixtures/controller.line/clip/default-y-max.png test/fixtures/controller.line/clip/default-y.png test/fixtures/controller.line/non-numeric-y.png test/fixtures/controller.line/point-style-offscreen-canvas.png test/fixtures/controller.line/point-style.png test/fixtures/controller.line/pointBackgroundColor/indexable.png test/fixtures/controller.line/pointBackgroundColor/scriptable.png test/fixtures/controller.line/pointBackgroundColor/value.png test/fixtures/controller.line/pointBorderColor/indexable.png test/fixtures/controller.line/pointBorderColor/scriptable.png test/fixtures/controller.line/pointBorderColor/value.png test/fixtures/controller.line/pointBorderWidth/indexable.png test/fixtures/controller.line/pointBorderWidth/scriptable.png test/fixtures/controller.line/pointBorderWidth/value.png test/fixtures/controller.line/pointStyle/indexable.png test/fixtures/controller.line/pointStyle/scriptable.png test/fixtures/controller.line/pointStyle/value.png test/fixtures/controller.line/radius/indexable.png test/fixtures/controller.line/radius/scriptable.png test/fixtures/controller.line/radius/value.png test/fixtures/controller.line/rotation/indexable.png test/fixtures/controller.line/rotation/scriptable.png test/fixtures/controller.line/rotation/value.png test/fixtures/controller.line/showLine/false.png test/fixtures/controller.line/stacking/stacked-scatter.png test/fixtures/controller.scatter/showLine/true.png test/fixtures/controller.scatter/showLine/undefined.png test/fixtures/core.layouts/hidden-vertical-boxes.png test/fixtures/core.layouts/no-boxes-all-padding.js test/fixtures/core.layouts/no-boxes-all-padding.png test/fixtures/core.layouts/refit-vertical-boxes.png test/fixtures/core.scale/autoSkip/fit-after.png test/fixtures/core.scale/cartesian-axis-border-settings.png test/fixtures/core.scale/label-align-end.png test/fixtures/core.scale/label-align-start.png test/fixtures/core.scale/x-axis-position-dynamic.png test/fixtures/element.line/default.png test/fixtures/element.line/skip/first-span.png test/fixtures/element.line/skip/first.png test/fixtures/element.line/skip/last-span.png test/fixtures/element.line/skip/last.png test/fixtures/element.line/stepped/after.png test/fixtures/element.line/stepped/before.png test/fixtures/element.line/stepped/default.png test/fixtures/element.line/stepped/middle.png test/fixtures/element.line/tension/default.png test/fixtures/element.line/tension/one.png test/fixtures/element.line/tension/zero.png test/fixtures/plugin.filler/fill-line-dataset-interpolated.png test/fixtures/plugin.tooltip/positioning.js test/fixtures/plugin.tooltip/positioning.png test/fixtures/scale.time/autoskip-major.png test/fixtures/scale.time/custom-parser.png test/fixtures/scale.time/data-ty.png test/fixtures/scale.time/data-xy.png test/fixtures/scale.time/negative-times.png test/fixtures/scale.time/source-auto-linear.png test/fixtures/scale.time/source-data-linear.png test/fixtures/scale.time/source-labels-linear-offset-min-max.png test/fixtures/scale.time/source-labels-linear.png test/fixtures/scale.time/ticks-reverse-linear-min-max.png test/fixtures/scale.time/ticks-reverse-linear.png test/fixtures/scale.time/ticks-reverse-offset.png test/fixtures/scale.time/ticks-reverse.png test/fixtures/scale.timeseries/normalize.png test/fixtures/scale.timeseries/source-auto.png test/fixtures/scale.timeseries/source-data-offset-min-max.png test/fixtures/scale.timeseries/source-data.png test/fixtures/scale.timeseries/source-labels-offset-min-max.png test/fixtures/scale.timeseries/source-labels.png test/fixtures/scale.timeseries/ticks-reverse-max.png test/fixtures/scale.timeseries/ticks-reverse-min-max.png test/fixtures/scale.timeseries/ticks-reverse-min.png test/fixtures/scale.timeseries/ticks-reverse.png test/specs/controller.bar.tests.js test/specs/controller.line.tests.js test/specs/core.controller.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/core.layouts/no-boxes-all-padding.js b/test/fixtures/core.layouts/no-boxes-all-padding.js
index ae8500851be..b50d67210d1 100644
--- a/test/fixtures/core.layouts/no-boxes-all-padding.js
+++ b/test/fixtures/core.layouts/no-boxes-all-padding.js
@@ -6,6 +6,7 @@ module.exports = {
       datasets: [{
         data: [0],
         radius: 16,
+        borderWidth: 0,
         backgroundColor: 'red'
       }],
     },
diff --git a/test/fixtures/plugin.tooltip/positioning.js b/test/fixtures/plugin.tooltip/positioning.js
index c30ff3e82c5..494bada5fce 100644
--- a/test/fixtures/plugin.tooltip/positioning.js
+++ b/test/fixtures/plugin.tooltip/positioning.js
@@ -12,7 +12,8 @@ module.exports = {
       datasets: [{
         data,
         backgroundColor: 'red',
-        radius: 8
+        radius: 1,
+        hoverRadius: 0
       }],
     },
     options: {
diff --git a/test/specs/controller.bar.tests.js b/test/specs/controller.bar.tests.js
index 6be8eb1ede7..f9decfe4f6f 100644
--- a/test/specs/controller.bar.tests.js
+++ b/test/specs/controller.bar.tests.js
@@ -691,9 +691,9 @@ describe('Chart.controllers.bar', function() {
     var bar2 = meta.data[1];
 
     expect(bar1.x).toBeCloseToPixel(179);
-    expect(bar1.y).toBeCloseToPixel(114);
-    expect(bar2.x).toBeCloseToPixel(435);
-    expect(bar2.y).toBeCloseToPixel(0);
+    expect(bar1.y).toBeCloseToPixel(117);
+    expect(bar2.x).toBeCloseToPixel(431);
+    expect(bar2.y).toBeCloseToPixel(4);
   });
 
   it('should get the bar points for hidden dataset', function() {
diff --git a/test/specs/controller.line.tests.js b/test/specs/controller.line.tests.js
index 9878eca185e..df0d7a14f73 100644
--- a/test/specs/controller.line.tests.js
+++ b/test/specs/controller.line.tests.js
@@ -142,8 +142,8 @@ describe('Chart.controllers.line', function() {
     expect(meta._parsed.length).toBe(2);
 
     [
-      {x: 0, y: 512},
-      {x: 171, y: 0}
+      {x: 5, y: 507},
+      {x: 171, y: 5}
     ].forEach(function(expected, i) {
       expect(meta.data[i].x).toBeCloseToPixel(expected.x);
       expect(meta.data[i].y).toBeCloseToPixel(expected.y);
@@ -192,7 +192,7 @@ describe('Chart.controllers.line', function() {
     var meta = chart.getDatasetMeta(0);
     // 1 point
     var point = meta.data[0];
-    expect(point.x).toBeCloseToPixel(0);
+    expect(point.x).toBeCloseToPixel(5);
 
     // 2 points
     chart.data.labels = ['One', 'Two'];
@@ -201,8 +201,8 @@ describe('Chart.controllers.line', function() {
 
     var points = meta.data;
 
-    expect(points[0].x).toBeCloseToPixel(0);
-    expect(points[1].x).toBeCloseToPixel(512);
+    expect(points[0].x).toBeCloseToPixel(5);
+    expect(points[1].x).toBeCloseToPixel(507);
 
     // 3 points
     chart.data.labels = ['One', 'Two', 'Three'];
@@ -211,9 +211,9 @@ describe('Chart.controllers.line', function() {
 
     points = meta.data;
 
-    expect(points[0].x).toBeCloseToPixel(0);
+    expect(points[0].x).toBeCloseToPixel(5);
     expect(points[1].x).toBeCloseToPixel(256);
-    expect(points[2].x).toBeCloseToPixel(512);
+    expect(points[2].x).toBeCloseToPixel(507);
 
     // 4 points
     chart.data.labels = ['One', 'Two', 'Three', 'Four'];
@@ -222,10 +222,10 @@ describe('Chart.controllers.line', function() {
 
     points = meta.data;
 
-    expect(points[0].x).toBeCloseToPixel(0);
+    expect(points[0].x).toBeCloseToPixel(5);
     expect(points[1].x).toBeCloseToPixel(171);
     expect(points[2].x).toBeCloseToPixel(340);
-    expect(points[3].x).toBeCloseToPixel(512);
+    expect(points[3].x).toBeCloseToPixel(507);
   });
 
   it('should update elements when the y scale is stacked', function() {
@@ -261,10 +261,10 @@ describe('Chart.controllers.line', function() {
     var meta0 = chart.getDatasetMeta(0);
 
     [
-      {x: 0, y: 146},
-      {x: 171, y: 439},
-      {x: 341, y: 146},
-      {x: 512, y: 439}
+      {x: 5, y: 148},
+      {x: 171, y: 435},
+      {x: 341, y: 148},
+      {x: 507, y: 435}
     ].forEach(function(values, i) {
       expect(meta0.data[i].x).toBeCloseToPixel(values.x);
       expect(meta0.data[i].y).toBeCloseToPixel(values.y);
@@ -273,10 +273,10 @@ describe('Chart.controllers.line', function() {
     var meta1 = chart.getDatasetMeta(1);
 
     [
-      {x: 0, y: 0},
-      {x: 171, y: 73},
-      {x: 341, y: 146},
-      {x: 512, y: 497}
+      {x: 5, y: 5},
+      {x: 171, y: 76},
+      {x: 341, y: 148},
+      {x: 507, y: 492}
     ].forEach(function(values, i) {
       expect(meta1.data[i].x).toBeCloseToPixel(values.x);
       expect(meta1.data[i].y).toBeCloseToPixel(values.y);
@@ -326,10 +326,10 @@ describe('Chart.controllers.line', function() {
     var meta0 = chart.getDatasetMeta(0);
 
     [
-      {x: 0, y: 146},
-      {x: 171, y: 439},
-      {x: 341, y: 146},
-      {x: 512, y: 439}
+      {x: 5, y: 148},
+      {x: 171, y: 435},
+      {x: 341, y: 148},
+      {x: 507, y: 435}
     ].forEach(function(values, i) {
       expect(meta0.data[i].x).toBeCloseToPixel(values.x);
       expect(meta0.data[i].y).toBeCloseToPixel(values.y);
@@ -338,10 +338,10 @@ describe('Chart.controllers.line', function() {
     var meta1 = chart.getDatasetMeta(1);
 
     [
-      {x: 0, y: 0},
-      {x: 171, y: 73},
-      {x: 341, y: 146},
-      {x: 512, y: 497}
+      {x: 5, y: 5},
+      {x: 171, y: 76},
+      {x: 341, y: 148},
+      {x: 507, y: 492}
     ].forEach(function(values, i) {
       expect(meta1.data[i].x).toBeCloseToPixel(values.x);
       expect(meta1.data[i].y).toBeCloseToPixel(values.y);
@@ -406,10 +406,10 @@ describe('Chart.controllers.line', function() {
     var meta0 = chart.getDatasetMeta(0);
 
     [
-      {x: 0, y: 146},
-      {x: 171, y: 439},
-      {x: 341, y: 146},
-      {x: 512, y: 439}
+      {x: 5, y: 148},
+      {x: 171, y: 435},
+      {x: 341, y: 148},
+      {x: 507, y: 435}
     ].forEach(function(values, i) {
       expect(meta0.data[i].x).toBeCloseToPixel(values.x);
       expect(meta0.data[i].y).toBeCloseToPixel(values.y);
@@ -418,10 +418,10 @@ describe('Chart.controllers.line', function() {
     var meta1 = chart.getDatasetMeta(1);
 
     [
-      {x: 0, y: 0},
-      {x: 171, y: 73},
-      {x: 341, y: 146},
-      {x: 512, y: 497}
+      {x: 5, y: 5},
+      {x: 171, y: 76},
+      {x: 341, y: 148},
+      {x: 507, y: 492}
     ].forEach(function(values, i) {
       expect(meta1.data[i].x).toBeCloseToPixel(values.x);
       expect(meta1.data[i].y).toBeCloseToPixel(values.y);
@@ -462,10 +462,10 @@ describe('Chart.controllers.line', function() {
     var meta0 = chart.getDatasetMeta(0);
 
     [
-      {x: 0, y: 146},
-      {x: 171, y: 439},
-      {x: 341, y: 146},
-      {x: 512, y: 439}
+      {x: 5, y: 148},
+      {x: 171, y: 435},
+      {x: 341, y: 148},
+      {x: 507, y: 435}
     ].forEach(function(values, i) {
       expect(meta0.data[i].x).toBeCloseToPixel(values.x);
       expect(meta0.data[i].y).toBeCloseToPixel(values.y);
@@ -474,10 +474,10 @@ describe('Chart.controllers.line', function() {
     var meta1 = chart.getDatasetMeta(1);
 
     [
-      {x: 0, y: 0},
-      {x: 171, y: 73},
-      {x: 341, y: 146},
-      {x: 512, y: 497}
+      {x: 5, y: 5},
+      {x: 171, y: 76},
+      {x: 341, y: 148},
+      {x: 507, y: 492}
     ].forEach(function(values, i) {
       expect(meta1.data[i].x).toBeCloseToPixel(values.x);
       expect(meta1.data[i].y).toBeCloseToPixel(values.y);
diff --git a/test/specs/core.controller.tests.js b/test/specs/core.controller.tests.js
index 9be597bf3ca..08436e93bc1 100644
--- a/test/specs/core.controller.tests.js
+++ b/test/specs/core.controller.tests.js
@@ -275,6 +275,30 @@ describe('Chart', function() {
       expect(chart.getActiveElements()).toEqual([{datasetIndex: 0, index: 1, element: point}]);
     });
 
+    it('should activate element on hover when minPadding pixels outside chart area', async function() {
+      var chart = acquireChart({
+        type: 'line',
+        data: {
+          labels: ['A', 'B', 'C', 'D'],
+          datasets: [{
+            data: [10, 20, 30, 100],
+            hoverRadius: 0
+          }],
+        },
+        options: {
+          scales: {
+            x: {display: false},
+            y: {display: false}
+          }
+        }
+      });
+
+      var point = chart.getDatasetMeta(0).data[0];
+
+      await jasmine.triggerMouseEvent(chart, 'mousemove', {x: 1, y: point.y});
+      expect(chart.getActiveElements()).toEqual([{datasetIndex: 0, index: 0, element: point}]);
+    });
+
     it('should not activate elements when hover is disabled', async function() {
       var chart = acquireChart({
         type: 'line',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 420aa027b305c91380d96d05e39db2767ec1333a test/fixtures/controller.line/clip/default-y-max.png test/fixtures/controller.line/clip/default-y.png test/fixtures/controller.line/non-numeric-y.png test/fixtures/controller.line/point-style-offscreen-canvas.png test/fixtures/controller.line/point-style.png test/fixtures/controller.line/pointBackgroundColor/indexable.png test/fixtures/controller.line/pointBackgroundColor/scriptable.png test/fixtures/controller.line/pointBackgroundColor/value.png test/fixtures/controller.line/pointBorderColor/indexable.png test/fixtures/controller.line/pointBorderColor/scriptable.png test/fixtures/controller.line/pointBorderColor/value.png test/fixtures/controller.line/pointBorderWidth/indexable.png test/fixtures/controller.line/pointBorderWidth/scriptable.png test/fixtures/controller.line/pointBorderWidth/value.png test/fixtures/controller.line/pointStyle/indexable.png test/fixtures/controller.line/pointStyle/scriptable.png test/fixtures/controller.line/pointStyle/value.png test/fixtures/controller.line/radius/indexable.png test/fixtures/controller.line/radius/scriptable.png test/fixtures/controller.line/radius/value.png test/fixtures/controller.line/rotation/indexable.png test/fixtures/controller.line/rotation/scriptable.png test/fixtures/controller.line/rotation/value.png test/fixtures/controller.line/showLine/false.png test/fixtures/controller.line/stacking/stacked-scatter.png test/fixtures/controller.scatter/showLine/true.png test/fixtures/controller.scatter/showLine/undefined.png test/fixtures/core.layouts/hidden-vertical-boxes.png test/fixtures/core.layouts/no-boxes-all-padding.js test/fixtures/core.layouts/no-boxes-all-padding.png test/fixtures/core.layouts/refit-vertical-boxes.png test/fixtures/core.scale/autoSkip/fit-after.png test/fixtures/core.scale/cartesian-axis-border-settings.png test/fixtures/core.scale/label-align-end.png test/fixtures/core.scale/label-align-start.png test/fixtures/core.scale/x-axis-position-dynamic.png test/fixtures/element.line/default.png test/fixtures/element.line/skip/first-span.png test/fixtures/element.line/skip/first.png test/fixtures/element.line/skip/last-span.png test/fixtures/element.line/skip/last.png test/fixtures/element.line/stepped/after.png test/fixtures/element.line/stepped/before.png test/fixtures/element.line/stepped/default.png test/fixtures/element.line/stepped/middle.png test/fixtures/element.line/tension/default.png test/fixtures/element.line/tension/one.png test/fixtures/element.line/tension/zero.png test/fixtures/plugin.filler/fill-line-dataset-interpolated.png test/fixtures/plugin.tooltip/positioning.js test/fixtures/plugin.tooltip/positioning.png test/fixtures/scale.time/autoskip-major.png test/fixtures/scale.time/custom-parser.png test/fixtures/scale.time/data-ty.png test/fixtures/scale.time/data-xy.png test/fixtures/scale.time/negative-times.png test/fixtures/scale.time/source-auto-linear.png test/fixtures/scale.time/source-data-linear.png test/fixtures/scale.time/source-labels-linear-offset-min-max.png test/fixtures/scale.time/source-labels-linear.png test/fixtures/scale.time/ticks-reverse-linear-min-max.png test/fixtures/scale.time/ticks-reverse-linear.png test/fixtures/scale.time/ticks-reverse-offset.png test/fixtures/scale.time/ticks-reverse.png test/fixtures/scale.timeseries/normalize.png test/fixtures/scale.timeseries/source-auto.png test/fixtures/scale.timeseries/source-data-offset-min-max.png test/fixtures/scale.timeseries/source-data.png test/fixtures/scale.timeseries/source-labels-offset-min-max.png test/fixtures/scale.timeseries/source-labels.png test/fixtures/scale.timeseries/ticks-reverse-max.png test/fixtures/scale.timeseries/ticks-reverse-min-max.png test/fixtures/scale.timeseries/ticks-reverse-min.png test/fixtures/scale.timeseries/ticks-reverse.png test/specs/controller.bar.tests.js test/specs/controller.line.tests.js test/specs/core.controller.tests.js
