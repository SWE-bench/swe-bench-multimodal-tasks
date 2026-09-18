#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 91b73692253827a03cfbd98411a5d809b46a776b
git checkout 91b73692253827a03cfbd98411a5d809b46a776b client/extensions/woocommerce/state/sites/locations/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/extensions/woocommerce/state/sites/locations/test/selectors.js b/client/extensions/woocommerce/state/sites/locations/test/selectors.js
index 32562f41e8db49..947719ee442ee6 100644
--- a/client/extensions/woocommerce/state/sites/locations/test/selectors.js
+++ b/client/extensions/woocommerce/state/sites/locations/test/selectors.js
@@ -14,6 +14,7 @@ import {
 	getContinents,
 	getCountries,
 	getCountryName,
+	getCountriesWithStates,
 	getStates,
 	hasStates,
 } from '../selectors';
@@ -259,4 +260,18 @@ describe( 'selectors', () => {
 			expect( hasStates( loadedState, 'US' ) ).to.be.true;
 		} );
 	} );
+
+	describe( '#getCountriesWithStates', () => {
+		test( 'should return an empty list if the locations are not loaded', () => {
+			expect( getCountriesWithStates( emptyState ) ).to.deep.equal( [] );
+		} );
+
+		test( 'should return an empty list if the locations are being loaded', () => {
+			expect( getCountriesWithStates( loadingState ) ).to.deep.equal( [] );
+		} );
+
+		test( 'should return the countries with states, sorted', () => {
+			expect( getCountriesWithStates( loadedState ) ).to.deep.equal( [ 'CA', 'US' ] );
+		} );
+	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/sites/locations/test/selectors.js
: '>>>>> End Test Output'
git checkout 91b73692253827a03cfbd98411a5d809b46a776b client/extensions/woocommerce/state/sites/locations/test/selectors.js
