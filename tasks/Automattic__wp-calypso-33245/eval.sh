#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 5d0969c7b7f1eb23d74e6b25cf3a8751ab36be05
git checkout 5d0969c7b7f1eb23d74e6b25cf3a8751ab36be05 client/components/happiness-support/test/index.jsx
git apply -v - <<'EOF_114329324912'
diff --git a/client/components/happiness-support/test/index.jsx b/client/components/happiness-support/test/index.jsx
index eed82dc973393..88e53b4f12b81 100644
--- a/client/components/happiness-support/test/index.jsx
+++ b/client/components/happiness-support/test/index.jsx
@@ -36,7 +36,7 @@ describe( 'HappinessSupport', () => {
 	} );
 
 	test( 'should render translated help content', () => {
-		const content = wrapper.find( 'p.happiness-support__text' );
+		const content = wrapper.find( 'p.happiness-support__description' );
 		expect( content ).to.have.length( 1 );
 		expect( content.props().children ).to.equal(
 			'Translated: {{strong}}Need help?{{/strong}} A Happiness Engineer can answer questions about your site and your account.'

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/components/happiness-support/test/index.jsx
: '>>>>> End Test Output'
git checkout 5d0969c7b7f1eb23d74e6b25cf3a8751ab36be05 client/components/happiness-support/test/index.jsx
