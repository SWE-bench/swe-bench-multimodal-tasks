#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff eb1aca6e4a7cf826b7ffa1e24a1075846747e344
rm -f tests/docs/smoke-all/2023/04/24/5286.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/04/24/5286.qmd b/tests/docs/smoke-all/2023/04/24/5286.qmd
new file mode 100644
index 0000000000..f48ea69f14
--- /dev/null
+++ b/tests/docs/smoke-all/2023/04/24/5286.qmd
@@ -0,0 +1,61 @@
+---
+_quarto:
+  tests:
+    latex:
+      ensureFileRegexMatches:
+        - []
+        - ['.*\\textless{}1\\textgreater{}.*']
+---
+
+
+##  Tests
+
+
+``` c
+#define EnterCritical()      \
+  do {                       \
+    __asm (                  \
+      "mrs   r0, PRIMASK \n" \ /* <1> */
+      "cpsid i           \n" \ /* <2> */
+      "strb r0, cpuSR    \n" \ /* <3> */
+    );                       \
+  } while(0)
+```
+1. `PRIMASK` wird in `R0` abgespeichert
+2. Interrupts deaktivieren
+3. `R0` in `cpuSR` abspeichern
+
+``` c
+#define ExitCritical()    \
+  do {                    \
+    __asm(                \
+      "ldrb r0, cpuSR \n" \ /* <1> */
+      "msr PRIMASK,r0 \n" \ /* <2> */
+    );                    \
+  } while(0)
+```
+1. Inhalt von `cpuSR` in `R0` laden
+2. `R0` nach `PRIMASK` kopieren.
+
+
+```javascript
+var foo = "bar" // <1>
+
+```
+1. This is a js annotation
+
+
+```yaml
+foo:
+  bar:
+    zed: This is a value # <1>
+```
+1. This is an annotation
+
+
+```bash
+((area=5*5))
+echo $area # <1>
+
+```
+1. This is an annotation
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/04/24/5286.qmd
