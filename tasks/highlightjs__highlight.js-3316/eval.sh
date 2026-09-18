#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff e4226f5724c5a8fad85a95ead2123bde49c070a4
git checkout e4226f5724c5a8fad85a95ead2123bde49c070a4 test/markup/cpp/bitwise-keywords.expect.txt test/markup/cpp/template-complexity.expect.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/cpp/bitwise-keywords.expect.txt b/test/markup/cpp/bitwise-keywords.expect.txt
index abf6570af9..c27ed59d06 100644
--- a/test/markup/cpp/bitwise-keywords.expect.txt
+++ b/test/markup/cpp/bitwise-keywords.expect.txt
@@ -1,5 +1,5 @@
-<span class="hljs-keyword">unsigned</span> <span class="hljs-type">char</span> a = <span class="hljs-number">0xFA</span>;
-<span class="hljs-keyword">unsigned</span> <span class="hljs-type">char</span> b = <span class="hljs-number">0x4C</span>;
+<span class="hljs-type">unsigned</span> <span class="hljs-type">char</span> a = <span class="hljs-number">0xFA</span>;
+<span class="hljs-type">unsigned</span> <span class="hljs-type">char</span> b = <span class="hljs-number">0x4C</span>;
 
 a = <span class="hljs-keyword">compl</span> b;
 a = <span class="hljs-keyword">not</span> b;
diff --git a/test/markup/cpp/template-complexity.expect.txt b/test/markup/cpp/template-complexity.expect.txt
index 9e004abdb7..92b83178b6 100644
--- a/test/markup/cpp/template-complexity.expect.txt
+++ b/test/markup/cpp/template-complexity.expect.txt
@@ -7,8 +7,8 @@
 }
 
 <span class="hljs-comment">// Disable overload for already valid operands.</span>
-<span class="hljs-keyword">template</span>&lt;<span class="hljs-keyword">class</span> <span class="hljs-title class_">T</span>, <span class="hljs-keyword">class</span> = std::<span class="hljs-type">enable_if_t</span>&lt;!impl::is_streamable_v&lt;<span class="hljs-keyword">const</span> T &amp;&gt; &amp;&amp; std::is_convertible_v&lt;<span class="hljs-keyword">const</span> T &amp;, std::wstring_view&gt;&gt;&gt;
-std::wostream &amp;<span class="hljs-keyword">operator</span> &lt;&lt;(std::wostream &amp;stream, <span class="hljs-keyword">const</span> T &amp;thing)
+<span class="hljs-keyword">template</span>&lt;<span class="hljs-keyword">class</span> <span class="hljs-title class_">T</span>, <span class="hljs-keyword">class</span> = std::<span class="hljs-type">enable_if_t</span>&lt;!impl::is_streamable_v&lt;<span class="hljs-type">const</span> T &amp;&gt; &amp;&amp; std::is_convertible_v&lt;<span class="hljs-type">const</span> T &amp;, std::wstring_view&gt;&gt;&gt;
+std::wostream &amp;<span class="hljs-keyword">operator</span> &lt;&lt;(std::wostream &amp;stream, <span class="hljs-type">const</span> T &amp;thing)
 {
     <span class="hljs-keyword">return</span> stream &lt;&lt; <span class="hljs-built_in">static_cast</span>&lt;std::wstring_view&gt;(thing);
 }

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout e4226f5724c5a8fad85a95ead2123bde49c070a4 test/markup/cpp/bitwise-keywords.expect.txt test/markup/cpp/template-complexity.expect.txt
