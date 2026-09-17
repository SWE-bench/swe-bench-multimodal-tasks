#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 909fb792eeb3c577123b12e4628c6e1ca8707de2
git checkout 909fb792eeb3c577123b12e4628c6e1ca8707de2 tests/configure-test-env.sh tests/unit/confluence.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/configure-test-env.sh b/tests/configure-test-env.sh
index 0ef8a95c2b..40c465cf37 100755
--- a/tests/configure-test-env.sh
+++ b/tests/configure-test-env.sh
@@ -17,7 +17,7 @@ python_exists=$(command -v python)
 if [ -z $python_exists ] 
 then 
   python_exists=$(command -v python3)
-  if [ -z python_exists] 
+  if [ -z python_exists]
   then
     echo "No python found in PATH - Check your PATH or install python add to PATH."
   fi
diff --git a/tests/unit/confluence.test.ts b/tests/unit/confluence.test.ts
index 2e728dec48..ff1e670ef4 100644
--- a/tests/unit/confluence.test.ts
+++ b/tests/unit/confluence.test.ts
@@ -3741,7 +3741,7 @@ const runUpdateLinks = () => {
     fileName: "release-planning.xml",
   };
 
-  const UPDATE_LINKS_INDEX: ContentUpdate = {
+  const UPDATE_LINK_TO_INDEX: ContentUpdate = {
     contentChangeType: ContentChangeType.update,
     id: "19890228",
     version: null,
@@ -3758,6 +3758,23 @@ const runUpdateLinks = () => {
     fileName: "release-planning.xml",
   };
 
+  const UPDATE_SELF_LINK_FROM_INDEX: ContentUpdate = {
+    contentChangeType: ContentChangeType.update,
+    id: "fake-folder-id",
+    version: null,
+    title: "fake-folder-title",
+    type: "page",
+    status: "current",
+    ancestors: [{ id: "19759105" }],
+    body: {
+      storage: {
+        value: "<a href='index.qmd'>self</a>",
+        representation: "storage",
+      },
+    },
+    fileName: "folder",
+  };
+
   const UPDATE_LINKS_SPECIAL_CHAR: ContentUpdate = {
     contentChangeType: ContentChangeType.update,
     id: "19890228",
@@ -3918,10 +3935,10 @@ const runUpdateLinks = () => {
   });
 
   test(suiteLabel("one_update_link_index"), async () => {
-    const changes: ConfluenceSpaceChange[] = [UPDATE_LINKS_INDEX];
+    const changes: ConfluenceSpaceChange[] = [UPDATE_LINK_TO_INDEX];
     const rootURL = "fake-server/wiki/spaces/QUARTOCONF/pages";
     const expectedUpdate: ContentUpdate = {
-      ...UPDATE_LINKS_INDEX,
+      ...UPDATE_LINK_TO_INDEX,
       body: {
         storage: {
           value: `<a href=\'fake-server/wiki/spaces/QUARTOCONF/pages/fake-folder-id'>team</a>`,
@@ -3933,6 +3950,22 @@ const runUpdateLinks = () => {
     check(expected, changes, fileMetadataTable, "fake-server", FAKE_PARENT);
   });
 
+  test(suiteLabel("one_update_link_from_index"), async () => {
+    const changes: ConfluenceSpaceChange[] = [UPDATE_SELF_LINK_FROM_INDEX];
+    const rootURL = "fake-server/wiki/spaces/QUARTOCONF/pages";
+    const expectedUpdate: ContentUpdate = {
+      ...UPDATE_SELF_LINK_FROM_INDEX,
+      body: {
+        storage: {
+          value: `<a href=\'fake-server/wiki/spaces/QUARTOCONF/pages/fake-index-id'>self</a>`,
+          representation: "storage",
+        },
+      },
+    };
+    const expected: ConfluenceSpaceChange[] = [expectedUpdate];
+    check(expected, changes, fileMetadataTable, "fake-server", FAKE_PARENT);
+  });
+
   test(suiteLabel("one_update_link_special_char"), async () => {
     const changes: ConfluenceSpaceChange[] = [UPDATE_LINKS_SPECIAL_CHAR];
     const rootURL = "fake-server/wiki/spaces/QUARTOCONF/pages";

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout 909fb792eeb3c577123b12e4628c6e1ca8707de2 tests/configure-test-env.sh tests/unit/confluence.test.ts
