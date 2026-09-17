#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4a63f3cea271bd0f209fbc648dd3612d685b31ab
git checkout 4a63f3cea271bd0f209fbc648dd3612d685b31ab lighthouse-core/test/audits/short-name-length-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/short-name-length-test.js b/lighthouse-core/test/audits/short-name-length-test.js
index 30f1544ea903..8e1ab7718d45 100644
--- a/lighthouse-core/test/audits/short-name-length-test.js
+++ b/lighthouse-core/test/audits/short-name-length-test.js
@@ -27,7 +27,9 @@ const EXAMPLE_DOC_URL = 'https://example.com/index.html';
 describe('Manifest: short_name_length audit', () => {
   it('fails when an empty manifest is present', () => {
     const Manifest = manifestParser('{}', EXAMPLE_MANIFEST_URL, EXAMPLE_DOC_URL);
-    return assert.equal(Audit.audit({Manifest}).rawValue, false);
+    const result = Audit.audit({Manifest});
+    assert.equal(result.rawValue, false);
+    assert.equal(result.debugString, 'No short_name found.');
   });
 
   it('fails when a manifest contains no short_name and too long name', () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/audits/short-name-length-test.js
: '>>>>> End Test Output'
git checkout 4a63f3cea271bd0f209fbc648dd3612d685b31ab lighthouse-core/test/audits/short-name-length-test.js
