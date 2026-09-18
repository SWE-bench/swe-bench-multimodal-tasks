#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5aeef234faf8a342bf5d195529019d61f5b05cbb
git checkout 5aeef234faf8a342bf5d195529019d61f5b05cbb lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js b/lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
index 8bbe83b1d6a6..e71a81f5d1ad 100644
--- a/lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
+++ b/lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
@@ -242,7 +242,7 @@ describe('PwaCategoryRenderer', () => {
   describe('#renderScoreGauge', () => {
     it('renders an error score gauge in case of category error', () => {
       category.score = null;
-      const badgeGauge = pwaRenderer.renderScoreGauge(category);
+      const badgeGauge = pwaRenderer.renderScoreGauge(category, sampleResults.categoryGroups);
 
       // Not a PWA gauge.
       assert.strictEqual(badgeGauge.querySelector('.lh-gauge--pwa__wrapper'), null);
@@ -251,5 +251,37 @@ describe('PwaCategoryRenderer', () => {
       assert.strictEqual(percentageElem.textContent, '?');
       assert.strictEqual(percentageElem.title, Util.UIStrings.errorLabel);
     });
+
+    it('renders score gauges with unique ids for items in <defs>', () => {
+      const gauge1 = pwaRenderer.renderScoreGauge(category, sampleResults.categoryGroups);
+      const gauge1Ids = [...gauge1.querySelectorAll('defs [id]')].map(el => el.id);
+      assert.ok(gauge1Ids.length > 3);
+
+      const gauge2 = pwaRenderer.renderScoreGauge(category, sampleResults.categoryGroups);
+      const gauge2Ids = [...gauge2.querySelectorAll('defs [id]')].map(el => el.id);
+      assert.ok(gauge2Ids.length === gauge1Ids.length);
+
+      /** Returns whether id is used by at least one <use> or fill under `rootEl`. */
+      function idInUseElOrFillAttr(rootEl, id) {
+        const isUse = rootEl.querySelector(`use[href="#${id}"]`);
+        const isFill = rootEl.querySelector(`[fill="url(#${id})"]`);
+
+        return !!(isUse || isFill);
+      }
+
+      // Check that each gauge1 ID is actually used in gauge1 and isn't used in gauge2.
+      for (const gauge1Id of gauge1Ids) {
+        assert.equal(idInUseElOrFillAttr(gauge1, gauge1Id), true);
+        assert.ok(!gauge2Ids.includes(gauge1Id));
+        assert.equal(idInUseElOrFillAttr(gauge2, gauge1Id), false);
+      }
+
+      // And that the reverse is true for gauge2 IDs.
+      for (const gauge2Id of gauge2Ids) {
+        assert.equal(idInUseElOrFillAttr(gauge1, gauge2Id), false);
+        assert.equal(idInUseElOrFillAttr(gauge2, gauge2Id), true);
+        assert.ok(!gauge1Ids.includes(gauge2Id));
+      }
+    });
   });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
: '>>>>> End Test Output'
git checkout 5aeef234faf8a342bf5d195529019d61f5b05cbb lighthouse-core/test/report/html/renderer/pwa-category-renderer-test.js
