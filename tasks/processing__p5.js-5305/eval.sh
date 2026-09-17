#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff efd946e7fcaf5d1f05e40209781520ec7cfad98a
git checkout efd946e7fcaf5d1f05e40209781520ec7cfad98a test/unit/core/error_helpers.js
git apply -v - <<'EOF_114329324912'
diff --git a/test/unit/core/error_helpers.js b/test/unit/core/error_helpers.js
index 47e6a29d0e..139b40dd85 100644
--- a/test/unit/core/error_helpers.js
+++ b/test/unit/core/error_helpers.js
@@ -532,204 +532,288 @@ suite('Global Error Handling', function() {
     p5._fesLogger = null;
   });
 
+  const prepSyntaxTest = (arr, resolve) => {
+    iframe = createP5Iframe(
+      [P5_SCRIPT_TAG, WAIT_AND_RESOLVE, '<script>', ...arr, '</script>'].join(
+        '\n'
+      )
+    );
+    log = [];
+    iframe.elt.contentWindow.logger = logger;
+    iframe.elt.contentWindow.afterSetup = resolve;
+    return iframe;
+  };
+
+  testUnMinified('identifies errors happenning internally', function() {
+    return new Promise(function(resolve) {
+      // quite an unusual way to test, but the error listener doesn't work
+      // under mocha. Also the stacktrace gets filled with mocha internal
+      // function calls. Using this method solves both of these problems.
+      // This method also allows us to test for SyntaxError without messing
+      // with flow of the other tests
+      prepSyntaxTest(
+        [
+          'function setup() {',
+          'let cnv = createCanvas(400, 400);',
+          'cnv.mouseClicked();', // Error in p5 library as no callback passed
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /inside the p5js library/);
+      assert.match(log[0], /mouseClicked/);
+    });
+  });
+
+  testUnMinified('identifies errors in preload', function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function preload() {',
+          'circle(5, 5, 2);', // error
+          '}',
+          'function setup() {',
+          'createCanvas(10, 10);',
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /"circle" being called from preload/);
+    });
+  });
+
+  testUnMinified("identifies TypeError 'notDefined'", function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function setup() {',
+          'let x = asdfg + 5;', // ReferenceError: asdfg is not defined
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /asdfg/);
+      assert.match(log[0], /not defined in the current scope/);
+    });
+  });
+
   testUnMinified(
-    'correctly identifies errors happenning internally',
+    "identifies SyntaxError 'Invalid or unexpected Token'",
     function() {
       return new Promise(function(resolve) {
-        // quite an unusual way to test, but the error listerner doesn't work
-        // under mocha. Also the stacktrace gets filled with mocha internal
-        // function calls. Using this method solves both of these problems.
-        // This method also allows us to test for SyntaxError without messing
-        // with flow of the other tests
-        iframe = createP5Iframe(
+        prepSyntaxTest(
           [
-            P5_SCRIPT_TAG,
-            WAIT_AND_RESOLVE,
-            '<script>',
             'function setup() {',
-            'let cnv = createCanvas(400, 400);',
-            'cnv.mouseClicked();', // Error in p5 library as no callback passed
-            '}',
-            '</script>'
-          ].join('\n')
+            'let x = “not a string”', // SyntaxError: Invalid or unexpected token
+            '}'
+          ],
+          resolve
         );
-        log = [];
-        iframe.elt.contentWindow.logger = logger;
-        iframe.elt.contentWindow.afterSetup = resolve;
       }).then(function() {
         assert.strictEqual(log.length, 1);
-        assert.match(log[0], /inside the p5js library/);
-        assert.match(log[0], /mouseClicked/);
+        assert.match(log[0], /Syntax Error/);
+        assert.match(log[0], /JavaScript doesn't recognize/);
       });
     }
   );
 
-  testUnMinified('correctly identifies errors in preload', function() {
+  testUnMinified("identifies SyntaxError 'unexpectedToken'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
-          'function preload() {',
-          'circle(5, 5, 2);', // error
-          '}',
           'function setup() {',
-          'createCanvas(10, 10);',
-          '}',
-          '</script>'
-        ].join('\n')
+          'for (let i = 0; i < 5,; ++i) {}', // SyntaxError: Unexpected token
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /"circle" being called from preload/);
+      assert.match(log[0], /Syntax Error/);
+      assert.match(log[0], /typo/);
     });
   });
 
-  testUnMinified('correctly identifies errors in user code I', function() {
+  testUnMinified("identifies TypeError 'notFunc'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function setup() {',
-          'let x = asdfg + 5;', // ReferenceError: asdfg is not defined
-          '}',
-          '</script>'
-        ].join('\n')
+          'let asdfg = 5',
+          'asdfg()', // TypeError: asdfg is not a function
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /asdfg/);
-      assert.match(log[0], /not being defined in the current scope/);
+      assert.match(log[0], /"asdfg" could not be called as a function/);
     });
   });
 
