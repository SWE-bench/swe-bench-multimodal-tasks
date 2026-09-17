#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4d828109ecdaf06509bf5217a4e72b0435b7954a
git checkout 4d828109ecdaf06509bf5217a4e72b0435b7954a test/table/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/table/index-spec.js b/test/table/index-spec.js
index 00a73a9d3b..4578053816 100644
--- a/test/table/index-spec.js
+++ b/test/table/index-spec.js
@@ -108,6 +108,58 @@ describe('Table', () => {
         );
     });
 
+    it('should support columnProps/titleProps/titleAddons of rowSelection', done => {
+        timeout(
+            {
+                rowSelection: {
+                    columnProps: () => {
+                        return {
+                            lock: 'right',
+                            width: 90,
+                            align: 'center',
+                        };
+                    },
+                    titleAddons: () => {
+                        return <div id="table-titleAddons">请选择</div>;
+                    },
+                    titleProps: () => {
+                        return {
+                            disabled: true,
+                            children: '>',
+                        };
+                    },
+                },
+            },
+            () => {
+                assert(
+                    wrapper
+                        .find('#table-titleAddons')
+                        .at(0)
+                        .text() === '请选择'
+                );
+                assert(
+                    wrapper
+                        .find('colgroup')
+                        .at(2)
+                        .props().children[0].props.style.width === 90
+                );
+                assert(
+                    wrapper
+                        .find('th .next-checkbox-wrapper')
+                        .at(1)
+                        .hasClass('disabled')
+                );
+                assert(
+                    wrapper
+                        .find('th .next-checkbox-wrapper .next-checkbox-label')
+                        .at(0)
+                        .text() === '>'
+                );
+                done();
+            }
+        );
+    });
+
     it('should support events', done => {
         const onRowClick = sinon.spy();
         const onRowMouseEnter = sinon.spy();

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test table"'
: '>>>>> End Test Output'
git checkout 4d828109ecdaf06509bf5217a4e72b0435b7954a test/table/index-spec.js
