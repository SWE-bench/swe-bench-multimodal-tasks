#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 2a8152e66e02cf71406fb96e3c49642946a24be0
git checkout 2a8152e66e02cf71406fb96e3c49642946a24be0 packages/stylesheet/tests/resolve.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/stylesheet/tests/resolve.test.js b/packages/stylesheet/tests/resolve.test.js
index b2ace6c16..f858bce84 100644
--- a/packages/stylesheet/tests/resolve.test.js
+++ b/packages/stylesheet/tests/resolve.test.js
@@ -455,6 +455,24 @@ describe('stylesheet resolve', () => {
     expect(styles).toEqual({ fontWeight: 800 });
   });
 
+  test('should keep flex basis percent value', () => {
+    const styles = resolve({}, { flexBasis: '40%' });
+
+    expect(styles).toEqual({ flexBasis: '40%' });
+  });
+
+  test('should keep flex shrink percent value', () => {
+    const styles = resolve({}, { flexShrink: '40%' });
+
+    expect(styles).toEqual({ flexShrink: '40%' });
+  });
+
+  test('should keep flex grow percent value', () => {
+    const styles = resolve({}, { flexGrow: '40%' });
+
+    expect(styles).toEqual({ flexGrow: '40%' });
+  });
+
   test('should resolve max-height media queries on narrow container', () => {
     const styles = resolve(
       { height: 300 },

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 2a8152e66e02cf71406fb96e3c49642946a24be0 packages/stylesheet/tests/resolve.test.js
