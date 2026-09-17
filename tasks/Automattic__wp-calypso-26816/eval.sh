#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 5bb7ee7beec05830b9edbaa2f12d3bf27d67a079
git checkout 5bb7ee7beec05830b9edbaa2f12d3bf27d67a079 client/state/ui/test/reducer.js config/test.json && rm -f client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js client/state/ui/gutenberg-opt-in-dialog/test/actions.js client/state/ui/gutenberg-opt-in-dialog/test/reducer.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js b/client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js
new file mode 100644
index 0000000000000..7c37df3b25a64
--- /dev/null
+++ b/client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js
@@ -0,0 +1,38 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import isGutenbergOptInDialogShowing from 'state/selectors/is-gutenberg-opt-in-dialog-showing';
+
+describe( 'isGutenbergOptInDialogShowing()', () => {
+	test( 'should return false if the value is not known', () => {
+		const result = isGutenbergOptInDialogShowing( { ui: {} } );
+
+		expect( result ).toBe( false );
+	} );
+
+	test( 'should return false if the isGutenbergOptInDialogShowing reducer is false', () => {
+		const result = isGutenbergOptInDialogShowing( {
+			ui: {
+				gutenbergOptInDialog: {
+					isShowing: false,
+				},
+			},
+		} );
+
+		expect( result ).toBe( false );
+	} );
+
+	test( 'should return true if the isGutenbergOptInDialogShowing reducer is true', () => {
+		const result = isGutenbergOptInDialogShowing( {
+			ui: {
+				gutenbergOptInDialog: {
+					isShowing: true,
+				},
+			},
+		} );
+
+		expect( result ).toBe( true );
+	} );
+} );
diff --git a/client/state/ui/gutenberg-opt-in-dialog/test/actions.js b/client/state/ui/gutenberg-opt-in-dialog/test/actions.js
new file mode 100644
index 0000000000000..dc94ce5226bac
--- /dev/null
+++ b/client/state/ui/gutenberg-opt-in-dialog/test/actions.js
@@ -0,0 +1,31 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import { showGutenbergOptInDialog, hideGutenbergOptInDialog } from '../actions';
+import { GUTENBERG_OPT_IN_DIALOG_IS_SHOWING } from 'state/action-types';
+
+describe( 'actions', () => {
+	describe( 'showGutenbergOptInDialog()', () => {
+		test( 'should return an action object', () => {
+			const action = showGutenbergOptInDialog();
+
+			expect( action ).toEqual( {
+				type: GUTENBERG_OPT_IN_DIALOG_IS_SHOWING,
+				isShowing: true,
+			} );
+		} );
+	} );
+
+	describe( 'hideGutenbergOptInDialog()', () => {
+		test( 'should return an action object', () => {
+			const action = hideGutenbergOptInDialog();
+
+			expect( action ).toEqual( {
+				type: GUTENBERG_OPT_IN_DIALOG_IS_SHOWING,
+				isShowing: false,
+			} );
+		} );
+	} );
+} );
diff --git a/client/state/ui/gutenberg-opt-in-dialog/test/reducer.js b/client/state/ui/gutenberg-opt-in-dialog/test/reducer.js
new file mode 100644
index 0000000000000..39e93b4fff3ff
--- /dev/null
+++ b/client/state/ui/gutenberg-opt-in-dialog/test/reducer.js
@@ -0,0 +1,12 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import reducer from '../reducer';
+
+describe( 'reducer', () => {
+	test( 'should export expected reducer keys', () => {
+		expect( reducer( undefined, {} ) ).toHaveProperty( 'isShowing' );
+	} );
+} );
diff --git a/client/state/ui/test/reducer.js b/client/state/ui/test/reducer.js
index 3773f46968010..4c285489deb89 100644
--- a/client/state/ui/test/reducer.js
+++ b/client/state/ui/test/reducer.js
@@ -21,6 +21,7 @@ describe( 'reducer', () => {
 			'editor',
 			'googleMyBusiness',
 			'guidedTour',
+			'gutenbergOptInDialog',
 			'hasSidebar',
 			'isLoading',
 			'isNotificationsOpen',
diff --git a/config/test.json b/config/test.json
index 9b6dbdfc6aece..552ccdcebd5c5 100644
--- a/config/test.json
+++ b/config/test.json
@@ -40,6 +40,7 @@
 		"google-analytics": false,
 		"google-my-business": false,
 		"gutenberg": true,
+		"gutenberg/opt-in": true,
 		"help": true,
 		"jetpack/checklist": true,
 		"jetpack/connect/remote-install": true,

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/gutenberg-opt-in-dialog/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/gutenberg-opt-in-dialog/test/reducer.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/ui/test/reducer.js
: '>>>>> End Test Output'
git checkout 5bb7ee7beec05830b9edbaa2f12d3bf27d67a079 client/state/ui/test/reducer.js config/test.json && rm -f client/state/selectors/test/is-gutenberg-opt-in-dialog-showing.js client/state/ui/gutenberg-opt-in-dialog/test/actions.js client/state/ui/gutenberg-opt-in-dialog/test/reducer.js
