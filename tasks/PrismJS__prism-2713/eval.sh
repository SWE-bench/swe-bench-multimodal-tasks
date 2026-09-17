#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 4e7b2a82d733fc705bc4a50192fb1bbe552bc687
git checkout 4e7b2a82d733fc705bc4a50192fb1bbe552bc687 tests/languages/javascript/keyword_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/javascript/keyword_feature.test b/tests/languages/javascript/keyword_feature.test
index c5ae92ad74..431af5baf6 100644
--- a/tests/languages/javascript/keyword_feature.test
+++ b/tests/languages/javascript/keyword_feature.test
@@ -1,27 +1,67 @@
-catch finally;
-async function;
-
-as; await; break; case;
-class; const; continue; debugger;
-default; delete; do; else; enum;
-export; extends; for;
-from; if; implements;
-import; in; instanceof; interface; let;
-new; null; of; package; private;
-protected; public; return; static;
-super; switch; this; throw; try;
-typeof; undefined; var; void; while;
-with; yield;
+as;
+await;
+break;
+case;
+class;
+const;
+continue;
+debugger;
+default;
+delete;
+do;
+else;
+enum;
+export;
+extends;
+for;
+if;
+implements;
+import;
+in;
+instanceof;
+interface;
+let;
+new;
+null;
+of;
+package;
+private;
+protected;
+public;
+return;
+static;
+super;
+switch;
+this;
+throw;
+try;
+typeof;
+undefined;
+var;
+void;
+while;
+with;
+yield;
 
-----------------------------------------------------
+// contextual keywords
 
-[
-	["keyword", "catch"],
-	["keyword", "finally"], ["punctuation", ";"],
+try {} catch {} finally {}
+try {} catch (e) {} finally {}
+async function (){}
+async a => {}
+async (a,b,c) => {}
+import {} from "foo"
+import {} from 'foo'
+class { get foo(){} set baz(){} get [value](){} }
 
-	["keyword", "async"],
-	["keyword", "function"], ["punctuation", ";"],
+// variables, not keywords
+
+const { async, from, to } = bar;
+promise.catch(foo).finally(bar);
+
+----------------------------------------------------
 
+[
 	["keyword", "as"], ["punctuation", ";"],
 	["keyword", "await"], ["punctuation", ";"],
 	["keyword", "break"], ["punctuation", ";"],
@@ -38,7 +78,6 @@ with; yield;
 	["keyword", "export"], ["punctuation", ";"],
 	["keyword", "extends"], ["punctuation", ";"],
 	["keyword", "for"], ["punctuation", ";"],
-	["keyword", "from"], ["punctuation", ";"],
 	["keyword", "if"], ["punctuation", ";"],
 	["keyword", "implements"], ["punctuation", ";"],
 	["keyword", "import"], ["punctuation", ";"],
@@ -66,7 +105,122 @@ with; yield;
 	["keyword", "void"], ["punctuation", ";"],
 	["keyword", "while"], ["punctuation", ";"],
 	["keyword", "with"], ["punctuation", ";"],
-	["keyword", "yield"], ["punctuation", ";"]
+	["keyword", "yield"], ["punctuation", ";"],
+
+	["comment", "// contextual keywords"],
+
+	["keyword", "try"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "catch"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "finally"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+
+	["keyword", "try"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "catch"],
+	["punctuation", "("],
+	"e",
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "finally"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+
+	["keyword", "async"],
+	["keyword", "function"],
+	["punctuation", "("],
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+
+	["keyword", "async"],
+	["parameter", ["a"]],
+	["operator", "=>"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+
+	["keyword", "async"],
+	["punctuation", "("],
+	["parameter", [
+		"a",
+		["punctuation", ","],
+		"b",
+		["punctuation", ","],
+		"c"
+	]],
+	["punctuation", ")"],
+	["operator", "=>"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+
+	["keyword", "import"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "from"],
+	["string", "\"foo\""],
+
+	["keyword", "import"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "from"],
+	["string", "'foo'"],
+
+	["keyword", "class"],
+	["punctuation", "{"],
+	["keyword", "get"],
+	["function", "foo"],
+	["punctuation", "("],
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "set"],
+	["function", "baz"],
+	["punctuation", "("],
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["keyword", "get"],
+	["punctuation", "["],
+	"value",
+	["punctuation", "]"],
+	["punctuation", "("],
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"],
+	["punctuation", "}"],
+
+	["comment", "// variables, not keywords"],
+
+	["keyword", "const"],
+	["punctuation", "{"],
+	" async",
+	["punctuation", ","],
+	" from",
+	["punctuation", ","],
+	" to ",
+	["punctuation", "}"],
+	["operator", "="],
+	" bar",
+	["punctuation", ";"],
+
+	"\r\npromise",
+	["punctuation", "."],
+	["function", "catch"],
+	["punctuation", "("],
+	"foo",
+	["punctuation", ")"],
+	["punctuation", "."],
+	["function", "finally"],
+	["punctuation", "("],
+	"bar",
+	["punctuation", ")"],
+	["punctuation", ";"]
 ]
 
 ----------------------------------------------------

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language javascript
: '>>>>> End Test Output'
git checkout 4e7b2a82d733fc705bc4a50192fb1bbe552bc687 tests/languages/javascript/keyword_feature.test
