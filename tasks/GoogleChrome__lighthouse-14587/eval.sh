#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 3ccdb7ac55c0a41d87a1d611546e034260107167
git checkout 3ccdb7ac55c0a41d87a1d611546e034260107167 flow-report/test/sidebar/sidebar-test.tsx report/test/renderer/util-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/flow-report/test/sidebar/sidebar-test.tsx b/flow-report/test/sidebar/sidebar-test.tsx
index 66bdbca7c00d..92779ac32d19 100644
--- a/flow-report/test/sidebar/sidebar-test.tsx
+++ b/flow-report/test/sidebar/sidebar-test.tsx
@@ -58,11 +58,17 @@ describe('SidebarRuntimeSettings', () => {
         throughputKbps: 1.6 * 1024,
         rttMs: 150,
       },
-      screenEmulation: {disabled: true},
+      screenEmulation: {
+        disabled: false,
+        width: 200,
+        height: 200,
+        deviceScaleFactor: 3,
+        mobile: true,
+      },
     } as any;
     const root = render(<SidebarRuntimeSettings settings={settings}/>, {wrapper});
 
-    expect(root.getByText('Emulated Moto G4')).toBeTruthy();
+    expect(root.getByText('Emulated Moto G4 - 200x200, DPR 3')).toBeTruthy();
     expect(root.queryByText('Emulated Moto G4 -')).toBeFalsy();
     expect(root.getByText('Slow 4G throttling')).toBeTruthy();
     expect(root.getByText('4x slowdown'));
@@ -83,6 +89,7 @@ describe('SidebarRuntimeSettings', () => {
       screenEmulation: {
         width: 100,
         height: 100,
+        mobile: false,
         deviceScaleFactor: 2,
       },
     } as any;
@@ -92,4 +99,18 @@ describe('SidebarRuntimeSettings', () => {
     expect(root.getByText('Custom throttling')).toBeTruthy();
     expect(root.getByText('1x slowdown'));
   });
+
+  it('displays runtime settings when screenEmulation disabled', async () => {
+    const settings = {
+      formFactor: 'mobile',
+      throttlingMethod: 'provided',
+      throttling: {},
+      screenEmulation: {disabled: true},
+    } as any;
+    const root = render(<SidebarRuntimeSettings settings={settings}/>, {wrapper});
+
+    expect(root.getByText('No emulation')).toBeTruthy();
+    expect(root.queryByText('Emulated Moto G4 -')).toBeFalsy();
+    expect(root.getByText('Provided by environment')).toBeTruthy();
+  });
 });
diff --git a/report/test/renderer/util-test.js b/report/test/renderer/util-test.js
index 88b6dfb495d0..49d6aa5eda14 100644
--- a/report/test/renderer/util-test.js
+++ b/report/test/renderer/util-test.js
@@ -33,12 +33,13 @@ describe('util helpers', () => {
   });
 
   it('builds device emulation string', () => {
-    const get = opts => Util.getEmulationDescriptions({
-      ...opts,
-      screenEmulation: {disabled: true},
-    }).deviceEmulation;
-    assert.equal(get({formFactor: 'mobile'}), 'Emulated Moto G4');
-    assert.equal(get({formFactor: 'desktop'}), 'Emulated Desktop');
+    const get = settings => Util.getEmulationDescriptions(settings).deviceEmulation;
+    /* eslint-disable max-len */
+    assert.equal(get({formFactor: 'mobile', screenEmulation: {disabled: false, mobile: true}}), 'Emulated Moto G4');
+    assert.equal(get({formFactor: 'mobile', screenEmulation: {disabled: true, mobile: true}}), 'No emulation');
+    assert.equal(get({formFactor: 'desktop', screenEmulation: {disabled: false, mobile: false}}), 'Emulated Desktop');
+    assert.equal(get({formFactor: 'desktop', screenEmulation: {disabled: true, mobile: false}}), 'No emulation');
+    /* eslint-enable max-len */
   });
 
   it('builds throttling strings when provided', () => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn unit-flow ; yarn unit-report report/test/renderer/util-test.js
: '>>>>> End Test Output'
git checkout 3ccdb7ac55c0a41d87a1d611546e034260107167 flow-report/test/sidebar/sidebar-test.tsx report/test/renderer/util-test.js
