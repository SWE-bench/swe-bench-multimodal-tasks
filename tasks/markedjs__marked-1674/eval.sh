#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 0cd85983ce810c5f833c939cdf66b341dc2d6825
git checkout 0cd85983ce810c5f833c939cdf66b341dc2d6825 test/specs/new/list_loose_tasks.html test/specs/new/list_loose_tasks.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/list_loose_tasks.html b/test/specs/new/list_loose_tasks.html
index ae4e8c58b2..f7bc47eb1b 100644
--- a/test/specs/new/list_loose_tasks.html
+++ b/test/specs/new/list_loose_tasks.html
@@ -9,4 +9,7 @@
 <p><input type="checkbox" disabled=""></p>
 <pre>Task2</pre>
 </li>
+<li>
+<p><input type="checkbox" disabled=""></p>
+</li>
 </ul>
diff --git a/test/specs/new/list_loose_tasks.md b/test/specs/new/list_loose_tasks.md
index cb1cab5b0d..7ed70e1b6c 100644
--- a/test/specs/new/list_loose_tasks.md
+++ b/test/specs/new/list_loose_tasks.md
@@ -2,3 +2,5 @@
 - [x] Task1
 
 - [ ] <pre>Task2</pre>
+
+- [ ] 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout 0cd85983ce810c5f833c939cdf66b341dc2d6825 test/specs/new/list_loose_tasks.html test/specs/new/list_loose_tasks.md
