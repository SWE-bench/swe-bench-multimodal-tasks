#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6dbb7e74462d5b7dedf2124a622a3e678964dd83
git checkout 6dbb7e74462d5b7dedf2124a622a3e678964dd83 test/fixtures/controller.bar/horizontal-borders.png test/specs/helpers.options.tests.js && rm -f test/fixtures/controller.bar/border-radius.js test/fixtures/controller.bar/border-radius.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/controller.bar/border-radius.js b/test/fixtures/controller.bar/border-radius.js
new file mode 100644
index 00000000000..67c579ff09a
--- /dev/null
+++ b/test/fixtures/controller.bar/border-radius.js
@@ -0,0 +1,45 @@
+module.exports = {
+	threshold: 0.01,
+	config: {
+		type: 'bar',
+		data: {
+			labels: [0, 1, 2, 3, 4, 5],
+			datasets: [
+				{
+					// option in dataset
+					data: [0, 5, 10, null, -10, -5],
+					borderWidth: 2,
+					borderRadius: 5
+				},
+				{
+					// option in element (fallback)
+					data: [0, 5, 10, null, -10, -5],
+					borderSkipped: false,
+					borderRadius: Number.MAX_VALUE
+				}
+			]
+		},
+		options: {
+			legend: false,
+			title: false,
+			indexAxis: 'y',
+			elements: {
+				bar: {
+					backgroundColor: '#AAAAAA80',
+					borderColor: '#80808080',
+					borderWidth: {bottom: 6, left: 15, top: 6, right: 15}
+				}
+			},
+			scales: {
+				x: {display: false},
+				y: {display: false}
+			}
+		}
+	},
+	options: {
+		canvas: {
+			height: 256,
+			width: 512
+		}
+	}
+};
diff --git a/test/specs/helpers.options.tests.js b/test/specs/helpers.options.tests.js
index f742b1bf548..6bad385c122 100644
--- a/test/specs/helpers.options.tests.js
+++ b/test/specs/helpers.options.tests.js
@@ -1,4 +1,4 @@
-const {toLineHeight, toPadding, toFont, resolve} = Chart.helpers; // from '../../src/helpers/helpers.options';
+const {toLineHeight, toPadding, toFont, resolve, toTRBLCorners} = Chart.helpers; // from '../../src/helpers/helpers.options';
 
 describe('Chart.helpers.options', function() {
 	describe('toLineHeight', function() {
@@ -23,6 +23,43 @@ describe('Chart.helpers.options', function() {
 		});
 	});
 
+	describe('toTRBLCorners', function() {
+		it('should support number values', function() {
+			expect(toTRBLCorners(4)).toEqual(
+				{topLeft: 4, topRight: 4, bottomLeft: 4, bottomRight: 4});
+			expect(toTRBLCorners(4.5)).toEqual(
+				{topLeft: 4.5, topRight: 4.5, bottomLeft: 4.5, bottomRight: 4.5});
+		});
+		it('should support string values', function() {
+			expect(toTRBLCorners('4')).toEqual(
+				{topLeft: 4, topRight: 4, bottomLeft: 4, bottomRight: 4});
+			expect(toTRBLCorners('4.5')).toEqual(
+				{topLeft: 4.5, topRight: 4.5, bottomLeft: 4.5, bottomRight: 4.5});
+		});
+		it('should support object values', function() {
+			expect(toTRBLCorners({topLeft: 1, topRight: 2, bottomLeft: 3, bottomRight: 4})).toEqual(
+				{topLeft: 1, topRight: 2, bottomLeft: 3, bottomRight: 4});
+			expect(toTRBLCorners({topLeft: 1.5, topRight: 2.5, bottomLeft: 3.5, bottomRight: 4.5})).toEqual(
+				{topLeft: 1.5, topRight: 2.5, bottomLeft: 3.5, bottomRight: 4.5});
+			expect(toTRBLCorners({topLeft: '1', topRight: '2', bottomLeft: '3', bottomRight: '4'})).toEqual(
+				{topLeft: 1, topRight: 2, bottomLeft: 3, bottomRight: 4});
+		});
+		it('should fallback to 0 for invalid values', function() {
+			expect(toTRBLCorners({topLeft: 'foo', topRight: 'foo', bottomLeft: 'foo', bottomRight: 'foo'})).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+			expect(toTRBLCorners({topLeft: null, topRight: null, bottomLeft: null, bottomRight: null})).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+			expect(toTRBLCorners({})).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+			expect(toTRBLCorners('foo')).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+			expect(toTRBLCorners(null)).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+			expect(toTRBLCorners(undefined)).toEqual(
+				{topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0});
+		});
+	});
+
 	describe('toPadding', function() {
 		it ('should support number values', function() {
 			expect(toPadding(4)).toEqual(

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 6dbb7e74462d5b7dedf2124a622a3e678964dd83 test/fixtures/controller.bar/horizontal-borders.png test/specs/helpers.options.tests.js && rm -f test/fixtures/controller.bar/border-radius.js test/fixtures/controller.bar/border-radius.png
