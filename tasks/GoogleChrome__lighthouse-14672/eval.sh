#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3055496570b7f18378718b2ddcaaa62edde563d7
git checkout 3055496570b7f18378718b2ddcaaa62edde563d7 report/test/renderer/util-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/report/test/renderer/util-test.js b/report/test/renderer/util-test.js
index 49d6aa5eda14..3504b38162c6 100644
--- a/report/test/renderer/util-test.js
+++ b/report/test/renderer/util-test.js
@@ -37,8 +37,10 @@ describe('util helpers', () => {
     /* eslint-disable max-len */
     assert.equal(get({formFactor: 'mobile', screenEmulation: {disabled: false, mobile: true}}), 'Emulated Moto G4');
     assert.equal(get({formFactor: 'mobile', screenEmulation: {disabled: true, mobile: true}}), 'No emulation');
+    assert.equal(get({formFactor: 'mobile', screenEmulation: {disabled: true, mobile: true}, channel: 'devtools'}), 'Emulated Moto G4');
     assert.equal(get({formFactor: 'desktop', screenEmulation: {disabled: false, mobile: false}}), 'Emulated Desktop');
     assert.equal(get({formFactor: 'desktop', screenEmulation: {disabled: true, mobile: false}}), 'No emulation');
+    assert.equal(get({formFactor: 'desktop', screenEmulation: {disabled: true, mobile: true}, channel: 'devtools'}), 'Emulated Desktop');
     /* eslint-enable max-len */
   });
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn unit-report report/test/renderer/util-test.js
: '>>>>> End Test Output'
git checkout 3055496570b7f18378718b2ddcaaa62edde563d7 report/test/renderer/util-test.js
