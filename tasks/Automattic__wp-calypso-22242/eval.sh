#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 30b6c1b8d322efcd61485fd28f57364640d831c6
git checkout 30b6c1b8d322efcd61485fd28f57364640d831c6 client/jetpack-connect/test/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/jetpack-connect/test/main.js b/client/jetpack-connect/test/main.js
index 36a23f8c8f3803..d8a8af238ccc00 100644
--- a/client/jetpack-connect/test/main.js
+++ b/client/jetpack-connect/test/main.js
@@ -34,6 +34,23 @@ jest.mock( 'lib/route/path', () => ( {
 } ) );
 
 describe( 'JetpackConnectMain', () => {
+	describe( 'cleanUrl', () => {
+		test( 'should prepare entered urls for network access', () => {
+			const cleanUrl = new JetpackConnectMain( REQUIRED_PROPS ).cleanUrl;
+			const results = [
+				{ input: '', expected: '' },
+				{ input: 'a', expected: 'http://a' },
+				{ input: 'example.com', expected: 'http://example.com' },
+				{ input: '  example.com   ', expected: 'http://example.com' },
+				{ input: 'http://example.com/', expected: 'http://example.com' },
+				{ input: 'eXAmple.com', expected: 'http://example.com' },
+				{ input: 'example.com/wp-admin', expected: 'http://example.com' },
+			];
+
+			results.forEach( ( { input, expected } ) => expect( cleanUrl( input ) ).toBe( expected ) );
+		} );
+	} );
+
 	describe( 'makeSafeRedirectionFunction', () => {
 		const component = new JetpackConnectMain( REQUIRED_PROPS );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/jetpack-connect/test/main.js
: '>>>>> End Test Output'
git checkout 30b6c1b8d322efcd61485fd28f57364640d831c6 client/jetpack-connect/test/main.js
