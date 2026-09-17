#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f55960af898af617ba3544ee03c5344abc77e7a0
git checkout f55960af898af617ba3544ee03c5344abc77e7a0 tests/js/directives/jsfmt.spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/js/directives/jsfmt.spec.js b/tests/js/directives/jsfmt.spec.js
index eb85eda6bd02..f5b37cd79521 100644
--- a/tests/js/directives/jsfmt.spec.js
+++ b/tests/js/directives/jsfmt.spec.js
@@ -1,1 +1,48 @@
-run_spec(__dirname, ["babel", "flow", "typescript"]);
+const { outdent } = require("outdent");
+
+run_spec(
+  {
+    dirname: __dirname,
+    snippets: [
+      {
+        code: outdent`
+          'use strict';
+
+          // comment
+        `,
+        output:
+          outdent`
+            "use strict";
+
+            // comment
+          ` + "\n",
+      },
+      {
+        code: outdent`
+          'use strict';
+          // comment
+        `,
+        output:
+          outdent`
+            "use strict";
+            // comment
+          ` + "\n",
+      },
+      {
+        code:
+          outdent`
+            'use strict';
+
+            // comment
+          ` + "\n",
+        output:
+          outdent`
+            "use strict";
+
+            // comment
+          ` + "\n",
+      },
+    ],
+  },
+  ["babel", "flow", "typescript"]
+);

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests/js/directives/jsfmt.spec.js
: '>>>>> End Test Output'
git checkout f55960af898af617ba3544ee03c5344abc77e7a0 tests/js/directives/jsfmt.spec.js
