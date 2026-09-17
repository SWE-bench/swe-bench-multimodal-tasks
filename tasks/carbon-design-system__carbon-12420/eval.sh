#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 133d29493bb8e72131982bd03762406c4f286df7
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 133d29493bb8e72131982bd03762406c4f286df7 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/TimePicker/TimePicker-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 036acc7a161c..876180ab74cc 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -8325,6 +8325,9 @@ Map {
       "placeholder": Object {
         "type": "string",
       },
+      "readOnly": Object {
+        "type": "bool",
+      },
       "size": Object {
         "args": Array [
           Array [
diff --git a/packages/react/src/components/TimePicker/TimePicker-test.js b/packages/react/src/components/TimePicker/TimePicker-test.js
index 7aec125bb018..59ca5f2e899b 100644
--- a/packages/react/src/components/TimePicker/TimePicker-test.js
+++ b/packages/react/src/components/TimePicker/TimePicker-test.js
@@ -7,7 +7,8 @@
 
 import React from 'react';
 import { default as TimePicker } from './TimePicker';
-
+import SelectItem from '../SelectItem';
+import TimePickerSelect from '../TimePickerSelect/next/TimePickerSelect.js';
 import { render, screen, fireEvent } from '@testing-library/react';
 import userEvent from '@testing-library/user-event';
 
@@ -40,6 +41,51 @@ describe('TimePicker', () => {
       expect(onClick).not.toHaveBeenCalled();
     });
 
+    it('should behave readonly as expected', () => {
+      const onClick = jest.fn();
+      const onChange = jest.fn();
+
+      render(
+        <TimePicker
+          id="time-picker"
+          onClick={onClick}
+          onChange={onChange}
+          readOnly={true}>
+          <TimePickerSelect id="time-picker-select-1">
+            <SelectItem value="AM" text="AM" />
+            <SelectItem value="PM" text="PM" />
+          </TimePickerSelect>
+          <TimePickerSelect id="time-picker-select-2">
+            <SelectItem value="Time zone 1" text="Time zone 1" />
+            <SelectItem value="Time zone 2" text="Time zone 2" />
+          </TimePickerSelect>
+        </TimePicker>
+      );
+
+      const input = screen.getByRole('textbox');
+      userEvent.click(input);
+      expect(onClick).toHaveBeenCalled();
+      expect(input).toHaveAttribute('readonly');
+
+      userEvent.type(input, '01:50');
+      expect(onChange).not.toHaveBeenCalled();
+
+      screen.getByDisplayValue('AM');
+      screen.getByDisplayValue('Time zone 1');
+
+      //------------------------------------------------------------------------
+      // Testing library - userEvent.type() does not work on <select> elements
+      // and using selectOption causes the value to change.
+      // Ideally we'd use userEvent.type(theSelect, '{arrowdown}{enter}') to test the readOnly prop
+      // or have a way to click on a slotted option.
+      // https://github.com/testing-library/user-event/issues/786
+      //------------------------------------------------------------------------
+      // userEvent.selectOptions(theSelect, 'option-1'); // unfortunately this bypasses the readOnly prop
+
+      // Change events should *not* fire
+      // expect(screen.getByText('Option 1').selected).toBe(false);
+    });
+
     it('should set placeholder as expected', () => {
       render(<TimePicker id="time-picker" placeholder="🧸" />);
       expect(screen.getByPlaceholderText('🧸')).toBeInTheDocument();

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/TimePicker/TimePicker-test.js
: '>>>>> End Test Output'
git checkout 133d29493bb8e72131982bd03762406c4f286df7 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/TimePicker/TimePicker-test.js
