#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 201ddffa1d0d0bf61a4372ff1386dbcffd606850
git checkout 201ddffa1d0d0bf61a4372ff1386dbcffd606850 test/fixtures/plugin.legend/legend-doughnut-right-center-mulitiline-labels.png
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
pnpm install ; pnpm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.cjs ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.cjs --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 201ddffa1d0d0bf61a4372ff1386dbcffd606850 test/fixtures/plugin.legend/legend-doughnut-right-center-mulitiline-labels.png
