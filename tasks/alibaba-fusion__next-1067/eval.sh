#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a631db4c318d4aba852a6126a4fcfd2a667eff54
git checkout a631db4c318d4aba852a6126a4fcfd2a667eff54 test/slider/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/slider/index-spec.js b/test/slider/index-spec.js
index 277e9ac4a4..69e294919e 100644
--- a/test/slider/index-spec.js
+++ b/test/slider/index-spec.js
@@ -361,6 +361,23 @@ describe('slider', function () {
             });
         });
 
+        it('should have correct disabled class for next/prev arrow', () => {
+            return co(function* () {
+                wrapper = mount(<Slider
+                    infinite={false}
+                    defaultActiveIndex={2}
+                    slidesToShow={5}
+                    >{slides}</Slider>);
+                yield delay(100);
+                assert(
+                    wrapper.find('.next-slick-arrow.next-slick-next').at(0).hasClass('disabled')
+                );
+                assert(
+                    !wrapper.find('.next-slick-arrow.next-slick-prev').at(0).hasClass('disabled')
+                );
+            });
+        });
+
         it('should hover next/prev arrow', () => {
             return co(function* () {
                 wrapper = mount(<Slider infinite={false}>{slides}</Slider>);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test slider"'
: '>>>>> End Test Output'
git checkout a631db4c318d4aba852a6126a4fcfd2a667eff54 test/slider/index-spec.js
