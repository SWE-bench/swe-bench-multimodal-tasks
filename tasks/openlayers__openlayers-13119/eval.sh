#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 848965b25c21e106671d3ae2cd23a05d2ba4de21
git checkout 848965b25c21e106671d3ae2cd23a05d2ba4de21 test/browser/spec/ol/layer/WebGLTile.test.js && rm -f test/rendering/cases/webgl-precompose-event/expected.png test/rendering/cases/webgl-precompose-event/main.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/browser/spec/ol/layer/WebGLTile.test.js b/test/browser/spec/ol/layer/WebGLTile.test.js
index d4b14695f8c..f590af4c265 100644
--- a/test/browser/spec/ol/layer/WebGLTile.test.js
+++ b/test/browser/spec/ol/layer/WebGLTile.test.js
@@ -257,6 +257,21 @@ describe('ol/layer/WebGLTile', function () {
     });
   });
 
+  it('dispatches a precompose event with WebGL context', (done) => {
+    let called = false;
+    layer.on('precompose', (event) => {
+      expect(event.context).to.be.a(WebGLRenderingContext);
+      called = true;
+    });
+
+    map.once('rendercomplete', () => {
+      expect(called).to.be(true);
+      done();
+    });
+
+    map.render();
+  });
+
   it('dispatches a prerender event with WebGL context and inverse pixel transform', (done) => {
     let called = false;
     layer.on('prerender', (event) => {
diff --git a/test/rendering/cases/webgl-precompose-event/main.js b/test/rendering/cases/webgl-precompose-event/main.js
new file mode 100644
index 00000000000..750ef76160a
--- /dev/null
+++ b/test/rendering/cases/webgl-precompose-event/main.js
@@ -0,0 +1,80 @@
+import DataTileSource from '../../../../src/ol/source/DataTile.js';
+import Map from '../../../../src/ol/Map.js';
+import TileLayer from '../../../../src/ol/layer/WebGLTile.js';
+import View from '../../../../src/ol/View.js';
+
+const high = new Uint8Array(256 * 256).fill(255);
+const low = new Uint8Array(256 * 256).fill(0);
+
+const red = new TileLayer({
+  transition: 0,
+  source: new DataTileSource({
+    minZoom: 2,
+    loader: function (z, x, y) {
+      if ((x + y) % 2 === 0) {
+        return high;
+      }
+      return low;
+    },
+  }),
+  style: {
+    color: ['array', ['band', 1], 0, 0, 1],
+  },
+});
+
+const green = new TileLayer({
+  transition: 0,
+  source: new DataTileSource({
+    minZoom: 2,
+    loader: (z, x) => {
+      if (x % 2 === 0) {
+        return high;
+      }
+      return low;
+    },
+  }),
+  style: {
+    color: ['array', 0, ['band', 1], 0, 1],
+  },
+});
+
+green.on('precompose', (event) => {
+  const gl = event.context;
+  gl.blendEquation(gl.FUNC_ADD);
+  gl.blendFunc(gl.ONE, gl.ONE);
+});
+
+const blue = new TileLayer({
+  transition: 0,
+  source: new DataTileSource({
+    minZoom: 2,
+    loader: (z, x, y) => {
+      if (y % 2 === 0) {
+        return high;
+      }
+      return low;
+    },
+  }),
+  style: {
+    color: ['array', 0, 0, ['band', 1], 1],
+  },
+});
+
+blue.on('precompose', (event) => {
+  const gl = event.context;
+  gl.blendEquation(gl.FUNC_ADD);
+  gl.blendFunc(gl.ONE, gl.ONE);
+});
+
+new Map({
+  target: 'map',
+  layers: [red, green, blue],
+  view: new View({
+    center: [0, 0],
+    zoom: 0,
+  }),
+});
+
+render({
+  message: 'precompose events can be used to change layer blending',
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CI=1 PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" npm run test-rendering -- --headless --log-level info --match "(?:^|/)cases/(?:icon\\-opacity|webgl\\-precompose\\-event)/main\\.js$" ; if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./browser/spec/ol/layer/WebGLTile.test.js'"'"');' > test/index_test.js; PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" spec/ol/layer/WebGLTile.test.js browser/spec/ol/layer/WebGLTile.test.js; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout 848965b25c21e106671d3ae2cd23a05d2ba4de21 test/browser/spec/ol/layer/WebGLTile.test.js && rm -f test/rendering/cases/webgl-precompose-event/expected.png test/rendering/cases/webgl-precompose-event/main.js
