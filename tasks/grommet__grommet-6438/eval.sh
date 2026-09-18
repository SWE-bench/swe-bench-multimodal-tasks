#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 129a24155febd00afcabbae4a522e38e4250187e
git checkout 129a24155febd00afcabbae4a522e38e4250187e src/js/components/DateInput/__tests__/DateInput-test.tsx
git apply -v - <<'EOF_114329324912'
diff --git a/src/js/components/DateInput/__tests__/DateInput-test.tsx b/src/js/components/DateInput/__tests__/DateInput-test.tsx
index 868d0a6a2f..3d0c6a201b 100644
--- a/src/js/components/DateInput/__tests__/DateInput-test.tsx
+++ b/src/js/components/DateInput/__tests__/DateInput-test.tsx
@@ -106,6 +106,32 @@ describe('DateInput', () => {
     expect(container.firstChild).toMatchSnapshot();
   });
 
+  test('format with date bounds', async () => {
+    const user = userEvent.setup();
+
+    render(
+      <Grommet>
+        <DateInput
+          id="item"
+          name="item"
+          format="mm/dd/yyyy"
+          calendarProps={{
+            bounds: ['2022-11-10', '2022-11-20'],
+          }}
+        />
+      </Grommet>,
+    );
+
+    const input = screen.getByRole('textbox');
+
+    await user.type(input, '09/09/2022');
+    expect(input).not.toHaveValue();
+
+    await user.clear(input);
+    await user.type(input, '11/15/2022');
+    expect(input).toHaveValue('11/15/2022');
+  });
+
   test('reverse calendar icon', () => {
     const { container } = render(
       <Grommet>
@@ -279,6 +305,32 @@ describe('DateInput', () => {
     expect(container.firstChild).toMatchSnapshot();
   });
 
+  test('range format with date bounds', async () => {
+    const user = userEvent.setup();
+
+    render(
+      <Grommet>
+        <DateInput
+          id="item"
+          name="item"
+          format="mm/dd/yyyy-mm/dd/yyyy"
+          calendarProps={{
+            bounds: ['2022-11-10', '2022-11-20'],
+          }}
+        />
+      </Grommet>,
+    );
+
+    const input = screen.getByRole('textbox');
+
+    await user.type(input, '09/09/2022-09/09/2022');
+    expect(input).not.toHaveValue();
+
+    await user.clear(input);
+    await user.type(input, '11/15/2022-11/15/2022');
+    expect(input).toHaveValue('11/15/2022-11/15/2022');
+  });
+
   test('dates initialized with empty array', async () => {
     const user = userEvent.setup();
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test
: '>>>>> End Test Output'
git checkout 129a24155febd00afcabbae4a522e38e4250187e src/js/components/DateInput/__tests__/DateInput-test.tsx
