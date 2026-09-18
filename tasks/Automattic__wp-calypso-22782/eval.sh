#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 5f4c22c561a31972c973dc9dadd907836070bceb
git checkout 5f4c22c561a31972c973dc9dadd907836070bceb client/lib/credit-card-details/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/credit-card-details/test/index.js b/client/lib/credit-card-details/test/index.js
index ef6bfbacbc842e..01e39cb741c398 100644
--- a/client/lib/credit-card-details/test/index.js
+++ b/client/lib/credit-card-details/test/index.js
@@ -12,6 +12,7 @@ import assert from 'assert';
  * Internal dependencies
  */
 import { getCreditCardType } from '../';
+import { formatCreditCard } from '../masking';
 
 jest.mock( 'lib/abtest', () => ( {
 	abtest: () => '',
@@ -102,4 +103,41 @@ describe( 'index', () => {
 			} );
 		} );
 	} );
+	describe( 'Masking', () => {
+		describe( 'American Express Card', () => {
+			test( 'formats a number as 4-6-5', () => {
+				expect( formatCreditCard( '378282246310005' ) ).toEqual( '3782 822463 10005' );
+			} );
+			test( 'formats a number as 4-6-5 with any sort of whitespace', () => {
+				expect( formatCreditCard( ' 3782 8224 6310 005 ' ) ).toEqual( '3782 822463 10005' );
+			} );
+			test( 'formats a number as 4-6-5 and trims to 15 digits', () => {
+				expect( formatCreditCard( '37828224631000512345' ) ).toEqual( '3782 822463 10005' );
+			} );
+		} );
+		describe( 'Diner Credit Cards', () => {
+			test( 'formats a number as 4-4-4-2', () => {
+				expect( formatCreditCard( '30569309025904' ) ).toEqual( '3056 9309 0259 04' );
+			} );
+			test( 'formats a number as 4-4-4-2 with any sort of whitespace', () => {
+				expect( formatCreditCard( '3056 9309 025   904' ) ).toEqual( '3056 9309 0259 04' );
+			} );
+		} );
+		describe( 'All Other Credit Cards', () => {
+			test( 'formats a number as 4-4-4-4', () => {
+				expect( formatCreditCard( '2223003122003222' ) ).toEqual( '2223 0031 2200 3222' );
+			} );
+			test( 'formats a number as 4-4-4-4 with any sort of whitespace', () => {
+				expect( formatCreditCard( '2223 0031220     03222' ) ).toEqual( '2223 0031 2200 3222' );
+			} );
+			test( '19 digit cards format as 4-4-4-7', () => {
+				expect( formatCreditCard( '6011496233608973938' ) ).toEqual( '6011 4962 3360 8973938' );
+			} );
+			test( 'has a maximum length of 19', () => {
+				expect( formatCreditCard( '6011496233608973938123456789' ) ).toEqual(
+					'6011 4962 3360 8973938'
+				);
+			} );
+		} );
+	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/credit-card-details/test/index.js
: '>>>>> End Test Output'
git checkout 5f4c22c561a31972c973dc9dadd907836070bceb client/lib/credit-card-details/test/index.js
