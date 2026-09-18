#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c09ddc15a6790afcc96c9a76141ea83cfb30be45
git checkout c09ddc15a6790afcc96c9a76141ea83cfb30be45 test/menu/index-spec.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/menu/index-spec.js b/test/menu/index-spec.js
index acde87880a..64eb67e964 100644
--- a/test/menu/index-spec.js
+++ b/test/menu/index-spec.js
@@ -84,6 +84,28 @@ describe('Menu', () => {
         assert(item.find('.next-menu-item-helper').text() === 'helper');
     });
 
+    it('Group/SubMenu should accepct string/number/node', () => {
+        wrapper = mount(
+            <Menu defaultOpenKeys={['sub-menu']}>
+                 <Group label="Group">
+                    test-group-string
+                    <Item className="custom-className" key="group-1">
+                        Group option 1
+                    </Item>
+                </Group>
+                <SubMenu key="sub-menu" label="Sub menu">
+                    test-submenu-string
+                    <Item className="custom-className" key="sub-1">
+                        Sub option 1
+                    </Item>
+                </SubMenu>
+            </Menu>
+        );
+        const innerHTML = wrapper.find('.next-menu').at(0).instance().innerHTML;
+        assert(innerHTML.match('test-group-string'));
+        assert(innerHTML.match('test-submenu-string'));
+    });
+
     it('should filter duplicate keys', () => {
         wrapper = mount(
             <Menu>
@@ -163,6 +185,36 @@ describe('Menu', () => {
         assert(item.prop('aria-disabled'));
     });
 
+    it('paddingleft should only be related to inline mode', () => {
+        wrapper = mount(
+            <Menu direction="hoz" mode="popup" defaultOpenKeys={['sub', 'sub1', 'sub2', 'suba', 'suba1', 'suba2']}>
+                <SubMenu label="submenu1" key="sub">
+                    <Item>1</Item>
+                    <SubMenu label="submenu2" mode="inline" key="sub1">
+                        <Item>2</Item>
+                        <SubMenu label="submenu3" mode="inline" key="sub2">
+                            <Item id="sub2-item">3</Item>
+                        </SubMenu>
+                    </SubMenu>
+                </SubMenu>
+                <SubMenu label="submenu11" key="suba">
+                    <Item>11</Item>
+                    <SubMenu label="submenu21" key="suba1">
+                        <Item>21</Item>
+                        <SubMenu label="submenu31" mode="inline" key="suba2">
+                            <Item id="suba2-item">31</Item>
+                        </SubMenu>
+                    </SubMenu>
+                </SubMenu>
+            </Menu>
+        );
+        const item1Level = wrapper.find('#sub2-item').at(0).props().inlineLevel;
+        const item2Level = wrapper.find('#suba2-item').at(0).props().inlineLevel;
+
+        assert(item1Level === 3);
+        assert(item2Level === 2);
+    });
+
     it('should render menu divider', () => {
         wrapper = mount(
             <Menu>

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
sed -i "s/browsers: \['Chrome'\]/browsers: ['ChromeTravis']/" scripts/test/karma.js || true
sed -i "s/singleRun: singleRun,/singleRun: true,/" scripts/test/karma.js || true
: '>>>>> Start Test Output'
timeout 10m bash -c 'PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run test menu"'
: '>>>>> End Test Output'
git checkout c09ddc15a6790afcc96c9a76141ea83cfb30be45 test/menu/index-spec.js
