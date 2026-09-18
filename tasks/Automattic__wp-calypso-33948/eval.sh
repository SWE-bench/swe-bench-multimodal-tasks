#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff d1c128c3c97e81421f8137c138a2a1b112d44c8b
git checkout d1c128c3c97e81421f8137c138a2a1b112d44c8b client/lib/localforage/test/localforage-bypass.js client/lib/signup/test/step-actions.js client/lib/user-settings/test/index.js client/my-sites/people/people-invite-details/test/index.jsx client/state/jetpack-connect/test/actions.js client/state/test/initial-state.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/localforage/test/localforage-bypass.js b/client/lib/localforage/test/localforage-bypass.js
deleted file mode 100644
index 435ff34603422a..00000000000000
--- a/client/lib/localforage/test/localforage-bypass.js
+++ /dev/null
@@ -1,146 +0,0 @@
-/** @format */
-
-/**
- * External dependencies
- */
-import { expect } from 'chai';
-
-/**
- * Internal dependencies
- */
-import localForageBypass from '../localforage-bypass';
-
-describe( 'localforage-bypass', () => {
-	const localForage = localForageBypass;
-	let db = null;
-
-	beforeEach( () => {
-		localForage.ready = () => Promise.resolve();
-		return localForage._initStorage( {} ).then( () => {
-			db = localForage._dbInfo.db;
-		} );
-	} );
-
-	describe( 'keys', () => {
-		test( 'should list all keys', () => {
-			db.one = 1;
-			db.two = 2;
-			return localForage.keys().then( keys => {
-				expect( keys ).to.have.length( 2 );
-				expect( keys ).to.deep.equal( [ 'one', 'two' ] );
-			} );
-		} );
-
-		test( 'should be empty when initialized', () => {
-			return localForage.keys().then( keys => {
-				expect( keys ).to.have.length( 0 );
-			} );
-		} );
-	} );
-
-	describe( 'length', () => {
-		const length = () => localForage.length();
-		const expectLength = expected => {
-			return () => {
-				return length().then( l => expect( l ).to.equal( expected ) );
-			};
-		};
-		const addItem = ( key, value ) => {
-			return () => localForage.setItem( key, value );
-		};
-
-		test( 'should be zero when initialized', () => {
-			return expectLength( 0 )();
-		} );
-
-		test( 'should match number of items', () => {
-			db.one = 1;
-			db.two = 2;
-			return expectLength( 2 )();
-		} );
-
-		test( 'should increment after setItem', () => {
-			db.one = 1;
-			db.two = 2;
-
-			return expectLength( 2 )()
-				.then( addItem( 'eight', 8 ) )
-				.then( expectLength( 3 ) );
-		} );
-
-		test( 'should not increment after setItem where key already exists', () => {
-			db.one = 1;
-			db.two = 2;
-
-			return expectLength( 2 )()
-				.then( addItem( 'two', 9 ) )
-				.then( length )
-				.then( expectLength( 2 ) );
-		} );
-	} );
-
-	describe( 'clear', () => {
-		test( 'should remove all keys', () => {
-			db.one = 1;
-			db.two = 2;
-			return localForage.clear().then( () => {
-				expect( db ).to.be.empty;
-			} );
-		} );
-	} );
-
-	describe( 'getItem', () => {
-		test( 'should get an item that exists', () => {
-			db.one = 1;
-			return localForage.getItem( 'one' ).then( value => {
-				expect( value ).to.equal( 1 );
-			} );
-		} );
-
-		test( "should return undefined for an item that doesn't exist", () => {
-			db.one = 1;
-			localForage.getItem( 'two' ).then( value => {
-				expect( value ).to.be.undefined;
-			} );
-		} );
-	} );
-
-	describe( 'setItem', () => {
-		test( 'should set an item', () => {
-			localForage.setItem( 'abc', 123 ).then( () => {
-				expect( db.abc ).to.equal( 123 );
-			} );
-		} );
-
-		test( 'should overwrite an item', () => {
-			db.abc = 'not a number';
-			localForage.setItem( 'abc', 123 ).then( () => {
-				expect( db.abc ).to.equal( 123 );
-			} );
-		} );
-	} );
-
-	describe( 'removeItem', () => {
-		test( 'should remove an item', () => {
-			db.one = 1;
-			db.two = 2;
-			db.three = 3;
-			localForage.removeItem( 'two' ).then( () => {
-				expect( db ).to.deep.equal( { one: 1, three: 3 } );
-			} );
-		} );
-
-		test( "should silently fail to remove item that doesn't exist", () => {
-			db.one = 1;
-			db.two = 2;
-			db.three = 3;
-			localForage.removeItem( 'four' ).then( () => {
-				expect( db ).to.deep.equal( {
-					one: 1,
-					two: 2,
-					three: 3,
-				} );
-			} );
-		} );
-	} );
-} );
diff --git a/client/lib/signup/test/step-actions.js b/client/lib/signup/test/step-actions.js
index e78a6fb4638819..9a6f9678fe1baf 100644
--- a/client/lib/signup/test/step-actions.js
+++ b/client/lib/signup/test/step-actions.js
@@ -13,9 +13,6 @@ import {
 import { useNock } from 'test/helpers/use-nock';
 import flows from 'signup/config/flows';
 
-// This is necessary since localforage will throw "no local storage method found" promise rejection without this.
-// See how lib/user-settings/test apply the same trick.
-jest.mock( 'lib/localforage', () => require( 'lib/localforage/localforage-bypass' ) );
 jest.mock( 'lib/abtest', () => ( { abtest: () => '' } ) );
 
 jest.mock( 'signup/config/steps', () => require( './mocks/signup/config/steps' ) );
diff --git a/client/lib/user-settings/test/index.js b/client/lib/user-settings/test/index.js
index 72bd85cf20dbba..2e4ac8a4cbcb3c 100644
--- a/client/lib/user-settings/test/index.js
+++ b/client/lib/user-settings/test/index.js
@@ -8,7 +8,6 @@
  */
 import userSettings from '..';
 
-jest.mock( 'lib/localforage', () => require( 'lib/localforage/localforage-bypass' ) );
 jest.mock( 'lib/wp', () => require( './mocks/wp' ) );
 jest.mock( 'lib/user/utils', () => require( './mocks/user-utils' ) );
 
diff --git a/client/my-sites/people/people-invite-details/test/index.jsx b/client/my-sites/people/people-invite-details/test/index.jsx
index ea43a3a265e03f..409cc063fca9dc 100644
--- a/client/my-sites/people/people-invite-details/test/index.jsx
+++ b/client/my-sites/people/people-invite-details/test/index.jsx
@@ -10,11 +10,6 @@ import React from 'react';
 import moment from 'moment';
 import { shallow } from 'enzyme';
 
-// Avoids a couple of warnings/errors from localforage and a network request:
-// - Unhandled promise rejection: Error: No available storage method found.
-// - superagent/lib/node/index.js:575 double callback!
-jest.mock( 'lib/user', () => () => {} );
-
 const mockGoBack = jest.fn();
 jest.mock( 'page', () => ( { back: mockGoBack } ) );
 
diff --git a/client/state/jetpack-connect/test/actions.js b/client/state/jetpack-connect/test/actions.js
index 6b374a2766da15..484a63375d0a9c 100644
--- a/client/state/jetpack-connect/test/actions.js
+++ b/client/state/jetpack-connect/test/actions.js
@@ -25,8 +25,6 @@ import {
 	SITE_RECEIVE,
 } from 'state/action-types';
 
-jest.mock( 'lib/localforage', () => require( 'lib/localforage/localforage-bypass' ) );
-
 describe( '#confirmJetpackInstallStatus()', () => {
 	test( 'should dispatch confirm status action when called', () => {
 		const { confirmJetpackInstallStatus } = actions;
@@ -400,8 +398,8 @@ describe( '#createAccount()', () => {
 		const userData = { username: 'happyuser' };
 		const data = { bearer_token: '1234 abcd' };
 		jest.spyOn( wpcom, 'undocumented' ).mockImplementation( () => ( {
-			async usersNew() {
-				return data;
+			usersNew() {
+				return Promise.resolve( data );
 			},
 		} ) );
 
@@ -415,8 +413,8 @@ describe( '#createAccount()', () => {
 		const userData = { username: 'happyuser' };
 		const error = { code: 'user_exists' };
 		jest.spyOn( wpcom, 'undocumented' ).mockImplementation( () => ( {
-			async usersNew() {
-				throw error;
+			usersNew() {
+				return Promise.reject( error );
 			},
 		} ) );
 
@@ -436,8 +434,8 @@ describe( '#createSocialAccount()', () => {
 			message: 'An error message',
 		};
 		jest.spyOn( wpcom, 'undocumented' ).mockImplementation( () => ( {
-			async usersSocialNew() {
-				throw error;
+			usersSocialNew() {
+				return Promise.reject( error );
 			},
 		} ) );
 
@@ -452,11 +450,11 @@ describe( '#createSocialAccount()', () => {
 		const bearerToken = 'foobar';
 		const username = 'a_happy_user';
 		jest.spyOn( wpcom, 'undocumented' ).mockImplementation( () => ( {
-			async usersSocialNew() {
-				return {
+			usersSocialNew() {
+				return Promise.resolve( {
 					bearer_token: bearerToken,
 					username,
-				};
+				} );
 			},
 		} ) );
 
diff --git a/client/state/test/initial-state.js b/client/state/test/initial-state.js
index 9f9a0c96813757..65117f0760e2da 100644
--- a/client/state/test/initial-state.js
+++ b/client/state/test/initial-state.js
@@ -13,7 +13,7 @@ import { useFakeTimers } from 'sinon';
  * Internal dependencies
  */
 import { isEnabled } from 'config';
-import localforage from 'lib/localforage';
+import * as browserStorage from 'lib/browser-storage';
 import userFactory from 'lib/user';
 import { isSupportSession } from 'lib/user/support-user-interop';
 import { SERIALIZE, DESERIALIZE } from 'state/action-types';
@@ -35,7 +35,6 @@ jest.mock( 'config', () => {
 	return config;
 } );
 
-jest.mock( 'lib/localforage', () => require( 'lib/localforage/localforage-bypass' ) );
 jest.mock( 'lib/user', () => () => ( {
 	get: () => ( {
 		ID: 123456789,
@@ -49,7 +48,7 @@ describe( 'initial-state', () => {
 	describe( 'getInitialState', () => {
 		describe( 'persist-redux disabled', () => {
 			describe( 'with recently persisted data and initial server data', () => {
-				let state, consoleErrorSpy, getItemSpy;
+				let state, consoleErrorSpy, getStoredItemSpy;
 
 				const savedState = {
 					currentUser: { id: 123456789 },
@@ -69,14 +68,16 @@ describe( 'initial-state', () => {
 				beforeAll( async () => {
 					window.initialReduxState = serverState;
 					consoleErrorSpy = jest.spyOn( global.console, 'error' );
-					getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+					getStoredItemSpy = jest
+						.spyOn( browserStorage, 'getStoredItem' )
+						.mockResolvedValue( savedState );
 					state = await getInitialState( initialReducer );
 				} );
 
 				afterAll( () => {
 					window.initialReduxState = null;
 					consoleErrorSpy.mockRestore();
-					getItemSpy.mockRestore();
+					getStoredItemSpy.mockRestore();
 				} );
 
 				test( 'builds initial state without errors', () => {
@@ -100,7 +101,7 @@ describe( 'initial-state', () => {
 		describe( 'persist-redux enabled', () => {
 			describe( 'switched user', () => {
 				describe( 'with recently persisted data and initial server data', () => {
-					let state, consoleErrorSpy, getItemSpy;
+					let state, consoleErrorSpy, getStoredItemSpy;
 
 					const savedState = {
 						currentUser: { id: 123456789 },
@@ -120,7 +121,9 @@ describe( 'initial-state', () => {
 						isSupportSession.mockReturnValue( true );
 						window.initialReduxState = { currentUser: { currencyCode: 'USD' } };
 						consoleErrorSpy = jest.spyOn( global.console, 'error' );
-						getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+						getStoredItemSpy = jest
+							.spyOn( browserStorage, 'getStoredItem' )
+							.mockResolvedValue( savedState );
 						state = await getInitialState( initialReducer );
 					} );
 
@@ -129,7 +132,7 @@ describe( 'initial-state', () => {
 						isSupportSession.mockReturnValue( false );
 						window.initialReduxState = null;
 						consoleErrorSpy.mockRestore();
-						getItemSpy.mockRestore();
+						getStoredItemSpy.mockRestore();
 					} );
 
 					test( 'builds initial state without errors', () => {
@@ -151,7 +154,7 @@ describe( 'initial-state', () => {
 			} );
 
 			describe( 'with recently persisted data and initial server data', () => {
-				let state, consoleErrorSpy, getItemSpy;
+				let state, consoleErrorSpy, getStoredItemSpy;
 
 				const savedState = {
 					currentUser: { id: 123456789 },
@@ -180,7 +183,9 @@ describe( 'initial-state', () => {
 					window.initialReduxState = serverState;
 					isEnabled.enablePersistRedux();
 					consoleErrorSpy = jest.spyOn( global.console, 'error' );
-					getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+					getStoredItemSpy = jest
+						.spyOn( browserStorage, 'getStoredItem' )
+						.mockResolvedValue( savedState );
 					state = await getInitialState( initialReducer );
 				} );
 
@@ -188,7 +193,7 @@ describe( 'initial-state', () => {
 					window.initialReduxState = null;
 					isEnabled.disablePersistRedux();
 					consoleErrorSpy.mockRestore();
-					getItemSpy.mockRestore();
+					getStoredItemSpy.mockRestore();
 				} );
 
 				test( 'builds initial state without errors', () => {
@@ -209,7 +214,7 @@ describe( 'initial-state', () => {
 			} );
 
 			describe( 'with stale persisted data and initial server data', () => {
-				let state, consoleErrorSpy, getItemSpy;
+				let state, consoleErrorSpy, getStoredItemSpy;
 
 				const savedState = {
 					currentUser: { id: 123456789 },
@@ -238,7 +243,9 @@ describe( 'initial-state', () => {
 					window.initialReduxState = serverState;
 					isEnabled.enablePersistRedux();
 					consoleErrorSpy = jest.spyOn( global.console, 'error' );
-					getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+					getStoredItemSpy = jest
+						.spyOn( browserStorage, 'getStoredItem' )
+						.mockResolvedValue( savedState );
 					state = await getInitialState( initialReducer );
 				} );
 
@@ -246,7 +253,7 @@ describe( 'initial-state', () => {
 					window.initialReduxState = null;
 					isEnabled.disablePersistRedux();
 					consoleErrorSpy.mockRestore();
-					getItemSpy.mockRestore();
+					getStoredItemSpy.mockRestore();
 				} );
 
 				test( 'builds store without errors', () => {
@@ -267,7 +274,7 @@ describe( 'initial-state', () => {
 			} );
 
 			describe( 'with recently persisted data and no initial server data', () => {
-				let state, consoleErrorSpy, getItemSpy;
+				let state, consoleErrorSpy, getStoredItemSpy;
 
 				const savedState = {
 					currentUser: { id: 123456789 },
@@ -288,7 +295,9 @@ describe( 'initial-state', () => {
 					window.initialReduxState = serverState;
 					isEnabled.enablePersistRedux();
 					consoleErrorSpy = jest.spyOn( global.console, 'error' );
-					getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+					getStoredItemSpy = jest
+						.spyOn( browserStorage, 'getStoredItem' )
+						.mockResolvedValue( savedState );
 					state = await getInitialState( initialReducer );
 				} );
 
@@ -296,7 +305,7 @@ describe( 'initial-state', () => {
 					window.initialReduxState = null;
 					isEnabled.disablePersistRedux();
 					consoleErrorSpy.mockRestore();
-					getItemSpy.mockRestore();
+					getStoredItemSpy.mockRestore();
 				} );
 
 				test( 'builds initial state without errors', () => {
@@ -314,7 +323,7 @@ describe( 'initial-state', () => {
 			} );
 
 			describe( 'with invalid persisted data and no initial server data', () => {
-				let state, consoleErrorSpy, getItemSpy;
+				let state, consoleErrorSpy, getStoredItemSpy;
 
 				const savedState = {
 					// Create an invalid state by forcing the user ID
@@ -338,7 +347,9 @@ describe( 'initial-state', () => {
 					window.initialReduxState = serverState;
 					isEnabled.enablePersistRedux();
 					consoleErrorSpy = jest.spyOn( global.console, 'error' );
-					getItemSpy = jest.spyOn( localforage, 'getItem' ).mockResolvedValue( savedState );
+					getStoredItemSpy = jest
+						.spyOn( browserStorage, 'getStoredItem' )
+						.mockResolvedValue( savedState );
 					state = await getInitialState( initialReducer );
 				} );
 
@@ -346,7 +357,7 @@ describe( 'initial-state', () => {
 					window.initialReduxState = null;
 					isEnabled.disablePersistRedux();
 					consoleErrorSpy.mockRestore();
-					getItemSpy.mockRestore();
+					getStoredItemSpy.mockRestore();
 				} );
 
 				test( 'builds initial state without errors', () => {
@@ -365,7 +376,7 @@ describe( 'initial-state', () => {
 	} );
 
 	describe( '#persistOnChange()', () => {
-		let store, clock, setItemSpy;
+		let store, clock, setStoredItemSpy;
 
 		const dataReducer = ( state = null, { data } ) => {
 			if ( data && data !== state ) {
@@ -394,8 +405,8 @@ describe( 'initial-state', () => {
 			// we use fake timers from Sinon (aka Lolex) because `lodash.throttle` also uses `Date.now()`
 			// and relies on it returning a mocked value. Jest fake timers don't mock `Date`, Lolex does.
 			clock = useFakeTimers();
-			setItemSpy = jest
-				.spyOn( localforage, 'setItem' )
+			setStoredItemSpy = jest
+				.spyOn( browserStorage, 'setStoredItem' )
 				.mockImplementation( value => Promise.resolve( value ) );
 
 			store = createReduxStore( initialState, reducer );
@@ -405,7 +416,7 @@ describe( 'initial-state', () => {
 		afterEach( () => {
 			isEnabled.enablePersistRedux();
 			clock.restore();
-			setItemSpy.mockRestore();
+			setStoredItemSpy.mockRestore();
 		} );
 
 		test( 'should persist state for first dispatch', () => {
@@ -416,7 +427,7 @@ describe( 'initial-state', () => {
 
 			clock.tick( SERIALIZE_THROTTLE );
 
-			expect( setItemSpy ).toHaveBeenCalledTimes( 1 );
+			expect( setStoredItemSpy ).toHaveBeenCalledTimes( 1 );
 		} );
 
 		test( 'should not persist invalid state', () => {
@@ -430,7 +441,7 @@ describe( 'initial-state', () => {
 
 			clock.tick( SERIALIZE_THROTTLE );
 
-			expect( setItemSpy ).toHaveBeenCalledTimes( 0 );
+			expect( setStoredItemSpy ).toHaveBeenCalledTimes( 0 );
 		} );
 
 		test( 'should persist state for changed state', () => {
@@ -448,7 +459,7 @@ describe( 'initial-state', () => {
 
 			clock.tick( SERIALIZE_THROTTLE );
 
-			expect( setItemSpy ).toHaveBeenCalledTimes( 2 );
+			expect( setStoredItemSpy ).toHaveBeenCalledTimes( 2 );
 		} );
 
 		test( 'should not persist state for unchanged state', () => {
@@ -466,7 +477,7 @@ describe( 'initial-state', () => {
 
 			clock.tick( SERIALIZE_THROTTLE );
 
-			expect( setItemSpy ).toHaveBeenCalledTimes( 1 );
+			expect( setStoredItemSpy ).toHaveBeenCalledTimes( 1 );
 		} );
 
 		test( 'should throttle', () => {
@@ -499,12 +510,12 @@ describe( 'initial-state', () => {
 
 			clock.tick( SERIALIZE_THROTTLE );
 
-			expect( setItemSpy ).toHaveBeenCalledTimes( 2 );
-			expect( setItemSpy ).toHaveBeenCalledWith(
+			expect( setStoredItemSpy ).toHaveBeenCalledTimes( 2 );
+			expect( setStoredItemSpy ).toHaveBeenCalledWith(
 				'redux-state-123456789',
 				expect.objectContaining( { data: 3 } )
 			);
-			expect( setItemSpy ).toHaveBeenCalledWith(
+			expect( setStoredItemSpy ).toHaveBeenCalledWith(
 				'redux-state-123456789',
 				expect.objectContaining( { data: 5 } )
 			);
@@ -534,7 +545,7 @@ describe( 'loading stored state with dynamic reducers', () => {
 	const currentUserReducer = ( state = { id: null } ) => state;
 	currentUserReducer.hasCustomPersistence = true;
 
-	let getItemSpy;
+	let getStoredItemSpy;
 
 	beforeEach( () => {
 		isEnabled.enablePersistRedux();
@@ -568,15 +579,15 @@ describe( 'loading stored state with dynamic reducers', () => {
 			},
 		};
 
-		// localforage mock to return mock IndexedDB state
-		getItemSpy = jest
-			.spyOn( localforage, 'getItem' )
+		// `lib/browser-storage` mock to return mock IndexedDB state
+		getStoredItemSpy = jest
+			.spyOn( browserStorage, 'getStoredItem' )
 			.mockImplementation( key => storedState[ key ] );
 	} );
 
 	afterEach( () => {
 		isEnabled.disablePersistRedux();
-		getItemSpy.mockRestore();
+		getStoredItemSpy.mockRestore();
 	} );
 
 	test( 'loads state from multiple storage keys', async () => {

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/localforage/test/localforage-bypass.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/signup/test/step-actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/user-settings/test/index.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/my-sites/people/people-invite-details/test/index.jsx ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/jetpack-connect/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/test/initial-state.js
: '>>>>> End Test Output'
git checkout d1c128c3c97e81421f8137c138a2a1b112d44c8b client/lib/localforage/test/localforage-bypass.js client/lib/signup/test/step-actions.js client/lib/user-settings/test/index.js client/my-sites/people/people-invite-details/test/index.jsx client/state/jetpack-connect/test/actions.js client/state/test/initial-state.js
