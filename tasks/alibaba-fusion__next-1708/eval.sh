#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff bd48e0b8804febc0e9f771772d24c5bc6c53c37a
git checkout bd48e0b8804febc0e9f771772d24c5bc6c53c37a test/tree/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/tree/index-spec.js b/test/tree/index-spec.js
index 4e99112fa9..2465c0b0ca 100644
--- a/test/tree/index-spec.js
+++ b/test/tree/index-spec.js
@@ -1,4 +1,4 @@
-import React, { Component } from 'react';
+import React, { Component, useState } from 'react';
 import ReactDOM from 'react-dom';
 import propTypes from 'prop-types';
 import assert from 'power-assert';
@@ -604,6 +604,95 @@ describe('Tree', () => {
         ['1', '5', '6'].forEach(key => assertChecked(key, true));
     });
 
+    it('should support setting indeterminate key when checkStrictly true', done => {
+        class Demo extends Component {
+            constructor () {
+                super();
+
+                setTimeout(() => {
+                    ['1', '2', '3'].forEach(key => assertChecked(key, true));
+                    ['4', '5', '6'].forEach(key => assertIndeterminate(key, true));
+
+                    this.setState({ checkedKeys: [] });
+                    ['4', '5', '6'].forEach(key => assertChecked(key, false));
+
+                    this.setState({
+                        checkedKeys: {
+                            checked: '1',
+                            indeterminate: '2'
+                        }
+                    });
+                    assertChecked('1', true);
+                    assertIndeterminate('2', true);
+
+                    done();
+                }, 100)
+            }
+
+            state = {
+                checkedKeys: {
+                    checked: ['1', '2', '3'],
+                    indeterminate: ['4', '5', '6']
+                }
+            }
+
+            render() {
+                return (
+                    <Tree
+                        defaultExpandAll
+                        checkable
+                        checkStrictly
+                        checkedKeys={this.state.checkedKeys}
+                        dataSource={cloneData(dataSource, {
+                            2: { disabled: false }
+                        })}
+                    />
+                );
+            }
+        }
+
+        ReactDOM.render(<Demo />, mountNode);
+    });
+
+    it('should support update indeterminate key when dataSource change', done => {
+        class Demo extends Component {
+            constructor () {
+                super();
+
+                setTimeout(() => {
+                    ['1', '2', '3'].forEach(key => assertChecked(key, false));
+
+                    checkTreeNode('5');
+                    assertIndeterminate('2', true);
+
+                    this.state.data[0].children[0].children.length = 1;
+                    this.setState({ data: this.state.data });
+                    assertIndeterminate('2', false)
+                    
+                    done();
+                }, 100);
+            }
+
+            state = {
+                data: cloneData(dataSource, {
+                    2: { disabled: false }
+                })
+            }
+
+            render() {
+                return (
+                    <Tree
+                        defaultExpandAll
+                        checkable
+                        dataSource={this.state.data}
+                    />
+                );
+            }
+        }
+        ReactDOM.render(<Demo/>, mountNode);
+    });
+
+
     it('should support editing node', () => {
         let called = false;
         const handleEditFinish = (key, label, node) => {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test tree"'
: '>>>>> End Test Output'
git checkout bd48e0b8804febc0e9f771772d24c5bc6c53c37a test/tree/index-spec.js
