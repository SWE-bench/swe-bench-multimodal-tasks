#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff b2470486463164cea0a887439758a5d75a31f446
git checkout b2470486463164cea0a887439758a5d75a31f446 packages/stylesheet/tests/expand.test.js packages/stylesheet/tests/resolve.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/stylesheet/tests/expand.test.js b/packages/stylesheet/tests/expand.test.js
index 17fa971dc..60843a221 100644
--- a/packages/stylesheet/tests/expand.test.js
+++ b/packages/stylesheet/tests/expand.test.js
@@ -223,6 +223,18 @@ describe('stylesheet transform', () => {
     expect(left.marginLeft).toBe(4);
   });
 
+  test('should keep auto margins', () => {
+    const top = expandStyles({ marginTop: 'auto' });
+    const right = expandStyles({ marginRight: 'auto' });
+    const bottom = expandStyles({ marginBottom: 'auto' });
+    const left = expandStyles({ marginLeft: 'auto' });
+
+    expect(top.marginTop).toBe('auto');
+    expect(right.marginRight).toBe('auto');
+    expect(bottom.marginBottom).toBe('auto');
+    expect(left.marginLeft).toBe('auto');
+  });
+
   test('should process padding shorthand', () => {
     const top = expandStyles({ paddingTop: '1 2 3 4' });
     const right = expandStyles({ paddingRight: '1 2 3 4' });
@@ -271,6 +283,18 @@ describe('stylesheet transform', () => {
     expect(left.paddingLeft).toBe(4);
   });
 
+  test('should keep auto paddings', () => {
+    const top = expandStyles({ paddingTop: 'auto' });
+    const right = expandStyles({ paddingRight: 'auto' });
+    const bottom = expandStyles({ paddingBottom: 'auto' });
+    const left = expandStyles({ paddingLeft: 'auto' });
+
+    expect(top.paddingTop).toBe('auto');
+    expect(right.paddingRight).toBe('auto');
+    expect(bottom.paddingBottom).toBe('auto');
+    expect(left.paddingLeft).toBe('auto');
+  });
+
   test('should process borderWidth shorthand', () => {
     const top = expandStyles({ borderTopWidth: '1 solid blue' });
     const right = expandStyles({ borderRightWidth: '1 solid blue' });
diff --git a/packages/stylesheet/tests/resolve.test.js b/packages/stylesheet/tests/resolve.test.js
index 98138c434..2301bc8ca 100644
--- a/packages/stylesheet/tests/resolve.test.js
+++ b/packages/stylesheet/tests/resolve.test.js
@@ -328,6 +328,17 @@ describe('stylesheet resolve', () => {
     });
   });
 
+  test('should transform margin auto shortcut correctly', () => {
+    const styles = resolve({}, { margin: 'auto' });
+
+    expect(styles).toEqual({
+      marginRight: 'auto',
+      marginLeft: 'auto',
+      marginTop: 'auto',
+      marginBottom: 'auto',
+    });
+  });
+
   test('should transform padding style correctly', () => {
     const styles = resolve({}, { padding: 4 });
 
@@ -405,6 +416,17 @@ describe('stylesheet resolve', () => {
     });
   });
 
+  test('should transform padding auto shortcut correctly', () => {
+    const styles = resolve({}, { padding: 'auto' });
+
+    expect(styles).toEqual({
+      paddingRight: 'auto',
+      paddingLeft: 'auto',
+      paddingTop: 'auto',
+      paddingBottom: 'auto',
+    });
+  });
+
   test('should transform font weight correctly', () => {
     const styles = resolve({}, { fontWeight: 'ultrabold' });
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout b2470486463164cea0a887439758a5d75a31f446 packages/stylesheet/tests/expand.test.js packages/stylesheet/tests/resolve.test.js
