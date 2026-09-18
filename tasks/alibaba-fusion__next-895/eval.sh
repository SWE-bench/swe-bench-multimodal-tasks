#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4b87e771f2e388c607dd96a474f5837e772f9826
git checkout 4b87e771f2e388c607dd96a474f5837e772f9826 test/nav/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/nav/index-spec.js b/test/nav/index-spec.js
index 5c0f28be1d..5404b82291 100644
--- a/test/nav/index-spec.js
+++ b/test/nav/index-spec.js
@@ -265,7 +265,7 @@ describe('Nav', () => {
 
         let items = nav.find('li.next-nav-item');
         assert(items.at(0).find('i.next-nav-icon').length === 1);
-        assert(items.at(1).find('span.next-nav-icon-placeholder').length === 1);
+        assert(items.at(1).find('i.next-nav-icon').length === 0);
 
         let subNavItems = nav.find('li.next-nav-sub-nav-item');
         assert(
@@ -296,7 +296,7 @@ describe('Nav', () => {
         );
 
         const groupLabel = nav.find('li.next-nav-group-label');
-        assert(groupLabel.find('span.next-nav-icon-placeholder').length === 1);
+        assert(groupLabel.find('.next-menu-item-inner > span').length === 1);
 
         wrapper.setProps({
             mode: 'popup',
@@ -324,13 +324,13 @@ describe('Nav', () => {
         subNavItems = nav.find('li.next-nav-sub-nav-item');
         assert(subNavItems.at(0).find('i.next-nav-icon').length === 1);
         assert(
-            subNavItems.at(1).find('span.next-nav-icon-placeholder').length ===
+            subNavItems.at(1).find('.next-menu-item-text > span').length ===
                 1
         );
         popupItems = nav.find('li.next-nav-popup-item');
         assert(popupItems.at(0).find('i.next-nav-icon').length === 1);
         assert(
-            popupItems.at(1).find('span.next-nav-icon-placeholder').length === 1
+            popupItems.at(1).find('.next-menu-item-text > span').length === 1
         );
         items = nav.find('li.next-nav-item');
         items.at(0).simulate('mouseenter');

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test nav"'
: '>>>>> End Test Output'
git checkout 4b87e771f2e388c607dd96a474f5837e772f9826 test/nav/index-spec.js
