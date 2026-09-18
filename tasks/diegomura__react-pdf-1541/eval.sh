#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff bef5d6e39ee877fb0ca6957652984dda09e1cb71
rm -f packages/layout/tests/fullPageView.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/layout/tests/fullPageView.test.js b/packages/layout/tests/fullPageView.test.js
new file mode 100644
index 000000000..fdec3879a
--- /dev/null
+++ b/packages/layout/tests/fullPageView.test.js
@@ -0,0 +1,56 @@
+import resolvePagination from '../src/steps/resolvePagination';
+import resolveDimensions from '../src/steps/resolveDimensions';
+
+const calcLayout = node => resolvePagination(resolveDimensions(node));
+
+describe('layout', () => {
+  const root = {
+    type: 'DOCUMENT',
+    children: [
+      {
+        type: 'PAGE',
+        box: {},
+        style: {
+          width: 100,
+          height: 100,
+        },
+        children: [
+          {
+            type: 'VIEW',
+            box: {},
+            style: {
+              position: 'absolute',
+              width: '50%',
+              top: 0,
+              bottom: 0,
+            },
+            props: {},
+            children: [],
+          },
+          {
+            type: 'TEXT',
+            box: {},
+            style: {},
+            props: {},
+            children: [
+              {
+                type: 'TEXT_INSTANCE',
+                value: 'hello world',
+              },
+            ],
+          },
+        ],
+      },
+    ],
+  };
+
+  test('should stretch absolute block to full page size', () => {
+    const layout = calcLayout(root);
+
+    const page = layout.children[0];
+    const view = layout.children[0].children[0];
+
+    expect(page.box.height).toBe(100);
+    expect(view.box.height).toBe(100);
+  });
+});

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
rm -f packages/layout/tests/fullPageView.test.js
