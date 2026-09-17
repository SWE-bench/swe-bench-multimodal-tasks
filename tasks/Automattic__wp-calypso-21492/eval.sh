#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 97d16987f9b4897e3e71ab9d3688ad59d4c57e3d
git checkout 97d16987f9b4897e3e71ab9d3688ad59d4c57e3d client/jetpack-connect/test/utils.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/jetpack-connect/test/utils.js b/client/jetpack-connect/test/utils.js
index 032f1eeb91e55..acaf551dd7946 100644
--- a/client/jetpack-connect/test/utils.js
+++ b/client/jetpack-connect/test/utils.js
@@ -3,7 +3,7 @@
 /**
  * Internal dependencies
  */
-import { addCalypsoEnvQueryArg } from '../utils';
+import { addCalypsoEnvQueryArg, getRoleFromScope } from '../utils';
 
 jest.mock( 'config', () => input => {
 	const lookupTable = {
@@ -22,3 +22,25 @@ describe( 'addCalypsoEnvQueryArg', () => {
 		);
 	} );
 } );
+
+describe( 'getRoleFromScope', () => {
+	test( 'should return role from scope', () => {
+		const result = getRoleFromScope( 'role:e8ae7346d1a0f800b64e' );
+		expect( result ).toBe( 'role' );
+	} );
+
+	test( 'should return null if no role is found', () => {
+		const result = getRoleFromScope( ':e8ae7346d1a0f800b64e' );
+		expect( result ).toBe( null );
+	} );
+
+	test( 'should return null if no hash is found', () => {
+		const result = getRoleFromScope( 'role' );
+		expect( result ).toBe( null );
+	} );
+
+	test( 'should return null if scope is malformed', () => {
+		const result = getRoleFromScope( 'rolee8ae7346d1a0f800b64e' );
+		expect( result ).toBe( null );
+	} );
+} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/jetpack-connect/test/utils.js
: '>>>>> End Test Output'
git checkout 97d16987f9b4897e3e71ab9d3688ad59d4c57e3d client/jetpack-connect/test/utils.js
