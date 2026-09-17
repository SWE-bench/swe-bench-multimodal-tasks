#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff f508d4e9938e80e888deb2dc8cada6d84e116427
git checkout f508d4e9938e80e888deb2dc8cada6d84e116427 tests/background.test.js tests/borders.test.js tests/utils/dummyRoot.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/background.test.js b/tests/background.test.js
index ef8799851..affd319b9 100644
--- a/tests/background.test.js
+++ b/tests/background.test.js
@@ -24,13 +24,7 @@ describe('Background', () => {
 
     expect(dummyRoot.instance.fillColor.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.fillColor.mock.calls[0][0]).toBe('tomato');
-    expect(dummyRoot.instance.roundedRect.mock.calls[0]).toEqual([
-      0,
-      0,
-      50,
-      50,
-      0,
-    ]);
+    expect(dummyRoot.instance.rect.mock.calls[0]).toEqual([0, 0, 50, 50]);
     expect(dummyRoot.instance.fill.mock.calls).toHaveLength(1);
   });
 
@@ -48,13 +42,7 @@ describe('Background', () => {
 
     expect(dummyRoot.instance.fillColor.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.fillColor.mock.calls[0][0]).toBe('tomato');
-    expect(dummyRoot.instance.roundedRect.mock.calls[0]).toEqual([
-      40,
-      40,
-      50,
-      50,
-      0,
-    ]);
+    expect(dummyRoot.instance.rect.mock.calls[0]).toEqual([40, 40, 50, 50]);
     expect(dummyRoot.instance.fill.mock.calls).toHaveLength(1);
   });
 
@@ -72,13 +60,7 @@ describe('Background', () => {
 
     expect(dummyRoot.instance.fillColor.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.fillColor.mock.calls[0][0]).toBe('tomato');
-    expect(dummyRoot.instance.roundedRect.mock.calls[0]).toEqual([
-      0,
-      0,
-      50,
-      50,
-      0,
-    ]);
+    expect(dummyRoot.instance.rect.mock.calls[0]).toEqual([0, 0, 50, 50]);
     expect(dummyRoot.instance.fill.mock.calls).toHaveLength(1);
   });
 
@@ -101,13 +83,7 @@ describe('Background', () => {
 
     expect(dummyRoot.instance.fillColor.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.fillColor.mock.calls[0][0]).toBe('tomato');
-    expect(dummyRoot.instance.roundedRect.mock.calls[0]).toEqual([
-      0,
-      0,
-      50,
-      50,
-      5,
-    ]);
+    expect(dummyRoot.instance.rect.mock.calls[0]).toEqual([0, 0, 50, 50]);
     expect(dummyRoot.instance.fill.mock.calls).toHaveLength(1);
   });
 });
diff --git a/tests/borders.test.js b/tests/borders.test.js
index 7ac3ed5c8..a2a5dd937 100644
--- a/tests/borders.test.js
+++ b/tests/borders.test.js
@@ -23,7 +23,7 @@ describe('Borders', () => {
     await doc.render();
 
     expect(dummyRoot.instance.lineWidth.mock.calls).toHaveLength(1);
-    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(2);
+    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(4);
     expect(dummyRoot.instance.stroke.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.dash.mock.calls).toHaveLength(0);
   });
@@ -41,7 +41,7 @@ describe('Borders', () => {
     await doc.render();
 
     expect(dummyRoot.instance.lineWidth.mock.calls).toHaveLength(1);
-    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(2);
+    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(4);
     expect(dummyRoot.instance.stroke.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.dash.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.dash.mock.calls[0][0]).toBe(4);
@@ -60,7 +60,7 @@ describe('Borders', () => {
     await doc.render();
 
     expect(dummyRoot.instance.lineWidth.mock.calls).toHaveLength(1);
-    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(2);
+    expect(dummyRoot.instance.lineWidth.mock.calls[0][0]).toBe(4);
     expect(dummyRoot.instance.stroke.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.dash.mock.calls).toHaveLength(1);
     expect(dummyRoot.instance.dash.mock.calls[0][0]).toBe(2);
diff --git a/tests/utils/dummyRoot.js b/tests/utils/dummyRoot.js
index d190101f7..82392f836 100644
--- a/tests/utils/dummyRoot.js
+++ b/tests/utils/dummyRoot.js
@@ -25,6 +25,11 @@ export default {
     instance.scale = jest.fn().mockReturnValue(instance);
     instance.translate = jest.fn().mockReturnValue(instance);
     instance.link = jest.fn().mockReturnValue(instance);
+    instance.clip = jest.fn().mockReturnValue(instance);
+    instance.bezierCurveTo = jest.fn().mockReturnValue(instance);
+    instance.closePath = jest.fn().mockReturnValue(instance);
+    instance.undash = jest.fn().mockReturnValue(instance);
+    instance.moveTo = jest.fn().mockReturnValue(instance);
 
     return {
       instance,

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout f508d4e9938e80e888deb2dc8cada6d84e116427 tests/background.test.js tests/borders.test.js tests/utils/dummyRoot.js
