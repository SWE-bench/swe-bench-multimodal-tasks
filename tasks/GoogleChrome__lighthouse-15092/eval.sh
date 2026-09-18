#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8c053edec6565a80abf8a1ca4e3f8f104fe365e6
git checkout 8c053edec6565a80abf8a1ca4e3f8f104fe365e6 flow-report/test/wrappers/category-score-test.tsx report/test/renderer/pwa-category-renderer-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/flow-report/test/wrappers/category-score-test.tsx b/flow-report/test/wrappers/category-score-test.tsx
index 2eada342c8a7..5489735b4a29 100644
--- a/flow-report/test/wrappers/category-score-test.tsx
+++ b/flow-report/test/wrappers/category-score-test.tsx
@@ -55,9 +55,11 @@ describe('CategoryScore', () => {
     );
 
     const link = root.getByRole('link') as HTMLAnchorElement;
+    const lhGaugePercentage = root.getByTitle('Error!') as HTMLDivElement;
 
     expect(link.href).toEqual('file:///Users/example/report.html/#seo');
-    expect(root.getByText('?')).toBeTruthy();
+    expect(lhGaugePercentage).toBeTruthy();
+    expect(lhGaugePercentage.textContent).toBe('');
   });
 
   it('renders category fraction', () => {
diff --git a/report/test/renderer/pwa-category-renderer-test.js b/report/test/renderer/pwa-category-renderer-test.js
index 7f03799fc1b9..b761d88f42a9 100644
--- a/report/test/renderer/pwa-category-renderer-test.js
+++ b/report/test/renderer/pwa-category-renderer-test.js
@@ -262,7 +262,7 @@ describe('PwaCategoryRenderer', () => {
       assert.strictEqual(badgeGauge.querySelector('.lh-gauge--pwa__wrapper'), null);
 
       const percentageElem = badgeGauge.querySelector('.lh-gauge__percentage');
-      assert.strictEqual(percentageElem.textContent, '?');
+      assert.strictEqual(percentageElem.textContent, '');
       assert.strictEqual(percentageElem.title, UIStrings.errorLabel);
     });
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn unit-flow ; yarn unit-report report/test/renderer/pwa-category-renderer-test.js
: '>>>>> End Test Output'
git checkout 8c053edec6565a80abf8a1ca4e3f8f104fe365e6 flow-report/test/wrappers/category-score-test.tsx report/test/renderer/pwa-category-renderer-test.js
