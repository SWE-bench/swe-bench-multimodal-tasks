#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 0eb9ced9ae6d833a230c1c27dbf42dcb4e30bec4
git checkout 0eb9ced9ae6d833a230c1c27dbf42dcb4e30bec4 test/unit/components/__snapshots__/sound-editor.test.jsx.snap
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/components/__snapshots__/sound-editor.test.jsx.snap b/test/unit/components/__snapshots__/sound-editor.test.jsx.snap
index af7a255a407..d648559d748 100644
--- a/test/unit/components/__snapshots__/sound-editor.test.jsx.snap
+++ b/test/unit/components/__snapshots__/sound-editor.test.jsx.snap
@@ -230,6 +230,7 @@ exports[`Sound Editor Component matches snapshot 1`] = `
               }
             >
               <img
+                draggable={false}
                 src="test-file-stub"
               />
             </div>
@@ -252,6 +253,7 @@ exports[`Sound Editor Component matches snapshot 1`] = `
               }
             >
               <img
+                draggable={false}
                 src="test-file-stub"
               />
             </div>
@@ -295,6 +297,7 @@ exports[`Sound Editor Component matches snapshot 1`] = `
               }
             >
               <img
+                draggable={false}
                 src="test-file-stub"
               />
             </div>
@@ -317,6 +320,7 @@ exports[`Sound Editor Component matches snapshot 1`] = `
               }
             >
               <img
+                draggable={false}
                 src="test-file-stub"
               />
             </div>

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
export NODE_OPTIONS=--unhandled-rejections=warn
: '>>>>> Start Test Output'
./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/button.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/cards.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/controls.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/icon-button.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/menu-bar.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/monitor-list.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/sound-editor.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/sprite-selector-item.test.jsx
: '>>>>> End Test Output'
git checkout 0eb9ced9ae6d833a230c1c27dbf42dcb4e30bec4 test/unit/components/__snapshots__/sound-editor.test.jsx.snap
