#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 4e8168f998f4619a58251fb93fdc0683596399bc
git checkout 4e8168f998f4619a58251fb93fdc0683596399bc client/lib/posts/test/utils.js client/state/posts/test/reducer.js client/state/posts/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/posts/test/utils.js b/client/lib/posts/test/utils.js
index 26139b25c11b14..9ea3987988b288 100644
--- a/client/lib/posts/test/utils.js
+++ b/client/lib/posts/test/utils.js
@@ -3,11 +3,6 @@
  * @jest-environment jsdom
  */
 
-/**
- * External dependencies
- */
-import assert from 'assert'; // eslint-disable-line import/no-nodejs-modules
-
 /**
  * Internal dependencies
  */
@@ -49,113 +44,115 @@ describe( 'utils', () => {
 
 	describe( '#getVisibility', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.getVisibility() === undefined );
+			expect( postUtils.getVisibility() ).toBeUndefined();
 		} );
 
 		test( 'should return public when password and private are not set', () => {
-			assert( postUtils.getVisibility( {} ) === 'public' );
+			expect( postUtils.getVisibility( {} ) ).toEqual( 'public' );
 		} );
 
 		test( 'should return private when post#status is private', () => {
-			assert( postUtils.getVisibility( { status: 'private' } ) === 'private' );
+			expect( postUtils.getVisibility( { status: 'private' } ) ).toEqual( 'private' );
 		} );
 
 		test( 'should return password when post#password is set', () => {
-			assert( postUtils.getVisibility( { password: 'unicorn' } ) === 'password' );
+			expect( postUtils.getVisibility( { password: 'unicorn' } ) ).toEqual( 'password' );
 		} );
 	} );
 
 	describe( '#isPrivate', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.isPrivate() === undefined );
+			expect( postUtils.isPrivate() ).toBeUndefined();
 		} );
 
 		test( 'should return true when post.status is private', () => {
-			assert( postUtils.isPrivate( { status: 'private' } ) );
+			expect( postUtils.isPrivate( { status: 'private' } ) ).toBe( true );
 		} );
 
 		test( 'should return false when post.status is not private', () => {
-			assert( ! postUtils.isPrivate( { status: 'draft' } ) );
+			expect( postUtils.isPrivate( { status: 'draft' } ) ).toBe( false );
 		} );
 	} );
 
 	describe( '#isPublished', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.isPublished() === undefined );
+			expect( postUtils.isPublished() ).toBeUndefined();
 		} );
 
 		test( 'should return true when post.status is private', () => {
-			assert( postUtils.isPublished( { status: 'private' } ) );
+			expect( postUtils.isPublished( { status: 'private' } ) ).toBe( true );
 		} );
 
 		test( 'should return true when post.status is publish', () => {
-			assert( postUtils.isPublished( { status: 'publish' } ) );
+			expect( postUtils.isPublished( { status: 'publish' } ) ).toBe( true );
 		} );
 
 		test( 'should return false when post.status is not publish or private', () => {
-			assert( ! postUtils.isPublished( { status: 'draft' } ) );
+			expect( postUtils.isPublished( { status: 'draft' } ) ).toBe( false );
 		} );
 	} );
 
 	describe( '#isPending', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.isPending() === undefined );
