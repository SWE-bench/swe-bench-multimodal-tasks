#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 6c4bfeec80fcdd4f72541313bc3d994d707cbed0
git checkout 6c4bfeec80fcdd4f72541313bc3d994d707cbed0 lighthouse-core/test/audits/font-display-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/lighthouse-core/test/audits/font-display-test.js b/lighthouse-core/test/audits/font-display-test.js
index 2958d925c67c..2aca05b98821 100644
--- a/lighthouse-core/test/audits/font-display-test.js
+++ b/lighthouse-core/test/audits/font-display-test.js
@@ -301,7 +301,8 @@ describe('Performance: Font Display audit', () => {
     expect(result.details.items).toEqual([]);
     expect(result.score).toEqual(1);
     expect(result.warnings).toHaveLength(1);
-    expect(result.warnings[0]).toBeDisplayString(/font-0.woff/);
+    expect(result.warnings[0])
+      .toBeDisplayString(/value for the origin https:\/\/example\.com\.$/);
   });
 
   it('should handle mixed content', async () => {
@@ -335,6 +336,40 @@ describe('Performance: Font Display audit', () => {
     }]);
     expect(result.score).toEqual(0);
     expect(result.warnings).toHaveLength(1);
-    expect(result.warnings[0]).toBeDisplayString(/font-1.woff/);
+    expect(result.warnings[0])
+      .toBeDisplayString(/value for the origin https:\/\/example\.com\.$/);
+  });
+
+  it('should dedupe warnings by origin when there are multiple uncheckable fonts', async () => {
+    stylesheet.content = ``;
+
+    networkRecords = [{
+      url: 'https://example.com/foo/bar/font-a.woff',
+      endTime: 3, startTime: 1,
+      resourceType: 'Font',
+    }, {
+      url: 'https://example.com/foo/font-b.woff',
+      endTime: 5, startTime: 1,
+      resourceType: 'Font',
+    }, {
+      url: 'https://example.com/foo/bar/font.woff',
+      endTime: 2, startTime: 1,
+      resourceType: 'Font',
+    }, {
+      url: 'https://fonts.gstatic.com/s/would-you-look-at-this-font.woff2',
+      endTime: 7, startTime: 1,
+      resourceType: 'Font',
+    }];
+
+    const result = await FontDisplayAudit.audit(getArtifacts(), context);
+    expect(result.details.items).toHaveLength(0);
+    expect(result.score).toEqual(1);
+
+    expect(result.warnings).toHaveLength(2);
+    expect(result.warnings[0])
+      // Plural 'values' for multiple fonts.
+      .toBeDisplayString(/values for the origin https:\/\/example\.com\.$/);
+    expect(result.warnings[1])
+      .toBeDisplayString(/value for the origin https:\/\/fonts\.gstatic\.com\.$/);
   });
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn jest --no-colors lighthouse-core/test/audits/font-display-test.js
: '>>>>> End Test Output'
git checkout 6c4bfeec80fcdd4f72541313bc3d994d707cbed0 lighthouse-core/test/audits/font-display-test.js
