#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 721113e72e73b308caa7dd82b0776418e76c491b
git checkout 721113e72e73b308caa7dd82b0776418e76c491b packages/layout/tests/image/getSource.test.js && rm -f packages/layout/tests/image/resolveSource.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/layout/tests/image/getSource.test.js b/packages/layout/tests/image/getSource.test.js
index e465d6295..4d5e3fad1 100644
--- a/packages/layout/tests/image/getSource.test.js
+++ b/packages/layout/tests/image/getSource.test.js
@@ -5,17 +5,17 @@ const VALUE = 'gotcha';
 describe('image getSource', () => {
   test('Should get src', () => {
     const node = { type: 'IMAGE', props: { src: VALUE } };
-    expect(getSource(node)).toEqual({ uri: VALUE });
+    expect(getSource(node)).toEqual(VALUE);
   });
 
   test('Should get source', () => {
     const node = { type: 'IMAGE', props: { source: VALUE } };
-    expect(getSource(node)).toEqual({ uri: VALUE });
+    expect(getSource(node)).toEqual(VALUE);
   });
 
   test('Should get href', () => {
     const node = { type: 'IMAGE', props: { href: VALUE } };
-    expect(getSource(node)).toEqual({ uri: VALUE });
+    expect(getSource(node)).toEqual(VALUE);
   });
 
   test('Should get undefined if either present', () => {
diff --git a/packages/layout/tests/image/resolveSource.test.js b/packages/layout/tests/image/resolveSource.test.js
new file mode 100644
index 000000000..80bbe4e84
--- /dev/null
+++ b/packages/layout/tests/image/resolveSource.test.js
@@ -0,0 +1,104 @@
+import resolveSource from '../../src/image/resolveSource';
+
+const SOURCE_URL = 'gotcha';
+const SOURCE_URL_OBJECT = { uri: 'gotcha', method: 'GET' };
+const SOURCE_BUFFER = Buffer.from('gotcha');
+const SOURCE_DATA_BUFFER = { data: Buffer.from('gotcha'), format: 'png' };
+
+describe('image resolveSource', () => {
+  describe('source', () => {
+    it('resolves url', () => {
+      expect(resolveSource(SOURCE_URL)).resolves.toEqual({ uri: SOURCE_URL });
+    });
+
+    it('resolves url object', () => {
+      expect(resolveSource(SOURCE_URL_OBJECT)).resolves.toBe(SOURCE_URL_OBJECT);
+    });
+
+    it('resolves buffer', () => {
+      expect(resolveSource(SOURCE_BUFFER)).resolves.toBe(SOURCE_BUFFER);
+    });
+
+    it('resolves data buffer', () => {
+      expect(resolveSource(SOURCE_DATA_BUFFER)).resolves.toBe(
+        SOURCE_DATA_BUFFER,
+      );
+    });
+  });
+
+  describe('async', () => {
+    it('resolves url', () => {
+      expect(resolveSource(Promise.resolve(SOURCE_URL))).resolves.toEqual({
+        uri: SOURCE_URL,
+      });
+    });
+
+    it('resolves url object', () => {
+      expect(resolveSource(Promise.resolve(SOURCE_URL_OBJECT))).resolves.toBe(
+        SOURCE_URL_OBJECT,
+      );
+    });
+
+    it('resolves buffer', () => {
+      expect(resolveSource(Promise.resolve(SOURCE_BUFFER))).resolves.toBe(
+        SOURCE_BUFFER,
+      );
+    });
+
+    it('resolves data buffer', () => {
+      expect(resolveSource(Promise.resolve(SOURCE_DATA_BUFFER))).resolves.toBe(
+        SOURCE_DATA_BUFFER,
+      );
+    });
+  });
+
+  describe('factory', () => {
+    it('resolves url', () => {
+      expect(resolveSource(() => SOURCE_URL)).resolves.toEqual({
+        uri: SOURCE_URL,
+      });
+    });
+
+    it('resolves url object', () => {
+      expect(resolveSource(() => SOURCE_URL_OBJECT)).resolves.toBe(
+        SOURCE_URL_OBJECT,
+      );
+    });
+
+    it('resolves buffer', () => {
+      expect(resolveSource(() => SOURCE_BUFFER)).resolves.toBe(SOURCE_BUFFER);
+    });
+
+    it('resolves data buffer', () => {
+      expect(resolveSource(() => SOURCE_DATA_BUFFER)).resolves.toBe(
+        SOURCE_DATA_BUFFER,
+      );
+    });
+  });
+
+  describe('async factory', () => {
+    it('resolves url', () => {
+      expect(resolveSource(async () => SOURCE_URL)).resolves.toEqual({
+        uri: SOURCE_URL,
+      });
+    });
+
+    it('resolves url object', () => {
+      expect(resolveSource(async () => SOURCE_URL_OBJECT)).resolves.toBe(
+        SOURCE_URL_OBJECT,
+      );
+    });
+
+    it('resolves buffer', () => {
+      expect(resolveSource(async () => SOURCE_BUFFER)).resolves.toBe(
+        SOURCE_BUFFER,
+      );
+    });
+
+    it('resolves data buffer', () => {
+      expect(resolveSource(async () => SOURCE_DATA_BUFFER)).resolves.toBe(
+        SOURCE_DATA_BUFFER,
+      );
+    });
+  });
+});

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color
: '>>>>> End Test Output'
git checkout 721113e72e73b308caa7dd82b0776418e76c491b packages/layout/tests/image/getSource.test.js && rm -f packages/layout/tests/image/resolveSource.test.js
