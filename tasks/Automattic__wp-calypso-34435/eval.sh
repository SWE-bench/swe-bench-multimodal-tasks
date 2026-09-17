#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c04808de96782fb03d59914beff43e9bb1784b69
git checkout c04808de96782fb03d59914beff43e9bb1784b69 client/signup/test/fixtures/flows.js client/signup/test/utils.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/signup/test/fixtures/flows.js b/client/signup/test/fixtures/flows.js
index e41ba8edcfcea8..c5fa761a2640a8 100644
--- a/client/signup/test/fixtures/flows.js
+++ b/client/signup/test/fixtures/flows.js
@@ -33,6 +33,11 @@ export default {
 		destination: '/',
 	},
 
+	'onboarding-blog': {
+		steps: [ 'user', 'site-type', 'site-topic', 'site-title', 'domains', 'plans' ],
+		destination: '/',
+	},
+
 	'disallow-resume': {
 		steps: [
 			'user',
diff --git a/client/signup/test/utils.js b/client/signup/test/utils.js
index dee6e73581c36d..ab49bc01890937 100644
--- a/client/signup/test/utils.js
+++ b/client/signup/test/utils.js
@@ -13,6 +13,8 @@ import sinon from 'sinon';
  * Internal dependencies
  */
 import {
+	canResumeFlow,
+	getCompletedSteps,
 	getValueFromProgressStore,
 	getValidPath,
 	getStepName,
@@ -216,4 +218,84 @@ describe( 'utils', () => {
 			assert.equal( getValueFromProgressStore( config ), null );
 		} );
 	} );
+
+	describe( 'getCompletedSteps', () => {
+		const mixedFlowsSignupProgress = [
+			{ stepName: 'user', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-type', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-topic', lastKnownFlow: 'onboarding-blog', status: 'completed' },
+			{ stepName: 'site-title', lastKnownFlow: 'onboarding-blog', status: 'completed' },
+			{ stepName: 'domains', lastKnownFlow: 'onboarding-blog', status: 'pending' },
+			{ stepName: 'plans', lastKnownFlow: 'onboarding-blog', status: 'pending' },
+		];
+		const singleFlowSignupProgress = [
+			{ stepName: 'user', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-type', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-topic-with-preview', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-title-with-preview', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'site-style-with-preview', lastKnownFlow: 'onboarding', status: 'completed' },
+			{ stepName: 'domains-with-preview', lastKnownFlow: 'onboarding', status: 'pending' },
+			{ stepName: 'plans', lastKnownFlow: 'onboarding', status: 'pending' },
+		];
+
+		test( 'step names should match steps of a particular flow given progress with mixed flows', () => {
+			const completedSteps = getCompletedSteps( 'onboarding-blog', mixedFlowsSignupProgress );
+			const stepNames = completedSteps.map( step => step.stepName );
+
+			expect( stepNames ).toStrictEqual( flows.getFlow( 'onboarding-blog' ).steps );
+		} );
+
+		test( 'should not match steps of a flow given progress with mixed flows and `shouldMatchFlowName` flag', () => {
+			const completedSteps = getCompletedSteps( 'onboarding-blog', mixedFlowsSignupProgress, {
+				shouldMatchFlowName: true,
+			} );
+			const filteredOnboardingBlogSteps = mixedFlowsSignupProgress.filter(
+				step => step.lastKnownFlow === 'onboarding-blog'
+			);
+			const stepNames = completedSteps.map( step => step.stepName );
+
+			expect( stepNames ).not.toStrictEqual( flows.getFlow( 'onboarding-blog' ).steps );
+			expect( completedSteps ).toStrictEqual( filteredOnboardingBlogSteps );
+		} );
+
+		test( 'should match steps of a flow given progress with single flow and `shouldMatchFlowName` flag', () => {
+			const completedSteps = getCompletedSteps( 'onboarding', singleFlowSignupProgress, {
+				shouldMatchFlowName: true,
+			} );
+			const stepNames = completedSteps.map( step => step.stepName );
+
+			expect( stepNames ).toStrictEqual( flows.getFlow( 'onboarding' ).steps );
+			expect( completedSteps ).toStrictEqual( singleFlowSignupProgress );
+		} );
+	} );
+
+	describe( 'canResumeFlow', () => {
+		test( 'should return true when given flow matches progress state', () => {
+			const signupProgress = [ { stepName: 'site-type', lastKnownFlow: 'onboarding' } ];
+			const canResume = canResumeFlow( 'onboarding', signupProgress );
+
+			expect( canResume ).toBe( true );
+		} );
+
+		test( 'should return false when given flow does not match progress state', () => {
+			const signupProgress = [ { stepName: 'site-type', lastKnownFlow: 'onboarding' } ];
+			const canResume = canResumeFlow( 'onboarding-blog', signupProgress );
+
+			expect( canResume ).toBe( false );
+		} );
+
+		test( 'should return false when flow sets disallowResume', () => {
+			const signupProgress = [ { stepName: 'site-type', lastKnownFlow: 'disallow-resume' } ];
+			const canResume = canResumeFlow( 'disallow-resume', signupProgress );
+
+			expect( canResume ).toBe( false );
+		} );
+
+		test( 'should return false when progress state is empty', () => {
+			const signupProgress = [];
+			const canResume = canResumeFlow( 'onboarding', signupProgress );
+
+			expect( canResume ).toBe( false );
+		} );
+	} );
 } );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/signup/test/utils.js
: '>>>>> End Test Output'
git checkout c04808de96782fb03d59914beff43e9bb1784b69 client/signup/test/fixtures/flows.js client/signup/test/utils.js
