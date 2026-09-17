#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f3a6cedd8e096a45b22fd503878858cd63d81672
git checkout f3a6cedd8e096a45b22fd503878858cd63d81672 tests/lib/rules/no-unused-vars.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/lib/rules/no-unused-vars.js b/tests/lib/rules/no-unused-vars.js
index 8ab2208f431..a966ebb101e 100644
--- a/tests/lib/rules/no-unused-vars.js
+++ b/tests/lib/rules/no-unused-vars.js
@@ -287,7 +287,13 @@ ruleTester.run("no-unused-vars", rule, {
         {
             code: "class Foo { set bar(UNUSED) {} } console.log(Foo)",
             parserOptions: { ecmaVersion: 6 }
-        }
+        },
+
+        // https://github.com/eslint/eslint/issues/8119
+        includeRestPropertyParser({
+            code: "(({a, ...rest}) => rest)",
+            options: [{ args: "all", ignoreRestSiblings: true }]
+        })
     ],
     invalid: [
         { code: "function foox() { return foox(); }", errors: [definedError("foox")] },
@@ -396,6 +402,13 @@ ruleTester.run("no-unused-vars", rule, {
             ]
         }),
 
+        // https://github.com/eslint/eslint/issues/8119
+        includeRestPropertyParser({
+            code: "(({a, ...rest}) => {})",
+            options: [{ args: "all", ignoreRestSiblings: true }],
+            errors: ["'rest' is defined but never used."]
+        }),
+
         // https://github.com/eslint/eslint/issues/3714
         {
             code: "/* global a$fooz,$foo */\na$fooz;",

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"
: '>>>>> End Test Output'
git checkout f3a6cedd8e096a45b22fd503878858cd63d81672 tests/lib/rules/no-unused-vars.js
