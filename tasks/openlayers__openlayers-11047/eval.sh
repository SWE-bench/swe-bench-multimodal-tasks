#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff bfc035415edabfe297faf6d68575d8118e088fba
git checkout bfc035415edabfe297faf6d68575d8118e088fba test/spec/ol/disposable.test.js test/spec/ol/source/raster.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/spec/ol/disposable.test.js b/test/spec/ol/disposable.test.js
index a118a0a0b7f..14d3669b073 100644
--- a/test/spec/ol/disposable.test.js
+++ b/test/spec/ol/disposable.test.js
@@ -8,16 +8,16 @@ describe('ol.Disposable', function () {
     });
   });
 
-  describe('#disposed_', function () {
+  describe('#disposed', function () {
     it('is initially false', function () {
       const disposable = new Disposable();
-      expect(disposable.disposed_).to.be(false);
+      expect(disposable.disposed).to.be(false);
     });
 
     it('is true after a call to dispose', function () {
       const disposable = new Disposable();
       disposable.dispose();
-      expect(disposable.disposed_).to.be(true);
+      expect(disposable.disposed).to.be(true);
     });
   });
 
diff --git a/test/spec/ol/source/raster.test.js b/test/spec/ol/source/raster.test.js
index 5a8facbb584..e3ca585d208 100644
--- a/test/spec/ol/source/raster.test.js
+++ b/test/spec/ol/source/raster.test.js
@@ -3,7 +3,10 @@ import ImageLayer from '../../../../src/ol/layer/Image.js';
 import Map from '../../../../src/ol/Map.js';
 import Point from '../../../../src/ol/geom/Point.js';
 import Projection from '../../../../src/ol/proj/Projection.js';
-import RasterSource from '../../../../src/ol/source/Raster.js';
+import RasterSource, {
+  Processor,
+  newImageData,
+} from '../../../../src/ol/source/Raster.js';
 import Source from '../../../../src/ol/source/Source.js';
 import Static from '../../../../src/ol/source/ImageStatic.js';
 import TileSource from '../../../../src/ol/source/Tile.js';
@@ -135,6 +138,20 @@ where('Uint8ClampedArray').describe('ol.source.Raster', function () {
       view.setZoom(0);
     });
 
+    it('disposes the processor when disposed', function () {
+      const source = new RasterSource({
+        threads: 0,
+        sources: [redSource, greenSource, blueSource],
+        operation: function (inputs) {
+          return inputs[0];
+        },
+      });
+
+      source.dispose();
+
+      expect(source.processor_.disposed).to.be(true);
+    });
+
     it('allows operation type to be set to "image"', function (done) {
       const log = [];
 
@@ -256,6 +273,17 @@ where('Uint8ClampedArray').describe('ol.source.Raster', function () {
         }
       });
     });
+
+    it('disposes the previous processor', function () {
+      const previousProcessor = raster.processor_;
+
+      raster.setOperation(function (pixels) {
+        return pixels[0];
+      });
+
+      expect(previousProcessor.disposed).to.be(true);
+      expect(raster.processor_.disposed).to.be(false);
+    });
   });
 
   describe('beforeoperations', function () {
@@ -388,3 +416,269 @@ where('Uint8ClampedArray').describe('ol.source.Raster', function () {
     });
   });
 });
