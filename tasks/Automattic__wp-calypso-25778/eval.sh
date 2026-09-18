#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 54d626a276373d45ffddd2cf4f7099733c8e43de
git checkout 54d626a276373d45ffddd2cf4f7099733c8e43de client/state/data-layer/wpcom/comments/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/data-layer/wpcom/comments/test/index.js b/client/state/data-layer/wpcom/comments/test/index.js
index 139947cb8d4bf8..de235c9ec31c9b 100644
--- a/client/state/data-layer/wpcom/comments/test/index.js
+++ b/client/state/data-layer/wpcom/comments/test/index.js
@@ -177,6 +177,7 @@ describe( 'wpcom-api', () => {
 						notice: expect.objectContaining( {
 							status: 'is-error',
 							text: 'Could not retrieve comments for requested post',
+							duration: 5000,
 						} ),
 					} )
 				);

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/data-layer/wpcom/comments/test/index.js
: '>>>>> End Test Output'
git checkout 54d626a276373d45ffddd2cf4f7099733c8e43de client/state/data-layer/wpcom/comments/test/index.js
