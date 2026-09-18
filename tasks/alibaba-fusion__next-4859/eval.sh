#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 56f9fa2b426e4212cb43f6d7f78d51c6c17becc8
git checkout 56f9fa2b426e4212cb43f6d7f78d51c6c17becc8 components/cascader-select/__tests__/issue-spec.tsx components/cascader/__tests__/index-spec.tsx
git apply -v - <<'EOF_114329324912'
diff --git a/components/cascader-select/__tests__/issue-spec.tsx b/components/cascader-select/__tests__/issue-spec.tsx
index d5a0303bc9..65b1428489 100644
--- a/components/cascader-select/__tests__/issue-spec.tsx
+++ b/components/cascader-select/__tests__/issue-spec.tsx
@@ -100,4 +100,23 @@ describe('CascaderSelect issues', function () {
         shouldExpanded('乌鲁木齐', 1, 0);
         shouldSelected('乌鲁木齐市', 2, 0);
     });
+
+    // Fix https://github.com/alibaba-fusion/next/issues/3704
+    it('When using virtual scrolling, the background color should be white', () => {
+        cy.mount(
+            <div style={{ background: '#ccc', height: '300px' }}>
+                <CascaderSelect
+                    useVirtual
+                    defaultVisible
+                    defaultValue={['3078']}
+                    dataSource={ChinaAreaData}
+                />
+            </div>
+        );
+        cy.get('.next-cascader-menu-wrapper').should(
+            'have.css',
+            'background-color',
+            'rgb(255, 255, 255)'
+        );
+    });
 });
diff --git a/components/cascader/__tests__/index-spec.tsx b/components/cascader/__tests__/index-spec.tsx
index f65825a9a3..b4f5ebe45c 100644
--- a/components/cascader/__tests__/index-spec.tsx
+++ b/components/cascader/__tests__/index-spec.tsx
@@ -682,4 +682,61 @@ describe('Cascader', () => {
         cy.get('.next-menu-item[title="1"]').click();
         cy.get('.next-cascader-menu-wrapper').should('have.length', 1);
     });
+
+    // Fix https://github.com/alibaba-fusion/next/issues/3704
+    it('When using virtual scrolling, the background color should be white', () => {
+        const dataSource = [
+            {
+                value: '2973',
+                label: '陕西',
+                children: [
+                    {
+                        value: '2974',
+                        label: '西安',
+                        children: [
+                            { value: '2975', label: '西安市' },
+                            { value: '2976', label: '高陵县' },
+                        ],
+                    },
+                    {
+                        value: '2980',
+                        label: '铜川',
+                        children: [
+                            { value: '2981', label: '铜川市' },
+                            { value: '2982', label: '宜君县' },
+                        ],
+                    },
+                ],
+            },
+            {
+                value: '3371',
+                label: '新疆',
+                children: [
+                    {
+                        value: '3430',
+                        label: '巴音郭楞蒙古自治州',
+                        children: [
+                            { value: '3431', label: '库尔勒市' },
+                            { value: '3432', label: '和静县' },
+                        ],
+                    },
+                ],
+            },
+        ];
+        cy.mount(
+            <div style={{ background: '#ccc', height: '300px' }}>
+                <Cascader
+                    defaultValue="3439"
+                    useVirtual
+                    defaultExpandedValue={['3371', '3430']}
+                    dataSource={dataSource}
+                />
+            </div>
+        );
+        cy.get('.next-cascader-menu-wrapper').should(
+            'have.css',
+            'background-color',
+            'rgb(255, 255, 255)'
+        );
+    });
 });

EOF_114329324912
chmod -R a+w /testbed/node_modules 2>/dev/null || true
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test cascader"' ; timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test cascader-select"'
: '>>>>> End Test Output'
git checkout 56f9fa2b426e4212cb43f6d7f78d51c6c17becc8 components/cascader-select/__tests__/issue-spec.tsx components/cascader/__tests__/index-spec.tsx
