#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff fac839d3f39b142a7257510e46e7916def20f0ca
git checkout fac839d3f39b142a7257510e46e7916def20f0ca client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap client/signup/steps/site-information/test/__snapshots__/index.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap b/client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap
index adb31b3004179..38fa38732b568 100644
--- a/client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap
+++ b/client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap
@@ -4,7 +4,7 @@ exports[`<SiteVerticalsSuggestionSearch /> should render 1`] = `
 <SuggestionSearch
   id="siteTopic"
   onChange={[Function]}
-  placeholder="e.g. Fashion, travel, design, plumber, electrician"
+  placeholder="e.g. Fashion, travel, design, plumber"
   sortResults={[Function]}
   suggestions={
     Array [
diff --git a/client/signup/steps/site-information/test/__snapshots__/index.js.snap b/client/signup/steps/site-information/test/__snapshots__/index.js.snap
index d82d5b87bc58d..b5a34f0f5940d 100644
--- a/client/signup/steps/site-information/test/__snapshots__/index.js.snap
+++ b/client/signup/steps/site-information/test/__snapshots__/index.js.snap
@@ -35,7 +35,7 @@ exports[`<SiteInformation /> should render 1`] = `
                 id="title"
                 name="title"
                 onChange={[Function]}
-                placeholder="E.g. Vail Renovations"
+                placeholder="E.g., Vail Renovations"
                 value="Ho ho ho!"
               />
               <Button
@@ -69,7 +69,7 @@ exports[`<SiteInformation /> should render 1`] = `
                 id="address"
                 name="address"
                 onChange={[Function]}
-                placeholder="E.g., 60 29th Street #343, San Francisco, CA 94110"
+                placeholder="E.g., 60 29th St, San Francisco, CA 94110"
                 value=""
               />
               <Button
@@ -103,7 +103,7 @@ exports[`<SiteInformation /> should render 1`] = `
                 id="phone"
                 name="phone"
                 onChange={[Function]}
-                placeholder="E.g. (555) 555-5555"
+                placeholder="E.g., (555) 555-5555"
                 value=""
               />
               <Button

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/components/site-verticals-suggestion-search/test/index.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/signup/steps/site-information/test/index.js
: '>>>>> End Test Output'
git checkout fac839d3f39b142a7257510e46e7916def20f0ca client/components/site-verticals-suggestion-search/test/__snapshots__/index.js.snap client/signup/steps/site-information/test/__snapshots__/index.js.snap
