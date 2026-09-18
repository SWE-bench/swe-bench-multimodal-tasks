#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 7acd39fa1b60d2379e48584964d8c4643aa473be
git checkout 7acd39fa1b60d2379e48584964d8c4643aa473be packages/layout/tests/steps/resolvePagination.test.js && rm -f packages/layout/tests/steps/resolveTextLayout.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/layout/tests/fullPageView.test.js b/packages/layout/tests/steps/resolvePagination.test.js
similarity index 82%
rename from packages/layout/tests/fullPageView.test.js
rename to packages/layout/tests/steps/resolvePagination.test.js
index fdec3879a..e44db425f 100644
--- a/packages/layout/tests/fullPageView.test.js
+++ b/packages/layout/tests/steps/resolvePagination.test.js
@@ -1,9 +1,10 @@
-import resolvePagination from '../src/steps/resolvePagination';
-import resolveDimensions from '../src/steps/resolveDimensions';
+import resolvePagination from '../../src/steps/resolvePagination';
+import resolveDimensions from '../../src/steps/resolveDimensions';
 
+// dimensions is required by pagination step and them are calculated here
 const calcLayout = node => resolvePagination(resolveDimensions(node));
 
-describe('layout', () => {
+describe('pagination step', () => {
   const root = {
     type: 'DOCUMENT',
     children: [
diff --git a/packages/layout/tests/steps/resolveTextLayout.test.js b/packages/layout/tests/steps/resolveTextLayout.test.js
new file mode 100644
index 000000000..380ff6d80
--- /dev/null
+++ b/packages/layout/tests/steps/resolveTextLayout.test.js
@@ -0,0 +1,59 @@
+import resolveTextLayout from '../../src/steps/resolveTextLayout';
+import resolveDimensions from '../../src/steps/resolveDimensions';
+
+const getRoot = (text = 'hello world', styles = {}) => ({
+  type: 'DOCUMENT',
+  children: [
+    {
+      type: 'PAGE',
+      box: {},
+      style: {
+        width: 100,
+        height: 100,
+      },
+      children: [
+        {
+          type: 'TEXT',
+          box: {},
+          style: styles,
+          props: {},
+          children: [
+            {
+              type: 'TEXT_INSTANCE',
+              value: text,
+            },
+          ],
+        },
+      ],
+    },
+  ],
+});
+
+describe('text layout step', () => {
+  const getText = root => root.children[0].children[0];
+
+  test('should calculate lines for text while resolve dimensions', () => {
+    const root = getRoot('text text text');
+    const dimensions = resolveDimensions(root);
+
+    expect(getText(dimensions).lines).toBeDefined();
+  });
+
+  test('should calculate lines for text width defined height', () => {
+    const root = getRoot('text text text', { height: 50 });
+    const dimensions = resolveDimensions(root);
+
+    expect(getText(dimensions).lines).not.toBeDefined();
+
+    const textLayout = resolveTextLayout(dimensions);
+
+    expect(getText(textLayout).lines).toBeDefined();
+  });
+
+  test('should calculate lines for empty text', () => {
+    const root = getRoot('');
+    const dimensions = resolveDimensions(root);
+
+    expect(getText(dimensions).lines).toBeDefined();
+  });
+});

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 7acd39fa1b60d2379e48584964d8c4643aa473be packages/layout/tests/steps/resolvePagination.test.js && rm -f packages/layout/tests/steps/resolveTextLayout.test.js
