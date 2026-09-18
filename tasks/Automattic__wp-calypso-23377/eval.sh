#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 01c60033934bb2c7df5ac14e1153f7739696042e
git checkout 01c60033934bb2c7df5ac14e1153f7739696042e client/state/notices/test/middleware.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/notices/test/middleware.js b/client/state/notices/test/middleware.js
index 180459d92ca2e..4e1fce7efd6e9 100644
--- a/client/state/notices/test/middleware.js
+++ b/client/state/notices/test/middleware.js
@@ -200,27 +200,30 @@ describe( 'middleware', () => {
 			} );
 
 			test( 'should dispatch success notice for trash', () => {
-				const noticeAction = onPostSaveSuccess( {
+				onPostSaveSuccess( {
 					type: POST_SAVE_SUCCESS,
 					post: { status: 'trash' },
-				} );
+					savedPost: { global_ID: 'asdfjkl' },
+				} )( dispatch );
 
-				expect( noticeAction ).toMatchObject( {
+				sinon.assert.calledWithMatch( dispatch, {
 					type: NOTICE_CREATE,
 					notice: {
 						status: 'is-success',
-						text: 'Post successfully moved to trash',
+						noticeId: 'trash_asdfjkl',
+						text: 'Post successfully moved to trash.',
+						button: 'Undo',
 					},
 				} );
 			} );
 
 			test( 'should dispatch success notice for publish', () => {
-				const noticeAction = onPostSaveSuccess( {
+				onPostSaveSuccess( {
 					type: POST_SAVE_SUCCESS,
 					post: { status: 'publish' },
-				} );
+				} )( dispatch );
 
-				expect( noticeAction ).toMatchObject( {
+				sinon.assert.calledWithMatch( dispatch, {
 					type: NOTICE_CREATE,
 					notice: {
 						status: 'is-success',

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/notices/test/middleware.js
: '>>>>> End Test Output'
git checkout 01c60033934bb2c7df5ac14e1153f7739696042e client/state/notices/test/middleware.js
