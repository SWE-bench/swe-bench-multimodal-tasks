#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b751de512b3026fe7c5d35596afb362b1287a3f6
git checkout b751de512b3026fe7c5d35596afb362b1287a3f6 lighthouse-core/test/index-test.js lighthouse-core/test/runner-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/index-test.js b/lighthouse-core/test/index-test.js
index e5c678c77154..c56e77851f6e 100644
--- a/lighthouse-core/test/index-test.js
+++ b/lighthouse-core/test/index-test.js
@@ -87,22 +87,26 @@ describe('Module Tests', function() {
       });
   });
 
-  it('should throw an error when the url is invalid', function() {
-    return lighthouse('https:/i-am-not-valid', {}, {})
-      .then(() => {
-        throw new Error('Should not have resolved when url is invalid');
-      }, err => {
-        assert.ok(err);
-      });
-  });
-
-  it('should throw an error when the url is invalid protocol (file:///)', function() {
-    return lighthouse('file:///a/fake/index.html', {}, {})
-      .then(() => {
-        throw new Error('Should not have resolved when url is file:///');
-      }, err => {
-        assert.ok(err);
-      });
+  it('should throw an error when the url is invalid', async () => {
+    expect.hasAssertions();
+    try {
+      await lighthouse('i-am-not-valid', {}, {});
+    } catch (err) {
+      expect(err.friendlyMessage)
+          .toBeDisplayString('The URL you have provided appears to be invalid.');
+      expect(err.code).toEqual('INVALID_URL');
+    }
+  });
+
+  it('should throw an error when the url is invalid protocol (file:///)', async () => {
+    expect.hasAssertions();
+    try {
+      await lighthouse('file:///a/fake/index.html', {}, {});
+    } catch (err) {
+      expect(err.friendlyMessage)
+          .toBeDisplayString('The URL you have provided appears to be invalid.');
+      expect(err.code).toEqual('INVALID_URL');
+    }
   });
 
   it('should return formatted LHR when given no categories', function() {
diff --git a/lighthouse-core/test/runner-test.js b/lighthouse-core/test/runner-test.js
index bb9b38c6cb11..ccf4bf339401 100644
--- a/lighthouse-core/test/runner-test.js
+++ b/lighthouse-core/test/runner-test.js
@@ -514,20 +514,24 @@ describe('Runner', () => {
   });
 
 
-  it('rejects when not given a URL', () => {
-    return Runner.run({}, {}).then(_ => assert.ok(false), _ => assert.ok(true));
+  it('rejects when not given a URL', async () => {
+    const config = new Config({});
+    await expect(Runner.run({}, {config})).rejects.toThrow('INVALID_URL');
   });
 
-  it('rejects when given a URL of zero length', () => {
-    return Runner.run({}, {url: ''}).then(_ => assert.ok(false), _ => assert.ok(true));
+  it('rejects when given a URL of zero length', async () => {
+    const config = new Config({});
+    await expect(Runner.run({}, {url: '', config})).rejects.toThrow('INVALID_URL');
   });
 
-  it('rejects when given a URL without protocol', () => {
-    return Runner.run({}, {url: 'localhost'}).then(_ => assert.ok(false), _ => assert.ok(true));
+  it('rejects when given a URL without protocol', async () => {
+    const config = new Config({});
+    await expect(Runner.run({}, {url: 'localhost', config})).rejects.toThrow('INVALID_URL');
   });
 
-  it('rejects when given a URL without hostname', () => {
-    return Runner.run({}, {url: 'https://'}).then(_ => assert.ok(false), _ => assert.ok(true));
+  it('rejects when given a URL without hostname', async () => {
+    const config = new Config({});
+    await expect(Runner.run({}, {url: 'https://', config})).rejects.toThrow('INVALID_URL');
   });
 
   it('only supports core audits with names matching their filename', () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/index-test.js lighthouse-core/test/runner-test.js
: '>>>>> End Test Output'
git checkout b751de512b3026fe7c5d35596afb362b1287a3f6 lighthouse-core/test/index-test.js lighthouse-core/test/runner-test.js
