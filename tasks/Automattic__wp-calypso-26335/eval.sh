#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 1afcc6abc9e3e772d27086374d0a1b6e5a733a67
git checkout 1afcc6abc9e3e772d27086374d0a1b6e5a733a67 client/state/posts/test/actions.js client/state/ui/editor/test/edit-save-flow.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/posts/test/actions.js b/client/state/posts/test/actions.js
index d9ac0c8295cff..cd0fefd151ad3 100644
--- a/client/state/posts/test/actions.js
+++ b/client/state/posts/test/actions.js
@@ -89,7 +89,6 @@ describe( 'actions', () => {
 				postId: 841,
 				savedPost: savedPost,
 				post: attributes,
-				saveMarker: null,
 			} );
 		} );
 	} );
@@ -333,7 +332,6 @@ describe( 'actions', () => {
 						ID: 13640,
 						title: 'Hello World',
 					} ),
-					saveMarker: null,
 				} );
 			} );
 		} );
@@ -376,7 +374,6 @@ describe( 'actions', () => {
 						ID: 13640,
 						title: 'Updated',
 					} ),
-					saveMarker: null,
 				} );
 			} );
 		} );
diff --git a/client/state/ui/editor/test/edit-save-flow.js b/client/state/ui/editor/test/edit-save-flow.js
index efdfccf6c2ba4..6522fb07e2d6b 100644
--- a/client/state/ui/editor/test/edit-save-flow.js
+++ b/client/state/ui/editor/test/edit-save-flow.js
@@ -20,9 +20,10 @@ import siteSettings from 'state/site-settings/reducer';
 import { selectedSiteId } from 'state/ui/reducer';
 import editor from 'state/ui/editor/reducer';
 import { setSelectedSiteId } from 'state/ui/actions';
+import { getSelectedSiteId } from 'state/ui/selectors';
 import { editPost, saveEdited } from 'state/posts/actions';
 import { startEditingNewPost } from 'state/ui/editor/actions';
-import { getEditedPostValue, isEditedPostDirty } from 'state/posts/selectors';
+import { getEditedPost, getEditedPostValue, isEditedPostDirty } from 'state/posts/selectors';
 import { getEditorPostId } from 'state/ui/editor/selectors';
 
 const SITE_ID = 123;
@@ -225,3 +226,43 @@ test( 'create post, save, type while saving, verify that edits are not lost', as
 	// check that post is still dirty
 	expect( isEditedPostDirty( store.getState(), SITE_ID, savedPostId ) ).toBe( true );
 } );
+
+test( 'create new post and save, verify that edited post is always valid', async () => {
+	const store = createEditorStore();
+
+	// select site and start editing new post
+	store.dispatch( setSelectedSiteId( SITE_ID ) );
+	store.dispatch( startEditingNewPost( SITE_ID ) );
+
+	// verify that the edited post is always non-null
+	store.subscribe( () => {
+		const state = store.getState();
+		const siteId = getSelectedSiteId( state );
+		const postId = getEditorPostId( state );
+		const post = getEditedPost( state, siteId, postId );
+		expect( post ).not.toBeNull();
+	} );
+
+	// edit title and content
+	const draftPostId = getEditorPostId( store.getState() );
+	store.dispatch( editPost( SITE_ID, draftPostId, { title: 'Title' } ) );
+
+	// mock the server response on save
+	nock( 'https://public-api.wordpress.com' )
+		.post( `/rest/v1.2/sites/${ SITE_ID }/posts/new?context=edit`, {
+			type: 'post',
+			status: 'draft',
+			title: 'Title',
+		} )
+		.reply( 200, {
+			global_ID: GLOBAL_ID,
+			site_ID: SITE_ID,
+			ID: POST_ID,
+			type: 'post',
+			status: 'draft',
+			title: 'Title',
+		} );
+
+	// trigger save
+	await store.dispatch( saveEdited() );
+} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/editor/test/edit-save-flow.js
: '>>>>> End Test Output'
git checkout 1afcc6abc9e3e772d27086374d0a1b6e5a733a67 client/state/posts/test/actions.js client/state/ui/editor/test/edit-save-flow.js
