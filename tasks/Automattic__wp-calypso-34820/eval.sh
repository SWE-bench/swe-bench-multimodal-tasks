#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 4250bc3ebba1c9fe1cbf0e913723f1177985dca2
git checkout 4250bc3ebba1c9fe1cbf0e913723f1177985dca2 client/lib/cart/store/test/index.js client/lib/user-settings/test/mocks/wp.js client/lib/user/test/utils.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/cart/store/test/index.js b/client/lib/cart/store/test/index.js
index d95aa8e01a2f9..79d943b915895 100644
--- a/client/lib/cart/store/test/index.js
+++ b/client/lib/cart/store/test/index.js
@@ -40,7 +40,7 @@ jest.mock( 'lib/products-list', () => () => ( { get: () => [] } ) );
 jest.mock( 'lib/wp', () => ( {
 	undocumented: () => ( {} ),
 	me: () => ( {
-		get: async () => ( {} ),
+		get: () => ( {} ),
 	} ),
 } ) );
 
diff --git a/client/lib/user-settings/test/mocks/wp.js b/client/lib/user-settings/test/mocks/wp.js
index 4751fb7b02f84..fe4cffa0a9046 100644
--- a/client/lib/user-settings/test/mocks/wp.js
+++ b/client/lib/user-settings/test/mocks/wp.js
@@ -1,6 +1,7 @@
+/** @format */
 const me = function() {
 	return {
-		get: async () => ( {} ),
+		get() {},
 		settings() {
 			return {
 				get( callback ) {
diff --git a/client/lib/user/test/utils.js b/client/lib/user/test/utils.js
index d45aeaab927c8..80261553ef3aa 100644
--- a/client/lib/user/test/utils.js
+++ b/client/lib/user/test/utils.js
@@ -18,15 +18,14 @@ import configMock from 'config';
 jest.mock( 'config', () => {
 	const { stub } = require( 'sinon' );
 
-	const mock = stub();
-	mock.isEnabled = stub();
+	const configMock = stub();
+	configMock.isEnabled = stub();
 
-	return mock;
+	return configMock;
 } );
-
 jest.mock( 'lib/wp', () => ( {
 	me: () => ( {
-		get: async () => ( {} ),
+		get: () => {},
 	} ),
 } ) );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/cart/store/test/index.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/user/test/utils.js
: '>>>>> End Test Output'
git checkout 4250bc3ebba1c9fe1cbf0e913723f1177985dca2 client/lib/cart/store/test/index.js client/lib/user-settings/test/mocks/wp.js client/lib/user/test/utils.js
