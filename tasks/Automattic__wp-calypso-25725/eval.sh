#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff af9cf1f55288ebefb6cd1d796df3893db41f2292
git checkout af9cf1f55288ebefb6cd1d796df3893db41f2292 client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/data-layer/wpcom/sites/plan-transfer/test/index.js b/client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
index 721f23a365e14..f6d08b02557ac 100644
--- a/client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
+++ b/client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
@@ -33,15 +33,17 @@ describe( 'requestPlanOwnershipTransfer()', () => {
 } );
 
 describe( 'handleTransferSuccess()', () => {
-	test( 'should return a success notice action', () => {
-		const action = handleTransferSuccess( { siteId } );
+	test( 'should return a success notice action and a function', () => {
+		const actions = handleTransferSuccess( { siteId } );
 
-		expect( action ).toMatchObject(
+		expect( actions ).toHaveLength( 2 );
+		expect( actions[ 0 ] ).toMatchObject(
 			successNotice( 'Plan purchaser has been changed successfully.', {
 				duration: 8000,
 				id: `sites-plan-transfer-notice-${ siteId }`,
 			} )
 		);
+		expect( actions[ 1 ] ).toBeInstanceOf( Function );
 	} );
 } );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
: '>>>>> End Test Output'
git checkout af9cf1f55288ebefb6cd1d796df3893db41f2292 client/state/data-layer/wpcom/sites/plan-transfer/test/index.js
