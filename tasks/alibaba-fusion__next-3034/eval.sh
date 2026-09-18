#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 46f8c31c4a20c6a02704463dad20d7706ebef893
git checkout 46f8c31c4a20c6a02704463dad20d7706ebef893 test/upload/card-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/upload/card-spec.js b/test/upload/card-spec.js
index b7fbad8639..627d1fbec0 100644
--- a/test/upload/card-spec.js
+++ b/test/upload/card-spec.js
@@ -97,6 +97,52 @@ describe('CardUpload', () => {
             assert(wrapper.props().value.length === 1);
             assert(wrapper.find('div.next-upload-list-item').length === 2);
         });
+        it('should support showDownload', () => {
+            const wrapper = mount(<CardUpload value={[]} />);
+            wrapper.setProps({
+                value: [
+                    {
+                        name: 'IMG_20140109_121958.jpg',
+                        state: 'done',
+                        url:
+                            'https://img.alicdn.com/tps/TB19O79MVXXXXcZXVXXXXXXXXXX-1024-1024.jpg',
+                        imgURL:
+                            'https://img.alicdn.com/tps/TB19O79MVXXXXcZXVXXXXXXXXXX-1024-1024.jpg',
+                    }
+                ],
+            });
+
+            assert(wrapper.find('i.next-upload-tool-download-icon').length === 1);
+
+            wrapper.setProps({
+                showDownload: false
+            });
+
+            assert(wrapper.find('i.next-upload-tool-download-icon').length === 0);
+        });
+        it('should support reUpload', () => {
+            const wrapper = mount(<CardUpload value={[]} />);
+            wrapper.setProps({
+                value: [
+                    {
+                        name: 'IMG_20140109_121958.jpg',
+                        state: 'error',
+                        url:
+                            'https://img.alicdn.com/tps/TB19O79MVXXXXcZXVXXXXXXXXXX-1024-1024.jpg',
+                        imgURL:
+                            'https://img.alicdn.com/tps/TB19O79MVXXXXcZXVXXXXXXXXXX-1024-1024.jpg',
+                    }
+                ],
+            });
+
+            assert(wrapper.find('i.next-upload-tool-reupload-icon').length === 0);
+
+            wrapper.setProps({
+                reUpload: true
+            });
+
+            assert(wrapper.find('i.next-upload-tool-reupload-icon').length === 1);
+        });
     });
 
     describe('[request]', () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test upload"'
: '>>>>> End Test Output'
git checkout 46f8c31c4a20c6a02704463dad20d7706ebef893 test/upload/card-spec.js