+			expect( postUtils.isPending() ).toBeUndefined();
 		} );
 
 		test( 'should return true when post.status is pending', () => {
-			assert( postUtils.isPending( { status: 'pending' } ) );
+			expect( postUtils.isPending( { status: 'pending' } ) ).toBe( true );
 		} );
 
 		test( 'should return false when post.status is not pending', () => {
-			assert( ! postUtils.isPending( { status: 'draft' } ) );
+			expect( postUtils.isPending( { status: 'draft' } ) ).toBe( false );
 		} );
 	} );
 
 	describe( '#isBackDatedPublished', () => {
 		test( 'should return false when no post is supplied', () => {
-			assert( ! postUtils.isBackDatedPublished() );
+			expect( postUtils.isBackDatedPublished() ).toBe( false );
 		} );
 
 		test( 'should return false when status !== future', () => {
-			assert( ! postUtils.isBackDatedPublished( { status: 'draft' } ) );
+			expect( postUtils.isBackDatedPublished( { status: 'draft' } ) ).toBe( false );
 		} );
 
 		test( 'should return false when status === future and date is in future', () => {
 			const tenMinutes = 1000 * 60;
 			const postDate = Date.now() + tenMinutes;
 
-			assert( ! postUtils.isBackDatedPublished( { status: 'future', date: postDate } ) );
+			expect( postUtils.isBackDatedPublished( { status: 'future', date: postDate } ) ).toBe(
+				false
+			);
 		} );
 
 		test( 'should return true when status === future and date is in the past', () => {
 			const tenMinutes = 1000 * 60;
 			const postDate = Date.now() - tenMinutes;
 
-			assert( postUtils.isBackDatedPublished( { status: 'future', date: postDate } ) );
+			expect( postUtils.isBackDatedPublished( { status: 'future', date: postDate } ) ).toBe( true );
 		} );
 	} );
 
 	describe( '#removeSlug', () => {
 		test( 'should return undefined when no path is supplied', () => {
-			assert( postUtils.removeSlug() === undefined );
+			expect( postUtils.removeSlug() ).toBeUndefined();
 		} );
 
 		test( 'should strip slug on post URL', () => {
 			const noSlug = postUtils.removeSlug(
 				'https://en.blog.wordpress.com/2015/08/26/new-action-bar/'
 			);
-			assert( noSlug === 'https://en.blog.wordpress.com/2015/08/26/' );
+			expect( noSlug ).toEqual( 'https://en.blog.wordpress.com/2015/08/26/' );
 		} );
 
 		test( 'should strip slug on page URL', () => {
 			const noSlug = postUtils.removeSlug( 'https://en.blog.wordpress.com/a-test-page/' );
-			assert( noSlug === 'https://en.blog.wordpress.com/' );
+			expect( noSlug ).toEqual( 'https://en.blog.wordpress.com/' );
 		} );
 	} );
 
 	describe( '#getPermalinkBasePath', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.getPermalinkBasePath() === undefined );
+			expect( postUtils.getPermalinkBasePath() ).toBeUndefined();
 		} );
 
 		test( 'should return post.URL when post is published', () => {
@@ -163,7 +160,7 @@ describe( 'utils', () => {
 				status: 'publish',
 				URL: 'https://en.blog.wordpress.com/2015/08/26/new-action-bar/',
 			} );
-			assert( path === 'https://en.blog.wordpress.com/2015/08/26/' );
+			expect( path ).toEqual( 'https://en.blog.wordpress.com/2015/08/26/' );
 		} );
 
 		test( 'should use permalink_URL when not published and present', () => {
@@ -171,13 +168,13 @@ describe( 'utils', () => {
 				other_URLs: { permalink_URL: 'http://zo.mg/a/permalink/%post_name%/' },
 				URL: 'https://en.blog.wordpress.com/2015/08/26/new-action-bar/',
 			} );
-			assert( path === 'http://zo.mg/a/permalink/' );
+			expect( path ).toEqual( 'http://zo.mg/a/permalink/' );
 		} );
 	} );
 
 	describe( '#getPagePath', () => {
 		test( 'should return undefined when no post is supplied', () => {
-			assert( postUtils.getPagePath() === undefined );
+			expect( postUtils.getPagePath() ).toBeUndefined();
 		} );
 
 		test( 'should return post.URL without slug when page is published', () => {
@@ -185,7 +182,7 @@ describe( 'utils', () => {
 				status: 'publish',
 				URL: 'http://zo.mg/a/permalink/',
 			} );
-			assert( path === 'http://zo.mg/a/' );
+			expect( path ).toEqual( 'http://zo.mg/a/' );
 		} );
 
 		test( 'should use permalink_URL when not published and present', () => {
@@ -193,13 +190,13 @@ describe( 'utils', () => {
 				status: 'draft',
 				other_URLs: { permalink_URL: 'http://zo.mg/a/permalink/%post_name%/' },
 			} );
-			assert( path === 'http://zo.mg/a/permalink/' );
+			expect( path ).toEqual( 'http://zo.mg/a/permalink/' );
 		} );
 	} );
 
 	describe( '#getFeaturedImageId()', () => {
 		test( 'should return undefined when no post is specified', () => {
-			assert( postUtils.getFeaturedImageId() === undefined );
+			expect( postUtils.getFeaturedImageId() ).toBeUndefined();
 		} );
 
 		test( 'should return a non-URL featured_image property', () => {
@@ -210,7 +207,7 @@ describe( 'utils', () => {
 				},
 			} );
 
-			assert( id === 'media-1' );
+			expect( id ).toEqual( 'media-1' );
 		} );
 
 		test( 'should return a `null` featured_image property', () => {
@@ -223,7 +220,17 @@ describe( 'utils', () => {
 				},
 			} );
 
-			assert( id === null );
+			expect( id ).toBeNull();
+		} );
+
+		test( 'should return empty string if that is the featured_image value', () => {
+			// These values are typical for posts without a featured image
+			const id = postUtils.getFeaturedImageId( {
+				featured_image: '',
+				post_thumbnail: null,
+			} );
+
+			expect( id ).toEqual( '' );
 		} );
 
 		test( 'should fall back to post thumbnail object ID if exists, if featured_image is URL', () => {
@@ -234,7 +241,7 @@ describe( 'utils', () => {
 				},
 			} );
 
-			assert( id === 1 );
+			expect( id ).toEqual( 1 );
 		} );
 
 		test( "should return undefined if featured_image is URL and post thumbnail object doesn't exist", () => {
@@ -242,7 +249,7 @@ describe( 'utils', () => {
 				featured_image: 'https://example.com/image.png',
 			} );
 
-			assert( id === undefined );
+			expect( id ).toBeUndefined();
 		} );
 	} );
 } );
