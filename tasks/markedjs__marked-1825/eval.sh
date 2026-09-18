#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff da071c9e408faceec944c0df4b8d4fac43c47d3d
rm -f test/specs/new/list_tasks_non_gfm.html test/specs/new/list_tasks_non_gfm.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/list_tasks_non_gfm.html b/test/specs/new/list_tasks_non_gfm.html
new file mode 100644
index 0000000000..dfa23220e1
--- /dev/null
+++ b/test/specs/new/list_tasks_non_gfm.html
@@ -0,0 +1,5 @@
+<ul>
+<li>[ ] A</li>
+<li>[x] B</li>
+<li>[ ] C</li>
+</ul>
diff --git a/test/specs/new/list_tasks_non_gfm.md b/test/specs/new/list_tasks_non_gfm.md
new file mode 100644
index 0000000000..b75875a679
--- /dev/null
+++ b/test/specs/new/list_tasks_non_gfm.md
@@ -0,0 +1,7 @@
+---
+gfm: false
+description: Task lists are ignored when not using GFM
+---
+- [ ] A
+- [x] B
+- [ ] C
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/specs/new/list_tasks_non_gfm.html test/specs/new/list_tasks_non_gfm.md
