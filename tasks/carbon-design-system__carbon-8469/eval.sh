#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 14b4dc1010d7ea5bdf54edc92fb4b939065bc02c
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 14b4dc1010d7ea5bdf54edc92fb4b939065bc02c packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/Toggle/Toggle-test.js && rm -f packages/react/src/components/Toggle/next/Toggle-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 581065ede35e..a718524c4dfe 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -6212,60 +6212,7 @@ Map {
       },
     },
   },
-  "Toggle" => Object {
-    "defaultProps": Object {
-      "aria-label": "Toggle",
-      "defaultToggled": false,
-      "labelA": "Off",
-      "labelB": "On",
-      "onToggle": [Function],
-    },
-    "propTypes": Object {
-      "aria-label": Object {
-        "isRequired": true,
-        "type": "string",
-      },
-      "className": Object {
-        "type": "string",
-      },
-      "defaultToggled": Object {
-        "type": "bool",
-      },
-      "id": Object {
-        "isRequired": true,
-        "type": "string",
-      },
-      "labelA": Object {
-        "isRequired": true,
-        "type": "node",
-      },
-      "labelB": Object {
-        "isRequired": true,
-        "type": "node",
-      },
-      "labelText": Object {
-        "type": "node",
-      },
-      "onChange": Object {
-        "type": "func",
-      },
-      "onToggle": Object {
-        "type": "func",
-      },
-      "size": Object {
-        "args": Array [
-          Array [
-            "sm",
-            "md",
-          ],
-        ],
-        "type": "oneOf",
-      },
-      "toggled": Object {
-        "type": "bool",
-      },
-    },
-  },
+  "Toggle" => Object {},
   "ToggleSmall" => Object {
     "defaultProps": Object {
       "defaultToggled": false,
diff --git a/packages/react/src/components/Toggle/Toggle-test.js b/packages/react/src/components/Toggle/Toggle-test.js
index 5e3f25d50182..a1cb2a8f498e 100644
--- a/packages/react/src/components/Toggle/Toggle-test.js
+++ b/packages/react/src/components/Toggle/Toggle-test.js
@@ -12,8 +12,15 @@ import { settings } from 'carbon-components';
 
 const { prefix } = settings;
 describe('Toggle', () => {
+  const commonProps = {
+    'aria-label': 'Toggle label',
+    labelA: 'Off',
+    labelB: 'On',
+    labelText: 'Toggle label',
+  };
+
   describe('Renders as expected', () => {
-    const wrapper = mount(<Toggle id="toggle-1" />);
+    const wrapper = mount(<Toggle {...commonProps} id="toggle-1" />);
 
     const input = wrapper.find('input');
 
@@ -63,7 +70,7 @@ describe('Toggle', () => {
   });
 
   it('toggled prop sets checked prop on input', () => {
-    const wrapper = mount(<Toggle id="test" toggled />);
+    const wrapper = mount(<Toggle {...commonProps} id="test" toggled />);
 
     const input = () => wrapper.find('input');
     expect(input().props().checked).toEqual(true);
@@ -76,7 +83,9 @@ describe('Toggle', () => {
     it('passes along onChange to <input>', () => {
       const onChange = jest.fn();
       const id = 'test-input';
-      const wrapper = mount(<Toggle id={id} onChange={onChange} />);
+      const wrapper = mount(
+        <Toggle {...commonProps} id={id} onChange={onChange} />
+      );
 
       const input = wrapper.find('input');
       const inputElement = input.instance();
@@ -94,7 +103,9 @@ describe('Toggle', () => {
     it('should invoke onToggle with expected arguments', () => {
       const onToggle = jest.fn();
       const id = 'test-input';
-      const wrapper = mount(<Toggle id={id} onToggle={onToggle} />);
+      const wrapper = mount(
+        <Toggle {...commonProps} id={id} onToggle={onToggle} />
+      );
 
       const input = wrapper.find('input');
       const inputElement = input.instance();
@@ -111,7 +122,7 @@ describe('Toggle', () => {
   });
 
   describe('ToggleSmall', () => {
-    const wrapper = mount(<Toggle id="toggle-1" size="sm" />);
+    const wrapper = mount(<Toggle {...commonProps} id="toggle-1" size="sm" />);
 
     it('Sets the `ToggleSmall` className', () => {
       const input = wrapper.find('input');
diff --git a/packages/react/src/components/Toggle/next/Toggle-test.js b/packages/react/src/components/Toggle/next/Toggle-test.js
new file mode 100644
index 000000000000..739d5e40917e
--- /dev/null
+++ b/packages/react/src/components/Toggle/next/Toggle-test.js
@@ -0,0 +1,146 @@
+/**
+ * Copyright IBM Corp. 2021
+ *
+ * This source code is licensed under the Apache-2.0 license found in the
+ * LICENSE file in the root directory of this source tree.
+ */
+
+import React from 'react';
+import Toggle from './Toggle';
+import { render } from '@testing-library/react';
+import userEvent from '@testing-library/user-event';
+import { settings } from 'carbon-components';
+
+const { prefix } = settings;
+
+describe('Toggle', () => {
+  const props = {
+    id: 'toggle-id',
+    labelA: 'labelA-unchecked',
+    labelB: 'labelB-checked',
+    labelText: 'Toggle label',
+    toggled: false,
+    onToggle: () => {},
+  };
+  let wrapper;
+
+  beforeEach(() => {
+    wrapper = render(<Toggle {...props} />);
+  });
+
+  describe('renders as expected', () => {
+    it('button and label ids should match', () => {
+      const button = wrapper.getByRole('switch');
+      const label = wrapper.container.querySelector('label');
+      expect(button.id).toBe(label.htmlFor);
+    });
+
+    it('renders labelA when unchecked', () => {
+      wrapper.rerender(<Toggle {...props} toggled={false} />);
+      expect(wrapper.queryByText(props.labelA)).toBeTruthy();
+      expect(wrapper.queryByText(props.labelB)).toBeNull();
+    });
+
+    it('renders labelB when checked', () => {
+      wrapper.rerender(<Toggle {...props} toggled={true} />);
+      expect(wrapper.queryByText(props.labelA)).toBeNull();
+      expect(wrapper.queryByText(props.labelB)).toBeTruthy();
+    });
+
+    it('supports additional css class names', () => {
+      const className = 'some-additional-class';
+      wrapper.rerender(<Toggle {...props} className={className} />);
+
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--toggle`)
+          .classList.contains(className)
+      ).toBe(true);
+    });
+
+    it('supports sm size', () => {
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--toggle__appearance`)
+          .classList.contains(`${prefix}--toggle__appearance--sm`)
+      ).toBe(false);
+      expect(
+        wrapper.container.querySelector(`.${prefix}--toggle__check`)
+      ).toBeNull();
+
+      wrapper.rerender(<Toggle {...props} size="sm" />);
+
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--toggle__appearance`)
+          .classList.contains(`${prefix}--toggle__appearance--sm`)
+      ).toBe(true);
+      expect(
+        wrapper.container.querySelector(`.${prefix}--toggle__check`)
+      ).toBeTruthy();
+    });
+
+    it('supports to use top label as side label', () => {
+      wrapper.rerender(<Toggle {...props} hideLabel />);
+
+      expect(
+        wrapper.container
+          .querySelector(`.${prefix}--toggle__label-text`)
+          .classList.contains(`${prefix}--visually-hidden`)
+      ).toBe(true);
+      expect(
+        wrapper.container.querySelector(`.${prefix}--toggle__label-text`)
+          .textContent
+      ).toBe(props.labelText);
+    });
+  });
+
+  describe('behaves as expected', () => {
+    it('supports to be disabled', () => {
+      expect(wrapper.getByRole('switch').disabled).toBe(false);
+      wrapper.rerender(<Toggle {...props} disabled />);
+      expect(wrapper.getByRole('switch').disabled).toBe(true);
+    });
+
+    it('can be controlled with props.toggled', () => {
+      wrapper.rerender(<Toggle {...props} toggled={false} />);
+      expect(wrapper.getByRole('switch').getAttribute('aria-checked')).toBe(
+        'false'
+      );
+      wrapper.rerender(<Toggle {...props} toggled={true} />);
+      expect(wrapper.getByRole('switch').getAttribute('aria-checked')).toBe(
+        'true'
+      );
+    });
+  });
+
+  describe('emits events as expected', () => {
+    it('passes along props.onClick to button', () => {
+      const onClick = jest.fn();
+      wrapper.rerender(<Toggle {...props} onClick={onClick} />);
+
+      expect(onClick).not.toHaveBeenCalled();
+      userEvent.click(wrapper.getByRole('switch'));
+      expect(onClick).toHaveBeenCalledTimes(1);
+    });
+
+    it('emits props.onToggle when toggled and passes current state', () => {
+      const onToggle = jest.fn();
+
+      wrapper.rerender(
+        <Toggle {...props} onToggle={onToggle} toggled={false} />
+      );
+      expect(onToggle).not.toHaveBeenCalled();
+      userEvent.click(wrapper.getByRole('switch'));
+      expect(onToggle).toHaveBeenCalledTimes(1);
+      expect(onToggle.mock.calls[0][0]).toBe(true);
+
+      wrapper.rerender(
+        <Toggle {...props} onToggle={onToggle} toggled={true} />
+      );
+      userEvent.click(wrapper.getByRole('switch'));
+      expect(onToggle).toHaveBeenCalledTimes(2);
+      expect(onToggle.mock.calls[1][0]).toBe(false);
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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/Toggle ; yarn test --maxWorkers=4 packages/react/src/components/Toggle/Toggle-test.js
: '>>>>> End Test Output'
git checkout 14b4dc1010d7ea5bdf54edc92fb4b939065bc02c packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/Toggle/Toggle-test.js && rm -f packages/react/src/components/Toggle/next/Toggle-test.js
