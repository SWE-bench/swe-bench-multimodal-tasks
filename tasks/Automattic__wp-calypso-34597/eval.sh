#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6324c6d30d4ece27eeb00faa3e7cc0aa1f817f83
git checkout 6324c6d30d4ece27eeb00faa3e7cc0aa1f817f83 client/blocks/post-share/test/nudges.jsx client/blocks/upgrade-nudge/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/blocks/post-share/test/nudges.jsx b/client/blocks/post-share/test/nudges.jsx
index 5ce7ac8843d61..1b49df00877a8 100644
--- a/client/blocks/post-share/test/nudges.jsx
+++ b/client/blocks/post-share/test/nudges.jsx
@@ -57,6 +57,7 @@ import {
 
 const props = {
 	translate: x => x,
+	canUserUpgrade: true,
 };
 
 describe( 'UpgradeToPremiumNudgePure basic tests', () => {
@@ -64,6 +65,15 @@ describe( 'UpgradeToPremiumNudgePure basic tests', () => {
 		const comp = shallow( <UpgradeToPremiumNudgePure { ...props } /> );
 		expect( comp.find( 'Banner' ).length ).toBe( 1 );
 	} );
+	
+	test( 'hide when user cannot upgrade', () => {
+		const props = {
+			translate: x => x,
+			canUserUpgrade: false,
+		};
+		const comp = shallow( <UpgradeToPremiumNudgePure { ...props } /> );
+		expect( comp.find( 'Banner' ).length ).toBe( 0 );
+	} );
 } );
 
 describe( 'UpgradeToPremiumNudgePure.render()', () => {
diff --git a/client/blocks/upgrade-nudge/test/index.js b/client/blocks/upgrade-nudge/test/index.js
index a850c6da1187c..4e6b1450b2f80 100644
--- a/client/blocks/upgrade-nudge/test/index.js
+++ b/client/blocks/upgrade-nudge/test/index.js
@@ -1,4 +1,3 @@
-/** @format */
 /**
  * External dependencies
  */
@@ -26,12 +25,12 @@ describe( 'UpgradeNudge', () => {
 		return merge( {}, defaultProps, overrideProps );
 	};
 
-	describe( '#shouldDisplay()', () => {
+	describe( 'wrapper', () => {
 		test( 'should display with default props', () => {
 			const props = createProps();
 			const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-			expect( wrapper.instance().shouldDisplay() ).toBe( true );
+			expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 1 );
 		} );
 
 		test( 'should not display without a site', () => {
@@ -39,7 +38,7 @@ describe( 'UpgradeNudge', () => {
 			delete props.site;
 			const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-			expect( wrapper.instance().shouldDisplay() ).toBe( false );
+			expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 		} );
 
 		test( 'should not display for paid plans without feature prop (personal)', () => {
@@ -53,7 +52,7 @@ describe( 'UpgradeNudge', () => {
 			delete props.feature;
 			const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-			expect( wrapper.instance().shouldDisplay() ).toBe( false );
+			expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 		} );
 
 		test( 'should not display for paid plans without feature prop (blogger)', () => {
@@ -67,32 +66,16 @@ describe( 'UpgradeNudge', () => {
 			delete props.feature;
 			const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-			expect( wrapper.instance().shouldDisplay() ).toBe( false );
+			expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 		} );
 
 		test( "should not display when user can't manage site", () => {
 			const props = createProps( { canManageSite: false } );
 			const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-			expect( wrapper.instance().shouldDisplay() ).toBe( false );
+			expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 		} );
-
-		describe( 'with shouldDisplay prop', () => {
-			test( 'should display when shouldDisplay returns true', () => {
-				const props = createProps( { shouldDisplay: () => true } );
-				const wrapper = shallow( <UpgradeNudge { ...props } /> );
-
-				expect( wrapper.instance().shouldDisplay() ).toBe( true );
-			} );
-
-			test( 'should not display when shouldDisplay returns false', () => {
-				const props = createProps( { shouldDisplay: () => false } );
-				const wrapper = shallow( <UpgradeNudge { ...props } /> );
-
-				expect( wrapper.instance().shouldDisplay() ).toBe( false );
-			} );
-		} );
-
+		
 		describe( 'with feature prop', () => {
 			test( 'should not display when plan has feature', () => {
 				const props = createProps( {
@@ -101,7 +84,7 @@ describe( 'UpgradeNudge', () => {
 				} );
 				const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-				expect( wrapper.instance().shouldDisplay() ).toBe( false );
+				expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 			} );
 
 			test( "should display when plan doesn't have feature", () => {
@@ -111,7 +94,7 @@ describe( 'UpgradeNudge', () => {
 				} );
 				const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-				expect( wrapper.instance().shouldDisplay() ).toBe( true );
+				expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 1 );
 			} );
 		} );
 
@@ -125,7 +108,7 @@ describe( 'UpgradeNudge', () => {
 				} );
 				const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-				expect( wrapper.instance().shouldDisplay() ).toBe( false );
+				expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 			} );
 
 			test( 'should not display when non-jetpack feature for jetpack sites', () => {
@@ -137,7 +120,7 @@ describe( 'UpgradeNudge', () => {
 				} );
 				const wrapper = shallow( <UpgradeNudge { ...props } /> );
 
-				expect( wrapper.instance().shouldDisplay() ).toBe( false );
+				expect( wrapper.find( '.upgrade-nudge' ) ).toHaveLength( 0 );
 			} );
 		} );
 	} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/post-share/test/nudges.jsx ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/upgrade-nudge/test/index.js
: '>>>>> End Test Output'
git checkout 6324c6d30d4ece27eeb00faa3e7cc0aa1f817f83 client/blocks/post-share/test/nudges.jsx client/blocks/upgrade-nudge/test/index.js
