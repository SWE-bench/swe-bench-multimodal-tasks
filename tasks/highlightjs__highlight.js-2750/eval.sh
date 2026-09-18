#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 7e6d53db5f15882d8364c83b0e1d97f268a2d284
git checkout 7e6d53db5f15882d8364c83b0e1d97f268a2d284 test/markup/javascript/inline-languages.expect.txt test/markup/typescript/inline-languages.expect.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/javascript/inline-languages.expect.txt b/test/markup/javascript/inline-languages.expect.txt
index 370f041a57..d9c1d31305 100644
--- a/test/markup/javascript/inline-languages.expect.txt
+++ b/test/markup/javascript/inline-languages.expect.txt
@@ -10,7 +10,7 @@ html`<span class="xml">
   <span class="hljs-tag">&lt;<span class="hljs-name">ul</span> <span class="hljs-attr">id</span>=<span class="hljs-string">&quot;list&quot;</span>&gt;</span>
     </span><span class="hljs-subst">${repeat([<span class="hljs-string">&#x27;a&#x27;</span>, <span class="hljs-string">&#x27;b&#x27;</span>, <span class="hljs-string">&#x27;c&#x27;</span>], (v) =&gt; {
       <span class="hljs-keyword">return</span> html`<span class="xml"><span class="hljs-tag">&lt;<span class="hljs-name">li</span> <span class="hljs-attr">class</span>=<span class="hljs-string">&quot;item&quot;</span>&gt;</span></span><span class="hljs-subst">${v}</span><span class="xml"><span class="hljs-tag">&lt;/<span class="hljs-name">li</span>&gt;</span>`</span>;
-    }</span><span class="xml">}
+    }}</span><span class="xml">
   <span class="hljs-tag">&lt;/<span class="hljs-name">ul</span>&gt;</span>
 `</span>;
 
diff --git a/test/markup/typescript/inline-languages.expect.txt b/test/markup/typescript/inline-languages.expect.txt
index 27e2c8f3cb..1ae73fefe0 100644
--- a/test/markup/typescript/inline-languages.expect.txt
+++ b/test/markup/typescript/inline-languages.expect.txt
@@ -10,7 +10,7 @@ html`<span class="xml">
   <span class="hljs-tag">&lt;<span class="hljs-name">ul</span> <span class="hljs-attr">id</span>=<span class="hljs-string">&quot;list&quot;</span>&gt;</span>
     </span><span class="hljs-subst">${repeat([<span class="hljs-string">&#x27;a&#x27;</span>, <span class="hljs-string">&#x27;b&#x27;</span>, <span class="hljs-string">&#x27;c&#x27;</span>], (v) =&gt; {
       <span class="hljs-keyword">return</span> html`<span class="xml"><span class="hljs-tag">&lt;<span class="hljs-name">li</span> <span class="hljs-attr">class</span>=<span class="hljs-string">&quot;item&quot;</span>&gt;</span></span><span class="hljs-subst">${v}</span><span class="xml"><span class="hljs-tag">&lt;/<span class="hljs-name">li</span>&gt;</span>`</span>;
-    }</span><span class="xml">}
+    }}</span><span class="xml">
   <span class="hljs-tag">&lt;/<span class="hljs-name">ul</span>&gt;</span>
 `</span>;
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 7e6d53db5f15882d8364c83b0e1d97f268a2d284 test/markup/javascript/inline-languages.expect.txt test/markup/typescript/inline-languages.expect.txt
