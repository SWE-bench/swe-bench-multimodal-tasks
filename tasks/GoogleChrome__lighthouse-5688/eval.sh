#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 8cee1138d75298418bbd413c01f52970084c97ab
git checkout 8cee1138d75298418bbd413c01f52970084c97ab lighthouse-core/test/audits/dobetterweb/doctype-test.js lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/dobetterweb/doctype-test.js b/lighthouse-core/test/audits/dobetterweb/doctype-test.js
index 937aa568a505..b77e49bf1c38 100644
--- a/lighthouse-core/test/audits/dobetterweb/doctype-test.js
+++ b/lighthouse-core/test/audits/dobetterweb/doctype-test.js
@@ -8,7 +8,7 @@
 const Audit = require('../../../audits/dobetterweb/doctype.js');
 const assert = require('assert');
 
-/* eslint-env mocha */
+/* eslint-env jest */
 
 describe('DOBETTERWEB: doctype audit', () => {
   it('fails when document does not contain a doctype', () => {
diff --git a/lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js b/lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
index 68dfe839c555..d017f0387938 100644
--- a/lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
+++ b/lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
@@ -5,7 +5,7 @@
  */
 'use strict';
 
-/* eslint-env mocha */
+/* eslint-env jest */
 
 const OptimizedImages =
     require('../../../../gather/gatherers/dobetterweb/optimized-images');
@@ -185,4 +185,23 @@ describe('Optimized images', () => {
       assert.ok(/gmail.*image.jpg/.test(artifact[3].url));
     });
   });
+
+  it('handles non-standard mime types too', async () => {
+    const traceData = {
+      networkRecords: [
+        {
+          requestId: '1',
+          url: 'http://google.com/image.bmp?x-ms',
+          mimeType: 'image/x-ms-bmp',
+          resourceSize: 12000,
+          transferSize: 20000,
+          resourceType: 'Image',
+          finished: true,
+        },
+      ],
+    };
+
+    const artifact = await optimizedImages.afterPass(options, traceData);
+    expect(artifact).toHaveLength(1);
+  });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/audits/dobetterweb/doctype-test.js lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
: '>>>>> End Test Output'
git checkout 8cee1138d75298418bbd413c01f52970084c97ab lighthouse-core/test/audits/dobetterweb/doctype-test.js lighthouse-core/test/gather/gatherers/dobetterweb/optimized-images-test.js
