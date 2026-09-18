#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff adc68ed44a6cb224a1dcfa0642284e2bf0fe4f77
git checkout adc68ed44a6cb224a1dcfa0642284e2bf0fe4f77 client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/extensions/woocommerce/state/sites/settings/general/test/selectors.js b/client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
index 3eca19e2a3e44..f381191f9c8ef 100644
--- a/client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
+++ b/client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
@@ -12,6 +12,7 @@ import {
 	areSettingsGeneralLoaded,
 	areSettingsGeneralLoading,
 	getPaymentCurrencySettings,
+	getShipToCountrySetting,
 } from '../selectors';
 import { LOADING } from 'woocommerce/state/constants';
 
@@ -48,13 +49,22 @@ const currencySetting = {
 	default: 'GBP',
 	value: 'USD',
 };
+
+const shipToCountrySetting = {
+	id: 'woocommerce_ship_to_countries',
+	label: 'Shipping location(s)',
+	type: 'select',
+	default: '',
+	value: 'disabled',
+};
+
 const loadedState = {
 	extensions: {
 		woocommerce: {
 			sites: {
 				123: {
 					settings: {
-						general: [ currencySetting ],
+						general: [ currencySetting, shipToCountrySetting ],
 					},
 				},
 			},
@@ -119,4 +129,14 @@ describe( 'selectors', () => {
 			expect( getPaymentCurrencySettings( loadedStateWithUi ) ).to.eql( currencySetting );
 		} );
 	} );
+
+	describe( 'getShipToCountrySetting', () => {
+		test( 'should get the setting from state.', () => {
+			expect( getShipToCountrySetting( loadedState, 123 ) ).to.eql( shipToCountrySetting );
+		} );
+
+		test( 'should get the siteId from the UI tree if not provided.', () => {
+			expect( getShipToCountrySetting( loadedStateWithUi ) ).to.eql( shipToCountrySetting );
+		} );
+	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
: '>>>>> End Test Output'
git checkout adc68ed44a6cb224a1dcfa0642284e2bf0fe4f77 client/extensions/woocommerce/state/sites/settings/general/test/selectors.js
