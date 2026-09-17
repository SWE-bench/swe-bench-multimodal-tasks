#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 7be94256475b667bca0ae7ba9193377a4cbe6321
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 7be94256475b667bca0ae7ba9193377a4cbe6321 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/__tests__/index-test.js && rm -f packages/react/src/components/ProgressBar/ProgressBar-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 375fc94eab71..d3823bafa6ae 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -7799,5 +7799,28 @@ Map {
       },
     },
   },
+  "unstable_ProgressBar" => Object {
+    "propTypes": Object {
+      "className": Object {
+        "type": "string",
+      },
+      "helperText": Object {
+        "type": "string",
+      },
+      "hideLabel": Object {
+        "type": "bool",
+      },
+      "label": Object {
+        "isRequired": true,
+        "type": "string",
+      },
+      "max": Object {
+        "type": "number",
+      },
+      "value": Object {
+        "type": "number",
+      },
+    },
+  },
 }
 `;
diff --git a/packages/react/src/__tests__/index-test.js b/packages/react/src/__tests__/index-test.js
index bc8eb2b2bcee..4ad9a349281b 100644
--- a/packages/react/src/__tests__/index-test.js
+++ b/packages/react/src/__tests__/index-test.js
@@ -205,6 +205,7 @@ describe('Carbon Components React', () => {
         "unstable_MenuSelectableItem",
         "unstable_PageSelector",
         "unstable_Pagination",
+        "unstable_ProgressBar",
         "unstable_Section",
         "unstable_TreeNode",
         "unstable_TreeView",
diff --git a/packages/react/src/components/ProgressBar/ProgressBar-test.js b/packages/react/src/components/ProgressBar/ProgressBar-test.js
new file mode 100644
index 000000000000..8730fd36aa39
--- /dev/null
+++ b/packages/react/src/components/ProgressBar/ProgressBar-test.js
@@ -0,0 +1,116 @@
+/**
+ * Copyright IBM Corp. 2021
+ *
+ * This source code is licensed under the Apache-2.0 license found in the
+ * LICENSE file in the root directory of this source tree.
+ */
+
+import React from 'react';
+import ProgressBar from './ProgressBar';
+import { render } from '@testing-library/react';
+import { settings } from 'carbon-components';
+
+const { prefix } = settings;
+
+describe('ProgressBar', () => {
+  const props = {
+    label: 'ProgressBar label',
+  };
+  let wrapper;
+
+  beforeEach(() => {
+    wrapper = render(<ProgressBar {...props} />);
+  });
+
+  describe('renders as expected', () => {
+    it('progress bar and label ids match', () => {
+      const bar = wrapper.getByRole('progressbar');
+      const label = wrapper.container.querySelector('label');
+      expect(bar.id).toBe(label.htmlFor);
+    });
+
+    it('renders helper text when passed', () => {
+      const text = 'ProgressBar helper text';
+      wrapper.rerender(<ProgressBar {...props} helperText={text} />);
+      const helperText = wrapper.container.querySelector(
+        `.${prefix}--progress-bar__helper-text`
+      );
+
+      expect(helperText.textContent).toBe(text);
+      expect(
+        wrapper.getByRole('progressbar').getAttribute('aria-describedby')
+      ).toBe(helperText.id);
+    });
+
+    it('still renders accessible when hideLabel is passed', () => {
+      wrapper.rerender(<ProgressBar {...props} hideLabel />);
+      const label = wrapper.container.querySelector('label');
+
+      expect(label.textContent).toBe(props.label);
+      expect(label.classList.contains(`${prefix}--visually-hidden`)).toBe(true);
+    });
+
+    it('renders as indeterminate when no value is passed', () => {
+      const bar = wrapper.getByRole('progressbar');
+
+      expect(bar.getAttribute('aria-valuenow')).toBe(null);
+      expect(bar.getAttribute('aria-valuemax')).toBe(null);
+      expect(bar.getAttribute('aria-valuemin')).toBe(null);
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--progress-bar`)
+          .classList.contains(`${prefix}--progress-bar--indeterminate`)
+      ).toBe(true);
+    });
+
+    it('sets aria-valuenow correctly', () => {
+      const value = 42;
+      wrapper.rerender(<ProgressBar {...props} value={value} />);
+
+      expect(
+        wrapper.getByRole('progressbar').getAttribute('aria-valuenow')
+      ).toBe(value.toString());
+    });
+
+    it('sets aria-valuemax correctly', () => {
+      const max = 84;
+      wrapper.rerender(<ProgressBar {...props} value={0} max={max} />);
+
+      expect(
+        wrapper.getByRole('progressbar').getAttribute('aria-valuemax')
+      ).toBe(max.toString());
+    });
+
+    it('supports additional css class names', () => {
+      const className = 'some-class';
+      wrapper.rerender(<ProgressBar {...props} className={className} />);
+
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--progress-bar`)
+          .classList.contains(className)
+      ).toBe(true);
+    });
+  });
+
+  describe('behaves as expected', () => {
+    it('limits value to max', () => {
+      const value = 200;
+      const max = 50;
+      wrapper.rerender(<ProgressBar {...props} value={value} max={max} />);
+
+      expect(
+        wrapper.getByRole('progressbar').getAttribute('aria-valuenow')
+      ).toBe(max.toString());
+    });
+
+    it('ensures a positive value', () => {
+      const value = -10;
+      wrapper.rerender(<ProgressBar {...props} value={value} />);
+
+      expect(
+        wrapper.getByRole('progressbar').getAttribute('aria-valuenow')
+      ).toBe('0');
+    });
+  });
+});

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/ ; yarn test --maxWorkers=4 packages/react/src/components/ProgressBar/ProgressBar-test.js
: '>>>>> End Test Output'
git checkout 7be94256475b667bca0ae7ba9193377a4cbe6321 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/__tests__/index-test.js && rm -f packages/react/src/components/ProgressBar/ProgressBar-test.js
