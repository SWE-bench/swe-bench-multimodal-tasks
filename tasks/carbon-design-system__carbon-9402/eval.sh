#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4907951277a98d8d9201699b0f3dc7d93eeac946
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 4907951277a98d8d9201699b0f3dc7d93eeac946 packages/react/src/components/ComboBox/ComboBox-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/ComboBox/ComboBox-test.js b/packages/react/src/components/ComboBox/ComboBox-test.js
index 2252549a8cb8..7bfe47f8f4b2 100644
--- a/packages/react/src/components/ComboBox/ComboBox-test.js
+++ b/packages/react/src/components/ComboBox/ComboBox-test.js
@@ -7,6 +7,8 @@
 
 import React from 'react';
 import { mount } from 'enzyme';
+import { render, screen, within } from '@testing-library/react';
+import userEvent from '@testing-library/user-event';
 import {
   findListBoxNode,
   findMenuNode,
@@ -201,5 +203,49 @@ describe('ComboBox', () => {
       const wrapper = mount(<ComboBox {...mockProps} />);
       expect(wrapper.find('input').instance().value).toBe('');
     });
+
+    it('should only render one listbox at a time when multiple comboboxes are present', () => {
+      render(
+        <>
+          <div data-testid="combobox-1">
+            <ComboBox {...mockProps} id="combobox-1" />
+          </div>
+          <div data-testid="combobox-2">
+            <ComboBox {...mockProps} id="combobox-2" />
+          </div>
+        </>
+      );
+      const firstCombobox = screen.getByTestId('combobox-1');
+      const secondCombobox = screen.getByTestId('combobox-2');
+
+      const firstComboboxChevron = within(firstCombobox).getByRole('button');
+      const secondComboboxChevron = within(secondCombobox).getByRole('button');
+
+      function firstListBox() {
+        return within(firstCombobox).getByRole('listbox');
+      }
+
+      function secondListBox() {
+        return within(secondCombobox).getByRole('listbox');
+      }
+
+      expect(firstListBox()).toBeEmptyDOMElement();
+      expect(secondListBox()).toBeEmptyDOMElement();
+
+      userEvent.click(firstComboboxChevron);
+
+      expect(firstListBox()).not.toBeEmptyDOMElement();
+      expect(secondListBox()).toBeEmptyDOMElement();
+
+      userEvent.click(secondComboboxChevron);
+
+      expect(firstListBox()).toBeEmptyDOMElement();
+      expect(secondListBox()).not.toBeEmptyDOMElement();
+
+      userEvent.click(secondComboboxChevron);
+
+      expect(firstListBox()).toBeEmptyDOMElement();
+      expect(secondListBox()).toBeEmptyDOMElement();
+    });
   });
 });

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
yarn test --maxWorkers=4 packages/react/src/components/ComboBox/ComboBox-test.js
: '>>>>> End Test Output'
git checkout 4907951277a98d8d9201699b0f3dc7d93eeac946 packages/react/src/components/ComboBox/ComboBox-test.js
