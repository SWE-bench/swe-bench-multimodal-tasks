#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f8c7358c43895ac8bb10e91ada33a5356a3adedd
git checkout f8c7358c43895ac8bb10e91ada33a5356a3adedd src/js/components/Form/__tests__/Form-test-controlled.js src/js/components/Form/__tests__/Form-test-uncontrolled.js
git apply -v - <<'EOF_114329324912'
diff --git a/src/js/components/Form/__tests__/Form-test-controlled.js b/src/js/components/Form/__tests__/Form-test-controlled.js
index 64b2ba7f9b..2e5766cf73 100644
--- a/src/js/components/Form/__tests__/Form-test-controlled.js
+++ b/src/js/components/Form/__tests__/Form-test-controlled.js
@@ -482,6 +482,7 @@ describe('Form controlled', () => {
       expect.objectContaining({
         errors: { mood: 'required' },
         infos: {},
+        valid: false,
       }),
     );
 
@@ -491,7 +492,7 @@ describe('Form controlled', () => {
     act(() => toggleField.focus());
     act(() => jest.advanceTimersByTime(200)); // allow validations to run
     expect(onValidate).toHaveBeenLastCalledWith(
-      expect.objectContaining({ errors: {}, infos: {} }),
+      expect.objectContaining({ errors: {}, infos: {}, valid: true }),
     );
 
     // clear mood, should fail validation
@@ -503,6 +504,7 @@ describe('Form controlled', () => {
       expect.objectContaining({
         errors: { mood: 'required' },
         infos: {},
+        valid: false,
       }),
     );
 
@@ -513,7 +515,7 @@ describe('Form controlled', () => {
     act(() => toggleField.focus());
     act(() => jest.advanceTimersByTime(200)); // allow validations to run
     expect(onValidate).toHaveBeenLastCalledWith(
-      expect.objectContaining({ errors: {}, infos: {} }),
+      expect.objectContaining({ errors: {}, infos: {}, valid: true }),
     );
 
     expect(container.firstChild).toMatchSnapshot();
diff --git a/src/js/components/Form/__tests__/Form-test-uncontrolled.js b/src/js/components/Form/__tests__/Form-test-uncontrolled.js
index b31f772ce5..61db8f6530 100644
--- a/src/js/components/Form/__tests__/Form-test-uncontrolled.js
+++ b/src/js/components/Form/__tests__/Form-test-uncontrolled.js
@@ -1389,6 +1389,7 @@ describe('Form uncontrolled', () => {
       expect.objectContaining({
         errors: { mood: 'required' },
         infos: {},
+        valid: false,
       }),
     );
 
@@ -1398,7 +1399,7 @@ describe('Form uncontrolled', () => {
     act(() => toggleField.focus());
     act(() => jest.advanceTimersByTime(200)); // allow validations to run
     expect(onValidate).toHaveBeenLastCalledWith(
-      expect.objectContaining({ errors: {}, infos: {} }),
+      expect.objectContaining({ errors: {}, infos: {}, valid: true }),
     );
 
     // clear mood, should fail validation
@@ -1410,6 +1411,7 @@ describe('Form uncontrolled', () => {
       expect.objectContaining({
         errors: { mood: 'required' },
         infos: {},
+        valid: false,
       }),
     );
 
@@ -1420,7 +1422,7 @@ describe('Form uncontrolled', () => {
     act(() => toggleField.focus());
     act(() => jest.advanceTimersByTime(200)); // allow validations to run
     expect(onValidate).toHaveBeenLastCalledWith(
-      expect.objectContaining({ errors: {}, infos: {} }),
+      expect.objectContaining({ errors: {}, infos: {}, valid: true }),
     );
 
     expect(container.firstChild).toMatchSnapshot();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test
: '>>>>> End Test Output'
git checkout f8c7358c43895ac8bb10e91ada33a5356a3adedd src/js/components/Form/__tests__/Form-test-controlled.js src/js/components/Form/__tests__/Form-test-uncontrolled.js
