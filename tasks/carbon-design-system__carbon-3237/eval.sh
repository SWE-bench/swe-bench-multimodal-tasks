#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 07f1a995ee488120aaa852825f69e28c1cc09919
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout 07f1a995ee488120aaa852825f69e28c1cc09919 packages/components/tests/spec/modal_spec.js packages/react/src/components/ComposedModal/ComposedModal-test.js packages/react/src/components/Modal/Modal-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/components/tests/spec/modal_spec.js b/packages/components/tests/spec/modal_spec.js
index 5707dbae5fc2..b67709bac982 100644
--- a/packages/components/tests/spec/modal_spec.js
+++ b/packages/components/tests/spec/modal_spec.js
@@ -41,6 +41,7 @@ describe('Test modal', function() {
           '.flatpickr-calendar',
         ],
         classVisible: 'is-visible',
+        classBody: 'bx--body--with-modal-open',
         attribInitTarget: 'data-modal-target',
         initEventNames: ['click'],
         eventBeforeShown: 'modal-beingshown',
diff --git a/packages/react/src/components/ComposedModal/ComposedModal-test.js b/packages/react/src/components/ComposedModal/ComposedModal-test.js
index 1896428d3536..4cc60a731e07 100644
--- a/packages/react/src/components/ComposedModal/ComposedModal-test.js
+++ b/packages/react/src/components/ComposedModal/ComposedModal-test.js
@@ -167,6 +167,17 @@ describe('<ComposedModal />', () => {
     expect(wrapper.state().open).toEqual(false);
   });
 
+  it('should change class of <body> upon open state', () => {
+    mount(<ComposedModal open />);
+    expect(
+      document.body.classList.contains('bx--body--with-modal-open')
+    ).toEqual(true);
+    mount(<ComposedModal open={false} />);
+    expect(
+      document.body.classList.contains('bx--body--with-modal-open')
+    ).toEqual(false);
+  });
+
   it('avoids change the open state upon setting props, unless there the value actually changes', () => {
     const wrapper = shallow(<ComposedModal />);
     wrapper.setProps({ open: true });
diff --git a/packages/react/src/components/Modal/Modal-test.js b/packages/react/src/components/Modal/Modal-test.js
index 41cda41132cc..3f3555b73eb1 100644
--- a/packages/react/src/components/Modal/Modal-test.js
+++ b/packages/react/src/components/Modal/Modal-test.js
@@ -109,10 +109,16 @@ describe('Modal', () => {
       const openClass = 'is-visible';
 
       expect(modalContainer.hasClass(openClass)).not.toEqual(true);
+      expect(
+        document.body.classList.contains('bx--body--with-modal-open')
+      ).not.toEqual(true);
       wrapper.setState({ isOpen: true });
       expect(wrapper.find(`.${prefix}--modal`).hasClass(openClass)).toEqual(
         true
       );
+      expect(
+        document.body.classList.contains('bx--body--with-modal-open')
+      ).toEqual(true);
     });
 
     it('should set state to open when trigger button is clicked', () => {

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
yarn test --maxWorkers=4 packages/components/tests/spec/modal_spec.js ; yarn test --maxWorkers=4 packages/react/src/components/ComposedModal/ComposedModal-test.js ; yarn test --maxWorkers=4 packages/react/src/components/Modal/Modal-test.js
: '>>>>> End Test Output'
git checkout 07f1a995ee488120aaa852825f69e28c1cc09919 packages/components/tests/spec/modal_spec.js packages/react/src/components/ComposedModal/ComposedModal-test.js packages/react/src/components/Modal/Modal-test.js
