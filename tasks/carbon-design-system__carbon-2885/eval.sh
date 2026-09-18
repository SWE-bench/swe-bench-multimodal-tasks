#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5fc3498a1e4005403db5030f9aea6c944d304ca8
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 5fc3498a1e4005403db5030f9aea6c944d304ca8 packages/react/src/components/Toggle/Toggle-test.js packages/react/src/components/ToggleSmall/ToggleSmall-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/Toggle/Toggle-test.js b/packages/react/src/components/Toggle/Toggle-test.js
index baa79d9be8bd..6528b4cf87e9 100644
--- a/packages/react/src/components/Toggle/Toggle-test.js
+++ b/packages/react/src/components/Toggle/Toggle-test.js
@@ -31,9 +31,9 @@ describe('Toggle', () => {
 
     it('Can set defaultToggled state', () => {
       wrapper.setProps({ defaultToggled: true });
-      expect(wrapper.find(`.${prefix}--toggle`).props().defaultChecked).toEqual(
-        true
-      );
+      expect(
+        wrapper.find(`.${prefix}--toggle-input`).props().defaultChecked
+      ).toEqual(true);
     });
 
     it('Should add extra classes that are passed via className', () => {
@@ -43,19 +43,21 @@ describe('Toggle', () => {
 
     it('Can be disabled', () => {
       wrapper.setProps({ disabled: true });
-      expect(wrapper.find(`.${prefix}--toggle`).props().disabled).toEqual(true);
+      expect(wrapper.find(`.${prefix}--toggle-input`).props().disabled).toEqual(
+        true
+      );
     });
 
     it('Can have a labelA', () => {
       wrapper.setProps({ labelA: 'labelA-test' });
-      expect(wrapper.find(`.${prefix}--toggle__text--left`).text()).toEqual(
+      expect(wrapper.find(`.${prefix}--toggle__text--off`).text()).toEqual(
         'labelA-test'
       );
     });
 
     it('Can have a labelB', () => {
       wrapper.setProps({ labelB: 'labelB-test' });
-      expect(wrapper.find(`.${prefix}--toggle__text--right`).text()).toEqual(
+      expect(wrapper.find(`.${prefix}--toggle__text--on`).text()).toEqual(
         'labelB-test'
       );
     });
diff --git a/packages/react/src/components/ToggleSmall/ToggleSmall-test.js b/packages/react/src/components/ToggleSmall/ToggleSmall-test.js
index 7365fdc9522a..3fdff7ee06e9 100644
--- a/packages/react/src/components/ToggleSmall/ToggleSmall-test.js
+++ b/packages/react/src/components/ToggleSmall/ToggleSmall-test.js
@@ -14,7 +14,14 @@ import { settings } from 'carbon-components';
 const { prefix } = settings;
 describe('ToggleSmall', () => {
   describe('Renders as expected', () => {
-    const wrapper = mount(<ToggleSmall id="toggle-1" ariaLabel="test label" />);
+    const wrapper = mount(
+      <ToggleSmall
+        id="toggle-1"
+        aria-label="test label"
+        labelA="Off"
+        labelB="On"
+      />
+    );
 
     const input = wrapper.find('input');
 
@@ -31,9 +38,9 @@ describe('ToggleSmall', () => {
 
     it('Can set defaultToggled state', () => {
       wrapper.setProps({ defaultToggled: true });
-      expect(wrapper.find(`.${prefix}--toggle`).props().defaultChecked).toEqual(
-        true
-      );
+      expect(
+        wrapper.find(`.${prefix}--toggle-input`).props().defaultChecked
+      ).toEqual(true);
     });
 
     it('Should add extra classes that are passed via className', () => {
@@ -43,13 +50,15 @@ describe('ToggleSmall', () => {
 
     it('Can be disabled', () => {
       wrapper.setProps({ disabled: true });
-      expect(wrapper.find(`.${prefix}--toggle`).props().disabled).toEqual(true);
+      expect(wrapper.find(`.${prefix}--toggle-input`).props().disabled).toEqual(
+        true
+      );
     });
   });
 
   it('toggled prop sets checked prop on input', () => {
     const wrapper = mount(
-      <ToggleSmall id="test" ariaLabel="test label" toggled />
+      <ToggleSmall id="test" aria-label="test label" toggled />
     );
 
     const input = () => wrapper.find('input');
@@ -64,7 +73,7 @@ describe('ToggleSmall', () => {
       const onChange = jest.fn();
       const id = 'test-input';
       const wrapper = mount(
-        <ToggleSmall ariaLabel="test label" id={id} onChange={onChange} />
+        <ToggleSmall aria-label="test label" id={id} onChange={onChange} />
       );
 
       const input = wrapper.find('input');
@@ -84,7 +93,7 @@ describe('ToggleSmall', () => {
       const onToggle = jest.fn();
       const id = 'test-input';
       const wrapper = mount(
-        <ToggleSmall ariaLabel="test label" id={id} onToggle={onToggle} />
+        <ToggleSmall aria-label="test label" id={id} onToggle={onToggle} />
       );
 
       const input = wrapper.find('input');

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
yarn test --maxWorkers=4 packages/react/src/components/Toggle/Toggle-test.js ; yarn test --maxWorkers=4 packages/react/src/components/ToggleSmall/ToggleSmall-test.js
: '>>>>> End Test Output'
git checkout 5fc3498a1e4005403db5030f9aea6c944d304ca8 packages/react/src/components/Toggle/Toggle-test.js packages/react/src/components/ToggleSmall/ToggleSmall-test.js
