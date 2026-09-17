#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b26f56bd316a3ed11c33f50cd4a3dac44a4ee529
git checkout b26f56bd316a3ed11c33f50cd4a3dac44a4ee529 tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap && rm -f tests/format/misc/embedded_language_formatting/in-markdown/issue-16342.md
git apply -v - <<'EOF_114329324912'
diff --git a/tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap b/tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap
index 7809e8056f07..00d8b5b1ce36 100644
--- a/tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap
+++ b/tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap
@@ -106,6 +106,71 @@ Hello world!
 ================================================================================
 `;
 
+exports[`issue-16342.md - {"embeddedLanguageFormatting":"off"} format 1`] = `
+====================================options=====================================
+embeddedLanguageFormatting: "off"
+parsers: ["markdown"]
+printWidth: 80
+                                                                                | printWidth
+=====================================input======================================
+---
+foo:
+  - bar1
+
+  - bar2
+
+  - bar3
+---
+
+Markdown
+
+=====================================output=====================================
+---
+foo:
+  - bar1
+
+  - bar2
+
+  - bar3
+---
+
+Markdown
+
+================================================================================
+`;
+
+exports[`issue-16342.md format 1`] = `
+====================================options=====================================
+parsers: ["markdown"]
+printWidth: 80
+                                                                                | printWidth
+=====================================input======================================
+---
+foo:
+  - bar1
+
+  - bar2
+
+  - bar3
+---
+
+Markdown
+
+=====================================output=====================================
+---
+foo:
+  - bar1
+
+  - bar2
+
+  - bar3
+---
+
+Markdown
+
+================================================================================
+`;
+
 exports[`test.md - {"embeddedLanguageFormatting":"off"} format 1`] = `
 ====================================options=====================================
 embeddedLanguageFormatting: "off"
diff --git a/tests/format/misc/embedded_language_formatting/in-markdown/issue-16342.md b/tests/format/misc/embedded_language_formatting/in-markdown/issue-16342.md
new file mode 100644
index 000000000000..bfad81ff8974
--- /dev/null
+++ b/tests/format/misc/embedded_language_formatting/in-markdown/issue-16342.md
@@ -0,0 +1,10 @@
+---
+foo:
+  - bar1
+
+  - bar2
+
+  - bar3
+---
+
+Markdown

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests/format/misc/embedded_language_formatting ; yarn test tests/format/misc/embedded_language_formatting/in-markdown/
: '>>>>> End Test Output'
git checkout b26f56bd316a3ed11c33f50cd4a3dac44a4ee529 tests/format/misc/embedded_language_formatting/in-markdown/__snapshots__/format.test.js.snap && rm -f tests/format/misc/embedded_language_formatting/in-markdown/issue-16342.md