-  testUnMinified('correctly identifies errors in user code II', function() {
+  testUnMinified("identifies TypeError 'notFuncObj'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function setup() {',
-          'let x = “not a string”', // SyntaxError: Invalid or unexpected token
-          '}',
-          '</script>'
-        ].join('\n')
+          'let asdfg = {}',
+          'asdfg.abcd()', // TypeError: abcd is not a function
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /syntax error/);
-      assert.match(log[0], /JavaScript doesn't recognize/);
+      assert.match(log[0], /"abcd" could not be called as a function/);
+      assert.match(log[0], /"asdfg" has "abcd" in it/);
     });
   });
 
-  testUnMinified('correctly identifies errors in user code III', function() {
+  testUnMinified("identifies ReferenceError 'cannotAccess'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function setup() {',
-          'for (let i = 0; i < 5,; ++i) {}', // SyntaxError: Unexpected token
-          '}',
-          '</script>'
-        ].join('\n')
+          'console.log(x)', // ReferenceError: Cannot access 'x' before initialization
+          'let x = 100',
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /syntax error/);
-      assert.match(log[0], /typo/);
+      assert.match(log[0], /Error/);
+      assert.match(log[0], /used before declaration/);
+    });
+  });
+
+  testUnMinified("identifies SyntaxError 'badReturnOrYield'", function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        ['function setup() {', 'let x = 100;', '}', 'return;'],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /Syntax Error/);
+      assert.match(log[0], /lies outside of a function/);
     });
   });
 
-  testUnMinified('correctly identifies errors in user code IV', function() {
+  testUnMinified("identifies SyntaxError 'missingInitializer'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function setup() {',
-          'let asdfg = 5',
-          'asdfg()', // TypeError: asdfg is not a function
-          '}',
-          '</script>'
-        ].join('\n')
+          'const x;', //SyntaxError: Missing initializer in const declaration
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /"asdfg" could not be called as a function/);
+      assert.match(log[0], /Syntax Error/);
+      assert.match(log[0], /but not initialized/);
     });
   });
 
-  testUnMinified('correctly identifies errors in user code IV', function() {
+  testUnMinified("identifies SyntaxError 'redeclaredVariable'", function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function setup() {',
-          'let asdfg = {}',
-          'asdfg.abcd()', // TypeError: abcd is not a function
-          '}',
-          '</script>'
-        ].join('\n')
+          'let x=100;',
+          'let x=99;', //SyntaxError: Identifier 'x' has already been declared
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 1);
-      assert.match(log[0], /"abcd" could not be called as a function/);
-      assert.match(log[0], /"asdfg" has "abcd" in it/);
+      assert.match(log[0], /Syntax Error/);
+      assert.match(log[0], /JavaScript doesn't allow/);
+    });
+  });
+
+  testUnMinified("identifies TypeError 'constAssign'", function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function setup() {',
+          'const x = 100;',
+          'x = 10;', //TypeError: Assignment to constant variable
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /Error/);
+      assert.match(log[0], /const variable is being/);
+    });
+  });
+
+  testUnMinified("identifies TypeError 'readFromNull'", function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function setup() {',
+          'const x = null;',
+          'console.log(x.prop);', //TypeError: Cannot read property 'prop' of null
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /Error/);
+      assert.match(log[0], /property of null/);
+    });
+  });
+
+  testUnMinified("identifies TypeError 'readFromUndefined'", function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function setup() {',
+          'const x = undefined;',
+          'console.log(x.prop);', //TypeError: Cannot read property 'prop' of undefined
+          '}'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /Error/);
+      assert.match(log[0], /property of undefined/);
     });
   });
 
