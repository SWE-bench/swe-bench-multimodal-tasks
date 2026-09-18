#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff c0138d99b476933eb105e9c7eff4b2cd006d70bb
rm -f test/markup/cpp/bugs.expect.txt test/markup/cpp/bugs.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/cpp/bugs.expect.txt b/test/markup/cpp/bugs.expect.txt
new file mode 100644
index 0000000000..08e8689dfc
--- /dev/null
+++ b/test/markup/cpp/bugs.expect.txt
@@ -0,0 +1,6 @@
+<span class="hljs-comment">//4. 对角矩阵</span>
+<span class="hljs-comment">//4.1 构造对角矩阵</span>
+<span class="hljs-function">Eigen::VectorXd <span class="hljs-title">vector</span><span class="hljs-params">(<span class="hljs-number">5</span>)</span></span>;                <span class="hljs-comment">//构建5维向量</span>
+vector&lt;&lt;<span class="hljs-number">1</span>,<span class="hljs-number">2</span>,<span class="hljs-number">3</span>,<span class="hljs-number">4</span>,<span class="hljs-number">5</span>;                        <span class="hljs-comment">//向量赋值</span>
+<span class="hljs-function">Eigen::MatrixXd  <span class="hljs-title">C</span><span class="hljs-params">(vector.asDiagonal())</span></span>;  <span class="hljs-comment">//使用向量生成对角阵</span>
+std::cout &lt;&lt; <span class="hljs-string">&quot;\nC= \n&quot;</span> &lt;&lt; C &lt;&lt; std::endl;
diff --git a/test/markup/cpp/bugs.txt b/test/markup/cpp/bugs.txt
new file mode 100644
index 0000000000..00c4281821
--- /dev/null
+++ b/test/markup/cpp/bugs.txt
@@ -0,0 +1,6 @@
+//4. 对角矩阵
+//4.1 构造对角矩阵
+Eigen::VectorXd vector(5);                //构建5维向量
+vector<<1,2,3,4,5;                        //向量赋值
+Eigen::MatrixXd  C(vector.asDiagonal());  //使用向量生成对角阵
+std::cout << "\nC= \n" << C << std::endl;

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/cpp/bugs.expect.txt test/markup/cpp/bugs.txt
