#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 0549951e9ee935836c92a20ef72d79d9ee10a226
git checkout 0549951e9ee935836c92a20ef72d79d9ee10a226 test/spec/ol/render/canvas/textbuilder.test.js test/spec/ol/renderer/canvas/builder.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/render/canvas/textbuilder.test.js b/test/spec/ol/render/canvas/textbuilder.test.js
index 805f0d9c203..9052a80e4cd 100644
--- a/test/spec/ol/render/canvas/textbuilder.test.js
+++ b/test/spec/ol/render/canvas/textbuilder.test.js
@@ -35,7 +35,7 @@ function executeInstructions(
   const executor = new Executor(0.02, 1, false, builder.finish());
   sinon.spy(executor, 'drawLabelWithPointPlacement_');
   const replayImageOrLabelStub = sinon.stub(executor, 'replayImageOrLabel_');
-  executor.execute(context, transform);
+  executor.execute(context, 1, transform);
   expect(executor.drawLabelWithPointPlacement_.callCount).to.be(
     expectedDrawTextImageCalls
   );
diff --git a/test/spec/ol/renderer/canvas/builder.test.js b/test/spec/ol/renderer/canvas/builder.test.js
index 15accafbeb8..473aa096a26 100644
--- a/test/spec/ol/renderer/canvas/builder.test.js
+++ b/test/spec/ol/renderer/canvas/builder.test.js
@@ -40,7 +40,7 @@ describe('ol.render.canvas.BuilderGroup', function () {
         !!overlaps,
         builder.finish()
       );
-      executor.execute(context, transform, 0, false);
+      executor.execute(context, 1, transform, 0, false);
     }
 
     beforeEach(function () {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/render/canvas/textbuilder.test.js'"'"');' 'require('"'"'./spec/ol/renderer/canvas/builder.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' '{spec/ol/render/canvas/textbuilder.test.js,spec/ol/renderer/canvas/builder.test.js}'; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 0549951e9ee935836c92a20ef72d79d9ee10a226 test/spec/ol/render/canvas/textbuilder.test.js test/spec/ol/renderer/canvas/builder.test.js
