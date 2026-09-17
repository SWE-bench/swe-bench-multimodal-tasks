#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 62ede8b710731228dddc8e900fe99e5d3cc487a8
git checkout 62ede8b710731228dddc8e900fe99e5d3cc487a8 tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap && rm -f tests/format/typescript/tuple/trailing-comma-for-empty-tuples.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap b/tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap
index 9681ac3ce717..e2c610475a59 100644
--- a/tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap
@@ -208,6 +208,71 @@ export interface ShopQueryResult {
 ================================================================================
 `;
 
+exports[`trailing-comma-for-empty-tuples.ts - {"trailingComma":"all"} format 1`] = `
+====================================options=====================================
+parsers: ["typescript"]
+printWidth: 80
+trailingComma: "all"
+                                                                                | printWidth
+=====================================input======================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong = []
+
+type Foo = Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends [] ? Foo3 : Foo4;
+=====================================output=====================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong =
+  [];
+
+type Foo =
+  Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends []
+    ? Foo3
+    : Foo4;
+
+================================================================================
+`;
+
+exports[`trailing-comma-for-empty-tuples.ts - {"trailingComma":"none"} format 1`] = `
+====================================options=====================================
+parsers: ["typescript"]
+printWidth: 80
+trailingComma: "none"
+                                                                                | printWidth
+=====================================input======================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong = []
+
+type Foo = Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends [] ? Foo3 : Foo4;
+=====================================output=====================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong =
+  [];
+
+type Foo =
+  Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends []
+    ? Foo3
+    : Foo4;
+
+================================================================================
+`;
+
+exports[`trailing-comma-for-empty-tuples.ts format 1`] = `
+====================================options=====================================
+parsers: ["typescript"]
+printWidth: 80
+                                                                                | printWidth
+=====================================input======================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong = []
+
+type Foo = Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends [] ? Foo3 : Foo4;
+=====================================output=====================================
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong =
+  [];
+
+type Foo =
+  Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends []
+    ? Foo3
+    : Foo4;
+
+================================================================================
+`;
+
 exports[`tuple.ts - {"trailingComma":"all"} format 1`] = `
 ====================================options=====================================
 parsers: ["typescript"]
diff --git a/tests/format/typescript/tuple/trailing-comma-for-empty-tuples.ts b/tests/format/typescript/tuple/trailing-comma-for-empty-tuples.ts
new file mode 100644
index 000000000000..5c1b157251d7
--- /dev/null
+++ b/tests/format/typescript/tuple/trailing-comma-for-empty-tuples.ts
@@ -0,0 +1,3 @@
+type Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong = []
+
+type Foo = Foooooooooooooooooooooooooooooooooooooooooooooooooooooooooo extends [] ? Foo3 : Foo4;
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests/format/typescript/tuple ; yarn test tests/format/typescript/tuple/
: '>>>>> End Test Output'
git checkout 62ede8b710731228dddc8e900fe99e5d3cc487a8 tests/format/typescript/tuple/__snapshots__/jsfmt.spec.js.snap && rm -f tests/format/typescript/tuple/trailing-comma-for-empty-tuples.ts
