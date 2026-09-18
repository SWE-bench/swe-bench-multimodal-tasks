#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9106e7ea1353a2f7c03026f939d540206620f66f
git checkout 9106e7ea1353a2f7c03026f939d540206620f66f tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap tests/format/js/switch/comments.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap b/tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap
index de7eb21716a1..9a4cf4dcab80 100644
--- a/tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap
@@ -30,6 +30,41 @@ switch(x) {
   }
 }
 
+switch(x) {
+  default: // comment
+    break;
+}
+
+switch(x) {
+  default: // comment
+    {break;}
+}
+
+switch(x) {
+  default: {// comment
+    break;}
+}
+
+switch(x) {
+  default: /* comment */
+    break;
+}
+
+switch(x) {
+  default: /* comment */
+    {break;}
+}
+
+switch(x) {
+  default: {/* comment */
+    break;}
+}
+
+switch(x) {
+  default: /* comment */ {
+    break;}
+}
+
 =====================================output=====================================
 switch (true) {
   case true:
@@ -55,6 +90,49 @@ switch (x) {
   }
 }
 
+switch (x) {
+  default: // comment
+    break;
+}
+
+switch (x) {
+  default: {
+    // comment
+    break;
+  }
+}
+
+switch (x) {
+  default: {
+    // comment
+    break;
+  }
+}
+
+switch (x) {
+  default: /* comment */
+    break;
+}
+
+switch (x) {
+  default: /* comment */ {
+    break;
+  }
+}
+
+switch (x) {
+  default: {
+    /* comment */
+    break;
+  }
+}
+
+switch (x) {
+  default: /* comment */ {
+    break;
+  }
+}
+
 ================================================================================
 `;
 
diff --git a/tests/format/js/switch/comments.js b/tests/format/js/switch/comments.js
index d91b1e9edc7c..42dceadbbac9 100644
--- a/tests/format/js/switch/comments.js
+++ b/tests/format/js/switch/comments.js
@@ -21,3 +21,38 @@ switch(x) {
   case y: {
   }
 }
+
+switch(x) {
+  default: // comment
+    break;
+}
+
+switch(x) {
+  default: // comment
+    {break;}
+}
+
+switch(x) {
+  default: {// comment
+    break;}
+}
+
+switch(x) {
+  default: /* comment */
+    break;
+}
+
+switch(x) {
+  default: /* comment */
+    {break;}
+}
+
+switch(x) {
+  default: {/* comment */
+    break;}
+}
+
+switch(x) {
+  default: /* comment */ {
+    break;}
+}

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests/format/js/switch ; yarn test tests/format/js/switch/
: '>>>>> End Test Output'
git checkout 9106e7ea1353a2f7c03026f939d540206620f66f tests/format/js/switch/__snapshots__/jsfmt.spec.js.snap tests/format/js/switch/comments.js
