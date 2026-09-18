#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e70264b8c397315d810c36d82f3f0f6d0173891f
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout e70264b8c397315d810c36d82f3f0f6d0173891f packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/__tests__/index-test.js && rm -f packages/react/src/components/ContextMenu/ContextMenu-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index 01a5c403c6ac..86cc00dfb459 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -7608,6 +7608,161 @@ Map {
       },
     },
   },
+  "unstable_ContextMenu" => Object {
+    "ContextMenuDivider": Object {},
+    "ContextMenuGroup": Object {
+      "propTypes": Object {
+        "children": Object {
+          "type": "node",
+        },
+        "label": Object {
+          "isRequired": true,
+          "type": "node",
+        },
+      },
+    },
+    "ContextMenuItem": Object {
+      "propTypes": Object {
+        "children": Object {
+          "type": "node",
+        },
+        "disabled": Object {
+          "type": "bool",
+        },
+        "label": Object {
+          "isRequired": true,
+          "type": "node",
+        },
+        "shortcut": Object {
+          "type": "node",
+        },
+      },
+    },
+    "ContextMenuRadioGroup": Object {
+      "propTypes": Object {
+        "initialSelectedItem": Object {
+          "type": "string",
+        },
+        "items": Object {
+          "args": Array [
+            Object {
+              "type": "string",
+            },
+          ],
+          "isRequired": true,
+          "type": "arrayOf",
+        },
+        "label": Object {
+          "isRequired": true,
+          "type": "string",
+        },
+        "onChange": Object {
+          "type": "func",
+        },
+      },
+    },
+    "ContextMenuSelectableItem": Object {
+      "propTypes": Object {
+        "initialChecked": Object {
+          "type": "bool",
+        },
+        "label": Object {
+          "isRequired": true,
+          "type": "node",
+        },
+        "onChange": Object {
+          "type": "func",
+        },
+      },
+    },
+    "propTypes": Object {
+      "children": Object {
+        "type": "node",
+      },
+      "level": Object {
+        "type": "number",
+      },
+      "onClose": Object {
+        "type": "func",
+      },
+      "open": Object {
+        "type": "bool",
+      },
+      "x": Object {
+        "type": "number",
+      },
+      "y": Object {
+        "type": "number",
+      },
+    },
+  },
+  "unstable_ContextMenuDivider" => Object {},
+  "unstable_ContextMenuGroup" => Object {
+    "propTypes": Object {
+      "children": Object {
+        "type": "node",
+      },
+      "label": Object {
+        "isRequired": true,
+        "type": "node",
+      },
+    },
+  },
+  "unstable_ContextMenuItem" => Object {
+    "propTypes": Object {
+      "children": Object {
+        "type": "node",
+      },
+      "disabled": Object {
+        "type": "bool",
+      },
+      "label": Object {
+        "isRequired": true,
+        "type": "node",
+      },
+      "shortcut": Object {
+        "type": "node",
+      },
+    },
+  },
+  "unstable_ContextMenuRadioGroup" => Object {
+    "propTypes": Object {
+      "initialSelectedItem": Object {
+        "type": "string",
+      },
+      "items": Object {
+        "args": Array [
+          Object {
+            "type": "string",
+          },
+        ],
+        "isRequired": true,
+        "type": "arrayOf",
+      },
+      "label": Object {
+        "isRequired": true,
+        "type": "string",
+      },
+      "onChange": Object {
+        "type": "func",
+      },
+    },
+  },
+  "unstable_ContextMenuSelectableItem" => Object {
+    "propTypes": Object {
+      "initialChecked": Object {
+        "type": "bool",
+      },
+      "label": Object {
+        "isRequired": true,
+        "type": "node",
+      },
+      "onChange": Object {
+        "type": "func",
+      },
+    },
+  },
+  "unstable_useContextMenu" => Object {},
   "unstable_Heading" => Object {
     "propTypes": Object {
       "children": Object {
diff --git a/packages/react/src/__tests__/index-test.js b/packages/react/src/__tests__/index-test.js
index df82386cb6f4..f13933ba9394 100644
--- a/packages/react/src/__tests__/index-test.js
+++ b/packages/react/src/__tests__/index-test.js
@@ -194,12 +194,19 @@ describe('Carbon Components React', () => {
         "TooltipDefinition",
         "TooltipIcon",
         "UnorderedList",
+        "unstable_ContextMenu",
+        "unstable_ContextMenuDivider",
+        "unstable_ContextMenuGroup",
+        "unstable_ContextMenuItem",
+        "unstable_ContextMenuRadioGroup",
+        "unstable_ContextMenuSelectableItem",
         "unstable_Heading",
         "unstable_PageSelector",
         "unstable_Pagination",
         "unstable_Section",
         "unstable_TreeNode",
         "unstable_TreeView",
+        "unstable_useContextMenu",
       ]
     `);
   });
diff --git a/packages/react/src/components/ContextMenu/ContextMenu-test.js b/packages/react/src/components/ContextMenu/ContextMenu-test.js
new file mode 100644
index 000000000000..18ea146ab8ea
--- /dev/null
+++ b/packages/react/src/components/ContextMenu/ContextMenu-test.js
@@ -0,0 +1,146 @@
+/**
+ * Copyright IBM Corp. 2020
+ *
+ * This source code is licensed under the Apache-2.0 license found in the
+ * LICENSE file in the root directory of this source tree.
+ */
+
+import React from 'react';
+import ContextMenu, {
+  ContextMenuItem,
+  ContextMenuRadioGroup,
+  ContextMenuSelectableItem,
+  ContextMenuDivider,
+} from '../ContextMenu';
+import { mount } from 'enzyme';
+import { settings } from 'carbon-components';
+import { describe, expect } from 'window-or-global';
+
+const { prefix } = settings;
+
+describe('ContextMenu', () => {
+  describe('renders as expected', () => {
+    describe('menu', () => {
+      it('receives the expected classes when closed', () => {
+        const wrapper = mount(<ContextMenu />);
+        const container = wrapper.childAt(0).childAt(0);
+
+        expect(container.hasClass(`${prefix}--context-menu`)).toBe(true);
+        expect(container.hasClass(`${prefix}--context-menu--open`)).toBe(false);
+      });
+
+      it('receives the expected classes when opened', () => {
+        const wrapper = mount(<ContextMenu open />);
+
+        const container = wrapper.childAt(0).childAt(0);
+
+        expect(container.hasClass(`${prefix}--context-menu`)).toBe(true);
+        expect(container.hasClass(`${prefix}--context-menu--open`)).toBe(true);
+      });
+    });
+
+    describe('option', () => {
+      it('receives the expected classes', () => {
+        const wrapper = mount(<ContextMenuItem label="Copy" />);
+        const container = wrapper.childAt(0).childAt(0);
+
+        expect(container.hasClass(`${prefix}--context-menu-option`)).toBe(true);
+      });
+
+      it('renders props.label', () => {
+        const wrapper = mount(<ContextMenuItem label="Copy" />);
+
+        expect(
+          wrapper.find(`span.${prefix}--context-menu-option__label`).text()
+        ).toBe('Copy');
+        expect(
+          wrapper
+            .find(`span.${prefix}--context-menu-option__label`)
+            .prop('title')
+        ).toBe('Copy');
+      });
+
+      it('renders props.shortcut when provided', () => {
+        const wrapper = mount(<ContextMenuItem label="Copy" shortcut="⌘C" />);
+
+        expect(
+          wrapper.find(`div.${prefix}--context-menu-option__info`).length
+        ).toBeGreaterThan(0);
+        expect(
+          wrapper.find(`div.${prefix}--context-menu-option__info`).text()
+        ).toBe('⌘C');
+      });
+
+      it('respects props.disabled', () => {
+        const wrapper = mount(<ContextMenuItem label="Copy" disabled />);
+        const content = wrapper.find(
+          `div.${prefix}--context-menu-option__content`
+        );
+
+        expect(
+          content.hasClass(`${prefix}--context-menu-option__content--disabled`)
+        ).toBe(true);
+        expect(
+          wrapper
+            .find(`li.${prefix}--context-menu-option`)
+            .prop('aria-disabled')
+        ).toBe(true);
+      });
+
+      it('renders props.children as submenu', () => {
+        const wrapper = mount(
+          <ContextMenu>
+            <ContextMenuItem label="Format">
+              <ContextMenuItem label="Bold" />
+              <ContextMenuItem label="Italic" />
+            </ContextMenuItem>
+          </ContextMenu>
+        );
+
+        const level1 = wrapper.find(`li.${prefix}--context-menu-option`).at(0);
+
+        expect(
+          level1.find(`ul.${prefix}--context-menu`).length
+        ).toBeGreaterThan(0);
+      });
+    });
+
+    describe('radiogroup', () => {
+      it('children have role "menuitemradio"', () => {
+        const wrapper = mount(
+          <ContextMenuRadioGroup label="Share with" items={['None', 'All']} />
+        );
+        const options = wrapper.find(`li.${prefix}--context-menu-option`);
+
+        expect(options.every('li[role="menuitemradio"]')).toBe(true);
+      });
+    });
+
+    describe('selectable', () => {
+      it('has role "menuitemcheckbox"', () => {
+        const wrapper = mount(<ContextMenuSelectableItem label="Publish" />);
+        const container = wrapper.childAt(0);
+
+        expect(container.prop('role')).toBe('menuitemcheckbox');
+      });
+    });
+
+    describe('divider', () => {
+      it('receives the expected classes', () => {
+        const wrapper = mount(<ContextMenuDivider />);
+        const container = wrapper.childAt(0);
+
+        expect(container.hasClass(`${prefix}--context-menu-divider`)).toBe(
+          true
+        );
+      });
+
+      it('has role "separator"', () => {
+        const wrapper = mount(<ContextMenuDivider />);
+        const container = wrapper.childAt(0);
+
+        expect(container.prop('role')).toBe('separator');
+      });
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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/ ; yarn test --maxWorkers=4 packages/react/src/components/ContextMenu/ContextMenu-test.js
: '>>>>> End Test Output'
git checkout e70264b8c397315d810c36d82f3f0f6d0173891f packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/__tests__/index-test.js && rm -f packages/react/src/components/ContextMenu/ContextMenu-test.js
