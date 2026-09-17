#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff e3953acf1edb80c3e99c53ea22634304f3c31afa
git checkout e3953acf1edb80c3e99c53ea22634304f3c31afa test/specs/core.plugin.tests.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/core.plugin.tests.js b/test/specs/core.plugin.tests.js
index c709846d1e9..af93dc53af3 100644
--- a/test/specs/core.plugin.tests.js
+++ b/test/specs/core.plugin.tests.js
@@ -342,5 +342,24 @@ describe('Chart.plugins', function() {
 
 			expect(plugin.hook).not.toHaveBeenCalled();
 		});
+
+		it('should not restart plugins when a double register occurs', function() {
+			var results = [];
+			var chart = window.acquireChart({
+				plugins: [{
+					start: function() {
+						results.push(1);
+					}
+				}]
+			});
+
+			Chart.register({id: 'abc', hook: function() {}});
+			Chart.register({id: 'def', hook: function() {}});
+
+			chart.update();
+
+			// The plugin on the chart should only be started once
+			expect(results).toEqual([1]);
+		});
 	});
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout e3953acf1edb80c3e99c53ea22634304f3c31afa test/specs/core.plugin.tests.js
