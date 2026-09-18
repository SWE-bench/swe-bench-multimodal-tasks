#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 63c189e531ac5a5a17bbae959eb1048ae425b6ac
git checkout 63c189e531ac5a5a17bbae959eb1048ae425b6ac test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap test/unit/components/sprite-selector-item.test.jsx
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap b/test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap
index 2c276ff6566..237e3dc2948 100644
--- a/test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap
+++ b/test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap
@@ -30,16 +30,9 @@ exports[`SpriteSelectorItemComponent matches snapshot when given a number and de
   >
     5
   </div>
-  <canvas
+  <img
     className={undefined}
-    height={32}
-    style={
-      Object {
-        "height": "32px",
-        "width": "32px",
-      }
-    }
-    width={32}
+    src="https://scratch.mit.edu/foo/bar/pony"
   />
   <div
     className={undefined}
@@ -113,16 +106,9 @@ exports[`SpriteSelectorItemComponent matches snapshot when selected 1`] = `
       src="test-file-stub"
     />
   </div>
-  <canvas
+  <img
     className={undefined}
-    height={32}
-    style={
-      Object {
-        "height": "32px",
-        "width": "32px",
-      }
-    }
-    width={32}
+    src="https://scratch.mit.edu/foo/bar/pony"
   />
   <div
     className={undefined}
diff --git a/test/unit/components/sprite-selector-item.test.jsx b/test/unit/components/sprite-selector-item.test.jsx
index 1bf52fe97e4..49e3fa705ef 100644
--- a/test/unit/components/sprite-selector-item.test.jsx
+++ b/test/unit/components/sprite-selector-item.test.jsx
@@ -1,7 +1,6 @@
 import React from 'react';
 import {mountWithIntl, shallowWithIntl, componentWithIntl} from '../../helpers/intl-helpers.jsx';
 import SpriteSelectorItemComponent from '../../../src/components/sprite-selector-item/sprite-selector-item';
-import CostumeCanvas from '../../../src/components/costume-canvas/costume-canvas';
 import CloseButton from '../../../src/components/close-button/close-button';
 
 describe('SpriteSelectorItemComponent', () => {
@@ -73,17 +72,6 @@ describe('SpriteSelectorItemComponent', () => {
         expect(onDeleteButtonClick).toHaveBeenCalled();
     });
 
-    test('creates a CostumeCanvas when a costume url is defined', () => {
-        const wrapper = shallowWithIntl(getComponent());
-        expect(wrapper.find(CostumeCanvas).exists()).toBe(true);
-    });
-
-    test('does not create a CostumeCanvas when a costume url is null', () => {
-        costumeURL = null;
-        const wrapper = shallowWithIntl(getComponent());
-        expect(wrapper.find(CostumeCanvas).exists()).toBe(false);
-    });
-
     test('it has a context menu with delete menu item and callback', () => {
         const wrapper = mountWithIntl(getComponent());
         const contextMenu = wrapper.find('ContextMenu');

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/button.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/controls.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/icon-button.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/sound-editor.test.jsx ; ./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc' --runTestsByPath test/unit/components/sprite-selector-item.test.jsx
: '>>>>> End Test Output'
git checkout 63c189e531ac5a5a17bbae959eb1048ae425b6ac test/unit/components/__snapshots__/sprite-selector-item.test.jsx.snap test/unit/components/sprite-selector-item.test.jsx