diff --git a/client/state/posts/test/reducer.js b/client/state/posts/test/reducer.js
index 16031782561f06..1d3ba6c758430d 100644
--- a/client/state/posts/test/reducer.js
+++ b/client/state/posts/test/reducer.js
@@ -1245,6 +1245,38 @@ describe( 'reducer', () => {
 			} );
 		} );
 
+		test( 'should remove featured image edit after it is saved', () => {
+			const state = edits(
+				deepFreeze( {
+					2916284: {
+						841: {
+							featured_image: 123,
+						},
+					},
+				} ),
+				{
+					type: POSTS_RECEIVE,
+					posts: [
+						{
+							ID: 841,
+							site_ID: 2916284,
+							type: 'post',
+							featured_image: 'https://example.files.wordpress.com/2018/02/img_4879.jpg',
+							post_thumbnail: {
+								ID: 123,
+							},
+						},
+					],
+				}
+			);
+
+			expect( state ).to.eql( {
+				2916284: {
+					841: {},
+				},
+			} );
+		} );
+
 		test( "should ignore reset edits action when discarded site doesn't exist", () => {
 			const original = deepFreeze( {} );
 			const state = edits( original, {
diff --git a/client/state/posts/test/selectors.js b/client/state/posts/test/selectors.js
index 36c05b3d4a9d2b..4fe2a9fc4efb73 100644
--- a/client/state/posts/test/selectors.js
+++ b/client/state/posts/test/selectors.js
@@ -2072,6 +2072,41 @@ describe( 'selectors', () => {
 
 			expect( isDirty ).to.be.false;
 		} );
+
+		test( "should return false if featured image ID didn't change", () => {
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
+										featured_image: 'https://example.files.wordpress.com/2018/02/img_4879.jpg',
+										post_thumbnail: {
+											ID: 123,
+										},
+									},
+								},
+							} ),
+						},
+						edits: {
+							2916284: {
+								841: {
+									featured_image: 123,
+								},
+							},
+						},
+					},
+				},
+				2916284,
+				841
+			);
+
+			expect( isDirty ).to.be.false;
+		} );
 	} );
 
 	describe( 'getPostPreviewUrl()', () => {

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/posts/test/utils.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/reducer.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/posts/test/selectors.js
: '>>>>> End Test Output'
git checkout 4e8168f998f4619a58251fb93fdc0683596399bc client/lib/posts/test/utils.js client/state/posts/test/reducer.js client/state/posts/test/selectors.js
