#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a7947a6b921e1f05f251bd59404d5626a7d23c29
rm -f test/markup/perl/regex.expect.txt test/markup/perl/regex.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/perl/regex.expect.txt b/test/markup/perl/regex.expect.txt
new file mode 100644
index 0000000000..a1cd881d65
--- /dev/null
+++ b/test/markup/perl/regex.expect.txt
@@ -0,0 +1,37 @@
+<span class="hljs-keyword">use</span> <span class="hljs-number">5.020</span>;
+<span class="hljs-keyword">use</span> strict;
+<span class="hljs-keyword">use</span> warnings;
+
+<span class="hljs-function"><span class="hljs-keyword">sub</span> <span class="hljs-title">saeaoagr</span> () </span>{
+    <span class="hljs-keyword">print</span> <span class="hljs-string">&quot;foo&quot;</span>;
+    <span class="hljs-regexp">qr/x/</span>;
+}
+
+<span class="hljs-comment"># Those are the most popular</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s/e/o/gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s!e!o!gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s|e|o|gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s{e}{o}gr</span> . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s(e)(o)gr</span> . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s[e][o]gr</span> . <span class="hljs-string">&quot;bar&quot;</span>);
+
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m/e/gr</span>;
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m!e!gr</span>;
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m|e|gr</span>;
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m{e}gr</span>;
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m(e)gr</span>;
+<span class="hljs-keyword">return</span> <span class="hljs-regexp">m[e]gr</span>;
+
+<span class="hljs-comment"># Those have syntactic significance</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s?e?o?gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s&#x27;e&#x27;o&#x27;gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);  <span class="hljs-comment"># &#x27; # quote to fix</span>
+
+<span class="hljs-comment"># Those are valid, but infrequent (and weird)</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s&quot;e&quot;o&quot;gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);  <span class="hljs-comment"># &quot; # quote to fix</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ s aeaoagr . <span class="hljs-string">&quot;bar&quot;</span>);
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ <span class="hljs-regexp">s#e#o#gr</span>  . <span class="hljs-string">&quot;bar&quot;</span>);
+
+<span class="hljs-comment"># Those must not be confused with the previous two</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ saeaoagr  . <span class="hljs-string">&quot;bar&quot;</span>);  <span class="hljs-comment"># calls saeaoagr()</span>
+<span class="hljs-keyword">say</span> (<span class="hljs-string">&quot;fee&quot;</span> =~ s <span class="hljs-comment">#e#o#gr              that&#x27;s a comment, not a regex</span>
+     (e)(o)gr . <span class="hljs-string">&quot;bar&quot;</span>);            <span class="hljs-comment"># and here&#x27;s the regex.</span>
diff --git a/test/markup/perl/regex.txt b/test/markup/perl/regex.txt
new file mode 100644
index 0000000000..1cf168d5ce
--- /dev/null
+++ b/test/markup/perl/regex.txt
@@ -0,0 +1,37 @@
+use 5.020;
+use strict;
+use warnings;
+
+sub saeaoagr () {
+    print "foo";
+    qr/x/;
+}
+
+# Those are the most popular
+say ("fee" =~ s/e/o/gr  . "bar");
+say ("fee" =~ s!e!o!gr  . "bar");
+say ("fee" =~ s|e|o|gr  . "bar");
+say ("fee" =~ s{e}{o}gr . "bar");
+say ("fee" =~ s(e)(o)gr . "bar");
+say ("fee" =~ s[e][o]gr . "bar");
+
+return m/e/gr;
+return m!e!gr;
+return m|e|gr;
+return m{e}gr;
+return m(e)gr;
+return m[e]gr;
+
+# Those have syntactic significance
+say ("fee" =~ s?e?o?gr  . "bar");
+say ("fee" =~ s'e'o'gr  . "bar");  # ' # quote to fix
+
+# Those are valid, but infrequent (and weird)
+say ("fee" =~ s"e"o"gr  . "bar");  # " # quote to fix
+say ("fee" =~ s aeaoagr . "bar");
+say ("fee" =~ s#e#o#gr  . "bar");
+
+# Those must not be confused with the previous two
+say ("fee" =~ saeaoagr  . "bar");  # calls saeaoagr()
+say ("fee" =~ s #e#o#gr              that's a comment, not a regex
+     (e)(o)gr . "bar");            # and here's the regex.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/perl/regex.expect.txt test/markup/perl/regex.txt
