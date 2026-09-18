#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 8cfa29ccd2a2759e8e60fe0d8d6df8c022beda4e
rm -f test/specs/new/image_links.html test/specs/new/image_links.md
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/new/image_links.html b/test/specs/new/image_links.html
new file mode 100644
index 0000000000..3f2828c536
--- /dev/null
+++ b/test/specs/new/image_links.html
@@ -0,0 +1,11 @@
+<p>
+	<a href="https://example.com/">
+		<img src="https://example.com/image.jpg" alt="test" title="title" />
+	</a>
+</p>
+
+<p>
+	<a href="https://example.com/">
+		<img src="https://example.com/image.jpg" alt="[test]" title="[title]" />
+	</a>
+</p>
diff --git a/test/specs/new/image_links.md b/test/specs/new/image_links.md
new file mode 100644
index 0000000000..109603266e
--- /dev/null
+++ b/test/specs/new/image_links.md
@@ -0,0 +1,3 @@
+[![test](https://example.com/image.jpg "title")](https://example.com/)
+
+[![\[test\]](https://example.com/image.jpg "[title]")](https://example.com/)

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
rm -f test/specs/new/image_links.html test/specs/new/image_links.md
