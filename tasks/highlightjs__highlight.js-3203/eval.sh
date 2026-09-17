#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 50a680877b2777ce2fe30f083037652f9decb5c9
rm -f test/markup/powershell/flags.expect.txt test/markup/powershell/flags.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/powershell/flags.expect.txt b/test/markup/powershell/flags.expect.txt
new file mode 100644
index 0000000000..c1c2ecefe1
--- /dev/null
+++ b/test/markup/powershell/flags.expect.txt
@@ -0,0 +1,4 @@
+<span class="hljs-string">&quot;Good Dog&quot;</span> <span class="hljs-literal">--match-lower-case</span> <span class="hljs-string">&quot;Dog&quot;</span>
+<span class="hljs-number">2</span> <span class="hljs-literal">--equality-check</span> <span class="hljs-number">2</span>
+<span class="hljs-string">&quot;abc&quot;</span> <span class="hljs-literal">--format-drive-fully</span> <span class="hljs-string">&quot;def&quot;</span>
+format /dev/devices/driveA <span class="hljs-literal">--format-drive-fully</span> <span class="hljs-literal">-yes</span>
\ No newline at end of file
diff --git a/test/markup/powershell/flags.txt b/test/markup/powershell/flags.txt
new file mode 100644
index 0000000000..78c60e70f5
--- /dev/null
+++ b/test/markup/powershell/flags.txt
@@ -0,0 +1,4 @@
+"Good Dog" --match-lower-case "Dog"
+2 --equality-check 2
+"abc" --format-drive-fully "def"
+format /dev/devices/driveA --format-drive-fully -yes
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/powershell/flags.expect.txt test/markup/powershell/flags.txt
