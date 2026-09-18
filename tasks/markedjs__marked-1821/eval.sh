#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 73f10d3a9a11657c08747095b58615e9cf9496e9
rm -f test/specs/new/del_strikethrough.html test/specs/new/del_strikethrough.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/del_strikethrough.html b/test/specs/new/del_strikethrough.html
new file mode 100644
index 0000000000..980134aa21
--- /dev/null
+++ b/test/specs/new/del_strikethrough.html
@@ -0,0 +1,16 @@
+<p><del>test</del></p>
+
+<p>~~test~</p>
+
+<p>~test~~</p>
+
+<p><del>test</del></p>
+
+<p><del>test
+test</del></p>
+
+<p>~~test</p>
+
+<p>test~~</p>
+
+<pre><code class="language-test~~~"></code></pre>
diff --git a/test/specs/new/del_strikethrough.md b/test/specs/new/del_strikethrough.md
new file mode 100644
index 0000000000..f3d5bca081
--- /dev/null
+++ b/test/specs/new/del_strikethrough.md
@@ -0,0 +1,16 @@
+~~test~~
+
+~~test~
+
+~test~~
+
+~test~
+
+~~test
+test~~
+
+~~test
+
+test~~
+
+~~~test~~~

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/specs/new/del_strikethrough.html test/specs/new/del_strikethrough.md