+
+where('Uint8ClampedArray').describe('Processor', function () {
+  const identity = function (inputs) {
+    return inputs[0];
+  };
+
+  describe('constructor', function () {
+    it('creates a new processor', function () {
+      const processor = new Processor({
+        operation: identity,
+      });
+
+      expect(processor).to.be.a(Processor);
+    });
+  });
+
+  describe('#process()', function () {
+    it('calls operation with input pixels', function (done) {
+      const processor = new Processor({
+        operation: function (inputs, meta) {
+          ++meta.count;
+          const pixel = inputs[0];
+          for (let i = 0, ii = pixel.length; i < ii; ++i) {
+            meta.sum += pixel[i];
+          }
+          return pixel;
+        },
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4, 5, 6, 7, 8]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {count: 0, sum: 0}, function (err, output, m) {
+        if (err) {
+          done(err);
+          return;
+        }
+        expect(m.count).to.equal(2);
+        expect(m.sum).to.equal(36);
+        done();
+      });
+    });
+
+    it('calls callback with processed image data', function (done) {
+      const processor = new Processor({
+        operation: function (inputs) {
+          const pixel = inputs[0];
+          pixel[0] *= 2;
+          pixel[1] *= 2;
+          pixel[2] *= 2;
+          pixel[3] *= 2;
+          return pixel;
+        },
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4, 5, 6, 7, 8]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {}, function (err, output, m) {
+        if (err) {
+          done(err);
+          return;
+        }
+        expect(output).to.be.a(ImageData);
+        expect(output.data).to.eql(
+          new Uint8ClampedArray([2, 4, 6, 8, 10, 12, 14, 16])
+        );
+        done();
+      });
+    });
+
+    it('allows library functions to be called', function (done) {
+      const lib = {
+        sum: function (a, b) {
+          return a + b;
+        },
+        diff: function (a, b) {
+          return a - b;
+        },
+      };
+
+      const normalizedDiff = function (pixels) {
+        const pixel = pixels[0];
+        const r = pixel[0];
+        const g = pixel[1];
+        /* eslint-disable */
+        var nd = diff(r, g) / sum(r, g);
+        /* eslint-enable */
+        const index = Math.round((255 * (nd + 1)) / 2);
+        return [index, index, index, pixel[3]];
+      };
+
+      const processor = new Processor({
+        operation: normalizedDiff,
+        lib: lib,
+      });
+
+      const array = new Uint8ClampedArray([10, 2, 0, 0, 5, 8, 0, 1]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {}, function (err, output, m) {
+        if (err) {
+          done(err);
+          return;
+        }
+        expect(output).to.be.a(ImageData);
+        const v0 = Math.round((255 * (1 + 8 / 12)) / 2);
+        const v1 = Math.round((255 * (1 + -3 / 13)) / 2);
+        expect(output.data).to.eql(
+          new Uint8ClampedArray([v0, v0, v0, 0, v1, v1, v1, 1])
+        );
+
+        done();
+      });
+    });
+
+    it('calls callbacks for each call', function (done) {
+      const processor = new Processor({
+        operation: identity,
+      });
+
+      let calls = 0;
+
+      function createCallback(index) {
+        return function (err, output, meta) {
+          if (err) {
+            done(err);
+            return;
+          }
+          expect(output).to.be.a(ImageData);
+          ++calls;
+        };
+      }
+
+      for (let i = 0; i < 5; ++i) {
+        const input = newImageData(new Uint8ClampedArray([1, 2, 3, 4]), 1, 1);
+        processor.process([input], {}, createCallback(i));
+      }
+
+      setTimeout(function () {
+        expect(calls).to.be(5);
+        done();
+      }, 1000);
+    });
+
+    it('respects max queue length', function (done) {
+      const processor = new Processor({
+        queue: 1,
+        operation: identity,
+      });
+
+      const log = [];
+
+      function createCallback(index) {
+        return function (err, output, meta) {
+          if (err) {
+            done(err);
+            return;
+          }
+          log.push(output);
+        };
+      }
+
+      for (let i = 0; i < 5; ++i) {
+        const input = newImageData(new Uint8ClampedArray([1, 2, 3, 4]), 1, 1);
+        processor.process([input], {}, createCallback(i));
+      }
+
+      setTimeout(function () {
+        expect(log).to.have.length(5);
+        expect(log[0]).to.be(null);
+        expect(log[1]).to.be(null);
+        expect(log[2]).to.be(null);
+        expect(log[3]).to.be.a(ImageData);
+        expect(log[4]).to.be.a(ImageData);
+        done();
+      }, 1000);
+    });
+  });
+
+  describe('#process() - faux worker', function () {
+    let identitySpy;
+    beforeEach(function () {
+      identitySpy = sinon.spy(identity);
+    });
+
+    it('calls operation with input pixels', function (done) {
+      const processor = new Processor({
+        threads: 0,
+        operation: identitySpy,
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4, 5, 6, 7, 8]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {}, function (err, output, m) {
+        if (err) {
+          done(err);
+          return;
+        }
+        expect(identitySpy.callCount).to.be(2);
+        const first = identitySpy.getCall(0);
+        expect(first.args).to.have.length(2);
+        done();
+      });
+    });
+
+    it('passes meta object to operations', function (done) {
+      const processor = new Processor({
+        threads: 0,
+        operation: identitySpy,
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4]);
+      const input = newImageData(array, 1, 1);
+      const meta = {foo: 'bar'};
+
+      processor.process([input], meta, function (err, output, m) {
+        if (err) {
+          done(err);
+          return;
+        }
+        expect(m).to.eql(meta);
+        expect(identitySpy.callCount).to.be(1);
+        done();
+      });
+    });
+  });
+
+  describe('#dispose()', function () {
+    it('stops callbacks from being called', function (done) {
+      const processor = new Processor({
+        operation: identity,
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4, 5, 6, 7, 8]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {}, function () {
+        done(new Error('Expected abort to stop callback from being called'));
+      });
+
+      processor.dispose();
+      setTimeout(done, 500);
+    });
+  });
+
+  describe('#dispose() - faux worker', function () {
+    it('stops callbacks from being called', function (done) {
+      const processor = new Processor({
+        threads: 0,
+        operation: identity,
+      });
+
+      const array = new Uint8ClampedArray([1, 2, 3, 4, 5, 6, 7, 8]);
+      const input = newImageData(array, 1, 2);
+
+      processor.process([input], {}, function () {
+        done(new Error('Expected abort to stop callback from being called'));
+      });
+
+      processor.dispose();
+      setTimeout(done, 20);
+    });
+  });
+});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
if [ -f test/index_test.js ]; then cp test/index_test.js /tmp/swebench-openlayers-index-test.js; printf '%s\n' 'require('"'"'./spec/ol/disposable.test.js'"'"');' 'require('"'"'./spec/ol/source/raster.test.js'"'"');' > test/index_test.js; NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; cp /tmp/swebench-openlayers-index-test.js test/index_test.js; rm -f /tmp/swebench-openlayers-index-test.js; (exit "$OPENLAYERS_STATUS"); else KARMA_CONFIG=test/browser/karma.config.cjs; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/browser/karma.config.js; [ -f "$KARMA_CONFIG" ] || KARMA_CONFIG=test/karma.config.js; KARMA_BACKUP=/tmp/swebench-openlayers-karma-config; if [ ! -f "$KARMA_CONFIG" ]; then echo "OpenLayers Karma config not found" >&2; OPENLAYERS_CONFIG_STATUS=2; else cp "$KARMA_CONFIG" "$KARMA_BACKUP"; node -e 'const fs=require("fs");const p=process.argv[1],modern=process.argv[2],legacy=process.argv[3],source=fs.readFileSync(p,"utf8");let updated=source.replace(/spec\/\*\*\/\*\.test\.js/g,modern);if(updated===source)updated=source.replace(/\*\*\/\*\.test\.js/g,legacy);if(updated===source)process.exit(2);fs.writeFileSync(p,updated)' "$KARMA_CONFIG" '{}' '{spec/ol/disposable.test.js,spec/ol/source/raster.test.js}'; OPENLAYERS_CONFIG_STATUS=$?; fi; if [ "$OPENLAYERS_CONFIG_STATUS" -eq 0 ]; then NODE_OPTIONS=--openssl-legacy-provider PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "npm run karma -- --single-run --log-level error"; OPENLAYERS_STATUS=$?; else OPENLAYERS_STATUS=$OPENLAYERS_CONFIG_STATUS; fi; if [ -f "$KARMA_BACKUP" ]; then cp "$KARMA_BACKUP" "$KARMA_CONFIG"; fi; rm -f "$KARMA_BACKUP"; (exit "$OPENLAYERS_STATUS"); fi
: '>>>>> End Test Output'
git checkout bfc035415edabfe297faf6d68575d8118e088fba test/spec/ol/disposable.test.js test/spec/ol/source/raster.test.js
