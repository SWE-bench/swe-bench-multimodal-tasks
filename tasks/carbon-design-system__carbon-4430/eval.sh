#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 1a74ae7520754a00ead4e60930f67a3cbb047923
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 1a74ae7520754a00ead4e60930f67a3cbb047923 packages/react/src/components/DataTable/__tests__/DataTable-test.js packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/DataTable/__tests__/DataTable-test.js b/packages/react/src/components/DataTable/__tests__/DataTable-test.js
index 3b4355be2294..e042bc7f96d2 100644
--- a/packages/react/src/components/DataTable/__tests__/DataTable-test.js
+++ b/packages/react/src/components/DataTable/__tests__/DataTable-test.js
@@ -340,6 +340,181 @@ describe('DataTable', () => {
     });
   });
 
+  describe('selection with filtering', () => {
+    let mockProps;
+
+    beforeEach(() => {
+      mockProps = {
+        rows: [
+          {
+            id: 'b',
+            fieldA: 'Field 2:A',
+            fieldB: 'Field 2:B',
+          },
+          {
+            id: 'a',
+            fieldA: 'Field 1:A',
+            fieldB: 'Field 1:B',
+          },
+          {
+            id: 'c',
+            fieldA: 'Field 3:A',
+            fieldB: 'Field 3:B',
+          },
+        ],
+        headers: [
+          {
+            key: 'fieldA',
+            header: 'Field A',
+          },
+          {
+            key: 'fieldB',
+            header: 'Field B',
+          },
+        ],
+        locale: 'en',
+        render: jest.fn(
+          ({
+            rows,
+            headers,
+            getHeaderProps,
+            getSelectionProps,
+            onInputChange,
+          }) => (
+            <TableContainer title="DataTable with selection">
+              <TableToolbar>
+                <TableToolbarContent>
+                  <TableToolbarSearch
+                    persistent
+                    onChange={onInputChange}
+                    id="custom-id"
+                  />
+                  <TableToolbarMenu>
+                    <TableToolbarAction primaryFocus onClick={jest.fn()}>
+                      Action 1
+                    </TableToolbarAction>
+                    <TableToolbarAction onClick={jest.fn()}>
+                      Action 2
+                    </TableToolbarAction>
+                    <TableToolbarAction onClick={jest.fn()}>
+                      Action 3
+                    </TableToolbarAction>
+                  </TableToolbarMenu>
+                  <Button onClick={jest.fn()} small kind="primary">
+                    Add new
+                  </Button>
+                </TableToolbarContent>
+              </TableToolbar>
+              <Table>
+                <TableHead>
+                  <TableRow>
+                    <TableSelectAll {...getSelectionProps()} />
+                    {headers.map(header => (
+                      <TableHeader {...getHeaderProps({ header })}>
+                        {header.header}
+                      </TableHeader>
+                    ))}
+                  </TableRow>
+                </TableHead>
+                <TableBody>
+                  {rows.map(row => (
+                    <TableRow key={row.id}>
+                      <TableSelectRow {...getSelectionProps({ row })} />
+                      {row.cells.map(cell => (
+                        <TableCell key={cell.id}>{cell.value}</TableCell>
+                      ))}
+                    </TableRow>
+                  ))}
+                </TableBody>
+              </Table>
+            </TableContainer>
+          )
+        ),
+      };
+    });
+
+    it('should only select all from filtered items', () => {
+      const wrapper = mount(<DataTable {...mockProps} />);
+
+      expect(getSelectAll(wrapper).prop('checked')).toBe(false);
+
+      const filterInput = getFilterInput(wrapper);
+
+      filterInput.getDOMNode().value = 'Field 1';
+      filterInput.simulate('change');
+
+      getInputAtIndex({ wrapper, index: 0, inputType: 'checkbox' }).simulate(
+        'click'
+      );
+
+      filterInput.getDOMNode().value = '';
+      filterInput.simulate('change');
+
+      expect(wrapper.find('TableSelectAll').prop('indeterminate')).toBe(true);
+
+      let { selectedRows } = getLastCallFor(mockProps.render)[0];
+      expect(selectedRows.length).toBe(1);
+
+      getSelectAll(wrapper).simulate('click');
+
+      selectedRows = getLastCallFor(mockProps.render)[0].selectedRows;
+      expect(selectedRows.length).toBe(0);
+    });
+
+    it('should only select rows that are not disabled even when filtered', () => {
+      const wrapper = mount(<DataTable {...mockProps} />);
+
+      const nextRows = [
+        ...mockProps.rows.map(row => ({ ...row })),
+        {
+          id: 'd',
+          fieldA: 'Field 3:A',
+          fieldB: 'Field 3:B',
+          disabled: true,
+        },
+      ];
+
+      wrapper.setProps({ rows: nextRows });
+
+      const filterInput = getFilterInput(wrapper);
+
+      filterInput.getDOMNode().value = 'Field 3';
+      filterInput.simulate('change');
+
+      getSelectAll(wrapper).simulate('click');
+
+      const { selectedRows } = getLastCallFor(mockProps.render)[0];
+      expect(selectedRows.length).toBe(1);
+
+      expect(wrapper.find('TableSelectAll').prop('indeterminate')).toBe(true);
+    });
+
+    it('does not select a row if they are all disabled', () => {
+      const wrapper = mount(<DataTable {...mockProps} />);
+
+      const nextRows = [
+        ...mockProps.rows.map(row => ({ ...row, disabled: true })),
+      ];
+
+      wrapper.setProps({ rows: nextRows });
+
+      getSelectAll(wrapper).simulate('click');
+
+      expect(wrapper.find('TableSelectAll').prop('indeterminate')).toBe(false);
+      expect(wrapper.find('TableSelectAll').prop('checked')).toBe(false);
+
+      const filterInput = getFilterInput(wrapper);
+
+      filterInput.getDOMNode().value = 'Field 3';
+      filterInput.simulate('change');
+
+      getSelectAll(wrapper).simulate('click');
+
+      const { selectedRows } = getLastCallFor(mockProps.render)[0];
+      expect(selectedRows.length).toBe(0);
+    });
+  });
+
   describe('selection -- radio buttons', () => {
     let mockProps;
 
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
index e9567e480837..085c093c4c4a 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
@@ -364,7 +364,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-b"
+                    id="data-table-14__select-row-b"
                     name="select-row-b"
                     onSelect={[Function]}
                     radio={true}
@@ -381,7 +381,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-a"
+                    id="data-table-14__select-row-a"
                     name="select-row-a"
                     onSelect={[Function]}
                     radio={true}
@@ -398,7 +398,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-c"
+                    id="data-table-14__select-row-c"
                     name="select-row-c"
                     onSelect={[Function]}
                     radio={true}
@@ -523,7 +523,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-b"
+                    id="data-table-14__select-row-b"
                     name="select-row-b"
                     onSelect={[Function]}
                     radio={true}
@@ -535,7 +535,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                         checked={false}
                         disabled={false}
                         hideLabel={true}
-                        id="data-table-11__select-row-b"
+                        id="data-table-14__select-row-b"
                         labelText="Select row"
                         name="select-row-b"
                         onClick={[Function]}
@@ -544,7 +544,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                           checked={false}
                           disabled={false}
                           hideLabel={true}
-                          id="data-table-11__select-row-b"
+                          id="data-table-14__select-row-b"
                           innerRef={null}
                           labelPosition="right"
                           labelText="Select row"
@@ -560,7 +560,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                               checked={false}
                               className="bx--radio-button"
                               disabled={false}
-                              id="data-table-11__select-row-b"
+                              id="data-table-14__select-row-b"
                               name="select-row-b"
                               onChange={[Function]}
                               onClick={[Function]}
@@ -570,7 +570,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                             <label
                               aria-label="Select row"
                               className="bx--radio-button__label"
-                              htmlFor="data-table-11__select-row-b"
+                              htmlFor="data-table-14__select-row-b"
                             >
                               <span
                                 className="bx--radio-button__appearance"
@@ -610,7 +610,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-a"
+                    id="data-table-14__select-row-a"
                     name="select-row-a"
                     onSelect={[Function]}
                     radio={true}
@@ -622,7 +622,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                         checked={false}
                         disabled={false}
                         hideLabel={true}
-                        id="data-table-11__select-row-a"
+                        id="data-table-14__select-row-a"
                         labelText="Select row"
                         name="select-row-a"
                         onClick={[Function]}
@@ -631,7 +631,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                           checked={false}
                           disabled={false}
                           hideLabel={true}
-                          id="data-table-11__select-row-a"
+                          id="data-table-14__select-row-a"
                           innerRef={null}
                           labelPosition="right"
                           labelText="Select row"
@@ -647,7 +647,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                               checked={false}
                               className="bx--radio-button"
                               disabled={false}
-                              id="data-table-11__select-row-a"
+                              id="data-table-14__select-row-a"
                               name="select-row-a"
                               onChange={[Function]}
                               onClick={[Function]}
@@ -657,7 +657,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                             <label
                               aria-label="Select row"
                               className="bx--radio-button__label"
-                              htmlFor="data-table-11__select-row-a"
+                              htmlFor="data-table-14__select-row-a"
                             >
                               <span
                                 className="bx--radio-button__appearance"
@@ -697,7 +697,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                     ariaLabel="Select row"
                     checked={false}
                     disabled={false}
-                    id="data-table-11__select-row-c"
+                    id="data-table-14__select-row-c"
                     name="select-row-c"
                     onSelect={[Function]}
                     radio={true}
@@ -709,7 +709,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                         checked={false}
                         disabled={false}
                         hideLabel={true}
-                        id="data-table-11__select-row-c"
+                        id="data-table-14__select-row-c"
                         labelText="Select row"
                         name="select-row-c"
                         onClick={[Function]}
@@ -718,7 +718,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                           checked={false}
                           disabled={false}
                           hideLabel={true}
-                          id="data-table-11__select-row-c"
+                          id="data-table-14__select-row-c"
                           innerRef={null}
                           labelPosition="right"
                           labelText="Select row"
@@ -734,7 +734,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                               checked={false}
                               className="bx--radio-button"
                               disabled={false}
-                              id="data-table-11__select-row-c"
+                              id="data-table-14__select-row-c"
                               name="select-row-c"
                               onChange={[Function]}
                               onClick={[Function]}
@@ -744,7 +744,7 @@ exports[`DataTable selection -- radio buttons should render 1`] = `
                             <label
                               aria-label="Select row"
                               className="bx--radio-button__label"
-                              htmlFor="data-table-11__select-row-c"
+                              htmlFor="data-table-14__select-row-c"
                             >
                               <span
                                 className="bx--radio-button__appearance"

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
yarn test --maxWorkers=4 packages/react/src/components/DataTable/
: '>>>>> End Test Output'
git checkout 1a74ae7520754a00ead4e60930f67a3cbb047923 packages/react/src/components/DataTable/__tests__/DataTable-test.js packages/react/src/components/DataTable/__tests__/__snapshots__/DataTable-test.js.snap
