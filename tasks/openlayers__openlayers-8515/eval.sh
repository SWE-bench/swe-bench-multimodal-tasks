#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a94dff2c0635cce72f2ca6de32fe6805d26c0444
git checkout a94dff2c0635cce72f2ca6de32fe6805d26c0444 test/spec/ol/interaction/draw.test.js test/spec/ol/interaction/modify.test.js test/spec/ol/interaction/select.test.js test/spec/ol/layer/layer.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/interaction/draw.test.js b/test/spec/ol/interaction/draw.test.js
index 7f70e0e30d4..cfc5f45a89c 100644
--- a/test/spec/ol/interaction/draw.test.js
+++ b/test/spec/ol/interaction/draw.test.js
@@ -1060,6 +1060,13 @@ describe('ol.interaction.Draw', function() {
     });
   });
 
+  describe('#getOverlay', function() {
+    it('returns the feature overlay layer', function() {
+      const draw = new Draw({});
+      expect (draw.getOverlay()).to.eql(draw.overlay_);
+    });
+  });
+
   describe('createRegularPolygon', function() {
     it('creates a regular polygon in Circle mode', function() {
       const draw = new Draw({
diff --git a/test/spec/ol/interaction/modify.test.js b/test/spec/ol/interaction/modify.test.js
index 2ac9ebb07d3..aa6ca05749c 100644
--- a/test/spec/ol/interaction/modify.test.js
+++ b/test/spec/ol/interaction/modify.test.js
@@ -712,4 +712,13 @@ describe('ol.interaction.Modify', function() {
     });
   });
 
+  describe('#getOverlay', function() {
+    it('returns the feature overlay layer', function() {
+      const modify = new Modify({
+        features: new Collection()
+      });
+      expect (modify.getOverlay()).to.eql(modify.overlay_);
+    });
+  });
+
 });
diff --git a/test/spec/ol/interaction/select.test.js b/test/spec/ol/interaction/select.test.js
index 79379cabc17..0445fecf531 100644
--- a/test/spec/ol/interaction/select.test.js
+++ b/test/spec/ol/interaction/select.test.js
@@ -442,4 +442,11 @@ describe('ol.interaction.Select', function() {
       });
     });
   });
+
+  describe('#getOverlay', function() {
+    it('returns the feature overlay layer', function() {
+      const select = new Select();
+      expect (select.getOverlay()).to.eql(select.featureOverlay_);
+    });
+  });
 });
diff --git a/test/spec/ol/layer/layer.test.js b/test/spec/ol/layer/layer.test.js
index 807531e8e21..ff3aeb97a58 100644
--- a/test/spec/ol/layer/layer.test.js
+++ b/test/spec/ol/layer/layer.test.js
@@ -434,6 +434,41 @@ describe('ol.layer.Layer', function() {
 
     });
 
+    describe('zIndex for unmanaged layers', function() {
+
+      let frameState, layer;
+
+      beforeEach(function() {
+        layer = new Layer({
+          map: map
+        });
+        frameState = {
+          layerStatesArray: [],
+          layerStates: {}
+        };
+      });
+
+      afterEach(function() {
+        layer.setMap(null);
+      });
+
+      it('has Infinity as zIndex when not configured otherwise', function() {
+        map.dispatchEvent(new RenderEvent('precompose', null,
+          frameState, null, null));
+        const layerState = frameState.layerStatesArray[0];
+        expect(layerState.zIndex).to.be(Infinity);
+      });
+
+      it('respects the configured zIndex', function() {
+        layer.setZIndex(42);
+        map.dispatchEvent(new RenderEvent('precompose', null,
+          frameState, null, null));
+        const layerState = frameState.layerStatesArray[0];
+        expect(layerState.zIndex).to.be(42);
+      });
+
+    });
+
   });
 
 });

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/interaction/draw.test.js'"'"');' 'require('"'"'./spec/ol/interaction/modify.test.js'"'"');' 'require('"'"'./spec/ol/interaction/select.test.js'"'"');' 'require('"'"'./spec/ol/layer/layer.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' '{spec/ol/interaction/draw.test.js,spec/ol/interaction/modify.test.js,spec/ol/interaction/select.test.js,spec/ol/layer/layer.test.js}'; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout a94dff2c0635cce72f2ca6de32fe6805d26c0444 test/spec/ol/interaction/draw.test.js test/spec/ol/interaction/modify.test.js test/spec/ol/interaction/select.test.js test/spec/ol/layer/layer.test.js
