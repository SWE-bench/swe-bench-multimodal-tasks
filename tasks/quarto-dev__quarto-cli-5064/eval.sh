#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 45f6955378250e8288a79cd176c2dce92b279d2b
rm -f tests/docs/smoke-all/2023/04/01/5060.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/04/01/5060.qmd b/tests/docs/smoke-all/2023/04/01/5060.qmd
new file mode 100644
index 0000000000..692dc3e055
--- /dev/null
+++ b/tests/docs/smoke-all/2023/04/01/5060.qmd
@@ -0,0 +1,85 @@
+--- 
+title: test
+format: latex
+_quarto:
+  tests:
+    latex:
+      ensureFileRegexMatches:
+        - []
+        - ["\\\\CommentTok\\{[^a-zA-Z0-9\\s]* \\\\textless\\{\\}\\d+\\\\textgreater\\{\\}\\}"]
+---
+
+```matlab
+a = [3 6 7];
+b = [1 9 4];
+c= a + b  % <1>
+
+```
+
+1. Add some cool things up in this piece.
+
+
+
+``` vhdl
+type state is (S0, S1, S2);
+signal c_st, n_st : state;
+
+p_seq: process (rst, clk)                       -- <1>
+begin
+  if rst = ’1’ then
+    c_st <= S0;
+  elsif rising_edge(clk) then
+    c_st <= n_st;
+  end if;
+end process;
+
+p_com: process (i, c_st)                        -- <2>
+begin                                           -- <2>
+  -- default assignments                        -- <2>
+  n_st <= c_st; -- remain in current state      -- <2>
+  o <= ’1’; -- most frequent value              -- <2>
+  -- specific assignments                       -- <2>
+  case c_st is                                  -- <2>
+    when S0 =>                                  -- <2>
+      if i = "00" then                          -- <2>
+        n_st <= S1;                             -- <2>
+      end if;                                   -- <2>
+  end case;
+end process;
+```
+1.  [*Memorizing*]{.underline} (sequentielle Logik)
+2.  [*Memoryless*]{.underline} (kombinatorische Logik)
+
+
+```cpp
+int main(void) {
+  uint8_t test;                                 // <1>
+}                                               // <1>
+
+void testing(int a) {                           // <2>
+  a += a;                                       // <2>
+}                                               // <2>
+```
+1. Hello World
+2. This is just a test
+
+```r
+library(tidyverse)
+library(palmerpenguins)
+penguins |>                                      # <1>
+  mutate(                                        # <2>
+    bill_ratio = bill_depth_mm / bill_length_mm, # <2>
+    bill_area  = bill_depth_mm * bill_length_mm  # <2>
+  )                                              # <2>  
+```
+1. Take `penguins`, and then,
+2. add new columns for the bill ratio and bill area.
+
+
+```python
+thislist = ["apple", "banana", "cherry"]
+thislist.remove("banana")                 # <1>
+print(thislist)                           # <2>
+```
+1. Remove `banana` from the list
+2. Print list
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/04/01/5060.qmd
