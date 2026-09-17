#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c961db4bf2ba81581c7c0eda02e9fc5f5ef78f01
git checkout c961db4bf2ba81581c7c0eda02e9fc5f5ef78f01 packages/stylesheet/tests/flex.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/stylesheet/tests/flex.test.js b/packages/stylesheet/tests/flex.test.js
index a24ded307..38ce5d788 100644
--- a/packages/stylesheet/tests/flex.test.js
+++ b/packages/stylesheet/tests/flex.test.js
@@ -10,4 +10,34 @@ describe('stylesheet flex transform', () => {
       flexBasis: 'auto',
     });
   });
+
+  test('should process flex shorthand with one digit', () => {
+    const styles = processFlex('flex', 1);
+
+    expect(styles).toEqual({
+      flexGrow: 1,
+      flexShrink: 1,
+      flexBasis: 0,
+    });
+  });
+
+  test("should process flex '1'", () => {
+    const styles = processFlex('flex', '1');
+
+    expect(styles).toEqual({
+      flexGrow: 1,
+      flexShrink: 1,
+      flexBasis: 0,
+    });
+  });
+
+  test('should process flex shorthand with two digits', () => {
+    const styles = processFlex('flex', '1 0');
+
+    expect(styles).toEqual({
+      flexGrow: 1,
+      flexShrink: 0,
+      flexBasis: 0,
+    });
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout c961db4bf2ba81581c7c0eda02e9fc5f5ef78f01 packages/stylesheet/tests/flex.test.js
