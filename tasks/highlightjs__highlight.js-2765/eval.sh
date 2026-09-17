#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3cf2f759ba4edd01177c59ead908e5c404fb05df
rm -f test/markup/handlebars/if-else.expect.txt test/markup/handlebars/if-else.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/handlebars/if-else.expect.txt b/test/markup/handlebars/if-else.expect.txt
new file mode 100644
index 0000000000..6affde8339
--- /dev/null
+++ b/test/markup/handlebars/if-else.expect.txt
@@ -0,0 +1,7 @@
+<span class="hljs-template-tag">{{#<span class="hljs-name"><span class="hljs-builtin-name">if</span></span> this.userData.isLoaded}}</span><span class="xml">
+  </span><span class="hljs-template-variable">{{<span class="hljs-name">this.userData.value.userName</span>}}</span><span class="xml">
+</span><span class="hljs-template-tag">{{<span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> this.userData.isError}}</span><span class="xml">
+  Whoops, something went wrong!
+</span><span class="hljs-template-tag">{{<span class="hljs-keyword">else</span>}}</span><span class="xml">
+  Something else!
+</span><span class="hljs-template-tag">{{/<span class="hljs-name"><span class="hljs-builtin-name">if</span></span>}}</span>
\ No newline at end of file
diff --git a/test/markup/handlebars/if-else.txt b/test/markup/handlebars/if-else.txt
new file mode 100644
index 0000000000..5f7168aad6
--- /dev/null
+++ b/test/markup/handlebars/if-else.txt
@@ -0,0 +1,7 @@
+{{#if this.userData.isLoaded}}
+  {{this.userData.value.userName}}
+{{else if this.userData.isError}}
+  Whoops, something went wrong!
+{{else}}
+  Something else!
+{{/if}}
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/handlebars/if-else.expect.txt test/markup/handlebars/if-else.txt
