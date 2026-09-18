#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 74740a755b1411119bcfbe53dda3c353c0644710
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 74740a755b1411119bcfbe53dda3c353c0644710 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/Tabs/Tabs-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 7aaaca309f3a..967f1dadc11c 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -4919,18 +4919,12 @@ Map {
   },
   "Tabs" => Object {
     "defaultProps": Object {
-      "ariaLabel": "listbox",
-      "iconDescription": "show menu options",
       "role": "navigation",
       "selected": 0,
       "selectionMode": "automatic",
-      "triggerHref": "#",
       "type": "default",
     },
     "propTypes": Object {
-      "ariaLabel": Object {
-        "type": "string",
-      },
       "children": Object {
         "type": "node",
       },
@@ -4940,9 +4934,8 @@ Map {
       "hidden": Object {
         "type": "bool",
       },
-      "iconDescription": Object {
-        "isRequired": true,
-        "type": "string",
+      "light": Object {
+        "type": "bool",
       },
       "onClick": Object {
         "type": "func",
@@ -4972,10 +4965,6 @@ Map {
       "tabContentClassName": Object {
         "type": "string",
       },
-      "triggerHref": Object {
-        "isRequired": true,
-        "type": "string",
-      },
       "type": Object {
         "args": Array [
           Array [
diff --git a/packages/react/src/components/Tabs/Tabs-test.js b/packages/react/src/components/Tabs/Tabs-test.js
index 69c0937e5ed9..93c43bfba130 100644
--- a/packages/react/src/components/Tabs/Tabs-test.js
+++ b/packages/react/src/components/Tabs/Tabs-test.js
@@ -6,7 +6,6 @@
  */
 
 import React from 'react';
-import { ChevronDown16 } from '@carbon/icons-react';
 import { settings } from 'carbon-components';
 import { shallow, mount } from 'enzyme';
 import Tabs from '../Tabs';
@@ -15,16 +14,7 @@ import TabsSkeleton from '../Tabs/Tabs.Skeleton';
 
 const { prefix } = settings;
 
-window.matchMedia = jest.fn().mockImplementation((query) => ({
-  matches: true,
-  media: query,
-  onchange: null,
-  addListener: jest.fn(), // deprecated
-  removeListener: jest.fn(), // deprecated
-  addEventListener: jest.fn(),
-  removeEventListener: jest.fn(),
-  dispatchEvent: jest.fn(),
-}));
+Element.prototype.scrollIntoView = jest.fn();
 
 describe('Tabs', () => {
   describe('renders as expected', () => {
@@ -79,36 +69,6 @@ describe('Tabs', () => {
       });
     });
 
-    describe('Trigger (<div>)', () => {
-      const wrapper = shallow(
-        <Tabs className="extra-class">
-          <Tab label="firstTab">content1</Tab>
-          <Tab label="lastTab">content2</Tab>
-        </Tabs>
-      );
-
-      const trigger = wrapper.find(`div.${prefix}--tabs-trigger`);
-      const tablist = wrapper.find('ul');
-
-      it('renders default className for trigger', () => {
-        expect(trigger.hasClass(`${prefix}--tabs-trigger`)).toBe(true);
-      });
-
-      it('renders hidden className by default', () => {
-        expect(tablist.hasClass(`${prefix}--tabs__nav--hidden`)).toBe(true);
-      });
-
-      it('renders default className for triggerText', () => {
-        expect(trigger.find('a').hasClass(`${prefix}--tabs-trigger-text`)).toBe(
-          true
-        );
-      });
-
-      it('renders <Icon>', () => {
-        expect(trigger.find(ChevronDown16).length).toBe(1);
-      });
-    });
-
     describe('Children (<Tab>)', () => {
       const wrapper = shallow(
         <Tabs>
@@ -172,39 +132,6 @@ describe('Tabs', () => {
   });
 
   describe('events', () => {
-    describe('click', () => {
-      const wrapper = mount(
-        <Tabs>
-          <Tab label="firstTab" className="firstTab">
-            content1
-          </Tab>
-          <Tab label="lastTab" className="lastTab">
-            content2
-          </Tab>
-        </Tabs>
-      );
-
-      describe('state: dropdownHidden', () => {
-        it('toggles dropdownHidden state after trigger is clicked', () => {
-          const trigger = wrapper.find(`.${prefix}--tabs-trigger`);
-
-          trigger.simulate('click');
-          expect(wrapper.state().dropdownHidden).toEqual(false);
-          trigger.simulate('click');
-          expect(wrapper.state().dropdownHidden).toEqual(true);
-        });
-
-        it('toggles hidden state after trigger-text is clicked', () => {
-          const triggerText = wrapper.find(`.${prefix}--tabs-trigger-text`);
-
-          triggerText.simulate('click');
-          expect(wrapper.state().dropdownHidden).toEqual(false);
-          triggerText.simulate('click');
-          expect(wrapper.state().dropdownHidden).toEqual(true);
-        });
-      });
-    });
-
     describe('keydown', () => {
       const leftKey = 37;
       const rightKey = 39;
@@ -341,12 +268,6 @@ describe('Tabs', () => {
       </Tabs>
     );
 
-    describe('dropdownHidden', () => {
-      it('should be true', () => {
-        expect(wrapper.state().dropdownHidden).toEqual(true);
-      });
-    });
-
     describe('selected', () => {
       it('should be 0', () => {
         expect(wrapper.state().selected).toEqual(0);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
rm -rf -- .achecker.yml .aat.yml && cp /opt/achecker-offline/.achecker.yml .achecker.yml && cp /opt/achecker-offline/.achecker.yml .aat.yml
for checker_dir in node_modules/@ibma/aat node_modules/accessibility-checker config/jest-config-carbon/node_modules/@ibma/aat config/jest-config-carbon/node_modules/accessibility-checker; do if [ -d "$checker_dir" ]; then find "$checker_dir" -type f \( -name AATMetricsLogger.js -o -name ACMetricsLogger.js \) -exec sed -i -e 's#http:/[/]ibmac96.austin.ibm.com/cgi-bin/log-cio/log.py#http://127.0.0.1:18080/tools/api/pub/meter/v2#g' -e 's#https:/[/]able.ibm.com/tools#http://127.0.0.1:18080/tools#g' {} +; fi; done
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost" no_proxy="${no_proxy:+$no_proxy,}127.0.0.1,localhost"
node -e 'var fs=require("fs"),http=require("http"),path=require("path"),url=require("url");var root="/opt/achecker-offline",port=18080,engineBase="/archives/2020.10.07/js/";http.createServer(function(request,response){response.setHeader("Access-Control-Allow-Origin","*");var pathname=decodeURIComponent(url.parse(request.url).pathname);if(pathname==="/tools/api/pub/meter/v2"){response.statusCode=204;response.end();return;}var legacyBrowserEngine=false;if(pathname===engineBase+"awe-node.js"){pathname=engineBase+"ace-node.js";}else if(pathname===engineBase+"awe.js"){pathname=engineBase+"ace.js";legacyBrowserEngine=true;}var filename=path.resolve(root,"."+pathname);if(filename.indexOf(root+path.sep)!==0){response.statusCode=403;response.end("forbidden");return;}if(/\.json$/.test(filename)){response.setHeader("Content-Type","application/json");}else if(/\.js$/.test(filename)){response.setHeader("Content-Type","application/javascript");}if(legacyBrowserEngine){fs.readFile(filename,function(error,contents){if(error){response.statusCode=404;response.end("not found");return;}response.end(Buffer.concat([contents,Buffer.from("\n;window.IBMAwe=ace;\n")]));});return;}var stream=fs.createReadStream(filename);stream.on("error",function(){if(!response.headersSent){response.statusCode=404;}response.end("not found");});stream.pipe(response);}).listen(port,"127.0.0.1");' > /tmp/achecker-offline-server.log 2>&1 &
ACHECKER_OFFLINE_PID=$!
trap 'kill $ACHECKER_OFFLINE_PID 2>/dev/null || true' EXIT
ACHECKER_OFFLINE_READY=0
for _ in {1..50}; do if curl --noproxy '*' -fsS http://127.0.0.1:18080/archives.json > /dev/null 2>&1; then ACHECKER_OFFLINE_READY=1; break; fi; sleep 0.1; done
[ "$ACHECKER_OFFLINE_READY" -eq 1 ] || { cat /tmp/achecker-offline-server.log; exit 1; }
: '>>>>> Start Test Output'
yarn test --maxWorkers=1 packages/react/ ; yarn test --maxWorkers=1 packages/react/src/components/Tabs/Tabs-test.js
: '>>>>> End Test Output'
git checkout 74740a755b1411119bcfbe53dda3c353c0644710 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/Tabs/Tabs-test.js
