#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 2df12a7f2a0544a979efc49ab9ee4407354002eb
rm -f test/specs/new/list_loose_tasks.html test/specs/new/list_loose_tasks.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/list_loose_tasks.html b/test/specs/new/list_loose_tasks.html
new file mode 100644
index 0000000000..ae4e8c58b2
--- /dev/null
+++ b/test/specs/new/list_loose_tasks.html
@@ -0,0 +1,12 @@
+<ul>
+<li>
+<p>Tasks</p>
+</li>
+<li>
+<p><input type="checkbox" checked="" disabled=""> Task1</p>
+</li>
+<li>
+<p><input type="checkbox" disabled=""></p>
+<pre>Task2</pre>
+</li>
+</ul>
diff --git a/test/specs/new/list_loose_tasks.md b/test/specs/new/list_loose_tasks.md
new file mode 100644
index 0000000000..cb1cab5b0d
--- /dev/null
+++ b/test/specs/new/list_loose_tasks.md
@@ -0,0 +1,4 @@
+- Tasks
+- [x] Task1
+
+- [ ] <pre>Task2</pre>

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/specs/new/list_loose_tasks.html test/specs/new/list_loose_tasks.md
