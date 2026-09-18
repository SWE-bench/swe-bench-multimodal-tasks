#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8dd1cf539631b1efd8d716a25dbe4de60a0d03d2
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 8dd1cf539631b1efd8d716a25dbe4de60a0d03d2 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/DataTable-test.js packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
index e7e99169d66d..57ad9ac6f903 100644
--- a/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
+++ b/packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap
@@ -2004,10 +2004,10 @@ Map {
     },
     "TableSelectAll": Object {
       "propTypes": Object {
-        "ariaLabel": Object {
-          "isRequired": true,
+        "aria-label": Object {
           "type": "string",
         },
+        "ariaLabel": [Function],
         "checked": Object {
           "isRequired": true,
           "type": "bool",
@@ -2037,10 +2037,10 @@ Map {
     },
     "TableSelectRow": Object {
       "propTypes": Object {
-        "ariaLabel": Object {
-          "isRequired": true,
+        "aria-label": Object {
           "type": "string",
         },
+        "ariaLabel": [Function],
         "checked": Object {
           "isRequired": true,
           "type": "bool",
@@ -8006,10 +8006,10 @@ Map {
   },
   "TableSelectAll" => Object {
     "propTypes": Object {
-      "ariaLabel": Object {
-        "isRequired": true,
+      "aria-label": Object {
         "type": "string",
       },
+      "ariaLabel": [Function],
       "checked": Object {
         "isRequired": true,
         "type": "bool",
@@ -8039,10 +8039,10 @@ Map {
   },
   "TableSelectRow" => Object {
     "propTypes": Object {
-      "ariaLabel": Object {
-        "isRequired": true,
+      "aria-label": Object {
         "type": "string",
       },
+      "ariaLabel": [Function],
       "checked": Object {
         "isRequired": true,
         "type": "bool",
diff --git a/packages/react/src/components/DataTable/__tests__/DataTable-test.js b/packages/react/src/components/DataTable/__tests__/DataTable-test.js
index 743653d8a195..6dca7f4cc31f 100644
--- a/packages/react/src/components/DataTable/__tests__/DataTable-test.js
+++ b/packages/react/src/components/DataTable/__tests__/DataTable-test.js
@@ -296,8 +296,11 @@ describe('DataTable', () => {
 
     describe('selection', () => {
       let mockProps;
+      let spy;
 
       beforeEach(() => {
+        // v12 TODO: Remove the mock of console.warn once we remove ariaLabel from DataTable
+        spy = jest.spyOn(console, 'warn').mockImplementation(() => {});
         mockProps = {
           rows: [
             {
@@ -402,6 +405,10 @@ describe('DataTable', () => {
         };
       });
 
+      afterEach(() => {
+        spy.mockRestore();
+      });
+
       it('should render and match snapshot', () => {
         const { container } = render(<DataTable {...mockProps} />);
         expect(container).toMatchSnapshot();
diff --git a/packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js b/packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js
index 67f1eca5f176..7103e7c9718a 100644
--- a/packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js
+++ b/packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js
@@ -20,7 +20,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={false}
                 id="select-all"
                 name="select-all"
@@ -39,7 +39,8 @@ describe('TableSelectAll', () => {
       );
     });
 
-    it('should respect ariaLabel prop', () => {
+    it('should respect the deprecated ariaLabel prop', () => {
+      const spy = jest.spyOn(console, 'warn').mockImplementation(() => {});
       render(
         <Table>
           <TableHead>
@@ -57,6 +58,50 @@ describe('TableSelectAll', () => {
       );
 
       expect(screen.getByLabelText('Select all rows')).toBeInTheDocument();
+      spy.mockRestore();
+    });
+
+    it('should respect aria-label prop', () => {
+      render(
+        <Table>
+          <TableHead>
+            <TableRow>
+              <TableSelectAll
+                aria-label="Select all rows"
+                checked={false}
+                id="select-all"
+                name="select-all"
+                onSelect={() => {}}
+              />
+            </TableRow>
+          </TableHead>
+        </Table>
+      );
+
+      expect(screen.getByLabelText('Select all rows')).toBeInTheDocument();
+    });
+
+    it('should give priority to new aria-label compared to old ariaLabel', () => {
+      const spy = jest.spyOn(console, 'warn').mockImplementation(() => {});
+      render(
+        <Table>
+          <TableHead>
+            <TableRow>
+              <TableSelectAll
+                aria-label="Select all rows"
+                ariaLabel="Skipped in favor of aria-label"
+                checked={false}
+                id="select-all"
+                name="select-all"
+                onSelect={() => {}}
+              />
+            </TableRow>
+          </TableHead>
+        </Table>
+      );
+
+      expect(screen.getByLabelText('Select all rows')).toBeInTheDocument();
+      spy.mockRestore();
     });
 
     it('should respect checked prop', () => {
@@ -65,7 +110,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={true}
                 id="select-all"
                 name="select-all"
@@ -85,7 +130,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={false}
                 id="select-all"
                 name="select-all"
@@ -106,7 +151,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={false}
                 id="select-all"
                 name="select-all"
@@ -127,7 +172,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={false}
                 id="select-all"
                 name="select-all"
@@ -148,7 +193,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={true}
                 id="select-all"
                 name="select-all"
@@ -169,7 +214,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={true}
                 id="select-all"
                 name="select-all-input"
@@ -193,7 +238,7 @@ describe('TableSelectAll', () => {
           <TableHead>
             <TableRow>
               <TableSelectAll
-                ariaLabel="Select all rows"
+                aria-label="Select all rows"
                 checked={true}
                 id="select-all"
                 name="select-all-input"
diff --git a/packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js b/packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js
index 5b893e8a4939..d91eeeca604c 100644
--- a/packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js
+++ b/packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js
@@ -21,7 +21,7 @@ describe('DataTable.TableSelectRow', () => {
       onChange: jest.fn(),
       onSelect: jest.fn(),
       className: 'custom-class-name',
-      ariaLabel: 'Aria label',
+      'aria-label': 'New Aria label',
     };
   });
 
@@ -53,6 +53,52 @@ describe('DataTable.TableSelectRow', () => {
       expect(screen.getByRole('checkbox')).toBeChecked();
     });
 
+    it('should respect deprecated ariaLabel prop if aria-label is not defined', () => {
+      const spy = jest.spyOn(console, 'warn').mockImplementation(() => {});
+      render(
+        <Table>
+          <TableHead>
+            <TableRow>
+              <TableSelectRow
+                {...mockProps}
+                aria-label={null}
+                ariaLabel="Aria label"
+                checked
+              />
+            </TableRow>
+          </TableHead>
+        </Table>
+      );
+
+      expect(screen.getByLabelText('Aria label')).toBeInTheDocument();
+      spy.mockRestore();
+    });
+
+    it('should give priority to new aria-label compared to old ariaLabel', () => {
+      const spy = jest.spyOn(console, 'warn').mockImplementation(() => {});
+      spy.mockRestore();
+      render(
+        <Table>
+          <TableHead>
+            <TableRow>
+              <TableSelectRow
+                {...mockProps}
+                ariaLabel="Deprecated aria label"
+                checked
+              />
+            </TableRow>
+          </TableHead>
+        </Table>
+      );
+
+      expect(screen.getByLabelText('New Aria label')).toBeInTheDocument();
+      expect(
+        screen.queryByLabelText('Deprecated aria label')
+      ).not.toBeInTheDocument();
+
+      spy.mockRestore();
+    });
+
     it('should support a custom `className` prop on the outermost element', () => {
       render(
         <Table>
diff --git a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap
index b18e8fa7fec2..c64d691b7639 100644
--- a/packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap
+++ b/packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap
@@ -30,7 +30,7 @@ exports[`DataTable.TableSelectRow renders as expected - Component API should ren
                 <span
                   class="cds--visually-hidden"
                 >
-                  Aria label
+                  New Aria label
                 </span>
               </label>
             </div>

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
yarn test --maxWorkers=4 packages/react/ ; yarn test --maxWorkers=4 packages/react/src/components/DataTable/
: '>>>>> End Test Output'
git checkout 8dd1cf539631b1efd8d716a25dbe4de60a0d03d2 packages/react/__tests__/__snapshots__/PublicAPI-test.js.snap packages/react/src/components/DataTable/__tests__/DataTable-test.js packages/react/src/components/DataTable/__tests__/TableSelectAll-test.js packages/react/src/components/DataTable/__tests__/TableSelectRow-test.js packages/react/src/components/DataTable/__tests__/__snapshots__/TableSelectRow-test.js.snap
