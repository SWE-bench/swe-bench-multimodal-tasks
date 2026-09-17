#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 09303ce69e8b79166aa566c6882536683af43a14
git checkout 09303ce69e8b79166aa566c6882536683af43a14 components/cascader-select/__tests__/index-spec.tsx
git apply -v - <<'EOF_114329324912'
diff --git a/components/cascader-select/__tests__/index-spec.tsx b/components/cascader-select/__tests__/index-spec.tsx
index 8c7259dd30..a80851ea2e 100644
--- a/components/cascader-select/__tests__/index-spec.tsx
+++ b/components/cascader-select/__tests__/index-spec.tsx
@@ -536,4 +536,26 @@ describe('CascaderSelect', () => {
         cy.get('input').type('{upArrow}', { force: true });
         cy.get('.next-cascader-select-dropdown').should('exist');
     });
+
+    it('should support empty search value after selection , close #3008', () => {
+        const handleChange = cy.spy();
+        cy.mount(
+            <CascaderSelect
+                showSearch
+                style={{ width: '240px' }}
+                dataSource={ChinaArea}
+                placeholder="搜索名字"
+                onChange={handleChange}
+                autoClearSearchValue
+                multiple
+            />
+        );
+        cy.get('.next-select-trigger-search input').type('西安');
+        cy.get('.next-cascader-filtered-list').should('have.length', 1);
+        cy.get('.next-menu-item').first().click();
+        cy.get('.next-cascader-filtered-list').should('have.length', 0);
+        cy.get('.next-cascader > .next-cascader-inner').should('not.be.empty');
+        cy.get('.next-tag').invoke('text').should('eq', '西安');
+        cy.get('.next-select-trigger-search input').should('have.text', '');
+    });
 });

EOF_114329324912
chmod -R a+w /testbed/node_modules 2>/dev/null || true
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test cascader-select"'
: '>>>>> End Test Output'
git checkout 09303ce69e8b79166aa566c6882536683af43a14 components/cascader-select/__tests__/index-spec.tsx
