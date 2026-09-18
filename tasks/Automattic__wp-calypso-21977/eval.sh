#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6c46667b4d171af667fa6fc0990c0cf35e954ae3
git checkout 6c46667b4d171af667fa6fc0990c0cf35e954ae3 client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js
index 648e144340577..3f783bffa36b6 100644
--- a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js
+++ b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js
@@ -11,6 +11,7 @@ import { spy } from 'sinon';
  */
 import useNock from 'test/helpers/use-nock';
 import {
+	clearCompletedNotification,
 	clearError,
 	createAccount,
 	deauthorizeAccount,
@@ -19,6 +20,7 @@ import {
 	oauthConnect,
 } from '../actions';
 import {
+	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_COMPLETED_NOTIFICATION,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_ERROR,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CREATE,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CREATE_COMPLETE,
@@ -33,6 +35,20 @@ import {
 } from 'woocommerce/state/action-types';
 
 describe( 'actions', () => {
+	describe( '#clearCompletedNotification()', () => {
+		const siteId = '123';
+
+		test( 'should dispatch an action', () => {
+			const getState = () => ( {} );
+			const dispatch = spy();
+			clearCompletedNotification( siteId )( dispatch, getState );
+			expect( dispatch ).to.have.been.calledWith( {
+				type: WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_COMPLETED_NOTIFICATION,
+				siteId,
+			} );
+		} );
+	} );
+
 	describe( '#clearError()', () => {
 		const siteId = '123';
 
diff --git a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js
index 050bbc99b17b7..fe82c142d6b0a 100644
--- a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js
+++ b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js
@@ -10,6 +10,7 @@ import { expect } from 'chai';
  */
 import stripeConnectAccountReducer from '../reducer';
 import {
+	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_COMPLETED_NOTIFICATION,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_ERROR,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CREATE,
 	WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CREATE_COMPLETE,
@@ -32,6 +33,17 @@ describe( 'reducer', () => {
 		} );
 	} );
 
+	describe( 'clearCompletedNotification', () => {
+		test( 'should reset flag in state', () => {
+			const action = {
+				type: WOOCOMMERCE_SETTINGS_STRIPE_CONNECT_ACCOUNT_CLEAR_COMPLETED_NOTIFICATION,
+				siteId: 123,
+			};
+			const newState = stripeConnectAccountReducer( { notifyCompleted: true }, action );
+			expect( newState.notifyCompleted ).to.eql( false );
+		} );
+	} );
+
 	describe( 'clearError', () => {
 		test( 'should reset error in state', () => {
 			const action = {
@@ -102,6 +114,7 @@ describe( 'reducer', () => {
 				isRequesting: false,
 				lastName: '',
 				logo: '',
+				notifyCompleted: true,
 			} );
 		} );
 
@@ -759,6 +772,7 @@ describe( 'reducer', () => {
 				isRequesting: false,
 				lastName: '',
 				logo: '',
+				notifyCompleted: true,
 			} );
 		} );
 
diff --git a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
index 25d617ce25e7f..42b467eefb37b 100644
--- a/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
+++ b/client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
@@ -15,6 +15,7 @@ import {
 	getIsOAuthConnecting,
 	getIsOAuthInitializing,
 	getIsRequesting,
+	getNotifyCompleted,
 	getOAuthURL,
 	getStripeConnectAccount,
 } from '../selectors';
@@ -40,6 +41,7 @@ const creatingState = {
 				123: {
 					settings: {
 						stripeConnectAccount: {
+							notifyCompleted: false,
 							isCreating: true,
 						},
 					},
@@ -59,6 +61,7 @@ const createdState = {
 							connectedUserID: 'acct_14qyt6Alijdnw0EA',
 							email: 'foo@bar.com',
 							isCreating: false,
+							notifyCompleted: true,
 						},
 					},
 				},
@@ -224,6 +227,7 @@ const oauthConnectingState = {
 							logo: '',
 							lastName: '',
 							oauthUrl: '',
+							notifyCompleted: false,
 						},
 					},
 				},
@@ -251,6 +255,7 @@ const oauthConnectedState = {
 							logo: '',
 							lastName: '',
 							oauthUrl: '',
+							notifyCompleted: true,
 						},
 					},
 				},
@@ -310,6 +315,24 @@ describe( 'selectors', () => {
 		} );
 	} );
 
+	describe( '#getNotifyCompleted', () => {
+		test( 'should return false when account is being created.', () => {
+			expect( getNotifyCompleted( creatingState, 123 ) ).to.eql( false );
+		} );
+
+		test( 'should return true after account has been created.', () => {
+			expect( getNotifyCompleted( createdState, 123 ) ).to.eql( true );
+		} );
+
+		test( 'should return false when oauth is connecting.', () => {
+			expect( getNotifyCompleted( oauthConnectingState, 123 ) ).to.eql( false );
+		} );
+
+		test( 'should return true when oauth has connected.', () => {
+			expect( getNotifyCompleted( oauthConnectedState, 123 ) ).to.eql( true );
+		} );
+	} );
+
 	describe( '#getIsRequesting', () => {
 		test( 'should be false when state is uninitialized.', () => {
 			expect( getIsRequesting( uninitializedState, 123 ) ).to.be.false;

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
: '>>>>> End Test Output'
git checkout 6c46667b4d171af667fa6fc0990c0cf35e954ae3 client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/actions.js client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/reducer.js client/extensions/woocommerce/state/sites/settings/stripe-connect-account/test/selectors.js
