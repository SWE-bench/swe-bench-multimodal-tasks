#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 476e7806ef40a758dd30703b613e8480a2304bba
git checkout 476e7806ef40a758dd30703b613e8480a2304bba lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js b/lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
index 2e53504cb288..758ef81a564c 100644
--- a/lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
+++ b/lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
@@ -115,6 +115,17 @@ describe('OffscreenImages audit', () => {
     });
   });
 
+  it('finds images with 0 area', () => {
+    return UnusedImages.audit_({
+      ViewportDimensions: DEFAULT_DIMENSIONS,
+      ImageUsage: [
+        generateImage(generateSize(0, 0), [0, 0], generateRecord(100)),
+      ],
+    }).then(auditResult => {
+      assert.equal(auditResult.results.length, 1);
+    });
+  });
+
   it('de-dupes images', () => {
     const urlB = 'https://google.com/logo2.png';
     return UnusedImages.audit_({

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
: '>>>>> End Test Output'
git checkout 476e7806ef40a758dd30703b613e8480a2304bba lighthouse-core/test/audits/byte-efficiency/offscreen-images-test.js
