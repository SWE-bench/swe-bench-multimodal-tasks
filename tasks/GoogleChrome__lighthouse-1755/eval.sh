#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4e140a9f74a465e72ab0e57fad1c6dbd5441654d
git checkout 4e140a9f74a465e72ab0e57fad1c6dbd5441654d lighthouse-core/test/report/handlebar-helpers-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/report/handlebar-helpers-test.js b/lighthouse-core/test/report/handlebar-helpers-test.js
index 42d0be57532a..04e4a055500b 100644
--- a/lighthouse-core/test/report/handlebar-helpers-test.js
+++ b/lighthouse-core/test/report/handlebar-helpers-test.js
@@ -42,4 +42,12 @@ describe('Handlebar helpers', () => {
     assert.equal(handlebarHelpers.kebabCase('myURL$'), 'my-url');
     assert.equal(handlebarHelpers.kebabCase('the401k%_value'), 'the401k-value');
   });
+
+  it('`getAggregationScoreRating` calculates rating', () => {
+    assert.equal(handlebarHelpers.getAggregationScoreRating(undefined), 'poor');
+    assert.equal(handlebarHelpers.getAggregationScoreRating(1), 'good');
+    assert.equal(handlebarHelpers.getAggregationScoreRating(0.95), 'good');
+    assert.equal(handlebarHelpers.getAggregationScoreRating(0.50), 'average');
+    assert.equal(handlebarHelpers.getAggregationScoreRating(0.10), 'poor');
+  });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/report/handlebar-helpers-test.js
: '>>>>> End Test Output'
git checkout 4e140a9f74a465e72ab0e57fad1c6dbd5441654d lighthouse-core/test/report/handlebar-helpers-test.js
