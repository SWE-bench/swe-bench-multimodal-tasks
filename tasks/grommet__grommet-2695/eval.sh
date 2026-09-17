#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff bcde5d660f50359d8e46e33dcfe3bbc8968471ef
git checkout bcde5d660f50359d8e46e33dcfe3bbc8968471ef src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap
git apply -v - <<'EOF_114329324912'
diff --git a/src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap b/src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap
index 1c094dd1ab..979d048199 100644
--- a/src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap
+++ b/src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap
@@ -17,8 +17,8 @@ exports[`Meter background 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -144,8 +144,8 @@ exports[`Meter basic 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -196,8 +196,8 @@ exports[`Meter default 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -239,8 +239,8 @@ exports[`Meter many values 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -338,8 +338,8 @@ exports[`Meter round 1`] = `
 }
 
 .c2 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c1 {
@@ -349,8 +349,8 @@ exports[`Meter round 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -436,8 +436,8 @@ exports[`Meter size 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -718,8 +718,8 @@ exports[`Meter thickness 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
@@ -1051,8 +1051,8 @@ exports[`Meter type 1`] = `
 }
 
 .c1 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 <div
diff --git a/src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap b/src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap
index c422afc4e1..db5f7a0209 100644
--- a/src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap
+++ b/src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap
@@ -240,8 +240,8 @@ exports[`Video autoPlay renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {
@@ -824,8 +824,8 @@ exports[`Video controls renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {
@@ -1490,8 +1490,8 @@ exports[`Video fit renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {
@@ -2156,8 +2156,8 @@ exports[`Video loop renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {
@@ -2656,8 +2656,8 @@ exports[`Video mute renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {
@@ -3156,8 +3156,8 @@ exports[`Video renders 1`] = `
 }
 
 .c11 path {
-  -webkit-transition: all 0.3s;
-  transition: all 0.3s;
+  -webkit-transition: stroke 0.3s,stroke-width 0.3s;
+  transition: stroke 0.3s,stroke-width 0.3s;
 }
 
 .c2 {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test
: '>>>>> End Test Output'
git checkout bcde5d660f50359d8e46e33dcfe3bbc8968471ef src/js/components/Meter/__tests__/__snapshots__/Meter-test.js.snap src/js/components/Video/__tests__/__snapshots__/Video-test.js.snap
