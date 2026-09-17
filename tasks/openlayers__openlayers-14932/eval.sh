#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 0b90e813b8800cf8902b15edeebbdf48704d1a64
git checkout 0b90e813b8800cf8902b15edeebbdf48704d1a64 test/rendering/cases/text-style-linestring-nice/expected.png test/rendering/cases/text-style-linestring-nice/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/rendering/cases/text-style-linestring-nice/main.js b/test/rendering/cases/text-style-linestring-nice/main.js
index afada42cb20..6795c020a82 100644
--- a/test/rendering/cases/text-style-linestring-nice/main.js
+++ b/test/rendering/cases/text-style-linestring-nice/main.js
@@ -170,4 +170,4 @@ const map = new Map({
 });
 map.getView().fit(vectorSource.getExtent());
 
-render({tolerance: 0.021});
+render({tolerance: 0.01});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=true PUPPETEER_CACHE_DIR=/home/chromeuser/.cache/puppeteer xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "CI=true PUPPETEER_CACHE_DIR=/home/chromeuser/.cache/puppeteer npm run build-full && CI=true PUPPETEER_CACHE_DIR=/home/chromeuser/.cache/puppeteer node test/rendering/test.js --force --headless --log-level info --match '(?:^|/)cases/(?:full\-build|text\-style\-linestring\-nice)/main\.js$'"
: '>>>>> End Test Output'
git checkout 0b90e813b8800cf8902b15edeebbdf48704d1a64 test/rendering/cases/text-style-linestring-nice/expected.png test/rendering/cases/text-style-linestring-nice/main.js
