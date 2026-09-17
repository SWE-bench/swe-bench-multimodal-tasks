#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 0bab036290b284735a7b5043cc11d194bd8ec37d
git checkout 0bab036290b284735a7b5043cc11d194bd8ec37d client/lib/credit-card-details/test/ebanx.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/credit-card-details/test/ebanx.js b/client/lib/credit-card-details/test/ebanx.js
index f9d63d0c4a37b8..12a87218d63965 100644
--- a/client/lib/credit-card-details/test/ebanx.js
+++ b/client/lib/credit-card-details/test/ebanx.js
@@ -40,11 +40,12 @@ describe( 'Ebanx payment processing methods', () => {
 
 	describe( 'isValidCPF', () => {
 		test( 'should return true for valid CPF (Brazilian tax identification number)', () => {
+			expect( isValidCPF( '85384484632' ) ).toEqual( true );
 			expect( isValidCPF( '853.513.468-93' ) ).toEqual( true );
 		} );
 		test( 'should return false for invalid CPF', () => {
-			expect( isValidCPF( '85384484632' ) ).toEqual( false );
-			expect( isValidCPF( '853.844.846.32' ) ).toEqual( false );
+			expect( isValidCPF( '85384484612' ) ).toEqual( false );
+			expect( isValidCPF( '853.844.846.12' ) ).toEqual( false );
 		} );
 	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/credit-card-details/test/ebanx.js
: '>>>>> End Test Output'
git checkout 0bab036290b284735a7b5043cc11d194bd8ec37d client/lib/credit-card-details/test/ebanx.js
