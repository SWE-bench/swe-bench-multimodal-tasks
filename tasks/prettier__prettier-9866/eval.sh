#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 892a70e0d3011349155d2f82d56a99532f23fd19
git checkout 892a70e0d3011349155d2f82d56a99532f23fd19 tests/jsx/whitespace/jsfmt.spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/jsx/whitespace/jsfmt.spec.js b/tests/jsx/whitespace/jsfmt.spec.js
index 9d5fc32cf19e..e3e838ef6a4e 100644
--- a/tests/jsx/whitespace/jsfmt.spec.js
+++ b/tests/jsx/whitespace/jsfmt.spec.js
@@ -70,6 +70,18 @@ run_spec(
           );
         `,
       },
+      {
+        code: outdent`
+          <p>
+            <span />\u3000{this.props.data.title}\u3000<span />
+          </p>
+        `,
+        output: outdent`
+          <p>
+            <span />\u3000{this.props.data.title}\u3000<span />
+          </p>;
+        `,
+      },
     ].map((test) => ({ ...test, output: test.output + "\n" })),
   },
   ["flow", "typescript"]

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests/jsx/whitespace/jsfmt.spec.js
: '>>>>> End Test Output'
git checkout 892a70e0d3011349155d2f82d56a99532f23fd19 tests/jsx/whitespace/jsfmt.spec.js
