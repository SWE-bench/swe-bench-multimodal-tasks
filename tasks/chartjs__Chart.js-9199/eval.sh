#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 599e23abfd1bb3545e350d62647f19911125872b
git checkout 599e23abfd1bb3545e350d62647f19911125872b test/fixtures/plugin.legend/label-textAlign/rtl-left.png test/fixtures/plugin.legend/label-textAlign/rtl-right.png && rm -f test/fixtures/plugin.legend/label-textAlign/horizontal-left.js test/fixtures/plugin.legend/label-textAlign/horizontal-left.png test/fixtures/plugin.legend/label-textAlign/horizontal-right.js test/fixtures/plugin.legend/label-textAlign/horizontal-right.png test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.js test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.png test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.js test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.png
git apply -v - <<'EOF_114329324912'
diff --git a/test/fixtures/plugin.legend/label-textAlign/horizontal-left.js b/test/fixtures/plugin.legend/label-textAlign/horizontal-left.js
new file mode 100644
index 00000000000..46458c532e4
--- /dev/null
+++ b/test/fixtures/plugin.legend/label-textAlign/horizontal-left.js
@@ -0,0 +1,30 @@
+module.exports = {
+  config: {
+    type: 'pie',
+    data: {
+      labels: ['aaaa', 'bb', 'c'],
+      datasets: [
+        {
+          data: [1, 2, 3]
+        }
+      ]
+    },
+    options: {
+      plugins: {
+        legend: {
+          position: 'top',
+          labels: {
+            textAlign: 'left'
+          }
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      width: 256,
+      height: 256
+    }
+  }
+};
diff --git a/test/fixtures/plugin.legend/label-textAlign/horizontal-right.js b/test/fixtures/plugin.legend/label-textAlign/horizontal-right.js
new file mode 100644
index 00000000000..729c663ac0a
--- /dev/null
+++ b/test/fixtures/plugin.legend/label-textAlign/horizontal-right.js
@@ -0,0 +1,30 @@
+module.exports = {
+  config: {
+    type: 'pie',
+    data: {
+      labels: ['aaaa', 'bb', 'c'],
+      datasets: [
+        {
+          data: [1, 2, 3]
+        }
+      ]
+    },
+    options: {
+      plugins: {
+        legend: {
+          position: 'top',
+          labels: {
+            textAlign: 'right'
+          }
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      width: 256,
+      height: 256
+    }
+  }
+};
diff --git a/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.js b/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.js
new file mode 100644
index 00000000000..5fff9c72a2b
--- /dev/null
+++ b/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.js
@@ -0,0 +1,31 @@
+module.exports = {
+  config: {
+    type: 'pie',
+    data: {
+      labels: ['aaaa', 'bb', 'c'],
+      datasets: [
+        {
+          data: [1, 2, 3]
+        }
+      ]
+    },
+    options: {
+      plugins: {
+        legend: {
+          position: 'top',
+          rtl: true,
+          labels: {
+            textAlign: 'left'
+          }
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      width: 256,
+      height: 256
+    }
+  }
+};
diff --git a/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.js b/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.js
new file mode 100644
index 00000000000..ae900510368
--- /dev/null
+++ b/test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.js
@@ -0,0 +1,31 @@
+module.exports = {
+  config: {
+    type: 'pie',
+    data: {
+      labels: ['aaaa', 'bb', 'c'],
+      datasets: [
+        {
+          data: [1, 2, 3]
+        }
+      ]
+    },
+    options: {
+      plugins: {
+        legend: {
+          rtl: true,
+          position: 'top',
+          labels: {
+            textAlign: 'right'
+          }
+        }
+      }
+    }
+  },
+  options: {
+    spriteText: true,
+    canvas: {
+      width: 256,
+      height: 256
+    }
+  }
+};
EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm install ; npm run build ; sed -i '0,/\.set({/s//.set({\n    browserNoActivityTimeout: 300000,/' ./karma.conf.js ; xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" su chromeuser -c "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start ./karma.conf.js --single-run --coverage --grep --auto-watch false"
: '>>>>> End Test Output'
git checkout 599e23abfd1bb3545e350d62647f19911125872b test/fixtures/plugin.legend/label-textAlign/rtl-left.png test/fixtures/plugin.legend/label-textAlign/rtl-right.png && rm -f test/fixtures/plugin.legend/label-textAlign/horizontal-left.js test/fixtures/plugin.legend/label-textAlign/horizontal-left.png test/fixtures/plugin.legend/label-textAlign/horizontal-right.js test/fixtures/plugin.legend/label-textAlign/horizontal-right.png test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.js test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-left.png test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.js test/fixtures/plugin.legend/label-textAlign/horizontal-rtl-right.png
