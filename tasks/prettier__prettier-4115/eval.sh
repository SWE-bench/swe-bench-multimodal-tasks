#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f6f6f2e2eaa8d784ddb54e9219416e37cc3b94ec
git checkout f6f6f2e2eaa8d784ddb54e9219416e37cc3b94ec tests/markdown_html/__snapshots__/jsfmt.spec.js.snap tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap && rm -f tests/markdown_html/multiline.md
git apply -v - <<'EOF_114329324912'
diff --git a/tests/markdown_html/__snapshots__/jsfmt.spec.js.snap b/tests/markdown_html/__snapshots__/jsfmt.spec.js.snap
index ab27b98f9605..9b031dee39cf 100644
--- a/tests/markdown_html/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/markdown_html/__snapshots__/jsfmt.spec.js.snap
@@ -1,5 +1,56 @@
 // Jest Snapshot v1, https://goo.gl/fbAQLP
 
+exports[`multiline.md 1`] = `
+1.  Some test text, the goal is to have the html table below nested within this number. When formating on save Prettier will continue to add an indent each time pushing the table further and further out of sync. 
+
+    <table class="table table-striped">
+    <tr>
+    <th>Test</th>
+    <th>Table</th>
+    </tr>
+    <tbody>
+        <tr>
+        <td>will</td>
+        <td>be</td>
+        </tr>
+        <tr>
+        <td>pushed</td>
+        <td>When</td>
+        </tr>
+        <tr>
+        <td>Format on</td>
+        <td>Save</td>
+        </tr>
+    </tbody>
+    </table>
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+1.  Some test text, the goal is to have the html table below nested within this
+    number. When formating on save Prettier will continue to add an indent each
+    time pushing the table further and further out of sync.
+
+    <table class="table table-striped">
+    <tr>
+    <th>Test</th>
+    <th>Table</th>
+    </tr>
+    <tbody>
+        <tr>
+        <td>will</td>
+        <td>be</td>
+        </tr>
+        <tr>
+        <td>pushed</td>
+        <td>When</td>
+        </tr>
+        <tr>
+        <td>Format on</td>
+        <td>Save</td>
+        </tr>
+    </tbody>
+    </table>
+
+`;
+
 exports[`simple.md 1`] = `
 <!-- hello world -->
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
diff --git a/tests/markdown_html/multiline.md b/tests/markdown_html/multiline.md
new file mode 100644
index 000000000000..16716e4d76ec
--- /dev/null
+++ b/tests/markdown_html/multiline.md
@@ -0,0 +1,22 @@
+1.  Some test text, the goal is to have the html table below nested within this number. When formating on save Prettier will continue to add an indent each time pushing the table further and further out of sync. 
+
+    <table class="table table-striped">
+    <tr>
+    <th>Test</th>
+    <th>Table</th>
+    </tr>
+    <tbody>
+        <tr>
+        <td>will</td>
+        <td>be</td>
+        </tr>
+        <tr>
+        <td>pushed</td>
+        <td>When</td>
+        </tr>
+        <tr>
+        <td>Format on</td>
+        <td>Save</td>
+        </tr>
+    </tbody>
+    </table>
diff --git a/tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap b/tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap
index 620b215f8a8f..718b77ee05a4 100644
--- a/tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap
@@ -1540,7 +1540,7 @@ exports[`example-138.md 1`] = `
 bar
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 > <div>
-foo
+> foo
 
 bar
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests ; yarn test tests/markdown_html/ ; yarn test tests/markdown_spec/
: '>>>>> End Test Output'
git checkout f6f6f2e2eaa8d784ddb54e9219416e37cc3b94ec tests/markdown_html/__snapshots__/jsfmt.spec.js.snap tests/markdown_spec/__snapshots__/jsfmt.spec.js.snap && rm -f tests/markdown_html/multiline.md
