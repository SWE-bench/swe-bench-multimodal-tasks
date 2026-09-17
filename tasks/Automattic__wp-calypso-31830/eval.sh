#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 09c44691e663a6f2173fe7bc15d7e3b6dc299afb
rm -f client/lib/mobile-app/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/lib/mobile-app/test/index.js b/client/lib/mobile-app/test/index.js
new file mode 100644
index 0000000000000..edfd719a5b346
--- /dev/null
+++ b/client/lib/mobile-app/test/index.js
@@ -0,0 +1,35 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import { isWpMobileApp } from 'lib/mobile-app';
+
+describe( 'mobile-app', () => {
+	test( 'should identify the iOS mobile app', () => {
+		global.navigator = {
+			userAgent:
+				'Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91 wp-iphone/12.1',
+		};
+
+		expect( isWpMobileApp() ).toBeTruthy();
+	} );
+
+	test( 'should identify the Android mobile app', () => {
+		global.navigator = {
+			userAgent:
+				'Mozilla/5.0 (Linux; Android 6.0; Android SDK built for x86_64 Build/MASTER; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/44.0.2403.119 Mobile Safari/537.36 wp-android/4.7',
+		};
+
+		expect( isWpMobileApp() ).toBeTruthy();
+	} );
+
+	test( 'should not identify an unknown user agent', () => {
+		global.navigator = {
+			userAgent:
+				'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36',
+		};
+
+		expect( isWpMobileApp() ).toBeFalsy();
+	} );
+} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/lib/mobile-app/test/index.js
: '>>>>> End Test Output'
rm -f client/lib/mobile-app/test/index.js
