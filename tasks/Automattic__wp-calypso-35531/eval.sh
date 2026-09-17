#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 9e445e13dd96de61e7b7c5c98ad98e12268a4d12
git checkout 9e445e13dd96de61e7b7c5c98ad98e12268a4d12 client/blocks/plan-storage/test/plan-storage.jsx
git apply -v - <<'EOF_114329324912'
diff --git a/client/blocks/plan-storage/test/plan-storage.jsx b/client/blocks/plan-storage/test/plan-storage.jsx
index 6c5dd301fc10b5..d2f1b6bbdd242a 100644
--- a/client/blocks/plan-storage/test/plan-storage.jsx
+++ b/client/blocks/plan-storage/test/plan-storage.jsx
@@ -29,6 +29,7 @@ import { PlanStorage } from '../index';
 
 describe( 'PlanStorage basic tests', () => {
 	const props = {
+		canViewBar: true,
 		mediaStorage: {
 			max_storage_bytes: 1000,
 		},
@@ -90,6 +91,11 @@ describe( 'PlanStorage basic tests', () => {
 		const storage = shallow( <PlanStorage { ...props } jetpackSite={ true } /> );
 		assert.lengthOf( storage.find( '.plan-storage' ), 0 );
 	} );
+	
+	test( 'should not render for contributors', () => {
+		const storage = shallow( <PlanStorage { ...props } canViewBar={ false } /> );
+		assert.lengthOf( storage.find( '.plan-storage' ), 0 );
+	} );
 
 	test( 'should not render when site plan slug is empty', () => {
 		const storage = shallow( <PlanStorage { ...props } sitePlanSlug={ null } /> );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/plan-storage/test/plan-storage.jsx
: '>>>>> End Test Output'
git checkout 9e445e13dd96de61e7b7c5c98ad98e12268a4d12 client/blocks/plan-storage/test/plan-storage.jsx
