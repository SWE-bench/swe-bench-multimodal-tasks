#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6e1550c4c722cddbda9c09d3d375d37f477b7b3d
git checkout 6e1550c4c722cddbda9c09d3d375d37f477b7b3d packages/textkit/tests/layout/applyDefaultStyles.test.js && rm -f packages/render/tests/utils/parseColor.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/render/tests/utils/parseColor.test.js b/packages/render/tests/utils/parseColor.test.js
new file mode 100644
index 000000000..8f53261a6
--- /dev/null
+++ b/packages/render/tests/utils/parseColor.test.js
@@ -0,0 +1,28 @@
+import parseColor from '../../src/utils/parseColor';
+
+describe('parse color util', () => {
+  test(`should parse regular hex color`, () => {
+    const color = parseColor('#FF00FF');
+    expect(color.value).toBe('#FF00FF');
+  });
+
+  test(`should parse opacity as 1 if not provided`, () => {
+    const color = parseColor('#FF00FF');
+    expect(color.opacity).toBe(1);
+  });
+
+  test(`should parse opacity as 1 when provided`, () => {
+    const color = parseColor('#FF00FFFF');
+    expect(color.opacity).toBe(1);
+  });
+
+  test(`should parse opacity as 0 when provided`, () => {
+    const color = parseColor('#FF00FF00');
+    expect(color.opacity).toBe(0);
+  });
+
+  test(`should parse opacit provided`, () => {
+    const color = parseColor('#FF00FF54');
+    expect(color.opacity).toBe(0.32941176470588235);
+  });
+});
diff --git a/packages/textkit/tests/layout/applyDefaultStyles.test.js b/packages/textkit/tests/layout/applyDefaultStyles.test.js
index 9155e94f9..831b22dd5 100644
--- a/packages/textkit/tests/layout/applyDefaultStyles.test.js
+++ b/packages/textkit/tests/layout/applyDefaultStyles.test.js
@@ -23,7 +23,6 @@ const DEFAULTS = {
   link: null,
   marginLeft: 0,
   marginRight: 0,
-  opacity: 1,
   paddingTop: 0,
   paragraphSpacing: 0,
   underline: false,

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 6e1550c4c722cddbda9c09d3d375d37f477b7b3d packages/textkit/tests/layout/applyDefaultStyles.test.js && rm -f packages/render/tests/utils/parseColor.test.js
