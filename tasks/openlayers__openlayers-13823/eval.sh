#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 492458a141d9df7819589fd421ec41b26f8b1984
git checkout 492458a141d9df7819589fd421ec41b26f8b1984 test/node/ol/css.test.js test/rendering/cases/image-no-stretch-interpolate-false/expected.png test/rendering/cases/image-stretched-interpolate-false/expected.png test/rendering/cases/layer-image/expected.png test/rendering/cases/postrender-immediate/expected.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/node/ol/css.test.js b/test/node/ol/css.test.js
index 05d441ee98b..90c51d572e7 100644
--- a/test/node/ol/css.test.js
+++ b/test/node/ol/css.test.js
@@ -1,13 +1,7 @@
 import expect from '../expect.js';
-import {cssOpacity, getFontParameters} from '../../../src/ol/css.js';
+import {getFontParameters} from '../../../src/ol/css.js';
 
 describe('ol.css', function () {
-  describe('cssOpacity()', function () {
-    it('converts number to string, 1 to ""', function () {
-      expect(cssOpacity(0.5)).to.eql('0.5');
-      expect(cssOpacity(1)).to.eql('');
-    });
-  });
   describe('getFontParameters()', function () {
     const cases = [
       {
EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|image\\-no\\-stretch\\-interpolate\\-false|image\\-stretched\\-interpolate\\-false|layer\\-image|postrender\\-immediate)/main\\.js$" ; npm run test-node
: '>>>>> End Test Output'
git checkout 492458a141d9df7819589fd421ec41b26f8b1984 test/node/ol/css.test.js test/rendering/cases/image-no-stretch-interpolate-false/expected.png test/rendering/cases/image-stretched-interpolate-false/expected.png test/rendering/cases/layer-image/expected.png test/rendering/cases/postrender-immediate/expected.png
