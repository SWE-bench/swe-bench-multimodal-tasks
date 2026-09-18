#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff bcc8e2ee4ec5a0d30fabc995d9ebeedfed0a8fe0
git checkout bcc8e2ee4ec5a0d30fabc995d9ebeedfed0a8fe0 client/lib/media/test/actions.js client/lib/posts/test/actions.js client/lib/posts/test/mocks/lib/wp.js client/lib/posts/test/post-edit-store.js client/lib/posts/test/utils.js client/post-editor/editor-word-count/test/index.jsx client/post-editor/test/post-editor.jsx client/state/posts/test/reducer.js client/state/posts/test/selectors.js client/state/posts/test/utils.js client/state/selectors/test/edited-post-has-content.js client/state/ui/editor/test/actions.js client/state/ui/editor/test/reducer.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/media/test/actions.js b/client/lib/media/test/actions.js
index c060112cba5bc..e5149b1e3858c 100644
--- a/client/lib/media/test/actions.js
+++ b/client/lib/media/test/actions.js
@@ -47,14 +47,17 @@ jest.mock( 'lib/impure-lodash', () => ( {
 	uniqueId: () => 'media-1',
 } ) );
 
+let mockReduxPostId = null;
+jest.mock( 'lib/redux-bridge', () => ( {
+	reduxGetState: () => ( { ui: { editor: { postId: mockReduxPostId } } } ),
+} ) );
+
 describe( 'MediaActions', () => {
-	let MediaActions, sandbox, Dispatcher, PostEditStore, MediaListStore;
+	let MediaActions, sandbox, Dispatcher, MediaListStore;
 
 	beforeAll( function() {
 		Dispatcher = require( 'dispatcher' );
-		PostEditStore = require( 'lib/posts/post-edit-store' );
 		MediaListStore = require( '../list-store' );
-
 		MediaActions = require( '../actions' );
 	} );
 
@@ -73,6 +76,7 @@ describe( 'MediaActions', () => {
 		MediaActions._fetching = {};
 		window.FileList = function() {};
 		window.URL = { createObjectURL: sandbox.stub() };
+		mockReduxPostId = null;
 	} );
 
 	afterEach( () => {
@@ -250,7 +254,7 @@ describe( 'MediaActions', () => {
 		} );
 
 		test( 'should attach file upload to a post if one is being edited', () => {
-			sandbox.stub( PostEditStore, 'get' ).returns( { ID: 200 } );
+			mockReduxPostId = 200;
 
 			return MediaActions.add( site, DUMMY_UPLOAD ).then( () => {
 				expect( stubs.mediaAdd ).to.have.been.calledWithMatch(
@@ -264,7 +268,7 @@ describe( 'MediaActions', () => {
 		} );
 
 		test( 'should attach URL upload to a post if one is being edited', () => {
-			sandbox.stub( PostEditStore, 'get' ).returns( { ID: 200 } );
+			mockReduxPostId = 200;
 
 			return MediaActions.add( site, DUMMY_URL ).then( () => {
 				expect( stubs.mediaAddUrls ).to.have.been.calledWithMatch(
diff --git a/client/lib/posts/test/actions.js b/client/lib/posts/test/actions.js
deleted file mode 100644
index 236be2dd10bf2..0000000000000
--- a/client/lib/posts/test/actions.js
+++ /dev/null
@@ -1,101 +0,0 @@
-/**
- * @format
- * @jest-environment jsdom
- */
-
-/**
- * External dependencies
- */
-import sinon from 'sinon';
-
-/**
- * Internal dependencies
- */
-import PostActions from '../actions';
-import PostEditStore from '../post-edit-store';
-import Dispatcher from 'dispatcher';
-
-jest.mock( 'lib/localforage', () => require( 'lib/localforage/localforage-bypass' ) );
-jest.mock( 'lib/wp', () => require( './mocks/lib/wp' ) );
-
-jest.mock( 'lib/redux-bridge', () => ( {
-	reduxDispatch: action => action,
-	reduxGetState: () => ( { ui: { editor: { saveBlockers: [] } } } ),
-} ) );
-
-describe( 'actions', () => {
-	let sandbox;
-
-	beforeAll( () => {
-		sandbox = sinon.sandbox.create();
-	} );
-
-	beforeEach( () => {
-		sandbox.stub( Dispatcher, 'handleServerAction' );
-		sandbox.stub( Dispatcher, 'handleViewAction' );
-		sandbox.stub( PostEditStore, 'get' ).returns( {
-			metadata: [],
-		} );
-	} );
-
-	afterEach( () => {
-		sandbox.restore();
-	} );
-
-	describe( '#saveEdited()', () => {
-		test( 'should not send a request if the post has no content', () => {
-			sandbox.stub( PostEditStore, 'hasContent' ).returns( false );
-
-			const saveResult = PostActions.saveEdited( null );
-			return expect( saveResult ).rejects.toThrow( 'NO_CONTENT' );
-		} );
-
-		test( 'should not send a request if there are no changed attributes', () => {
-			sandbox.stub( PostEditStore, 'hasContent' ).returns( true );
-			sandbox.stub( PostEditStore, 'getChangedAttributes' ).returns( {} );
-
-			const saveResult = PostActions.saveEdited( null );
-			return expect( saveResult ).resolves.toBeUndefined();
-		} );
-
-		test( 'should normalize attributes and call the API', async () => {
-			sandbox.stub( PostEditStore, 'hasContent' ).returns( true );
-
-			const changedAttributes = {
-				ID: 777,
-				site_ID: 123,
-				author: {
-					ID: 3,
-				},
-				title: 'OMG Unicorns',
-				terms: {
-					category: [
-						{
-							ID: 7,
-							name: 'ribs',
-						},
-					],
-				},
-			};
-
-			const normalizedAttributes = {
-				ID: 777,
-				site_ID: 123,
-				author: 3,
-				title: 'OMG Unicorns',
-				terms: {},
-			};
-
-			sandbox.stub( PostEditStore, 'getChangedAttributes' ).returns( changedAttributes );
-
-			const saveResult = PostActions.saveEdited( null );
-			await expect( saveResult ).resolves.toBeUndefined();
-
-			sinon.assert.calledTwice( Dispatcher.handleViewAction );
-			sinon.assert.calledWithMatch( Dispatcher.handleServerAction, {
-				type: 'RECEIVE_POST_BEING_EDITED',
-				post: normalizedAttributes,
-			} );
-		} );
-	} );
-} );
diff --git a/client/lib/posts/test/mocks/lib/wp.js b/client/lib/posts/test/mocks/lib/wp.js
deleted file mode 100644
index 7e32923c37c3b..0000000000000
--- a/client/lib/posts/test/mocks/lib/wp.js
+++ /dev/null
@@ -1,11 +0,0 @@
-/** @format */
-export default {
-	me: () => ( {
-		get: () => {},
-	} ),
-	site: () => ( {
-		post: () => ( {
-			add: async ( query, attributes ) => attributes,
-		} ),
-	} ),
-};
diff --git a/client/lib/posts/test/post-edit-store.js b/client/lib/posts/test/post-edit-store.js
deleted file mode 100644
index d8d8109be6b31..0000000000000
--- a/client/lib/posts/test/post-edit-store.js
+++ /dev/null
@@ -1,875 +0,0 @@
-/**
- * @format
- * @jest-environment jsdom
- */
-
-/**
- * External dependencies
- */
-import assert from 'assert'; // eslint-disable-line import/no-nodejs-modules
-import { assign, isEqual } from 'lodash';
-import { spy } from 'sinon';
-
-/**
- * Internal dependencies
- */
-import Dispatcher from 'dispatcher';
-
-jest.mock( 'lib/user', () => () => {} );
-
-describe( 'post-edit-store', () => {
-	let PostEditStore, dispatcherCallback;
-
-	beforeAll( () => {
-		spy( Dispatcher, 'register' );
-		PostEditStore = require( '../post-edit-store' );
-		dispatcherCallback = Dispatcher.register.lastCall.args[ 0 ];
-	} );
-
-	afterAll( () => {
-		Dispatcher.register.restore();
-	} );
-
-	function dispatchReceivePost() {
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_TO_EDIT',
-				post: {
-					ID: 777,
-					site_ID: 123,
-					title: 'OMG Unicorns',
-					categories: {
-						Unicorns: {
-							ID: 199,
-							name: 'Unicorns',
-						},
-					},
-				},
-			},
-		} );
-	}
-
-	test( 'initializes new draft post properly', () => {
-		const siteId = 1234;
-
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				site: {
-					ID: siteId,
-				},
-			},
-		} );
-
-		assert( PostEditStore.getSavedPost().ID === undefined );
-		assert( PostEditStore.getSavedPost().site_ID === siteId );
-		const post = PostEditStore.get();
-		assert( post.status === 'draft' );
-	} );
-
-	test( 'reset the currently edited post and prepare to edit a new one', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'START_EDITING_POST',
-			},
-		} );
-
-		assert( PostEditStore.getSavedPost() == null );
-		assert( PostEditStore.isLoading() );
-	} );
-
-	test( 'sets parent_id properly', () => {
-		dispatchReceivePost();
-		const post = PostEditStore.get();
-		assert( post.parent_id === null );
-	} );
-
-	test( 'decodes entities on received post title', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				title: 'Ribs &amp; Chicken',
-			},
-		} );
-
-		assert( PostEditStore.get().title === 'Ribs & Chicken' );
-	} );
-
-	test( 'updates parent_id after a set', () => {
-		dispatchReceivePost();
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					parent: 101,
-				},
-			},
-		} );
-
-		const post = PostEditStore.get();
-		assert( post.parent_id, 101 );
-	} );
-
-	test( 'does not decode post title entities on EDIT_POST', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					title: 'Ribs &gt; Chicken',
-				},
-			},
-		} );
-
-		assert( PostEditStore.get().title === 'Ribs &gt; Chicken' );
-	} );
-
-	test( 'decodes post title entities on RECEIVE_POST_BEING_EDITED', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_BEING_EDITED',
-				post: {
-					title: 'Ribs &gt; Chicken',
-				},
-			},
-		} );
-
-		assert( PostEditStore.get().title === 'Ribs > Chicken' );
-	} );
-
-	test( 'reset on stop editing', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				site: {
-					ID: 1234,
-				},
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					title: 'hello, world!',
-					content: 'initial edit',
-				},
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'STOP_EDITING_POST',
-			},
-		} );
-
-		assert( PostEditStore.get() === null );
-		assert( PostEditStore.getSavedPost() === null );
-	} );
-
-	test( 'updates attributes on edit', () => {
-		const siteId = 1234,
-			postEdits = {
-				title: 'hello, world!',
-				content: 'initial edit',
-				metadata: [ { key: 'super', value: 'duper', operation: 'update' } ],
-			};
-
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				site: {
-					ID: siteId,
-				},
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: postEdits,
-			},
-		} );
-
-		assert( PostEditStore.getSavedPost().ID === undefined );
-		assert( PostEditStore.getSavedPost().title === '' );
-		assert( PostEditStore.get().title === postEdits.title );
-		assert( PostEditStore.get().content === postEdits.content );
-		assert( isEqual( PostEditStore.get().metadata, postEdits.metadata ) );
-		assert( PostEditStore.getChangedAttributes().title === postEdits.title );
-		assert( PostEditStore.getChangedAttributes().content === postEdits.content );
-		assert( isEqual( PostEditStore.getChangedAttributes().metadata, postEdits.metadata ) );
-	} );
-
-	test( 'preserves attributes when update is in-flight', () => {
-		const siteId = 1234,
-			initialPost = {
-				ID: 2345,
-				title: 'hello, world!',
-				content: 'initial edit',
-			},
-			updates = {
-				content: 'updated content',
-			};
-
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				site: {
-					ID: siteId,
-				},
-			},
-		} );
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: initialPost,
-			},
-		} );
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST_SAVE',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: updates,
-			},
-		} );
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_BEING_EDITED',
-				post: initialPost,
-			},
-		} );
-
-		assert( PostEditStore.get().content === updates.content );
-		assert( PostEditStore.isDirty() );
-	} );
-
-	test( 'updates existing metadata on edit', () => {
-		// initial post
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_TO_EDIT',
-				post: {
-					ID: 1234,
-					metadata: [
-						{ key: 'keepable', value: 'constvalue' },
-						{ key: 'updatable', value: 'oldvalue' },
-						{ key: 'deletable', value: 'trashvalue' },
-					],
-				},
-			},
-		} );
-
-		// apply some edits
-		const postEdits = {
-			title: 'Super Duper',
-			metadata: [
-				{ key: 'updatable', value: 'newvalue', operation: 'update' },
-				{ key: 'deletable', operation: 'delete' },
-			],
-		};
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: postEdits,
-			},
-		} );
-
-		// check the expected values of post attributes after the edit is applied
-		assert( PostEditStore.get().title === postEdits.title );
-		assert(
-			isEqual( PostEditStore.get().metadata, [
-				{ key: 'keepable', value: 'constvalue' },
-				{ key: 'updatable', value: 'newvalue', operation: 'update' },
-				{ key: 'deletable', operation: 'delete' },
-			] )
-		);
-
-		// check the modifications sent to the API endpoint
-		assert( PostEditStore.getChangedAttributes().title === postEdits.title );
-		assert(
-			isEqual( PostEditStore.getChangedAttributes().metadata, [
-				{ key: 'updatable', value: 'newvalue', operation: 'update' },
-				{ key: 'deletable', operation: 'delete' },
-			] )
-		);
-	} );
-
-	test( 'should include metadata edits made previously', () => {
-		// initial post
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_TO_EDIT',
-				post: {
-					ID: 1234,
-					metadata: [ { key: 'deletable', value: 'trashvalue' } ],
-				},
-			},
-		} );
-
-		// first edit
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					metadata: [ { key: 'deletable', operation: 'delete' } ],
-				},
-			},
-		} );
-
-		// second edit
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					metadata: [ { key: 'updatable', value: 'newvalue', operation: 'update' } ],
-				},
-			},
-		} );
-
-		assert(
-			isEqual( PostEditStore.get().metadata, [
-				{ key: 'deletable', operation: 'delete' },
-				{ key: 'updatable', value: 'newvalue', operation: 'update' },
-			] )
-		);
-	} );
-
-	test( 'should not duplicate existing metadata edits', () => {
-		// initial post
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_TO_EDIT',
-				post: {
-					ID: 1234,
-					metadata: [
-						{ key: 'keepable', value: 'constvalue' },
-						{ key: 'phoenixable', value: 'fawkes' },
-					],
-				},
-			},
-		} );
-
-		// delete metadata prop
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					metadata: [ { key: 'phoenixable', operation: 'delete' } ],
-				},
-			},
-		} );
-
-		// recreate the prop
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: {
-					metadata: [ { key: 'phoenixable', value: 'newfawkes', operation: 'update' } ],
-				},
-			},
-		} );
-
-		// edited post metadata after edits
-		assert(
-			isEqual( PostEditStore.get().metadata, [
-				{ key: 'keepable', value: 'constvalue' },
-				{ key: 'phoenixable', value: 'newfawkes', operation: 'update' },
-			] )
-		);
-
-		// metadata update request sent to the API endpoint
-		assert(
-			isEqual( PostEditStore.getChangedAttributes().metadata, [
-				{ key: 'phoenixable', value: 'newfawkes', operation: 'update' },
-			] )
-		);
-	} );
-
-	test( 'reset post after saving an edit', () => {
-		const siteId = 1234;
-		const postId = 5678;
-		const postEdits = {
-			title: 'hello, world!',
-			content: 'initial edit',
-		};
-
-		dispatcherCallback( {
-			action: {
-				type: 'DRAFT_NEW_POST',
-				site: {
-					ID: siteId,
-				},
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST',
-				post: postEdits,
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_BEING_EDITED',
-				post: assign( { ID: postId }, postEdits ),
-			},
-		} );
-
-		assert( PostEditStore.getSavedPost().ID === postId );
-		assert( PostEditStore.getSavedPost().title === postEdits.title );
-		assert( PostEditStore.getSavedPost().content === postEdits.content );
-		assert( PostEditStore.get().title === postEdits.title );
-		assert( PostEditStore.get().content === postEdits.content );
-		assert( PostEditStore.getChangedAttributes().title === undefined );
-		assert( PostEditStore.getChangedAttributes().content === undefined );
-		assert( PostEditStore.getChangedAttributes().metadata === undefined );
-	} );
-
-	test( 'resets raw content when receiving an updated post', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_TO_EDIT',
-				post: { content: 'bar' },
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST_RAW_CONTENT',
-				content: 'foo',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'RECEIVE_POST_BEING_EDITED',
-				post: { content: 'bar' },
-			},
-		} );
-
-		assert( ! PostEditStore.isDirty() );
-	} );
-
-	test( 'resets raw content on RESET_POST_RAW_CONTENT', () => {
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST_RAW_CONTENT',
-				content: 'foo',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'EDIT_POST_RAW_CONTENT',
-				content: 'bar',
-			},
-		} );
-
-		dispatcherCallback( {
-			action: {
-				type: 'RESET_POST_RAW_CONTENT',
-			},
-		} );
-
-		assert( ! PostEditStore.isDirty() );
-	} );
-
-	describe( '#setRawContent', () => {
-		test( "should not emit a change event if content hasn't changed", () => {
-			const onChange = spy();
-
-			dispatcherCallback( {
-				action: {
-					type: 'RECEIVE_POST_TO_EDIT',
-					post: {},
-				},
-			} );
-
-			PostEditStore.on( 'change', onChange );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: 'foo',
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: 'foo',
-				},
-			} );
-
-			PostEditStore.off( 'change', onChange );
-
-			assert( ! PostEditStore.isDirty() );
-			assert( onChange.callCount === 1 );
-		} );
-	} );
-
-	describe( '#getChangedAttributes()', () => {
-		test( 'includes status for a new post', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			assert( PostEditStore.getChangedAttributes().status === 'draft' );
-		} );
-
-		test( 'includes all attributes on a new post', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			assert(
-				isEqual( PostEditStore.getChangedAttributes(), {
-					site_ID: 1,
-					status: 'draft',
-					type: 'post',
-					parent_id: null,
-					title: '',
-					content: '',
-				} )
-			);
-		} );
-	} );
-
-	describe( '#isDirty()', () => {
-		test( 'returns false for a new post', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			assert( ! PostEditStore.isDirty() );
-		} );
-
-		test( 'returns false if the edited post is unchanged', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'RECEIVE_POST_TO_EDIT',
-					post: {},
-				},
-			} );
-
-			assert( ! PostEditStore.isDirty() );
-		} );
-
-		test( 'returns true if raw content changes over time', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'RECEIVE_POST_TO_EDIT',
-					post: {},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '',
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: 'foo',
-				},
-			} );
-
-			assert( PostEditStore.isDirty() );
-		} );
-	} );
-
-	describe( '#hasContent()', () => {
-		test( 'returns false for new post', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-
-		test( 'returns true if title is set', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { title: 'Draft' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === true );
-		} );
-
-		test( 'returns false if title is whitespace', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { title: ' ' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-
-		test( 'returns true if excerpt is set', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { excerpt: 'Excerpt' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === true );
-		} );
-
-		test( 'returns false if content includes bogus line break', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { content: '<p><br data-mce-bogus="1"></p>' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-
-		test( 'returns false if content includes non-breaking space', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { content: '<p>&nbsp;</p>' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-
-		test( 'returns false if content includes empty paragraph', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { content: '<p> </p>' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-
-		test( 'returns true if content is set', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { content: '<p>Hello World</p>' },
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === true );
-		} );
-
-		test( 'returns true if raw content is set', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '<p>Hello World</p>',
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === true );
-		} );
-
-		test( 'returns false if post content exists, but raw content is empty', () => {
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST',
-					siteId: 1,
-					post: { content: '<p>Hello World</p>' },
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '<p></p>',
-				},
-			} );
-
-			assert( PostEditStore.hasContent() === false );
-		} );
-	} );
-
-	describe( 'rawContent', () => {
-		afterAll( function() {
-			PostEditStore.removeAllListeners();
-		} );
-
-		test( "should not trigger changes if isDirty() and hadContent() don't change", () => {
-			let called = false;
-
-			dispatcherCallback( {
-				action: {
-					type: 'DRAFT_NEW_POST',
-					site: {
-						ID: 1,
-					},
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '<p>H</p>',
-				},
-			} );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '<p>Hello</p>',
-				},
-			} );
-
-			function callback() {
-				called = true;
-			}
-
-			PostEditStore.on( 'change', callback );
-
-			dispatcherCallback( {
-				action: {
-					type: 'EDIT_POST_RAW_CONTENT',
-					content: '<p>Hello World!</p>',
-				},
-			} );
-
-			assert( called === false );
-		} );
-	} );
-} );
diff --git a/client/lib/posts/test/utils.js b/client/lib/posts/test/utils.js
index 4ca66c4a7d865..8efa3e5e439fc 100644
--- a/client/lib/posts/test/utils.js
+++ b/client/lib/posts/test/utils.js
@@ -8,8 +8,6 @@
  */
 import * as postUtils from '../utils';
 
