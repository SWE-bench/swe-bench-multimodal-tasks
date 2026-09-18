#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff ac0f856067403c0ac9af7dfb2cfe37caf93c0e9b
git checkout ac0f856067403c0ac9af7dfb2cfe37caf93c0e9b test/table/index-spec.js test/tree/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/table/index-spec.js b/test/table/index-spec.js
index 77b9bc1c83..c11f2dff15 100644
--- a/test/table/index-spec.js
+++ b/test/table/index-spec.js
@@ -520,6 +520,29 @@ describe('Table', () => {
         );
     });
 
+    it('should support rowExpandable', done => {
+        timeout(
+            {
+                dataSource: [
+                    { id: '1', name: 'test', expandable: false },
+                    { id: '2', name: 'test2', expandable: true, },
+                    { id: '3', name: 'test3', expandable: true },
+                ],
+                expandedRowRender: record => record.name,
+                rowExpandable: record => record.expandable
+            },
+            () => {
+                let expandedTotal = wrapper
+                    .find('.next-table-row');
+                let expandedIcon = wrapper
+                    .find('.next-table-prerow .next-table-cell-wrapper .next-icon');
+
+                assert(expandedTotal.length - expandedIcon.length === 1);
+                done();
+            }
+        );
+    });
+
     it('should support multiple header', done => {
         timeout(
             {
@@ -594,6 +617,9 @@ describe('Table', () => {
             onFilter,
             children: [<Table.Column dataIndex="id" filters={filters} />],
         });
+
+        assert(wrapper.find('next-table-filter-active').length === 0);
+
         wrapper.find('.next-icon-filter').simulate('click');
         wrapper
             .find('.next-btn')
@@ -612,6 +638,7 @@ describe('Table', () => {
             .simulate('click');
         assert.deepEqual(id, '3');
 
+        assert(wrapper.find('next-table-filter-active'));
         wrapper.setProps({
             filterParams: {
                 id: {
diff --git a/test/tree/index-spec.js b/test/tree/index-spec.js
index 55773e4da4..dd29b3791b 100644
--- a/test/tree/index-spec.js
+++ b/test/tree/index-spec.js
@@ -20,12 +20,14 @@ const dataSource = freeze([
         label: '服装',
         key: '1',
         className: 'k-1',
+        icon: 'cry',
         children: [
             {
                 label: '男装',
                 key: '2',
                 className: 'k-2',
                 disabled: true,
+                icon: <Icon type="smile" />,
                 children: [
                     {
                         label: '外套',
@@ -796,8 +798,6 @@ describe('Tree', () => {
     });
 
     it('should support icon', () => {
-        dataSource[0].icon = 'cry';
-        dataSource[0].children[0].icon = <Icon type="smile" />;
 
         ReactDOM.render(<Tree defaultExpandAll dataSource={dataSource} />, mountNode);
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test table"' ; timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test tree"'
: '>>>>> End Test Output'
git checkout ac0f856067403c0ac9af7dfb2cfe37caf93c0e9b test/table/index-spec.js test/tree/index-spec.js
