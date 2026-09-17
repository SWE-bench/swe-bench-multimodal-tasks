#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff fe332f6e041fa5949a5062cf818f66fc6cb1f0e1
git checkout fe332f6e041fa5949a5062cf818f66fc6cb1f0e1 client/lib/post-normalizer/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/post-normalizer/test/index.js b/client/lib/post-normalizer/test/index.js
index 7d9d8c520ebb9..8d1743d4f4a20 100644
--- a/client/lib/post-normalizer/test/index.js
+++ b/client/lib/post-normalizer/test/index.js
@@ -1092,6 +1092,24 @@ describe( 'index', () => {
 				}
 			);
 		} );
+		test( 'links to embedded Polldaddy surveys', done => {
+			normalizer(
+				{
+					content:
+						'<div class="embed-polldaddy">' +
+						'<div class="pd-embed" data-settings="{&quot;type&quot;:&quot;iframe&quot;,&quot;auto&quot;:true,&quot;domain&quot;:&quot;bluefuton.polldaddy.com/s/&quot;,&quot;id&quot;:&quot;what-s-your-favourite-bird&quot;}">' +
+						'</div>',
+				},
+				[ normalizer.withContentDOM( [ normalizer.content.detectSurveys ] ) ],
+				function( err, normalized ) {
+					assert.include(
+						normalized.content,
+						'<p><a target="_blank" rel="external noopener noreferrer" href="https://bluefuton.polldaddy.com/s/what-s-your-favourite-bird">Take our survey</a></p>'
+					);
+					done( err );
+				}
+			);
+		} );
 
 		test( 'removes elements by selector', done => {
 			normalizer(

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/post-normalizer/test/index.js
: '>>>>> End Test Output'
git checkout fe332f6e041fa5949a5062cf818f66fc6cb1f0e1 client/lib/post-normalizer/test/index.js
