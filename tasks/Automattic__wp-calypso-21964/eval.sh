#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 4be8bc55357f68a51c2d0aeabe9b87820625aff8
git checkout 4be8bc55357f68a51c2d0aeabe9b87820625aff8 client/lib/paths/login/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/paths/login/test/index.js b/client/lib/paths/login/test/index.js
index 393fd9ddc64ef..ca7bc6d480f1c 100644
--- a/client/lib/paths/login/test/index.js
+++ b/client/lib/paths/login/test/index.js
@@ -63,5 +63,11 @@ describe( 'index', () => {
 
 			expect( url ).to.equal( '/log-in?email_address=foo%40bar.com' );
 		} );
+
+		test( 'should return the login url with encoded OAuth2 client ID param', () => {
+			const url = login( { isNative: true, oauth2ClientId: 12345 } );
+
+			expect( url ).to.equal( '/log-in?client_id=12345' );
+		} );
 	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/paths/login/test/index.js
: '>>>>> End Test Output'
git checkout 4be8bc55357f68a51c2d0aeabe9b87820625aff8 client/lib/paths/login/test/index.js
