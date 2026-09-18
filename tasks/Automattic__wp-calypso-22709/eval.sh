#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 58478c529c2ea594a96c89a8c8daa3f7d22c2dda
git checkout 58478c529c2ea594a96c89a8c8daa3f7d22c2dda client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/selectors/test/get-jetpack-onboarding-pending-steps.js b/client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
index 0f57610de2955..8f51d44f5fca7 100644
--- a/client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
+++ b/client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
@@ -9,6 +9,37 @@ import { getRequestKey } from 'state/data-layer/wpcom-http/utils';
 import { saveJetpackOnboardingSettings } from 'state/jetpack-onboarding/actions';
 
 describe( 'getJetpackOnboardingPendingSteps()', () => {
+	test( 'should return pending status for the contact form step', () => {
+		const siteId = 2916284;
+		const action = saveJetpackOnboardingSettings( siteId, {
+			addContactForm: true,
+		} );
+		const state = {
+			dataRequests: {
+				[ getRequestKey( action ) ]: {
+					status: 'pending',
+				},
+			},
+		};
+
+		const steps = [
+			STEPS.SITE_TITLE,
+			STEPS.SITE_TYPE,
+			STEPS.CONTACT_FORM,
+			STEPS.WOOCOMMERCE,
+			STEPS.STATS,
+		];
+		const expected = {
+			[ STEPS.SITE_TITLE ]: false,
+			[ STEPS.SITE_TYPE ]: false,
+			[ STEPS.CONTACT_FORM ]: true,
+			[ STEPS.WOOCOMMERCE ]: false,
+			[ STEPS.STATS ]: false,
+		};
+		const pending = getJetpackOnboardingPendingSteps( state, siteId, steps );
+		expect( pending ).toEqual( expected );
+	} );
+
 	test( 'should return pending status for the woocommerce step', () => {
 		const siteId = 2916284;
 		const action = saveJetpackOnboardingSettings( siteId, {
@@ -22,10 +53,17 @@ describe( 'getJetpackOnboardingPendingSteps()', () => {
 			},
 		};
 
-		const steps = [ STEPS.SITE_TITLE, STEPS.SITE_TYPE, STEPS.WOOCOMMERCE, STEPS.STATS ];
+		const steps = [
+			STEPS.SITE_TITLE,
+			STEPS.SITE_TYPE,
+			STEPS.CONTACT_FORM,
+			STEPS.WOOCOMMERCE,
+			STEPS.STATS,
+		];
 		const expected = {
 			[ STEPS.SITE_TITLE ]: false,
 			[ STEPS.SITE_TYPE ]: false,
+			[ STEPS.CONTACT_FORM ]: false,
 			[ STEPS.WOOCOMMERCE ]: true,
 			[ STEPS.STATS ]: false,
 		};
@@ -46,10 +84,17 @@ describe( 'getJetpackOnboardingPendingSteps()', () => {
 			},
 		};
 
-		const steps = [ STEPS.SITE_TITLE, STEPS.SITE_TYPE, STEPS.WOOCOMMERCE, STEPS.STATS ];
+		const steps = [
+			STEPS.SITE_TITLE,
+			STEPS.SITE_TYPE,
+			STEPS.CONTACT_FORM,
+			STEPS.WOOCOMMERCE,
+			STEPS.STATS,
+		];
 		const expected = {
 			[ STEPS.SITE_TITLE ]: false,
 			[ STEPS.SITE_TYPE ]: false,
+			[ STEPS.CONTACT_FORM ]: false,
 			[ STEPS.WOOCOMMERCE ]: false,
 			[ STEPS.STATS ]: true,
 		};

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
: '>>>>> End Test Output'
git checkout 58478c529c2ea594a96c89a8c8daa3f7d22c2dda client/state/selectors/test/get-jetpack-onboarding-pending-steps.js
