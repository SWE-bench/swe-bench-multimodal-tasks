#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff e9d12f1585da7f7bd4ee03f47f43bfd7a2247ab8
git checkout e9d12f1585da7f7bd4ee03f47f43bfd7a2247ab8 client/blocks/app-banner/test/app-banner.jsx
git apply -v - <<'EOF_114329324912'
diff --git a/client/blocks/app-banner/test/app-banner.jsx b/client/blocks/app-banner/test/app-banner.jsx
index 3fe0afb547bb7..e3712bee181cc 100644
--- a/client/blocks/app-banner/test/app-banner.jsx
+++ b/client/blocks/app-banner/test/app-banner.jsx
@@ -7,7 +7,7 @@
  * Internal dependencies
  */
 import { getiOSDeepLink, buildDeepLinkFragment } from 'blocks/app-banner';
-import { EDITOR, NOTES, READER, STATS } from 'blocks/app-banner/utils';
+import { EDITOR, NOTES, READER, STATS, getCurrentSection } from 'blocks/app-banner/utils';
 
 describe( 'iOS deep link fragments', () => {
 	test( 'properly encodes tricky fragments', () => {
@@ -62,3 +62,29 @@ describe( 'iOS deep links', () => {
 		expect( getiOSDeepLink( '/test', STATS ).split( '#' )[ 1 ].length ).toBeTruthy();
 	} );
 } );
+
+describe( 'getCurrentSection', () => {
+	test( 'returns stats if in stats section', () => {
+		expect( getCurrentSection( STATS, false, '/stats/123' ) ).toBe( STATS );
+	} );
+
+	test( 'returns null for activity log page', () => {
+		expect( getCurrentSection( STATS, false, '/stats/activity/123' ) ).toBe( null );
+	} );
+
+	test( 'returns notes if notes is open', () => {
+		expect( getCurrentSection( STATS, true, '/stats/123' ) ).toBe( NOTES );
+	} );
+
+	test( 'returns reader if in reader section', () => {
+		expect( getCurrentSection( READER, false, '/' ) ).toBe( READER );
+	} );
+
+	test( 'returns editor if in editor section', () => {
+		expect( getCurrentSection( EDITOR, false, '/post/123' ) ).toBe( EDITOR );
+	} );
+
+	test( 'returns null if in a disallowed section', () => {
+		expect( getCurrentSection( 'plugins', false, '/plugins/123' ) ).toBe( null );
+	} );
+} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/app-banner/test/app-banner.jsx
: '>>>>> End Test Output'
git checkout e9d12f1585da7f7bd4ee03f47f43bfd7a2247ab8 client/blocks/app-banner/test/app-banner.jsx
