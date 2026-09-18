#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 73ff0f9af67b31202eadf17fa93be4d406d418ab
git checkout 73ff0f9af67b31202eadf17fa93be4d406d418ab client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
git apply -v - <<'EOF_114329324912'
diff --git a/client/blocks/product-purchase-features-list/test/video-audio-posts.jsx b/client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
index ff6476954a9db..90d95b99253c5 100644
--- a/client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
+++ b/client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
@@ -72,7 +72,7 @@ describe( 'VideoAudioPosts should use proper description', () => {
 	[ PLAN_PREMIUM, PLAN_PREMIUM_2_YEARS ].forEach( plan => {
 		test( `for premium plan ${ plan }`, () => {
 			const comp = shallow( <VideoAudioPosts { ...props } plan={ plan } /> );
-			expect( comp.find( 'PurchaseDetail' ).props().description ).toContain( '10GB of media' );
+			expect( comp.find( 'PurchaseDetail' ).props().description ).toContain( '13GB of media' );
 		} );
 	} );
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
: '>>>>> End Test Output'
git checkout 73ff0f9af67b31202eadf17fa93be4d406d418ab client/blocks/product-purchase-features-list/test/video-audio-posts.jsx