-jest.mock( 'lib/wp', () => require( './mocks/lib/wp' ) );
-
 describe( 'utils', () => {
 	describe( '#getEditURL', () => {
 		test( 'should return correct path type=post is supplied', () => {
@@ -61,8 +59,8 @@ describe( 'utils', () => {
 	} );
 
 	describe( '#isPrivate', () => {
-		test( 'should return undefined when no post is supplied', () => {
-			expect( postUtils.isPrivate() ).toBeUndefined();
+		test( 'should return false when no post is supplied', () => {
+			expect( postUtils.isPrivate() ).toBe( false );
 		} );
 
 		test( 'should return true when post.status is private', () => {
@@ -75,8 +73,8 @@ describe( 'utils', () => {
 	} );
 
 	describe( '#isPublished', () => {
-		test( 'should return undefined when no post is supplied', () => {
-			expect( postUtils.isPublished() ).toBeUndefined();
+		test( 'should return false when no post is supplied', () => {
+			expect( postUtils.isPublished() ).toBe( false );
 		} );
 
 		test( 'should return true when post.status is private', () => {
@@ -93,8 +91,8 @@ describe( 'utils', () => {
 	} );
 
 	describe( '#isPending', () => {
-		test( 'should return undefined when no post is supplied', () => {
-			expect( postUtils.isPending() ).toBeUndefined();
+		test( 'should return false when no post is supplied', () => {
+			expect( postUtils.isPending() ).toBe( false );
 		} );
 
 		test( 'should return true when post.status is pending', () => {
diff --git a/client/post-editor/editor-word-count/test/index.jsx b/client/post-editor/editor-word-count/test/index.jsx
index 7849df66fdaf2..e9b0ea0f410ed 100644
--- a/client/post-editor/editor-word-count/test/index.jsx
+++ b/client/post-editor/editor-word-count/test/index.jsx
@@ -16,30 +16,29 @@ import React from 'react';
  */
 import { EditorWordCount } from '../';
 
-jest.mock( 'lib/wp', () => ( {
-	me: () => ( {
-		get: () => {},
-	} ),
-} ) );
-
 describe( 'EditorWordCount', () => {
 	test( 'should display word count if selected text is provided', () => {
 		const wrapper = mount(
-			<EditorWordCount selectedText={ 'Selected text' } translate={ translate } />
+			<EditorWordCount
+				rawContent="Selected text"
+				selectedText="Selected text"
+				translate={ translate }
+			/>
 		);
-		wrapper.setState( { rawContent: 'Selected text' } );
 		expect( wrapper.text() ).to.equal( '2 words selected / 2 words' );
 	} );
 
 	test( 'should not display word count if no selected text is provided', () => {
-		const wrapper = mount( <EditorWordCount selectedText={ null } translate={ translate } /> );
-		wrapper.setState( { rawContent: 'Selected text' } );
+		const wrapper = mount(
+			<EditorWordCount rawContent="Selected text" selectedText={ null } translate={ translate } />
+		);
 		expect( wrapper.text() ).to.equal( '2 words' );
 	} );
 
 	test( 'should display 0 words if no content in post', () => {
-		const wrapper = mount( <EditorWordCount selectedText={ null } translate={ translate } /> );
-		wrapper.setState( { rawContent: '' } );
+		const wrapper = mount(
+			<EditorWordCount rawContent="" selectedText={ null } translate={ translate } />
+		);
 		expect( wrapper.text() ).to.equal( '0 words' );
 	} );
 } );
diff --git a/client/post-editor/test/post-editor.jsx b/client/post-editor/test/post-editor.jsx
deleted file mode 100644
index ae09f5a7171ac..0000000000000
--- a/client/post-editor/test/post-editor.jsx
+++ /dev/null
@@ -1,187 +0,0 @@
-/**
- * @format
- * @jest-environment jsdom
- */
-
-/**
- * External dependencies
- */
-import { shallow } from 'enzyme';
-import { expect } from 'chai';
-import React from 'react';
-import { renderIntoDocument } from 'react-dom/test-utils';
-
-/**
- * Internal dependencies
- */
-import { PostEditor } from '../post-editor';
-import PostEditStore from 'lib/posts/post-edit-store';
-import { useSandbox } from 'test/helpers/use-sinon';
-
-jest.mock( 'components/tinymce', () => require( 'components/empty-component' ) );
-jest.mock( 'components/popover', () => require( 'components/empty-component' ) );
-jest.mock( 'components/forms/clipboard-button', () => require( 'components/empty-component' ) );
-jest.mock( 'components/notice/notice-action', () => require( 'components/empty-component' ) );
-jest.mock( 'components/notice', () => require( 'components/empty-component' ) );
-jest.mock( 'components/segmented-control', () => require( 'components/empty-component' ) );
-jest.mock( 'components/segmented-control/item', () => require( 'components/empty-component' ) );
-jest.mock( 'lib/preferences/actions', () => ( {
-	set() {},
-} ) );
-jest.mock( 'lib/user', () => () => {} );
-jest.mock( 'lib/wp', () => ( {
-	undocumented: () => {},
-} ) );
-jest.mock( 'post-editor/editor-document-head', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-action-bar', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-drawer', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-featured-image', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-ground-control', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-title', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-page-slug', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-media-advanced', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-author', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-visibility', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-word-count', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-preview', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/invalid-url-dialog', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/restore-post-dialog', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-sidebar', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-status-label', () => require( 'components/empty-component' ) );
-jest.mock( 'post-editor/editor-revisions/dialog', () => require( 'components/empty-component' ) );
-jest.mock( 'query', () => require( 'component-query' ), { virtual: true } );
-jest.mock( 'tinymce/tinymce', () => require( 'components/empty-component' ) );
-// TODO: REDUX - add proper tests when whole post-editor is reduxified
-jest.mock( 'react-redux', () => ( {
-	connect: () => component => component,
-} ) );
-
-describe( 'PostEditor', () => {
-	let sandbox;
-	const defaultProps = {
-		translate: string => string,
-		markSaved: () => {},
-		markChanged: () => {},
-		setLayoutFocus: () => {},
-		setNextLayoutFocus: () => {},
-		setNestedSidebar: () => {},
-		preferences: {},
-	};
-
-	useSandbox( newSandbox => ( sandbox = newSandbox ) );
-
-	afterEach( () => {
-		sandbox.restore();
-	} );
-
-	describe( 'onEditedPostChange', () => {
-		test( 'should clear content when store state transitions to new post', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			sandbox.stub( PostEditStore, 'getSavedPost' ).returns( {} );
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.onEditedPostChange();
-			expect( tree.editor.setEditorContent ).to.have.been.calledWith( '' );
-		} );
-
-		test( 'should not clear content when store state already has a new post', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			sandbox.stub( PostEditStore, 'getSavedPost' ).returns( {} );
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.setState( { savedPost: {} } );
-			tree.onEditedPostChange();
-			expect( tree.editor.setEditorContent ).to.not.have.been.called;
-		} );
-
-		test( 'should clear content when loading', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			sandbox.stub( PostEditStore, 'isLoading' ).returns( true );
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.onEditedPostChange();
-			expect( tree.editor.setEditorContent ).to.have.been.calledWith( '' );
-		} );
-
-		test( 'should set content after load', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			const content = 'loaded post';
-			sandbox.stub( PostEditStore, 'get' ).returns( { content } );
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.setState( { isLoading: true } );
-			tree.onEditedPostChange();
-			expect( tree.editor.setEditorContent ).to.have.been.calledWith( content );
-		} );
-
-		test( 'a normal content change should not clear content', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			const content = 'new content';
-			sandbox.stub( PostEditStore, 'get' ).returns( { content } );
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.setState( { post: { content: 'old content' } } );
-			tree.onEditedPostChange();
-
-			expect( tree.editor.setEditorContent ).to.not.have.been.called;
-		} );
-
-		test( 'is a copy and it should set the copied content', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			const content = 'copied content';
-			tree.setState( {
-				savedPost: {},
-				hasContent: true,
-				isDirty: false,
-			} );
-
-			sandbox.stub( PostEditStore, 'get' ).returns( { content } );
-
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.onEditedPostChange();
-
-			expect( tree.editor.setEditorContent ).to.have.been.calledWith( content );
-		} );
-
-		test( 'should not set the copied content more than once', () => {
-			const tree = renderIntoDocument( <PostEditor { ...defaultProps } /> );
-
-			const content = 'copied content';
-			tree.setState( {
-				isNew: true,
-				hasContent: true,
-				isDirty: true,
-			} );
-
-			sandbox.stub( PostEditStore, 'get' ).returns( { content: content } );
-
-			tree.editor = { setEditorContent: sandbox.spy() };
-			tree.onEditedPostChange();
-
-			expect( tree.editor.setEditorContent ).to.not.have.been.called;
-		} );
-	} );
-
-	describe( '#onEditorContentChange()', () => {
-		test( 'triggers a pending raw content and autosave, canceled on save', () => {
-			const wrapper = shallow( <PostEditor { ...defaultProps } /> );
-
-			wrapper.instance().debouncedAutosave = sandbox.stub();
-			wrapper.instance().debouncedAutosave.cancel = sandbox.stub();
-			wrapper.instance().throttledAutosave = sandbox.stub();
-			wrapper.instance().throttledAutosave.cancel = sandbox.stub();
-			wrapper.instance().debouncedSaveRawContent = sandbox.stub();
-
-			wrapper.instance().onEditorContentChange();
-
-			expect( wrapper.instance().debouncedAutosave ).to.have.been.called;
-			expect( wrapper.instance().debouncedSaveRawContent ).to.have.been.called;
-
-			wrapper.setState( { isSaving: true } );
-
-			expect( wrapper.instance().debouncedAutosave.cancel ).to.have.been.called;
-			expect( wrapper.instance().throttledAutosave.cancel ).to.have.been.called;
-		} );
-	} );
-} );
diff --git a/client/state/posts/test/reducer.js b/client/state/posts/test/reducer.js
index 1c59e77648a12..82f75a3317370 100644
--- a/client/state/posts/test/reducer.js
+++ b/client/state/posts/test/reducer.js
@@ -261,7 +261,9 @@ describe( 'reducer', () => {
 						site_ID: 2916284,
 						global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
 						title: 'Hello World',
-						meta: {},
+						meta: {
+							links: {},
+						},
 					},
 				],
 			} );
@@ -274,6 +276,7 @@ describe( 'reducer', () => {
 					site_ID: 2916284,
 					global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
 					title: 'Hello World',
+					meta: {},
 				},
 			] );
 		} );
@@ -1502,9 +1505,7 @@ describe( 'reducer', () => {
 
 			expect( state ).to.eql( {
 				2916284: {
-					841: {
-						type: 'jetpack-testimonial',
-					},
+					841: null,
 					'': {
 						title: 'Ribs & Chicken',
 					},
@@ -1534,7 +1535,9 @@ describe( 'reducer', () => {
 						site_ID: 2916284,
 						global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
 						title: 'Hello World',
-						meta: {},
+						meta: {
+							links: {},
+						},
 					},
 				],
 			} );
@@ -1545,6 +1548,7 @@ describe( 'reducer', () => {
 					site_ID: 2916284,
 					global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
 					title: 'Hello World',
+					meta: {},
 				},
 			] );
 		} );
diff --git a/client/state/posts/test/selectors.js b/client/state/posts/test/selectors.js
index ffdb39d9e7f2e..9de2dfc9f7f03 100644
--- a/client/state/posts/test/selectors.js
+++ b/client/state/posts/test/selectors.js
@@ -1812,6 +1812,11 @@ describe( 'selectors', () => {
 						},
 						edits: {},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -1844,6 +1849,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -1865,6 +1875,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284
 			);
@@ -1885,6 +1900,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284
 			);
@@ -1905,6 +1925,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284
 			);
@@ -1925,6 +1950,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284
 			);
@@ -1956,6 +1986,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -1964,6 +1999,46 @@ describe( 'selectors', () => {
 			expect( isDirty ).to.be.false;
 		} );
 
+		test( 'should return true if edited post is unchanged but the raw content is different', () => {
+			const isDirty = isEditedPostDirty(
+				{
+					posts: {
+						queries: {
+							2916284: new PostQueryManager( {
+								items: {
+									841: {
+										ID: 841,
+										site_ID: 2916284,
+										global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
+										content: 'Hello World',
+									},
+								},
+							} ),
+						},
+						edits: {
+							2916284: {
+								841: {
+									content: 'Hello World',
+								},
+							},
+						},
+					},
+					ui: {
+						editor: {
+							rawContent: {
+								initial: 'Hello World',
+								current: 'Hello World!',
+							},
+						},
+					},
+				},
+				2916284,
+				841
+			);
+
+			expect( isDirty ).to.be.true;
+		} );
+
 		test( 'should return true if saved post value does not equal edited post value', () => {
 			const isDirty = isEditedPostDirty(
 				{
@@ -1988,6 +2063,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2019,6 +2099,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2053,6 +2138,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2085,6 +2175,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2117,6 +2212,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2157,6 +2257,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2197,6 +2302,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2235,6 +2345,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2270,6 +2385,11 @@ describe( 'selectors', () => {
 							},
 						},
 					},
+					ui: {
+						editor: {
+							rawContent: {},
+						},
+					},
 				},
 				2916284,
 				841
@@ -2313,6 +2433,11 @@ describe( 'selectors', () => {
 							queries,
 							edits: updateEdits,
 						},
+						ui: {
+							editor: {
+								rawContent: {},
+							},
+						},
 					},
 					2916284,
 					841
@@ -2335,6 +2460,11 @@ describe( 'selectors', () => {
 							queries,
 							edits: deleteEdits,
 						},
+						ui: {
+							editor: {
+								rawContent: {},
+							},
+						},
 					},
 					2916284,
 					841
@@ -2373,6 +2503,11 @@ describe( 'selectors', () => {
 								},
 							},
 						},
+						ui: {
+							editor: {
+								rawContent: {},
+							},
+						},
 					},
 					2916284,
 					841
@@ -2428,6 +2563,11 @@ describe( 'selectors', () => {
 					queries: queries1,
 					edits,
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			};
 
 			const state2 = {
@@ -2436,6 +2576,11 @@ describe( 'selectors', () => {
 					queries: queries2,
 					edits,
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			};
 
 			// there are edits that change the post
diff --git a/client/state/posts/test/utils.js b/client/state/posts/test/utils.js
index cef68ec987257..a342217d1b7b3 100644
--- a/client/state/posts/test/utils.js
+++ b/client/state/posts/test/utils.js
@@ -172,23 +172,30 @@ describe( 'utils', () => {
 	} );
 
 	describe( 'normalizePostForState()', () => {
-		test( 'should deeply unset all meta', () => {
+		test( 'should deeply unset all meta links', () => {
 			const original = deepFreeze( {
 				ID: 814,
-				meta: {},
+				meta: {
+					links: {},
+					data: { autosave: true },
+				},
 				terms: {
 					category: {
 						meta: {
 							ID: 171,
 							name: 'meta',
-							meta: {},
+							meta: {
+								links: {},
+							},
 						},
 					},
 					post_tag: {
 						meta: {
 							ID: 171,
 							name: 'meta',
-							meta: {},
+							meta: {
+								links: {},
+							},
 						},
 					},
 				},
@@ -196,20 +203,26 @@ describe( 'utils', () => {
 					meta: {
 						ID: 171,
 						name: 'meta',
-						meta: {},
+						meta: {
+							links: {},
+						},
 					},
 				},
 				tags: {
 					meta: {
 						ID: 171,
 						name: 'meta',
-						meta: {},
+						meta: {
+							links: {},
+						},
 					},
 				},
 				attachments: {
 					14209: {
 						ID: 14209,
-						meta: {},
+						meta: {
+							links: {},
+						},
 					},
 				},
 			} );
@@ -218,17 +231,22 @@ describe( 'utils', () => {
 			expect( revised ).to.not.equal( original );
 			expect( revised ).to.eql( {
 				ID: 814,
+				meta: {
+					data: { autosave: true },
+				},
 				terms: {
 					category: {
 						meta: {
 							ID: 171,
 							name: 'meta',
+							meta: {},
 						},
 					},
 					post_tag: {
 						meta: {
 							ID: 171,
 							name: 'meta',
+							meta: {},
 						},
 					},
 				},
@@ -236,17 +254,20 @@ describe( 'utils', () => {
 					meta: {
 						ID: 171,
 						name: 'meta',
+						meta: {},
 					},
 				},
 				tags: {
 					meta: {
 						ID: 171,
 						name: 'meta',
+						meta: {},
 					},
 				},
 				attachments: {
 					14209: {
 						ID: 14209,
+						meta: {},
 					},
 				},
 			} );
diff --git a/client/state/selectors/test/edited-post-has-content.js b/client/state/selectors/test/edited-post-has-content.js
index dbc18e1d01a96..1ee1038a5508c 100644
--- a/client/state/selectors/test/edited-post-has-content.js
+++ b/client/state/selectors/test/edited-post-has-content.js
@@ -20,6 +20,11 @@ describe( 'editedPostHasContent()', () => {
 					queries: {},
 					edits: {},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -46,6 +51,11 @@ describe( 'editedPostHasContent()', () => {
 					},
 					edits: {},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -73,6 +83,11 @@ describe( 'editedPostHasContent()', () => {
 					},
 					edits: {},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -100,6 +115,11 @@ describe( 'editedPostHasContent()', () => {
 					},
 					edits: {},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -127,6 +147,11 @@ describe( 'editedPostHasContent()', () => {
 					},
 					edits: {},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -164,6 +189,11 @@ describe( 'editedPostHasContent()', () => {
 						},
 					},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -185,6 +215,11 @@ describe( 'editedPostHasContent()', () => {
 						},
 					},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -206,6 +241,11 @@ describe( 'editedPostHasContent()', () => {
 						},
 					},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
 			},
 			2916284,
 			841
@@ -227,6 +267,46 @@ describe( 'editedPostHasContent()', () => {
 						},
 					},
 				},
+				ui: {
+					editor: {
+						rawContent: {},
+					},
+				},
+			},
+			2916284,
+			841
+		);
+
+		expect( hasContent ).to.be.true;
+	} );
+
+	test( 'should return true if there is empty content and non-empty raw content', () => {
+		const hasContent = editedPostHasContent(
+			{
+				posts: {
+					queries: {
+						2916284: new PostQueryManager( {
+							items: {
+								841: {
+									ID: 841,
+									site_ID: 2916284,
+									global_ID: '3d097cb7c5473c169bba0eb8e3c6cb64',
+									type: 'post',
+									content: '',
+								},
+							},
+						} ),
+					},
+					edits: {},
+				},
+				ui: {
+					editor: {
+						rawContent: {
+							initial: '',
+							current: 'ribs',
+						},
+					},
+				},
 			},
 			2916284,
 			841
diff --git a/client/state/ui/editor/test/actions.js b/client/state/ui/editor/test/actions.js
index 58d7290d2c9ae..e078e5ff8c291 100644
--- a/client/state/ui/editor/test/actions.js
+++ b/client/state/ui/editor/test/actions.js
@@ -9,41 +9,11 @@ import { forEach } from 'lodash';
 /**
  * Internal dependencies
  */
-import {
-	MODAL_VIEW_STAT_MAPPING,
-	setEditorMediaModalView,
-	startEditingPost,
-	stopEditingPost,
-} from '../actions';
-import { ANALYTICS_STAT_BUMP, EDITOR_START, EDITOR_STOP } from 'state/action-types';
+import { MODAL_VIEW_STAT_MAPPING, setEditorMediaModalView } from '../actions';
+import { ANALYTICS_STAT_BUMP } from 'state/action-types';
 import { setMediaModalView } from 'state/ui/media-modal/actions';
 
 describe( 'actions', () => {
-	describe( 'startEditingPost()', () => {
-		test( 'should return an action object', () => {
-			const action = startEditingPost( 10, 183, 'post' );
-
-			expect( action ).to.eql( {
-				type: EDITOR_START,
-				siteId: 10,
-				postId: 183,
-				postType: 'post',
-			} );
-		} );
-	} );
-
-	describe( 'stopEditingPost()', () => {
-		test( 'should return an action object', () => {
-			const action = stopEditingPost( 10, 183 );
-
-			expect( action ).to.eql( {
-				type: EDITOR_STOP,
-				siteId: 10,
-				postId: 183,
-			} );
-		} );
-	} );
-
 	describe( 'setEditorMediaModalView()', () => {
 		test( 'should dispatch setMediaModalView with analytics', () => {
 			forEach( MODAL_VIEW_STAT_MAPPING, ( stat, view ) => {
diff --git a/client/state/ui/editor/test/reducer.js b/client/state/ui/editor/test/reducer.js
index 347006d1f3274..7a44cff315a06 100644
--- a/client/state/ui/editor/test/reducer.js
+++ b/client/state/ui/editor/test/reducer.js
@@ -15,6 +15,8 @@ describe( 'reducer', () => {
 	test( 'should export expected reducer keys', () => {
 		expect( reducer( undefined, {} ) ).to.have.keys( [
 			'postId',
+			'loadingError',
+			'isLoading',
 			'isAutosaving',
 			'autosavePreviewUrl',
 			'lastDraft',
@@ -22,6 +24,7 @@ describe( 'reducer', () => {
 			'imageEditor',
 			'videoEditor',
 			'saveBlockers',
+			'rawContent',
 		] );
 	} );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/media/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/posts/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/posts/test/post-edit-store.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/posts/test/utils.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/post-editor/editor-word-count/test/index.jsx ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/post-editor/test/post-editor.jsx ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/reducer.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/selectors.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/utils.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/selectors/test/edited-post-has-content.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/editor/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/editor/test/reducer.js
: '>>>>> End Test Output'
git checkout bcc8e2ee4ec5a0d30fabc995d9ebeedfed0a8fe0 client/lib/media/test/actions.js client/lib/posts/test/actions.js client/lib/posts/test/mocks/lib/wp.js client/lib/posts/test/post-edit-store.js client/lib/posts/test/utils.js client/post-editor/editor-word-count/test/index.jsx client/post-editor/test/post-editor.jsx client/state/posts/test/reducer.js client/state/posts/test/selectors.js client/state/posts/test/utils.js client/state/selectors/test/edited-post-has-content.js client/state/ui/editor/test/actions.js client/state/ui/editor/test/reducer.js
