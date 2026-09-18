#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 24d762a0fe3a92500f92323b038a2389cb6ecae5
git checkout 24d762a0fe3a92500f92323b038a2389cb6ecae5 client/lib/posts/test/utils.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/posts/test/utils.js b/client/lib/posts/test/utils.js
index af04eeea8cd37..26139b25c11b1 100644
--- a/client/lib/posts/test/utils.js
+++ b/client/lib/posts/test/utils.js
@@ -22,7 +22,7 @@ describe( 'utils', () => {
 				{ ID: 123, type: 'post' },
 				{ slug: 'en.blog.wordpress.com' }
 			);
-			assert( url === '/post/en.blog.wordpress.com/123' );
+			expect( url ).toEqual( '/post/en.blog.wordpress.com/123' );
 		} );
 
 		test( 'should return correct path type=page is supplied', () => {
@@ -30,7 +30,7 @@ describe( 'utils', () => {
 				{ ID: 123, type: 'page' },
 				{ slug: 'en.blog.wordpress.com' }
 			);
-			assert( url === '/page/en.blog.wordpress.com/123' );
+			expect( url ).toEqual( '/page/en.blog.wordpress.com/123' );
 		} );
 
 		test( 'should return correct path when custom post type is supplied', () => {
@@ -38,7 +38,12 @@ describe( 'utils', () => {
 				{ ID: 123, type: 'jetpack-portfolio' },
 				{ slug: 'en.blog.wordpress.com' }
 			);
-			assert( url === '/edit/jetpack-portfolio/en.blog.wordpress.com/123' );
+			expect( url ).toEqual( '/edit/jetpack-portfolio/en.blog.wordpress.com/123' );
+		} );
+
+		test( 'should default to type=post if no post type is supplied', () => {
+			const url = postUtils.getEditURL( { ID: 123, type: '' }, { slug: 'en.blog.wordpress.com' } );
+			expect( url ).toEqual( '/post/en.blog.wordpress.com/123' );
 		} );
 	} );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/posts/test/utils.js
: '>>>>> End Test Output'
git checkout 24d762a0fe3a92500f92323b038a2389cb6ecae5 client/lib/posts/test/utils.js
