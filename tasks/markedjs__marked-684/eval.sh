#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 86214bbce13ab5f2cd5faac3adb5d31653be782e
rm -f test/new/adjacent_lists.html test/new/adjacent_lists.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/new/adjacent_lists.html b/test/new/adjacent_lists.html
new file mode 100644
index 0000000000..b4cd8f5086
--- /dev/null
+++ b/test/new/adjacent_lists.html
@@ -0,0 +1,9 @@
+<ul>
+<li>This should be</li>
+<li>An unordered list</li>
+</ul>
+
+<ol>
+<li>This should be</li>
+<li>An unordered list</li>
+</ol>
diff --git a/test/new/adjacent_lists.md b/test/new/adjacent_lists.md
new file mode 100644
index 0000000000..3fd460b3d7
--- /dev/null
+++ b/test/new/adjacent_lists.md
@@ -0,0 +1,5 @@
+* This should be
+* An unordered list
+
+1. This should be
+2. An unordered list

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/new/adjacent_lists.html test/new/adjacent_lists.md
