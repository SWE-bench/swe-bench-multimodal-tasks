#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 39f9b8a255334d335b0c7678b2129aeff6372d87
git checkout 39f9b8a255334d335b0c7678b2129aeff6372d87 packages/textkit/tests/indices/resolve.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/textkit/tests/indices/resolve.test.js b/packages/textkit/tests/indices/resolve.test.js
index b65c64c93..73f212949 100644
--- a/packages/textkit/tests/indices/resolve.test.js
+++ b/packages/textkit/tests/indices/resolve.test.js
@@ -1,58 +1,140 @@
 import resolve from '../../src/indices/resolve';
 
+const singleGlyph = { codePoints: ['codePoint'] };
+
+const ligatureGlyph = { codePoints: ['codePoint', 'otherCodePoint'] };
+
+const longerLigatureGlyph = {
+  codePoints: ['codePoint', 'otherCodePoint', 'anotherCodePoint'],
+};
+
 describe('indices resolve operator', () => {
   test('should return empty array from empty array', () => {
-    const result = resolve('', []);
+    const result = resolve([]);
     expect(result).toEqual([]);
   });
 
   test('should return same indices from simple chars', () => {
-    const result = resolve('lorem', [0, 1, 2, 3, 4]);
+    // ex. lorem
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 4]);
   });
 
   test('should return correct glyph indices when starting with ligature', () => {
-    const result = resolve('firem', [0, 2, 3, 4]);
+    // ex. firem
+    const result = resolve([
+      ligatureGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 0, 1, 2, 3]);
   });
 
   test('should return correct glyph indices when contain ligature', () => {
-    const result = resolve('lofim', [0, 1, 2, 4]);
+    // ex. lofim
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      ligatureGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 2, 3]);
   });
 
   test('should return correct glyph indices when ending in ligature', () => {
-    const result = resolve('lorfi', [0, 1, 2, 3]);
+    // ex. lorfi
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      ligatureGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 3]);
   });
 
   test('should return correct glyph indices when starting with long ligature', () => {
-    const result = resolve('ffirem', [0, 3, 4, 5]);
+    // ex. ffirem
+    const result = resolve([
+      longerLigatureGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 0, 0, 1, 2, 3]);
   });
 
   test('should return correct glyph indices when contain long ligature', () => {
-    const result = resolve('loffim', [0, 1, 2, 5]);
+    // ex. loffim
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      longerLigatureGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 2, 2, 3]);
   });
 
   test('should return correct glyph indices when ending in long ligature', () => {
-    const result = resolve('lorffi', [0, 1, 2, 3]);
+    // ex. lorffi
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      longerLigatureGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 3, 3]);
   });
 
   test('should fill undefined index at start', () => {
-    const result = resolve('lorem', [undefined, 0, 1, 2, 3]);
+    // ex. lorem
+    const result = resolve([
+      undefined,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 4]);
   });
 
   test('should fill undefined index at middle', () => {
-    const result = resolve('lorem', [0, 1, undefined, 3, 4]);
+    // ex. lorem
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      undefined,
+      singleGlyph,
+      singleGlyph,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 4]);
   });
 
   test('should fill undefined index at end', () => {
-    const result = resolve('lorem', [0, 1, 2, 3, undefined]);
+    // ex. lorem
+    const result = resolve([
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      singleGlyph,
+      undefined,
+    ]);
+
     expect(result).toEqual([0, 1, 2, 3, 4]);
   });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 39f9b8a255334d335b0c7678b2129aeff6372d87 packages/textkit/tests/indices/resolve.test.js
