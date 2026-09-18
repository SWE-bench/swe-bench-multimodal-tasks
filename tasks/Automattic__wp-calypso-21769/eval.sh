#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6812e4b9ed2cbf65cf7ecaba2ff5fcb75e37865b
git checkout 6812e4b9ed2cbf65cf7ecaba2ff5fcb75e37865b client/state/help/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/help/test/selectors.js b/client/state/help/test/selectors.js
index d2483b7cadccb6..c58b9d3988f5bd 100644
--- a/client/state/help/test/selectors.js
+++ b/client/state/help/test/selectors.js
@@ -3,13 +3,12 @@
 /**
  * External dependencies
  */
-import { expect } from 'chai';
 import deepFreeze from 'deep-freeze';
 
 /**
  * Internal dependencies
  */
-import { getHelpSiteId } from '../selectors';
+import { getHelpSiteId, getHelpSelectedSiteId } from '../selectors';
 
 describe( 'selectors', () => {
 	describe( '#getHelpSiteId()', () => {
@@ -20,7 +19,7 @@ describe( 'selectors', () => {
 				},
 			} );
 
-			expect( getHelpSiteId( state ) ).to.be.null;
+			expect( getHelpSiteId( state ) ).toEqual( null );
 		} );
 
 		test( 'should return courses for given state', () => {
@@ -30,7 +29,187 @@ describe( 'selectors', () => {
 				},
 			} );
 
-			expect( getHelpSiteId( state ) ).to.eql( state.help.selectedSiteId );
+			expect( getHelpSiteId( state ) ).toEqual( state.help.selectedSiteId );
+		} );
+	} );
+	describe( '#getHelpSelectedSiteId()', () => {
+		test( 'defaults to customer chosen site', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: 1234,
+				},
+				sites: {
+					items: {
+						1234: { ID: 1234 },
+						77203074: { ID: 77203074 },
+						2916284: { ID: 2916284 },
+					},
+				},
+				ui: {
+					selectedSiteId: 2916284,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 77203074,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( 1234 );
+		} );
+
+		test( 'uses selected site if customer selected site is not available', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: null,
+				},
+				sites: {
+					items: {
+						1234: { ID: 1234 },
+						2916284: { ID: 2916284 },
+						77203074: { ID: 77203074 },
+					},
+				},
+				ui: {
+					selectedSiteId: 2916284,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 77203074,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( 2916284 );
+		} );
+
+		test( 'uses primary site if customer selected site or global selected site is not available', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: null,
+				},
+				sites: {
+					items: {
+						1234: { ID: 1234 },
+						2916284: { ID: 2916284 },
+						77203074: { ID: 77203074 },
+					},
+				},
+				ui: {
+					selectedSiteId: null,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 77203074,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( 77203074 );
+		} );
+
+		test( 'if customer selected site is not available, uses first site', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: 1234,
+				},
+				sites: {
+					items: {
+						2916284: { ID: 2916284 },
+						77203074: { ID: 77203074 },
+					},
+				},
+				ui: {
+					selectedSiteId: null,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 77203074,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( 2916284 );
+		} );
+
+		test( 'if selected site is not available, uses first site', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: null,
+				},
+				sites: {
+					items: {
+						77203074: { ID: 77203074 },
+					},
+				},
+				ui: {
+					selectedSiteId: 2916284,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 1234,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( 77203074 );
+		} );
+
+		test( 'if sites are not loaded, returns null', () => {
+			const state = deepFreeze( {
+				help: {
+					selectedSiteId: 1234,
+				},
+				sites: {
+					items: null,
+				},
+				ui: {
+					selectedSiteId: 2916284,
+				},
+				currentUser: {
+					id: 5678,
+					capabilities: {},
+				},
+				users: {
+					items: {
+						5678: {
+							ID: 5678,
+							primary_blog: 1234,
+						},
+					},
+				},
+			} );
+			expect( getHelpSelectedSiteId( state ) ).toEqual( null );
 		} );
 	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/help/test/selectors.js
: '>>>>> End Test Output'
git checkout 6812e4b9ed2cbf65cf7ecaba2ff5fcb75e37865b client/state/help/test/selectors.js
