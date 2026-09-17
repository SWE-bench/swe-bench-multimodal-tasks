#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 5c3ac8ed3c1d8f4b8f4cd82d7c5d79d88de26ec5
git checkout 5c3ac8ed3c1d8f4b8f4cd82d7c5d79d88de26ec5 tests/lib/rules/indent.js
git apply -v - <<'EOF_114329324912'
diff --git a/tests/lib/rules/indent.js b/tests/lib/rules/indent.js
index e655f3f0087..1d62177921f 100644
--- a/tests/lib/rules/indent.js
+++ b/tests/lib/rules/indent.js
@@ -4653,6 +4653,44 @@ ruleTester.run("indent", rule, {
                     </span>
                 )
             `
+        },
+        {
+            code: unIndent`
+                <div>
+                    {
+                        /* foo */
+                    }
+                </div>
+            `
+        },
+
+        // https://github.com/eslint/eslint/issues/8832
+        {
+            code: unIndent`
+                <div>
+                    {
+                        (
+                            1
+                        )
+                    }
+                </div>
+            `
+        },
+        {
+            code: unIndent`
+                function A() {
+                    return (
+                        <div>
+                            {
+                                b && (
+                                    <div>
+                                    </div>
+                                )
+                            }
+                        </div>
+                    );
+                }
+            `
         }
     ],
 
@@ -8801,6 +8839,44 @@ ruleTester.run("indent", rule, {
                 )
             `,
             errors: expectedErrors([[5, 4, 8, "Punctuator"], [6, 4, 8, "Punctuator"], [7, 0, 4, "Punctuator"]])
+        },
+        {
+            code: unIndent`
+                <div>
+                    {
+                    (
+                        1
+                    )
+                    }
+                </div>
+            `,
+            output: unIndent`
+                <div>
+                    {
+                        (
+                            1
+                        )
+                    }
+                </div>
+            `,
+            errors: expectedErrors([[3, 8, 4, "Punctuator"], [4, 12, 8, "Numeric"], [5, 8, 4, "Punctuator"]])
+        },
+        {
+            code: unIndent`
+                <div>
+                    {
+                      /* foo */
+                    }
+                </div>
+            `,
+            output: unIndent`
+                <div>
+                    {
+                        /* foo */
+                    }
+                </div>
+            `,
+            errors: expectedErrors([3, 8, 6, "Block"])
         }
     ]
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"
: '>>>>> End Test Output'
git checkout 5c3ac8ed3c1d8f4b8f4cd82d7c5d79d88de26ec5 tests/lib/rules/indent.js