-  testUnMinified('correctly builds friendlyStack', function() {
+  testUnMinified('builds friendlyStack', function() {
     return new Promise(function(resolve) {
-      iframe = createP5Iframe(
+      prepSyntaxTest(
         [
-          P5_SCRIPT_TAG,
-          WAIT_AND_RESOLVE,
-          '<script>',
           'function myfun(){',
           'asdfg()', // ReferenceError
           '}',
           'function setup() {',
           'myfun()',
-          '}',
-          '</script>'
-        ].join('\n')
+          '}'
+        ],
+        resolve
       );
-      log = [];
-      iframe.elt.contentWindow.logger = logger;
-      iframe.elt.contentWindow.afterSetup = resolve;
     }).then(function() {
       assert.strictEqual(log.length, 2);
       let temp = log[1].split('\n');
       temp = temp.filter(e => e.trim().length > 0);
       assert.strictEqual(temp.length, 2);
-      assert.match(log[0], /"asdfg" not being defined/);
+      assert.match(log[0], /"asdfg" is not defined/);
       assert.match(temp[0], /Error at/);
       assert.match(temp[0], /myfun/);
       assert.match(temp[1], /Called from/);
@@ -737,92 +821,65 @@ suite('Global Error Handling', function() {
     });
   });
 
-  testUnMinified(
-    'correctly indentifies internal error - instance mode',
-    function() {
-      return new Promise(function(resolve) {
-        iframe = createP5Iframe(
-          [
-            P5_SCRIPT_TAG,
-            WAIT_AND_RESOLVE,
-            '<script>',
-            'function sketch(p) {',
-            '  p.setup = function() {',
-            '    p.stroke();', // error
-            '  }',
-            '}',
-            'new p5(sketch);',
-            '</script>'
-          ].join('\n')
-        );
-        log = [];
-        iframe.elt.contentWindow.logger = logger;
-        iframe.elt.contentWindow.afterSetup = resolve;
-      }).then(function() {
-        assert.strictEqual(log.length, 1);
-        assert.match(log[0], /stroke/);
-        assert.match(log[0], /inside the p5js library/);
-      });
-    }
-  );
+  testUnMinified('indentifies internal error - instance mode', function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function sketch(p) {',
+          '  p.setup = function() {',
+          '    p.stroke();', // error
+          '  }',
+          '}',
+          'new p5(sketch);'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /stroke/);
+      assert.match(log[0], /inside the p5js library/);
+    });
+  });
 
-  testUnMinified(
-    'correctly indentifies error in preload - instance mode',
-    function() {
-      return new Promise(function(resolve) {
-        iframe = createP5Iframe(
-          [
-            P5_SCRIPT_TAG,
-            WAIT_AND_RESOLVE,
-            '<script>',
-            'function sketch(p) {',
-            '  p.preload = function() {',
-            '    p.circle(2, 2, 2);', // error
-            '  }',
-            '  p.setup = function() {',
-            '    p.createCanvas(5, 5);',
-            '  }',
-            '}',
-            'new p5(sketch);',
-            '</script>'
-          ].join('\n')
-        );
-        log = [];
-        iframe.elt.contentWindow.logger = logger;
-        iframe.elt.contentWindow.afterSetup = resolve;
-      }).then(function() {
-        assert.strictEqual(log.length, 1);
-        assert.match(log[0], /"circle" being called from preload/);
-      });
-    }
-  );
+  testUnMinified('indentifies error in preload - instance mode', function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function sketch(p) {',
+          '  p.preload = function() {',
+          '    p.circle(2, 2, 2);', // error
+          '  }',
+          '  p.setup = function() {',
+          '    p.createCanvas(5, 5);',
+          '  }',
+          '}',
+          'new p5(sketch);'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /"circle" being called from preload/);
+    });
+  });
 
-  testUnMinified(
-    'correctly indentifies error in user code - instance mode',
-    function() {
-      return new Promise(function(resolve) {
-        iframe = createP5Iframe(
-          [
-            P5_SCRIPT_TAG,
-            WAIT_AND_RESOLVE,
-            '<script>',
-            'function sketch(p) {',
-            '  p.setup = function() {',
-            '    myfun();', // ReferenceError: myfun is not defined
-            '  }',
-            '}',
-            'new p5(sketch);',
-            '</script>'
-          ].join('\n')
-        );
-        log = [];
-        iframe.elt.contentWindow.logger = logger;
-        iframe.elt.contentWindow.afterSetup = resolve;
-      }).then(function() {
-        assert.strictEqual(log.length, 1);
-        assert.match(log[0], /myfun/);
-        assert.match(log[0], /not being defined in the current scope/);
-      });
-    }
-  );
+  testUnMinified('indentifies error in user code - instance mode', function() {
+    return new Promise(function(resolve) {
+      prepSyntaxTest(
+        [
+          'function sketch(p) {',
+          '  p.setup = function() {',
+          '    myfun();', // ReferenceError: myfun is not defined
+          '  }',
+          '}',
+          'new p5(sketch);'
+        ],
+        resolve
+      );
+    }).then(function() {
+      assert.strictEqual(log.length, 1);
+      assert.match(log[0], /myfun/);
+      assert.match(log[0], /is not defined in the current scope/);
+    });
+  });
 });

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js
./node_modules/.bin/grunt yui --quiet || true
stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force
: '>>>>> End Test Output'
git checkout efd946e7fcaf5d1f05e40209781520ec7cfad98a test/unit/core/error_helpers.js
