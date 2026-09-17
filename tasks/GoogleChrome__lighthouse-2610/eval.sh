#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5c8d4ec7cd23fa84da485261427197d89e757921
git checkout 5c8d4ec7cd23fa84da485261427197d89e757921 lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js b/lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
index fa53dc291089..5260249c4fe2 100644
--- a/lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
+++ b/lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
@@ -30,7 +30,7 @@ const DETAILS = {
         responseReceivedTime: 5,
         startTime: 0,
         url: 'https://example.com/',
-        transferSize: 1
+        transferSize: 1000
       },
       children: {
         1: {
@@ -39,7 +39,7 @@ const DETAILS = {
             responseReceivedTime: 14,
             startTime: 11,
             url: 'https://example.com/b.js',
-            transferSize: 1
+            transferSize: 2000
           },
           children: {}
         },
@@ -49,7 +49,7 @@ const DETAILS = {
             responseReceivedTime: 15,
             startTime: 12,
             url: superLongURL,
-            transferSize: 1
+            transferSize: 3000
           },
           children: {}
         },
@@ -59,7 +59,7 @@ const DETAILS = {
             responseReceivedTime: 16,
             startTime: 13,
             url: 'about:blank',
-            transferSize: 1
+            transferSize: 4000
           },
           children: {}
         }
@@ -92,37 +92,19 @@ describe('DetailsRenderer', () => {
     const el = CriticalRequestChainRenderer.render(dom, dom.document(), DETAILS);
     const details = el.querySelector('.lh-details');
     const chains = details.querySelectorAll('.crc-node');
-    assert.equal(chains.length, 4, 'generates correct number of chain nodes');
 
-    const div = dom.createElement('div');
-    div.innerHTML = `<span class="crc-node__tree-marker">
-        <!-- fill me -->
-        <span class="tree-marker up-right"></span>
-        <span class="tree-marker right"></span>
-        <span class="tree-marker horiz-down"></span>
-      </span>
-      <span class="crc-node__tree-value">
-        <span class="crc-node__tree-file">/</span>
-        <span class="crc-node__tree-hostname">(example.com)</span>
-        <!-- fill me -->
-      </span>`;
-    assert.ok(chains[0].innerHTML, div.innerHTML);
+    // Main request
+    assert.equal(chains.length, 4, 'generates correct number of chain nodes');
+    assert.equal(chains[0].querySelector('.crc-node__tree-hostname').textContent, '(example.com)');
 
-    div.innerHTML = `<span class="crc-node__tree-marker">
-        <!-- fill me -->
-        <span class="tree-marker"></span>
-        <span class="tree-marker"></span>
-        <span class="tree-marker vert-right"></span>
-        <span class="tree-marker right"></span>
-        <span class="tree-marker right"></span>
-      </span>
-      <span class="crc-node__tree-value">
-        <span class="crc-node__tree-file">/b.js</span>
-        <span class="crc-node__tree-hostname">(example.com)</span>
-        <!-- fill me -->
-        <span class="crc-node__chain-duration"> - 5,000ms, </span>
-        <span class="crc-node__chain-duration">0KB</span>
-      </span>`;
-    assert.ok(chains[1].innerHTML, div.innerHTML);
+    // Children
+    assert.ok(chains[1].querySelector('.crc-node__tree-marker .vert-right'));
+    assert.equal(chains[1].querySelectorAll('.crc-node__tree-marker .right').length, 2);
+    assert.equal(chains[1].querySelector('.crc-node__tree-file').textContent, '/b.js');
+    assert.equal(chains[1].querySelector('.crc-node__tree-hostname').textContent, '(example.com)');
+    const durationNodes = chains[1].querySelectorAll('.crc-node__chain-duration');
+    assert.equal(durationNodes[0].textContent, ' - 5,000ms, ');
+    // Note: actual transferSize is 2000 bytes but formatter formats to KBs.
+    assert.equal(durationNodes[1].textContent, '1.95\xa0KB');
   });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --reporter json lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
: '>>>>> End Test Output'
git checkout 5c8d4ec7cd23fa84da485261427197d89e757921 lighthouse-core/test/report/v2/renderer/crc-details-renderer-test.js
