#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e2373206bcb72c1896f4ade48984d4317c1ee72c
git checkout e2373206bcb72c1896f4ade48984d4317c1ee72c tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap && rm -f tests/multiparser_markdown_js/markdown-preview-enhanced.md
git apply -v - <<'EOF_114329324912'
diff --git a/tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap b/tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap
index c589b54c6b37..d53c85a951c4 100644
--- a/tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap
+++ b/tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap
@@ -29,6 +29,33 @@ const Foo = () => {
 
 `;
 
+exports[`markdown-preview-enhanced.md 1`] = `
+## plain js block
+
+\`\`\`js   
+console.log(     "hello world"   );
+\`\`\`
+
+## js block with arguments
+
+\`\`\`js {cmd=node .line-numbers}
+console.log(     "hello world"   );
+\`\`\`
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+## plain js block
+
+\`\`\`js
+console.log("hello world");
+\`\`\`
+
+## js block with arguments
+
+\`\`\`js {cmd=node .line-numbers}
+console.log("hello world");
+\`\`\`
+
+`;
+
 exports[`trailing-comma.md 1`] = `
 ### Some heading
 
diff --git a/tests/multiparser_markdown_js/markdown-preview-enhanced.md b/tests/multiparser_markdown_js/markdown-preview-enhanced.md
new file mode 100644
index 000000000000..34f8f3600d4d
--- /dev/null
+++ b/tests/multiparser_markdown_js/markdown-preview-enhanced.md
@@ -0,0 +1,11 @@
+## plain js block
+
+```js   
+console.log(     "hello world"   );
+```
+
+## js block with arguments
+
+```js {cmd=node .line-numbers}
+console.log(     "hello world"   );
+```

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test tests ; yarn test tests/multiparser_markdown_js/
: '>>>>> End Test Output'
git checkout e2373206bcb72c1896f4ade48984d4317c1ee72c tests/multiparser_markdown_js/__snapshots__/jsfmt.spec.js.snap && rm -f tests/multiparser_markdown_js/markdown-preview-enhanced.md
