#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2c42a323d734f6dde4c765bee8ee891893c95bd3
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 2c42a323d734f6dde4c765bee8ee891893c95bd3 packages/react/src/components/ComboBox/ComboBox-test.js packages/react/src/components/Dropdown/Dropdown-test.js packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/ComboBox/ComboBox-test.js b/packages/react/src/components/ComboBox/ComboBox-test.js
index bacc66c3fb87..06b5ee247864 100644
--- a/packages/react/src/components/ComboBox/ComboBox-test.js
+++ b/packages/react/src/components/ComboBox/ComboBox-test.js
@@ -10,7 +10,6 @@ import { mount } from 'enzyme';
 import {
   findListBoxNode,
   findMenuNode,
-  findMenuItemNode,
   assertMenuOpen,
   assertMenuClosed,
   generateItems,
@@ -20,13 +19,7 @@ import ComboBox from '../ComboBox';
 import { settings } from 'carbon-components';
 
 const { prefix } = settings;
-
 const findInputNode = (wrapper) => wrapper.find(`.${prefix}--text-input`);
-const downshiftActions = {
-  setHighlightedIndex: jest.fn(),
-};
-const clearInput = (wrapper) =>
-  wrapper.instance().handleOnStateChange({ inputValue: '' }, downshiftActions);
 const openMenu = (wrapper) => {
   wrapper.find(`[role="combobox"]`).simulate('click');
 };
@@ -64,9 +57,8 @@ describe('ComboBox', () => {
     expect(mockProps.onChange).not.toHaveBeenCalled();
 
     for (let i = 0; i < mockProps.items.length; i++) {
-      clearInput(wrapper);
       openMenu(wrapper);
-      findMenuItemNode(wrapper, i).simulate('click');
+      wrapper.find('ForwardRef(ListBoxMenuItem)').at(i).simulate('click');
       expect(mockProps.onChange).toHaveBeenCalledTimes(i + 1);
       expect(mockProps.onChange).toHaveBeenCalledWith({
         selectedItem: mockProps.items[i],
@@ -100,7 +92,7 @@ describe('ComboBox', () => {
   it('should let the user select an option by clicking on the option node', () => {
     const wrapper = mount(<ComboBox {...mockProps} />);
     openMenu(wrapper);
-    findMenuItemNode(wrapper, 0).simulate('click');
+    wrapper.find('ForwardRef(ListBoxMenuItem)').at(0).simulate('click');
     expect(mockProps.onChange).toHaveBeenCalledTimes(1);
     expect(mockProps.onChange).toHaveBeenCalledWith({
       selectedItem: mockProps.items[0],
@@ -110,7 +102,7 @@ describe('ComboBox', () => {
     mockProps.onChange.mockClear();
 
     openMenu(wrapper);
-    findMenuItemNode(wrapper, 1).simulate('click');
+    wrapper.find('ForwardRef(ListBoxMenuItem)').at(1).simulate('click');
     expect(mockProps.onChange).toHaveBeenCalledTimes(1);
     expect(mockProps.onChange).toHaveBeenCalledWith({
       selectedItem: mockProps.items[1],
@@ -207,12 +199,7 @@ describe('ComboBox', () => {
 
     it('should set `inputValue` to an empty string if a falsey-y value is given', () => {
       const wrapper = mount(<ComboBox {...mockProps} />);
-
-      wrapper.instance().handleOnInputValueChange('foo', downshiftActions);
-      expect(wrapper.state('inputValue')).toBe('foo');
-
-      wrapper.instance().handleOnInputValueChange(null, downshiftActions);
-      expect(wrapper.state('inputValue')).toBe('');
+      expect(wrapper.find('input').instance().value).toBe('');
     });
   });
 });
diff --git a/packages/react/src/components/Dropdown/Dropdown-test.js b/packages/react/src/components/Dropdown/Dropdown-test.js
index 5c092d4cb041..06f5e3ea26a4 100644
--- a/packages/react/src/components/Dropdown/Dropdown-test.js
+++ b/packages/react/src/components/Dropdown/Dropdown-test.js
@@ -11,7 +11,6 @@ import { mount, shallow } from 'enzyme';
 import {
   assertMenuOpen,
   assertMenuClosed,
-  findMenuItemNode,
   openMenu,
   generateItems,
   generateGenericItem,
@@ -134,7 +133,7 @@ describe('Dropdown', () => {
   it('should let the user select an option by clicking on the option node', () => {
     const wrapper = mount(<Dropdown {...mockProps} />);
     openMenu(wrapper);
-    findMenuItemNode(wrapper, 0).simulate('click');
+    wrapper.find('ForwardRef(ListBoxMenuItem)').at(0).simulate('click');
     expect(mockProps.onChange).toHaveBeenCalledTimes(1);
     expect(mockProps.onChange).toHaveBeenCalledWith({
       selectedItem: mockProps.items[0],
@@ -144,7 +143,7 @@ describe('Dropdown', () => {
     mockProps.onChange.mockClear();
 
     openMenu(wrapper);
-    findMenuItemNode(wrapper, 1).simulate('click');
+    wrapper.find('ForwardRef(ListBoxMenuItem)').at(1).simulate('click');
     expect(mockProps.onChange).toHaveBeenCalledTimes(1);
     expect(mockProps.onChange).toHaveBeenCalledWith({
       selectedItem: mockProps.items[1],
diff --git a/packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap b/packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap
index 917f5b55ae98..0612f7662ee3 100644
--- a/packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap
+++ b/packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap
@@ -293,7 +293,7 @@ exports[`Dropdown should render custom item components 1`] = `
             role="listbox"
             tabIndex={-1}
           >
-            <ListBoxMenuItem
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-6-item-0"
               isActive={false}
@@ -328,8 +328,8 @@ exports[`Dropdown should render custom item components 1`] = `
                   </itemToElement>
                 </div>
               </div>
-            </ListBoxMenuItem>
-            <ListBoxMenuItem
+            </ForwardRef(ListBoxMenuItem)>
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-6-item-1"
               isActive={false}
@@ -364,8 +364,8 @@ exports[`Dropdown should render custom item components 1`] = `
                   </itemToElement>
                 </div>
               </div>
-            </ListBoxMenuItem>
-            <ListBoxMenuItem
+            </ForwardRef(ListBoxMenuItem)>
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-6-item-2"
               isActive={false}
@@ -400,8 +400,8 @@ exports[`Dropdown should render custom item components 1`] = `
                   </itemToElement>
                 </div>
               </div>
-            </ListBoxMenuItem>
-            <ListBoxMenuItem
+            </ForwardRef(ListBoxMenuItem)>
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-6-item-3"
               isActive={false}
@@ -436,8 +436,8 @@ exports[`Dropdown should render custom item components 1`] = `
                   </itemToElement>
                 </div>
               </div>
-            </ListBoxMenuItem>
-            <ListBoxMenuItem
+            </ForwardRef(ListBoxMenuItem)>
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-6-item-4"
               isActive={false}
@@ -472,7 +472,7 @@ exports[`Dropdown should render custom item components 1`] = `
                   </itemToElement>
                 </div>
               </div>
-            </ListBoxMenuItem>
+            </ForwardRef(ListBoxMenuItem)>
           </div>
         </ListBoxMenu>
       </div>
@@ -601,7 +601,7 @@ exports[`Dropdown should render with strings as items 1`] = `
             role="listbox"
             tabIndex={-1}
           >
-            <ListBoxMenuItem
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-4-item-0"
               isActive={false}
@@ -610,7 +610,6 @@ exports[`Dropdown should render with strings as items 1`] = `
               onClick={[Function]}
               onMouseMove={[Function]}
               role="option"
-              title="zar"
             >
               <div
                 aria-selected="false"
@@ -619,7 +618,6 @@ exports[`Dropdown should render with strings as items 1`] = `
                 onClick={[Function]}
                 onMouseMove={[Function]}
                 role="option"
-                title="zar"
               >
                 <div
                   className="bx--list-box__menu-item__option"
@@ -627,8 +625,8 @@ exports[`Dropdown should render with strings as items 1`] = `
                   zar
                 </div>
               </div>
-            </ListBoxMenuItem>
-            <ListBoxMenuItem
+            </ForwardRef(ListBoxMenuItem)>
+            <ForwardRef(ListBoxMenuItem)
               aria-selected="false"
               id="downshift-4-item-1"
               isActive={false}
@@ -637,7 +635,6 @@ exports[`Dropdown should render with strings as items 1`] = `
               onClick={[Function]}
               onMouseMove={[Function]}
               role="option"
-              title="doz"
             >
               <div
                 aria-selected="false"
@@ -646,7 +643,6 @@ exports[`Dropdown should render with strings as items 1`] = `
                 onClick={[Function]}
                 onMouseMove={[Function]}
                 role="option"
-                title="doz"
               >
                 <div
                   className="bx--list-box__menu-item__option"
@@ -654,7 +650,7 @@ exports[`Dropdown should render with strings as items 1`] = `
                   doz
                 </div>
               </div>
-            </ListBoxMenuItem>
+            </ForwardRef(ListBoxMenuItem)>
           </div>
         </ListBoxMenu>
       </div>
diff --git a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap
index 52cc01053551..c9d75663e139 100644
--- a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap
+++ b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap
@@ -9,7 +9,7 @@ exports[`ListBoxMenu should render 1`] = `
     id="test-listbox"
     role="listbox"
   >
-    <ListBoxMenuItem
+    <ForwardRef(ListBoxMenuItem)
       isActive={false}
       isHighlighted={false}
     >
@@ -22,7 +22,7 @@ exports[`ListBoxMenu should render 1`] = `
           Hello
         </div>
       </div>
-    </ListBoxMenuItem>
+    </ForwardRef(ListBoxMenuItem)>
   </div>
 </ListBoxMenu>
 `;
diff --git a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap
index 0f20253e8d57..8b1f126a2baf 100644
--- a/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap
+++ b/packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap
@@ -1,7 +1,7 @@
 // Jest Snapshot v1, https://goo.gl/fbAQLP
 
 exports[`ListBoxMenuItem should render 1`] = `
-<ListBoxMenuItem
+<ForwardRef(ListBoxMenuItem)
   isActive={false}
   isHighlighted={false}
 >
@@ -16,11 +16,11 @@ exports[`ListBoxMenuItem should render 1`] = `
       </span>
     </div>
   </div>
-</ListBoxMenuItem>
+</ForwardRef(ListBoxMenuItem)>
 `;
 
 exports[`ListBoxMenuItem should render 2`] = `
-<ListBoxMenuItem
+<ForwardRef(ListBoxMenuItem)
   isActive={true}
   isHighlighted={false}
 >
@@ -35,11 +35,11 @@ exports[`ListBoxMenuItem should render 2`] = `
       </span>
     </div>
   </div>
-</ListBoxMenuItem>
+</ForwardRef(ListBoxMenuItem)>
 `;
 
 exports[`ListBoxMenuItem should render 3`] = `
-<ListBoxMenuItem
+<ForwardRef(ListBoxMenuItem)
   isActive={false}
   isHighlighted={true}
 >
@@ -54,5 +54,5 @@ exports[`ListBoxMenuItem should render 3`] = `
       </span>
     </div>
   </div>
-</ListBoxMenuItem>
+</ForwardRef(ListBoxMenuItem)>
 `;
diff --git a/packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js b/packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js
index 94e3a0ac1b27..978a23ba03e7 100644
--- a/packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js
+++ b/packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js
@@ -17,7 +17,7 @@ import {
   generateGenericItem,
 } from '../../ListBox/test-helpers';
 
-const listItemName = 'ListBoxMenuItem';
+const listItemName = 'ForwardRef(ListBoxMenuItem)';
 
 describe('MultiSelect.Filterable', () => {
   let mockProps;
@@ -124,7 +124,7 @@ describe('MultiSelect.Filterable', () => {
     });
   });
 
-  it('should let items stay at thier position after selecting', () => {
+  it('should let items stay at their position after selecting', () => {
     const wrapper = mount(
       <MultiSelect.Filterable {...mockProps} selectionFeedback="fixed" />
     );
diff --git a/packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js b/packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js
index 6d290f73fb5c..69274c14bc32 100644
--- a/packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js
+++ b/packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js
@@ -400,7 +400,7 @@ describe('MultiSelect', () => {
       );
 
       // the first option in the list to the the former third option in the list
-      expect(optionsArray[0].title).toBe('Item 2');
+      expect(optionsArray[0].getAttribute('aria-label')).toBe('Item 2');
     });
 
     it('should accept a `ref` for the underlying button element', () => {

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
yarn test --maxWorkers=4 packages/react/src/components/ComboBox/ComboBox-test.js ; yarn test --maxWorkers=4 packages/react/src/components/Dropdown ; yarn test --maxWorkers=4 packages/react/src/components/Dropdown/Dropdown-test.js ; yarn test --maxWorkers=4 packages/react/src/components/ListBox/ ; yarn test --maxWorkers=4 packages/react/src/components/MultiSelect/
: '>>>>> End Test Output'
git checkout 2c42a323d734f6dde4c765bee8ee891893c95bd3 packages/react/src/components/ComboBox/ComboBox-test.js packages/react/src/components/Dropdown/Dropdown-test.js packages/react/src/components/Dropdown/__snapshots__/Dropdown-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenu-test.js.snap packages/react/src/components/ListBox/__tests__/__snapshots__/ListBoxMenuItem-test.js.snap packages/react/src/components/MultiSelect/__tests__/FilterableMultiSelect-test.js packages/react/src/components/MultiSelect/__tests__/MultiSelect-test.js
