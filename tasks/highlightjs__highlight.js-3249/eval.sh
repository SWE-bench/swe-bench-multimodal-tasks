#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 19711d4258dc203df65e67f45a14a080d3e5d01c
git checkout 19711d4258dc203df65e67f45a14a080d3e5d01c test/markup/latex/comments.expect.txt test/markup/latex/comments.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/latex/comments.expect.txt b/test/markup/latex/comments.expect.txt
index 69290f0496..abff4e9f73 100644
--- a/test/markup/latex/comments.expect.txt
+++ b/test/markup/latex/comments.expect.txt
@@ -2,3 +2,10 @@
 foo<span class="hljs-comment">%</span>
 <span class="hljs-meta">% !TeX program = pdflatex</span>
 <span class="hljs-comment">%% !TeX encoding = utf8</span>
+<span class="hljs-meta">%!TEX spellcheck = en-US</span>
+<span class="hljs-comment">%  !TeX foo</span>
+<span class="hljs-meta">% !tex foo</span>
+<span class="hljs-comment">% !tEx foo</span>
+<span class="hljs-meta">% !BIB foo</span>
+<span class="hljs-meta">%!bib foo</span>
+<span class="hljs-comment">% !Bib foo</span>
diff --git a/test/markup/latex/comments.txt b/test/markup/latex/comments.txt
index c12ec09044..2aa4c51ed1 100644
--- a/test/markup/latex/comments.txt
+++ b/test/markup/latex/comments.txt
@@ -2,3 +2,10 @@
 foo%
 % !TeX program = pdflatex
 %% !TeX encoding = utf8
+%!TEX spellcheck = en-US
+%  !TeX foo
+% !tex foo
+% !tEx foo
+% !BIB foo
+%!bib foo
+% !Bib foo

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 19711d4258dc203df65e67f45a14a080d3e5d01c test/markup/latex/comments.expect.txt test/markup/latex/comments.txt
