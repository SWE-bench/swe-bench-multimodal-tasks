#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 9231480516c5a3eed1d400baceca5b7169eba4cb
git checkout 9231480516c5a3eed1d400baceca5b7169eba4cb client/blocks/get-apps/test/__snapshots__/apps-badge.js.snap client/blocks/get-apps/test/apps-badge.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/me/get-apps/test/__snapshots__/apps-badge.js.snap b/client/blocks/get-apps/test/__snapshots__/apps-badge.js.snap
similarity index 100%
rename from client/me/get-apps/test/__snapshots__/apps-badge.js.snap
rename to client/blocks/get-apps/test/__snapshots__/apps-badge.js.snap
diff --git a/client/me/get-apps/test/apps-badge.js b/client/blocks/get-apps/test/apps-badge.js
similarity index 100%
rename from client/me/get-apps/test/apps-badge.js
rename to client/blocks/get-apps/test/apps-badge.js

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/blocks/get-apps/test/apps-badge.js
: '>>>>> End Test Output'
git checkout 9231480516c5a3eed1d400baceca5b7169eba4cb client/blocks/get-apps/test/__snapshots__/apps-badge.js.snap client/blocks/get-apps/test/apps-badge.js
