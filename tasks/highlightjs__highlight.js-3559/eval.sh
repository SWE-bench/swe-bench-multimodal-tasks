#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 998af68f0967bf4c50f5afef3b0ed55d47ec2647
git checkout 998af68f0967bf4c50f5afef3b0ed55d47ec2647 test/markup/kotlin/class.expect.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/kotlin/class.expect.txt b/test/markup/kotlin/class.expect.txt
index 583c2de7be..50936d3267 100644
--- a/test/markup/kotlin/class.expect.txt
+++ b/test/markup/kotlin/class.expect.txt
@@ -1,16 +1,16 @@
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">A</span> </span>{
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">A</span> {
 }
 
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">B</span></span>()
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">B</span>()
 
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">C</span></span>() {}
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">C</span>() {}
 
-<span class="hljs-keyword">public</span> <span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">D</span></span>
+<span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">D</span>
 
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">E1</span>&lt;<span class="hljs-type">T</span>&gt;</span>
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">E2</span>&lt;<span class="hljs-type">T, R</span>&gt;</span>
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">E3</span>&lt;<span class="hljs-type">T,R</span>&gt;</span>
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">E1</span>&lt;<span class="hljs-type">T</span>&gt;
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">E2</span>&lt;<span class="hljs-type">T, R</span>&gt;
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">E3</span>&lt;<span class="hljs-type">T,R</span>&gt;
 
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">F1</span> : <span class="hljs-type">A</span></span>
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">F2</span> : <span class="hljs-type">A</span>, <span class="hljs-type">B</span></span>
-<span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">F3</span> : <span class="hljs-type">A</span>&lt;<span class="hljs-type">T</span>&gt;</span>
\ No newline at end of file
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">F1</span> : <span class="hljs-type">A</span>
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">F2</span> : <span class="hljs-type">A</span>, <span class="hljs-type">B</span>
+<span class="hljs-keyword">class</span> <span class="hljs-title class_">F3</span> : <span class="hljs-type">A</span>&lt;<span class="hljs-type">T</span>&gt;
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 998af68f0967bf4c50f5afef3b0ed55d47ec2647 test/markup/kotlin/class.expect.txt
