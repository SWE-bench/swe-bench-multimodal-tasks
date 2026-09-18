#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 23b89c2869f75f4f843522de5e348c2f92e87a67
git checkout 23b89c2869f75f4f843522de5e348c2f92e87a67 tests/flattenStyles.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/flattenStyles.test.js b/tests/flattenStyles.test.js
index 5c14a4fa1..36512cf0d 100644
--- a/tests/flattenStyles.test.js
+++ b/tests/flattenStyles.test.js
@@ -28,4 +28,11 @@ describe('flatten styles', () => {
 
     return expect(flatten).toEqual({ fontSize: 16, color: 'white' });
   });
+
+  test('should flat nested arrays', () => {
+    const styles = [{ fontSize: 16, color: 'white' }, [{ color: 'red' }]];
+    const flatten = StyleSheet.flatten(styles);
+
+    return expect(flatten).toEqual({ fontSize: 16, color: 'red' });
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 23b89c2869f75f4f843522de5e348c2f92e87a67 tests/flattenStyles.test.js
