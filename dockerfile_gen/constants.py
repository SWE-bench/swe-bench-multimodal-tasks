"""
Constants for the multimodal (JavaScript) dockerfile generator.
Includes inlined data specs from swebench/data_specs/javascript.py.
"""

CONTAINER_WORKDIR = "/testbed"

REPO_BASE_COMMIT_BRANCH: dict[str, dict[str, str]] = {}

# The Chrome the 2026-08-14 images were built and verified against.
PINNED_CHROME_VERSION = "151.0.7922.137"

START_TEST_OUTPUT = ">>>>> Start Test Output"
END_TEST_OUTPUT = ">>>>> End Test Output"

FAIL_ONLY_REPOS = {
    "chartjs/Chart.js",
    "processing/p5.js",
    "markedjs/marked",
}

MAP_REPO_TO_PARSER_NAME = {
    "Automattic/wp-calypso": "parse_log_calypso",
    "chartjs/Chart.js": "parse_log_chart_js",
    "markedjs/marked": "parse_log_marked",
    "processing/p5.js": "parse_log_p5js",
    "diegomura/react-pdf": "parse_log_react_pdf",
    "babel/babel": "parse_log_jest",
    "vuejs/core": "parse_log_vitest",
    "facebook/docusaurus": "parse_log_jest",
    "immutable-js/immutable-js": "parse_log_immutable_js",
    "mrdoob/three.js": "parse_log_tap",
    "preactjs/preact": "parse_log_karma",
    "axios/axios": "parse_log_tap",
}

# --- Inlined from swebench/data_specs/javascript.py ---

TEST_XVFB_PREFIX = 'xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99"'
XVFB_DEPS = [
    "python3",
    "python3-pip",
    "xvfb",
    "x11-xkb-utils",
    "xfonts-100dpi",
    "xfonts-75dpi",
    "xfonts-scalable",
    "xfonts-cyrillic",
    "x11-apps",
    "firefox",
]
X11_DEPS = [
    "libx11-xcb1",
    "libxcomposite1",
    "libxcursor1",
    "libxdamage1",
    "libxi6",
    "libxtst6",
    "libnss3",
    "libcups2",
    "libxss1",
    "libxrandr2",
    "libasound2",
    "libatk1.0-0",
    "libgtk-3-0",
    "x11-utils",
]

# Chrome 146 has breaking changes for older tests (floating-point precision,
# disconnect timeouts, MessagePort errors, rendering differences).
# Use Chromium snapshots for era-appropriate versions.
# Snapshots are at: https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/{rev}/chrome-linux.zip
# Wrap the binary in a shell script that adds --no-sandbox (needed in Docker).
def _chromium_snapshot_install(revision: str) -> list[str]:
    """Install a specific Chromium snapshot revision, replacing system Chrome."""
    return [
        # libxtst6 is needed by old Chromium but not pulled by the APT Chrome package
        "apt-get update && apt-get install -y libxtst6 && rm -rf /var/lib/apt/lists/*",
        f"wget -q https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/{revision}/chrome-linux.zip",
        "unzip -q chrome-linux.zip -d /opt/",
        "rm chrome-linux.zip",
        # Replace symlinks with a wrapper script that adds --no-sandbox
        # (Chromium snapshots don't include the SUID sandbox helper)
        "rm -f /usr/bin/google-chrome /usr/bin/google-chrome-stable",
        'printf \'#!/bin/bash\\nexec /opt/chrome-linux/chrome --no-sandbox "$@"\\n\' > /usr/bin/google-chrome',
        "chmod +x /usr/bin/google-chrome",
        "cp /usr/bin/google-chrome /usr/bin/google-chrome-stable",
    ]


def _chrome_for_testing_install(version: str) -> list[str]:
    """Install an exact Chrome for Testing build, replacing system Chrome."""
    return [
        (
            "wget -q https://storage.googleapis.com/chrome-for-testing-public/"
            f"{version}/linux64/chrome-linux64.zip"
        ),
        "unzip -q chrome-linux64.zip -d /opt/",
        "rm chrome-linux64.zip",
        "rm -f /usr/bin/google-chrome /usr/bin/google-chrome-stable",
        'printf \'#!/bin/bash\\nexec /opt/chrome-linux64/chrome --no-sandbox "$@"\\n\' > /usr/bin/google-chrome',
        "chmod +x /usr/bin/google-chrome",
        "cp /usr/bin/google-chrome /usr/bin/google-chrome-stable",
    ]


# Revision → approximate Chrome version mapping:
#   599821 → Chrome ~72 (Oct 2018) — for v1.11-v1.15
#   793478 → Chrome ~85 (Aug 2020) — for v1.21
# Chrome for Testing 120 — for v1.27 and openlayers v7.4
_CHROMIUM_72_INSTALL = _chromium_snapshot_install("599821")
_CHROMIUM_85_INSTALL = _chromium_snapshot_install("793478")
_CHROME_120_INSTALL = _chrome_for_testing_install("120.0.6099.109")

# npm removed the unscoped color-studio, so commits pinning 1.0.5 can no longer install.
# The git tag still exists and later calypso commits install it this way themselves.
_CALYPSO_COLOR_STUDIO = (
    "sed -i 's|\"color-studio\": \"1.0.5\"|"
    '"color-studio": "github:Automattic/color-studio#1.0.5"|\' package.json'
)

SPECS_CALYPSO = {
    **{
        k: {
            "apt-pkgs": ["libsass-dev", "sassc"],
            "install": [
                _CALYPSO_COLOR_STUDIO,
                "npm install --unsafe-perm",
                "git checkout -- package.json || true",
            ],
            "test_cmd": "npm run test-client",
            "docker_specs": {
                "node_version": k,
            },
        }
        for k in [
            "0.8",
            "4.2.3",
            "4.3.0",
            "5.10.1",
            "5.11.1",
            "6.1.0",
            "6.7.0",
            "6.9.0",
            "6.9.1",
            "6.9.4",
            "6.10.0",
            "6.10.2",
            "6.10.3",
            "6.11.1",
            "6.11.2",
            "6.11.5",
            "8.9.1",
            "8.9.3",
            "8.9.4",
            "8.11.0",
            "8.11.2",
            "10.4.1",
            "10.5.0",
            "10.6.0",
            "10.9.0",
            "10.10.0",
            "10.12.0",
            "10.13.0",
            "10.14.0",
            "10.15.2",
            "10.16.3",
        ]
    }
}

TEST_CHART_JS_TEMPLATE = "./node_modules/.bin/cross-env NODE_ENV=test ./node_modules/.bin/karma start {} --single-run --coverage --grep --auto-watch false"
# karma drops the browser after 30s of silence, which a slow fixture render under
# the pinned Chrome can exceed -- that kills the whole run, not just the one test
def _karma_no_activity(conf: str) -> str:
    return (
        """sed -i '0,/\\.set({/s//.set({\\n    browserNoActivityTimeout: 300000,/' """
        + conf
    )
SPECS_CHART_JS = {
    **{
        k: {
            "install": [
                "pnpm install",
                "pnpm run build",
            ],
            "test_cmd": [
                "pnpm install",
                "pnpm run build",
                _karma_no_activity("./karma.conf.cjs"),
                f'{TEST_XVFB_PREFIX} su chromeuser -c "{TEST_CHART_JS_TEMPLATE.format("./karma.conf.cjs")}"',
            ],
            "docker_specs": {
                "node_version": "21.6.2",
                "pnpm_version": "7.9.0",
                "run_args": {
                    "cap_add": ["SYS_ADMIN"],
                },
            },
        }
        for k in ["4.0", "4.1", "4.2", "4.3", "4.4"]
    },
    **{
        k: {
            "install": ["npm install"],
            "test_cmd": [
                "npm install",
                "npm run build",
                _karma_no_activity("./karma.conf.js"),
                f'{TEST_XVFB_PREFIX} su chromeuser -c "{TEST_CHART_JS_TEMPLATE.format("./karma.conf.js")}"',
            ],
            "docker_specs": {
                "node_version": "21.6.2",
                "run_args": {
                    "cap_add": ["SYS_ADMIN"],
                },
            },
        }
        for k in ["3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8"]
    },
    **{
        k: {
            "install": ["npm install", "npm install -g gulp-cli"],
            "test_cmd": [
                "npm install",
                "gulp build",
                TEST_XVFB_PREFIX + ' su chromeuser -c "gulp test"',
            ],
            "docker_specs": {
                "node_version": "21.6.2",
                "run_args": {
                    "cap_add": ["SYS_ADMIN"],
                },
            },
        }
        for k in ["2.0", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9"]
    },
}
for v in SPECS_CHART_JS.keys():
    SPECS_CHART_JS[v]["apt-pkgs"] = XVFB_DEPS

SPECS_MARKED = {
    **{
        k: {
            "install": ["npm install"],
            "test_cmd": "./node_modules/.bin/jasmine --no-color --config=jasmine.json",
            "docker_specs": {
                "node_version": "12.22.12",
            },
        }
        for k in [
            "0.3",
            "0.5",
            "0.6",
            "0.7",
            "1.0",
            "1.1",
            "1.2",
            "2.0",
            "3.9",
            "4.0",
            "4.1",
            "5.0",
        ]
    }
}
for v in ["4.0", "4.1", "5.0"]:
    SPECS_MARKED[v]["docker_specs"]["node_version"] = "20.16.0"

SPECS_P5_JS = {
    **{
        k: {
            "apt-pkgs": X11_DEPS,
            "install": [
                "npm install",
                # both names must be cleared: puppeteer 18 reads PUPPETEER_SKIP_DOWNLOAD,
                # and leaving it set skips the download, so mochaChrome later hangs
                # looking for a browser until the eval hits its timeout
                "PUPPETEER_SKIP_CHROMIUM_DOWNLOAD='' PUPPETEER_SKIP_DOWNLOAD='' "
                "node node_modules/puppeteer/install.js",
                "./node_modules/.bin/grunt yui",
            ],
            "test_cmd": (
                """sed -i 's/concurrency:[[:space:]]*[0-9][0-9]*/concurrency: 1/g' Gruntfile.js\n"""
                # docs/parameterData.json is written by the yuidoc preprocessor, and a
                # patch can change that preprocessor -- so the docs step has to run after
                # the patch, not just at build time, or the build requires a file that
                # was never generated
                "./node_modules/.bin/grunt yui --quiet || true\n"
                "stdbuf -o 1M ./node_modules/.bin/grunt test --quiet --force"
            ),
            "docker_specs": {
                "node_version": "14.17.3",
            },
        }
        for k in [
            "0.10",
            "0.2",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0",
            "1.1",
            "1.2",
            "1.3",
            "1.4",
            "1.5",
            "1.6",
            "1.7",
            "1.8",
            "1.9",
        ]
    },
}
for k in ["0.4", "0.5", "0.6"]:
    SPECS_P5_JS[k]["install"] = [
        "npm install",
        "./node_modules/.bin/grunt yui",
    ]

SPECS_REACT_PDF = {
    **{
        k: {
            "apt-pkgs": [
                "pkg-config",
                "build-essential",
                "libpixman-1-0",
                "libpixman-1-dev",
                "libcairo2-dev",
                "libpango1.0-dev",
                "libjpeg-dev",
                "libgif-dev",
                "librsvg2-dev",
            ]
            + X11_DEPS,
            "install": ["npm i -g yarn", "yarn install"],
            "test_cmd": 'NODE_OPTIONS="--experimental-vm-modules" ./node_modules/.bin/jest --no-color',
            "docker_specs": {"node_version": "18.20.4"},
        }
        for k in ["1.0", "1.1", "1.2", "2.0"]
    }
}
for v in ["1.0", "1.1", "1.2"]:
    SPECS_REACT_PDF[v]["docker_specs"]["node_version"] = "8.17.0"
    SPECS_REACT_PDF[v]["install"] = ["npm install", "npm install cheerio@1.0.0-rc.3"]
    SPECS_REACT_PDF[v]["test_cmd"] = "./node_modules/.bin/jest --no-color"


JEST_JSON_JQ_TRANSFORM = """jq -r '.testResults[].assertionResults[] | "[" + (.status | ascii_upcase) + "] " + ((.ancestorTitles | join(" > ")) + (if .ancestorTitles | length > 0 then " > " else "" end) + .title)'"""

SPECS_BABEL = {
    "14532": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest babel-generator --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "13928": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ['yarn jest babel-parser -t "arrow" --verbose'],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "15649": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest packages/babel-traverse/test/scope.js --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "15445": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'yarn jest packages/babel-generator/test/index.js -t "generation " --verbose'
        ],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "16130": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest babel-helpers --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
}

SPECS_VUEJS = {
    "11899": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/compiler-sfc/__tests__/compileStyle.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
        "build": ["pnpm run build compiler-sfc"],
    },
    "11870": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/runtime-core/__tests__/helpers/renderList.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
    },
    "11739": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'pnpm run test packages/runtime-core/__tests__/hydration.spec.ts --no-watch --reporter=verbose -t "mismatch handling"'
        ],
        "install": ["pnpm i"],
    },
    "11915": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'pnpm run test packages/compiler-core/__tests__/parse.spec.ts --no-watch --reporter=verbose -t "Element"'
        ],
        "install": ["pnpm i"],
    },
    "11589": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/runtime-core/__tests__/apiWatch.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
    },
}

SPECS_DOCUSAURUS = {
    "10309": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-plugin-content-docs/src/client/__tests__/docsClientUtils.test.ts --verbose"
        ],
    },
    "10130": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus/src/server/__tests__/brokenLinks.test.ts --verbose"
        ],
    },
    "9897": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts --verbose"
        ],
    },
    "9183": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-theme-classic/src/__tests__/options.test.ts --verbose"
        ],
    },
    "8927": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-utils/src/__tests__/markdownLinks.test.ts --verbose"
        ],
    },
}

SPECS_IMMUTABLEJS = {
    "2006": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "build": ["npm run build"],
        "test_cmd": ["npx jest __tests__/Range.ts --verbose"],
    },
    "2005": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "build": ["npm run build"],
        "test_cmd": [
            f"npx jest __tests__/OrderedMap.ts __tests__/OrderedSet.ts --silent --json | {JEST_JSON_JQ_TRANSFORM}"
        ],
    },
}

SPECS_THREEJS = {
    "27395": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install --ignore-scripts"],
        "test_cmd": ["npx qunit test/unit/src/math/Sphere.tests.js"],
    },
    "26589": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install --ignore-scripts"],
        "test_cmd": [
            "npx qunit test/unit/src/objects/Line.tests.js test/unit/src/objects/Mesh.tests.js test/unit/src/objects/Points.tests.js"
        ],
    },
    "25687": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install --ignore-scripts"],
        "test_cmd": [
            'npx qunit test/unit/src/core/Object3D.tests.js -f "/json|clone|copy/i"'
        ],
    },
}

SPECS_PREACT = {
    "4152": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/components.test.js"'
        ],
    },
    "4316": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/events.test.js"'
        ],
    },
    "4245": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useId.test.js"'
        ],
    },
    "4182": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/errorBoundary.test.js"'
        ],
    },
    "4436": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/refs.test.js"'
        ],
    },
    "3763": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/lifecycles/componentDidMount.test.js"'
        ],
    },
    "3739": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useState.test.js"',
        ],
    },
    "3689": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/errorBoundary.test.js"',
        ],
    },
    "3567": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useEffect.test.js"',
        ],
    },
    "3562": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="compat/test/browser/render.test.js"',
        ],
    },
    "3454": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/svg.test.js"',
        ],
    },
    "3345": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useEffect.test.js"',
        ],
    },
    "3062": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "3010": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "2927": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "2896": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="compat/test/browser/memo.test.js"',
        ],
    },
    "2757": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
}

SPECS_AXIOS = {
    "5892": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha test/unit/adapters/http.js -R tap -g 'compression'"],
    },
    "5316": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "build": ["npm install"],
        "test_cmd": ["npx mocha test/unit/adapters/http.js -R tap -g 'FormData'"],
    },
    "4738": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            "timeout 10s npx mocha -R tap test/unit/adapters/http.js -g 'timeout'"
        ],
    },
    "4731": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/adapters/http.js -g 'body length'"],
    },
    "6539": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/regression/SNYK-JS-AXIOS-7361793.js"],
    },
    "5085": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/regression/bugs.js"],
    },
}



# ============================================================
# Test split repos (from SWE-bench/private constants)
# ============================================================

SET_OPENSSL_TO_LEGACY = "NODE_OPTIONS=--openssl-legacy-provider"
SET_PUPPETEER_ENV_VAR = "PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable"
SET_PUPPETEER_PATH = "sed -i \"s|process.env.CHROME_BIN = require('puppeteer').executablePath();|process.env.CHROME_BIN = '/usr/bin/google-chrome-stable';|\" {}"
INSTALL_JULIA = [
    "wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz",
    "tar zxvf julia-1.9.3-linux-x86_64.tar.gz",
    "mv julia-1.9.3/ /opt/",
    "ln -s /opt/julia-1.9.3/bin/julia /usr/local/bin/julia",
]

SPECS_HIGHLIGHTJS = {k: {
    "install": [
        "npm install",
        "npm run build"
    ],
    "test_cmd": [
        "npm run build",
        "npm run test",
    ],
    "docker_specs": {
        "node_version": "21.6.2"
    }
} for k in [
    '10.0', '10.2', '10.3', '10.4', '10.5', '10.6', '11.0', '11.2', '11.3',
    '11.4', '11.5', '11.6', '8.4', '8.9', '9.13', '9.15', '9.16', '9.17', '9.18',
    None
]}

SPECS_MAPBOX = {k: {
    "apt-pkgs": ["libglew-dev", "libxi-dev"],
    "install": ["npm install"],
    "test_cmd": "npm test",
    "docker_specs": {
        "node_version": "18.20.4"
    }
} for k in [
    '0.11', '0.12', '0.13', '0.14', '0.15', '0.18', '0.21', '0.22', '0.23',
    '0.25', '0.26', '0.28', '0.30', '0.31', '0.32', '0.33', '0.34', '0.36',
    '0.37', '0.38', '0.39', '0.40', '0.41', '0.42', '0.43', '0.44', '0.45',
    '0.46', '0.47', '0.49', '0.50', '0.51', '0.52', '0.53', '0.7', '0.8',
    '0.9', '1.6'
]}

SPECS_PLOTLYJS = {k: {
    "apt-pkgs": ["xvfb x11-xkb-utils",
                 "xfonts-100dpi", "xfonts-75dpi", "xfonts-scalable",
                 "xfonts-cyrillic x11-apps"],
    "install": [
        "su chromeuser -c 'npm install'",
        "su chromeuser -c 'npm run build'",
        "su chromeuser -c 'npm run pretest'",
    ],
    "test_cmd": (f'xvfb-run --server-args="-screen 0 1280x1024x24 -ac :99" '
                 'su chromeuser -c "./node_modules/.bin/karma start test/jasmine/karma.conf.js '
                 '--nowatch --verbose --capture-timeout 210000 --browser-disconnect-tolerance 3 '
                 '--browser-disconnect-timeout 210000 --browser-no-activity-timeout 210000"'),
    "docker_specs": {
        "node_version": "9.2.0",
        "run_args": {
            "cap_add": ["SYS_ADMIN"],
        },
    },
} for k in [
    "2.33", "2.32", "2.31", "2.30", "2.29", "2.28", "2.27", "2.26", "2.25",
    "2.24", "2.23", "2.22", "2.21", "2.20", "2.19", "2.18", "2.17", "2.16",
    "2.15", "2.14", "2.13", "2.12", "2.11", "2.10", "2.9", "2.8", "2.7",
    "2.6", "2.5", "2.4", "2.3", "2.2", "2.1", "2.0", "1.58", "1.57", "1.56",
    "1.55", "1.54", "1.53", "1.52", "1.51", "1.50", "1.49", "1.48", "1.47",
    "1.46", "1.45", "1.44", "1.43", "1.42", "1.41", "1.40", "1.39", "1.38",
    "1.37", "1.36", "1.35", "1.34", "1.33", "1.32", "1.31", "1.30", "1.29",
    "1.28", "1.27", "1.26", "1.25", "1.24", "1.23", "1.22", "1.21", "1.20",
    "1.19", "1.18", "1.17", "1.16", "1.15", "1.14", "1.13", "1.12", "1.11",
    "1.10", "1.9", "1.8", "1.7", "1.6", "1.5", "1.4", "1.3", "1.2", "1.1",
    "1.0",
]}
for k in [
    "2.33", "2.32", "2.31", "2.30", "2.29", "2.28", "2.27", "2.26", "2.25",
    "2.24", "2.23", "2.22", "2.21", "2.20", "2.19", "2.18", "2.17", "2.16",
    "2.15", "2.14", "2.13", "2.12", "2.11", "2.10", "2.9", "2.8", "2.7",
    "2.6", "2.5", "2.4", "2.3", "2.2", "2.1", "2.0"
]:
    SPECS_PLOTLYJS[k]["docker_specs"]["node_version"] = "16.20.2"

TEST_CMD_PRISM = "./node_modules/.bin/mocha tests/run.js --reporter json"
SPECS_PRISM = {
    **{k: {
        "install": ["npm ci", "npm run build"],
        "test_cmd": TEST_CMD_PRISM,
        "docker_specs": {
            "node_version": "12.22.12",
        }
    } for k in ['1.24', '1.25', '1.27', '1.28']},
    **{k: {
        "install": ["npm install", "npm run build"],
        "test_cmd": TEST_CMD_PRISM,
        "docker_specs": {
            "node_version": "10.24.1",
        }
    } for k in ['1.22', '1.23']},
    **{k: {
        "install": ["npm install"],
        "test_cmd": TEST_CMD_PRISM,
        "docker_specs": {
            "node_version": "8.17.0",
        }
    } for k in ['1.15', '1.16', '1.17', '1.19', '1.20']}
}
SPECS_PRISM['1.15']['docker_specs']['node_version'] = '4.9.1'
SPECS_PRISM['1.16']['docker_specs']['node_version'] = '21.6.2'
SPECS_PRISM['1.17']['docker_specs']['node_version'] = '21.6.2'

# Insomnia node versions:
# 1.0 = '10.15'
# 5.1 = '7.4.0'
# 5.2 = '7.4.0'
# 5.3 = '7.4.0'
# 5.11 = '8'
# 6.0 = '8'
# 6.2 = '10'
# 9.1 = '20.9.0'
# 9.3 = '20.9.0'
# 2020.1 = '10.15'
# 2020.2 = '10'
# 2020.4 = '12.18.3'
# 2020.5 = '12.18.3'
# 2021.1 = '12.18.3'
# 2021.2 = '12.18.3'
# 2021.4 = '12.18.3'
# 2021.5 = '12.18.3'
# 2021.6 = '12.18.3'
# 2022.4 = '16.13.2'
# 2022.7 = '16.17.0'
# 2023.1 = '16.17.0'
# 2023.2 = '16.17.0'
# 2023.5 = '18.15.0'
SPECS_INSOMNIA = {
    k: {
        "apt-pkgs": ["libfontconfig1-dev"],
        "install": ["npm install"],
        "test_cmd": "./node_modules/.bin/jest --json",
        # "test_cmd": PRINT_WORKSPACE_TESTS,
        "docker_specs": {},
    } for k in ['1.0', '5.1', '5.2', '5.3', '5.11', '6.0', '6.2', '9.1', '9.3',
                '2020.1', '2020.2', '2020.4', '2020.5', '2021.1', '2021.2',
                '2021.4', '2021.5', '2021.6', '2022.4', '2022.7', '2023.1',
                '2023.2', '2023.5']
}
for k in ['5.1', '5.2', '5.3']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '7.4.0'
for k in ['1.0', '2020.1']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '10.15.3'
for k in ['5.11', '6.0']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '8.17.0'
for k in ['6.2', '2020.2']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '10.24.1'  # '10.15.3'
for k in ['9.1', '9.3']:
    SPECS_INSOMNIA[k]["install"] = ["npm install"]
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '20.9.0'
    SPECS_INSOMNIA[k]['test_cmd'] = "npm run test -- --json"
for k in ['2020.4', '2020.5', '2021.1', '2021.2', '2021.4', '2021.5', '2021.6']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '12.18.3'
for k in ['2022.4']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '16.13.2'
for k in ['2022.7', '2023.1', '2023.2']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '16.17.0'
for k in ['2023.5']:
    SPECS_INSOMNIA[k]['docker_specs']['node_version'] = '18.15.0'


TEST_CMD_ESLINT = './node_modules/.bin/mocha --forbid-only --reporter min -t 10000 --no-colors "tests/{bin,conf,lib,tools}/**/*.js"'
SPECS_ESLINT = {
    **{k: {
        "install": ["npm install"],
        "test_cmd": TEST_CMD_ESLINT,
        "docker_specs": {
            "node_version": "10.24.1",
        }
    } for k in [
        '0.20', '0.24', '0.3', '0.5', '1.0', '1.1',
        '1.10', '1.5', '1.7', '1.9', '2.0', '2.10',
        '2.12', '2.13', '2.5', '3.1', '3.11',
        '3.16', '3.5', '4.1', '4.7', '4.9', '5.14',
        '6.6', '6.7', '7.18', '7.22', '8.1', '8.50'
    ]},
}
for v in ['0.20', '0.24', '0.3', '0.5', '1.0', '1.1', '1.10', '1.5',
    '1.7', '1.9', '2.0', '2.10', '2.12', '2.13', '2.5', '3.1', '3.11']:
    SPECS_ESLINT[v]["docker_specs"]["node_version"] = "4.9.1"
for v in ['8.1', '8.50']:
    SPECS_ESLINT[v]["docker_specs"]["node_version"] = "21.6.2"

TEST_CMD_BPMN_JS = "./node_modules/.bin/karma start test/config/karma.unit.js --no-colors"
SPECS_BPMN_JS = {
    **{k: {
        "install": ["npm install"],
        "test_cmd": [
            SET_PUPPETEER_PATH.format("test/config/karma.unit.js"),
            "sed -i \"/module.exports = function(karma) {/i \\\\\n"
            "var customLaunchers = { \\\\\n"
            "  ChromeNoSandbox: { \\\\\n"
            "    base: 'ChromeHeadless', \\\\\n"
            "    flags: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'] \\\\\n"
            "  } \\\\\n"
            "}; \\\\\n"
            "browsers = ['ChromeNoSandbox']; \\\\\n"
            "\" test/config/karma.unit.js",
            "sed -i \"/browsers,/a \\\\    customLaunchers,\" test/config/karma.unit.js",
            f'{SET_PUPPETEER_ENV_VAR} su chromeuser -c "{TEST_CMD_BPMN_JS}"',
        ],
        "docker_specs": {
            "node_version": "21.6.2",
        }
    } for k in [
        '0.27', '0.9', '2.3', '2.4', '2.5', '3.0', '3.3',
        '3.4', '4.0', '5.0', '5.1', '6.0', '6.3', '7.2', '7.3',
        '7.4', '8.3', '8.8', '8.9', '9.0', '9.1', '9.2', '9.3',
        '11.1', '11.3', '13.2', '14.0', '15.2'
    ]},
}
for v in ['6.0', '6.3', '7.2', '7.3', '7.4', '8.3', '8.8', '8.9', '9.0', '9.1', '9.2', '9.3']:
    SPECS_BPMN_JS[v]["docker_specs"]["node_version"] = "16.20.2"
# Set OpenSSL to legacy provider for certain versions
for v in ['3.0', '3.3', '3.4', '4.0', '5.0', '5.1']:
    SPECS_BPMN_JS[v]["test_cmd"][-1] = f'{SET_OPENSSL_TO_LEGACY} {SPECS_BPMN_JS[v]["test_cmd"][-1]}'

SPECS_OPENLAYERS = {
    **{k: {
        "apt-pkgs": XVFB_DEPS,
        "install": ["npm install"],
        "test_cmd": "npm run test",
        "docker_specs": {
            "node_version": "21.6.2",
            "run_args": {
                "cap_add": ["SYS_ADMIN"],
            }
        }
    } for k in [
        '3.0', '3.4', '3.5', '3.8', '3.10', '3.11', '3.12', '3.14', '3.16', '3.17', '3.18', '3.19', '3.20',
        '4.0', '4.3', '4.4', '4.5', '4.6',
        '5.1', '5.2', '5.3',
        '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.5.1', '6.6', '6.9', '6.10', '6.11', '6.12', '6.13', '6.14',
        '7.0', '7.1', '7.2', '7.3', '7.4', '7.5',
        '8.1', '9.0', '9.1'
    ]},
}
# Replace puppeteer executable path
# NOTE: 6.5.1 was an artificially introduced version for karma.config.[js -> cjs]
for v in [
    '6.5.1', '6.6', '6.9', '6.10', '6.11', '6.12', '6.13', '6.14',
    '7.0', '7.1', '7.2', '7.3', '7.5'
]:
    SPECS_OPENLAYERS[v]["install"].append(SET_PUPPETEER_PATH.format("test/browser/karma.config.cjs"))
for v in ['6.0', '6.1', '6.2', '6.3', '6.4', '6.5']:
    SPECS_OPENLAYERS[v]["install"].append(SET_PUPPETEER_PATH.format("test/karma.config.js"))
# OL v7.4: rendering tests use Puppeteer's bundled Chromium 115 (downloaded at eval time).
# No system Chrome override needed — Puppeteer.launch() uses its own browser.

SPECS_EMOTION = {
    **{k: {
        "install": [
            "npm i -g yarn",
            "yarn",
            "yarn build"
        ],
        "test_cmd": "yarn test",
        "docker_specs": {
            "node_version": "16.20.2"
        }
    } for k in ['10.0']},
    **{k: {
        "install": ["npm install"],
        "test_cmd": "npm test",
        "docker_specs": {
            "node_version": "8.17.0"
        }
    } for k in ['2.0', '5.1', '5.2', '7.0']}
}

SPECS_GROMMET = {
    **{k: {
        "install": [
            "npm i -g yarn",
            "yarn install"
        ],
        "test_cmd": [
            "yarn test",
        ],
        "docker_specs": {
            "node_version": "21.6.2"
        }
    } for k in [
        '1.7', '2.0', '2.3', '2.6', '2.7',
        '2.11', '2.13', '2.14', '2.15', '2.16', '2.17', '2.18', '2.19',
        '2.20', '2.21', '2.22', '2.25', '2.26', '2.27', '2.29',
        '2.31', '2.33', '2.34'
    ]}
}

SPECS_PIXIJS = {
    **{k: {
        "apt-pkgs": XVFB_DEPS + ["libfontconfig1-dev"],
        "install": [
            "sed -i \"s/'ts-jest': {/'ts-jest': { isolatedModules: true,/\" jest.config.js",
            "sed -i \"/coverageDirectory: '<rootDir>\/dist\/coverage',/d\" jest.config.js",
            "sed -i 's/testTimeout: 10000/testTimeout: 10000,/' jest.config.js",
            "sed -i 's/};/    maxConcurrency: 3,\\n};/' jest.config.js",
            "sed -i 's/};/    maxWorkers: \"50%\",\\n};/' jest.config.js",
            "npm install",
            "cat jest.config.js",
        ],
        "test_cmd": ["npx jest --silent --no-colors"],
        "docker_specs": {
            "node_version": "18.20.4"
        }
    } for k in [
        '4.1', '4.3', '4.5', '4.8', '5.0', '6.0',
        '7.1', '7.2', '7.3', '8.0', '8.1', '8.2'
    ]}
}

SPECS_NEXT = {
    **{k: {
        "apt-pkgs": XVFB_DEPS,
        "install": ["su chromeuser -c 'npm install'"],
        "test_cmd": "npm run test",
        "docker_specs": {
            "node_version": "14.11.0",
            "run_args": {
                "cap_add": ["SYS_ADMIN"],
            },
        }
    } for k in [
        '1.11', '1.14', '1.15', '1.16', '1.17', '1.18', '1.19',
        '1.20', '1.21', '1.22', '1.23', '1.24', '1.25', '1.26', '1.27'
    ]}
}
SPECS_NEXT['1.27']['docker_specs']['node_version'] = '21.6.2'
for v in ['1.22', '1.23', '1.24', '1.25', '1.26', '1.27']:
    SPECS_NEXT[v]['install'].insert(0, SET_PUPPETEER_PATH.format("scripts/test/karma.js"))
for v in [
    '1.11', '1.14', '1.15', '1.16', '1.17', '1.18',
    '1.19', '1.20', '1.21', '1.22', '1.23', '1.24', '1.25'
]:
    SPECS_NEXT[v]['install'].extend([
        "npm install babel-preset-es2015",
        "npm install cheerio@1.0.0-rc.3",
        'npm i sass@1.36.0 --save-exact',
        'npm show cheerio',
    ])
# Gold-only dependency changes are supplied through private evaluator caches. They must
# not be installed in these public solver images (see offline_dependencies.json).
# v1.22-1.24 (Node 14): pin puppeteer (v22+ requires Node 18) and highlight.js
# (latest uses \p{XID_Start} regex which requires Node 15+)
for v in ['1.22', '1.23', '1.24']:
    SPECS_NEXT[v]['install'].extend([
        "npm install puppeteer@19.11.1 --save-exact",
        "npm install highlight.js@10.7.3 --save-exact",
    ])
for v in ['1.11', '1.14', '1.15', '1.16', '1.17', '1.18', '1.19', '1.20']:
    SPECS_NEXT[v]['apt-pkgs'].extend(["libsass-dev", "sassc"])
    SPECS_NEXT[v]['docker_specs']['node_version'] = '8.17.0'
    # Pin React/enzyme to era-appropriate versions (Dec 2018).
    # Latest versions have behavior changes that break async state tests.
    SPECS_NEXT[v]['install'].extend([
        "npm install react@16.7.0 react-dom@16.7.0 enzyme@3.8.0 enzyme-adapter-react-16@1.7.1 --save-exact",
    ])
# Pin era-appropriate Chromium for versions with Chrome-sensitive tests
for v in ['1.11', '1.14', '1.15']:
    SPECS_NEXT[v]['install'] = _CHROMIUM_72_INSTALL + SPECS_NEXT[v]['install']
SPECS_NEXT['1.21']['install'] = _CHROMIUM_85_INSTALL + SPECS_NEXT['1.21']['install']
SPECS_NEXT['1.27']['install'] = _CHROME_120_INSTALL + SPECS_NEXT['1.27']['install']
# v1.27 uses Cypress for e2e tests — npm install only gets the Node wrapper,
# the actual Electron binary must be installed separately.
# Install to chromeuser's cache dir (tests run as chromeuser via su).
SPECS_NEXT['1.27']['install'].append(
    "CYPRESS_CACHE_FOLDER=/home/chromeuser/.cache/Cypress npx cypress install && "
    "chown -R chromeuser:chromeuser /home/chromeuser/.cache/Cypress"
)

# v1.21-1.26 pin puppeteer@19.11.1 above, and puppeteer-core reaches itself through the
# `./internal/*` exports subpath pattern, which node only resolves from 14.13.0. On
# 14.11.0 karma dies at require time with ERR_PACKAGE_PATH_NOT_EXPORTED before running a
# single test. 14.21.3 is the newest 14.x, so the runtime era is unchanged.
for v in ['1.21', '1.22', '1.23', '1.24', '1.25', '1.26']:
    SPECS_NEXT[v]['docker_specs']['node_version'] = '14.21.3'

SPECS_CYPRESS = {
    **{k: {
        "apt-pkgs": XVFB_DEPS,
        "install": ["npm i -g yarn", "yarn"],
        "test_cmd": "yarn test",
        "docker_specs": {
            "node_version": '16.20.2'
        }
    } for k in [
        '1.0', '1.1', '1.4',
        '10.0', '10.1', '10.10', '10.11', '10.2', '10.3', '10.5', '10.6', '10.7', '10.8', '10.9',
        '11.0', '11.1', '11.2',
        '12.0', '12.1', '12.2', '12.3', '12.4', '12.5', '12.6', '12.7', '12.8',
        '12.9', '12.10', '12.11', '12.12', '12.14', '12.17',
        '13.4', '13.6',
        '2.0', '2.1',
        '3.0', '3.1', '3.2', '3.3', '3.4', '3.5', '3.6', '3.7', '3.8',
        '4.0', '4.1', '4.10', '4.11', '4.12', '4.2', '4.3', '4.4', '4.5', '4.6', '4.7', '4.8', '4.9',
        '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6',
        '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.6', '6.7', '6.8',
        '7.1', '7.2', '7.4', '7.5', '7.7',
        '8.0', '8.1', '8.2', '8.3', '8.4', '8.6',
        '9.0', '9.1', '9.2', '9.3', '9.4', '9.5', '9.6', '9.7'
    ]}
}
for v in ['12.9', '12.10', '12.11', '12.12', '12.14', '12.17', '13.4', '13.6']:
    SPECS_CYPRESS[v]['docker_specs']['node_version'] = '21.6.2'

CARBON_ACHECKER_ARCHIVE = "07Oct2020"
CARBON_ACHECKER_ARCHIVE_PATH = "2020.10.07"
CARBON_ACHECKER_ENGINE_VERSION = "3.1.0"
CARBON_ACHECKER_OFFLINE_ROOT = "/opt/achecker-offline"
CARBON_ACHECKER_OFFLINE_PORT = 18080

SPECS_CARBON = {
    **{k: {
        "install": [
            "npm i -g yarn",
            "yarn install",
            "yarn build",
        ],
        "test_cmd": "yarn test",
        "docker_specs": {
            "node_version": {
                "20.14": "20.14.0", "20.12": "20.12.2", "20.11": "20.11.1", "20.9": "20.9.0",
                "18.17": "18.17.1", "18.16": "18.16.1", "18.15": "18.15.0", "18.14": "18.14.2",
                "16.19": "16.19.1", "16.18": "16.18.1", "16.17": "16.17.1", "16.16": "16.16.0",
                "16.15": "16.15.1", "16.14": "16.14.2", "16.13": "16.13.2",
                "14.17": "14.17.6", "14": "14.17.6", "12": "12.22.12", "10": "10.24.1",
                "7.2": "8.17.0"
            }[k]
        }
    } for k in [
        '7.2', '10', '12', '14', '14.17',
        '16.13', '16.14', '16.15', '16.16', '16.17', '16.18', '16.19',
        '18.14', '18.15', '18.16', '18.17', '20.9', '20.11', '20.12', '20.14'
    ]}
}
# Fix carbon P2P accessibility test failures:
# 1. nwsapi 2.2.0 doesn't support :scope>* selector — upgrade to 2.2.7
#    Use node to directly replace the module to avoid corrupting yarn 3 lockfiles.
# 2. accessibility-checker fetches "latest" rules from able.ibm.com which are
#    stricter than when tests were written — pin to a known-good archive
for v in SPECS_CARBON:
    SPECS_CARBON[v]['install'].append(
        "wget -q https://registry.npmjs.org/nwsapi/-/nwsapi-2.2.7.tgz && "
        "tar xzf nwsapi-2.2.7.tgz -C node_modules/nwsapi --strip-components=1 && "
        "rm nwsapi-2.2.7.tgz"
    )
# accessibility-checker normally fetches both archives.json and its ACE engine during
# every test run. Mirror the archive metadata and both Node/browser engine variants at
# image-build time. eval.sh serves this directory over loopback because checker releases
# 3.1.1 and 3.1.32 use different HTTP clients/configuration APIs, but both understand a
# custom HTTP rule server. The hashes make a CDN error page or changed artifact fail the
# image build instead of becoming a flaky evaluation.
for v in SPECS_CARBON:
    engine_dir = (
        f"{CARBON_ACHECKER_OFFLINE_ROOT}/archives/"
        f"{CARBON_ACHECKER_ARCHIVE_PATH}/js"
    )
    engine_url = (
        "https://cdn.jsdelivr.net/npm/accessibility-checker-engine@"
        f"{CARBON_ACHECKER_ENGINE_VERSION}"
    )
    SPECS_CARBON[v]["install"].extend([
        f"mkdir -p {engine_dir}",
        (
            "curl --retry 5 --retry-all-errors --connect-timeout 30 -fsSL "
            f"{engine_url}/ace-node.js -o {engine_dir}/ace-node.js"
        ),
        (
            "curl --retry 5 --retry-all-errors --connect-timeout 30 -fsSL "
            f"{engine_url}/ace.js -o {engine_dir}/ace.js"
        ),
        (
            "printf '%s\\n' "
            "'7d15e331ff61d00bb4688c4cc0ec1cda91d0e9d023c49a0ad66210d9d4cfad88  "
            f"{engine_dir}/ace-node.js' "
            "'49fd0b40371078288a3b0ba7efefba4db7c055e69a31d5657e0bd8bac50e1353  "
            f"{engine_dir}/ace.js' | sha256sum -c -"
        ),
        (
            "printf '%s\\n' "
            f"'[{{\"id\":\"{CARBON_ACHECKER_ARCHIVE}\","
            "\"name\":\"07 October 2020 Deployment (IBM 7.2)\","
            f"\"version\":\"{CARBON_ACHECKER_ENGINE_VERSION}\","
            f"\"path\":\"/archives/{CARBON_ACHECKER_ARCHIVE_PATH}\","
            "\"hidden\":true}]' "
            f"> {CARBON_ACHECKER_OFFLINE_ROOT}/archives.json"
        ),
        (
            "printf '%s\\n' "
            f"'ruleArchive: {CARBON_ACHECKER_ARCHIVE}' "
            "'customRuleServer: true' "
            f"'rulePack: http://127.0.0.1:{CARBON_ACHECKER_OFFLINE_PORT}/archives/"
            f"{CARBON_ACHECKER_ARCHIVE_PATH}/js' "
            f"'ruleServer: http://127.0.0.1:{CARBON_ACHECKER_OFFLINE_PORT}' "
            f"> {CARBON_ACHECKER_OFFLINE_ROOT}/.achecker.yml"
        ),
        (
            "for checker_dir in node_modules/accessibility-checker "
            "config/jest-config-carbon/node_modules/accessibility-checker; do "
            "if [ -d \"$checker_dir\" ]; then "
            "find \"$checker_dir\" -type f -name ACMetricsLogger.js -exec sed -i "
            f"'s#https://able.ibm.com/tools#http://127.0.0.1:"
            f"{CARBON_ACHECKER_OFFLINE_PORT}/tools#g' {{}} +; fi; done"
        ),
    ])

SPECS_SCRATCH = {
    **{k: {
        "install": ["npm install"],
        "test_cmd": "./node_modules/.bin/jest --runInBand --no-colors --forceExit --testPathIgnorePatterns='test/integration' --testPathIgnorePatterns='vm-manager-hoc'",
        "docker_specs": {
            "node_version": {
                "1": "20.16.0",
                "2": "20.16.0",
                "3": "12.22.12",
                "4": "12.22.12",
                "5": "20.16.0",
                "8": "20.16.0",
            }[k]
        }
    } for k in ['1', '2', '3', '4', '5', '8']}
}
for v in ['1', '2', '3', '4']:
    SPECS_SCRATCH[v]['install'].extend([
        "npm install cheerio@1.0.0-rc.3",
        "npm show cheerio"
    ])
# v8: AudioContext.resume() throws in web-audio-test-api mock because the default
# state is states[0] = "disabled". Swap array so "enabled" is default.
SPECS_SCRATCH['8']['install'].append(
    "sed -i 's/states: .\"disabled\", \"enabled\"./states: [\"enabled\", \"disabled\"]/' "
    "node_modules/web-audio-test-api/lib/utils/api.js"
)

SPECS_LIGHTHOUSE = {
    **{k: {
        "install": [
            "npm i -g yarn",
            "yarn",
            "yarn build-all"
        ],
        "test_cmd": "yarn mocha",
        "docker_specs": {
            "node_version": "16.20.2",
        }
    } for k in [
        '1.0', '1.1', '1.2', '1.4', '1.5', '1.6',
        '2.0', '2.1', '2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9',
        '3.0', '3.1', '3.2',
        '4.0', '4.1',
        '5.0', '5.1', '5.2', '5.6',
        '6.0', '6.1', '6.3', '6.4', '6.5',
        '7.0',
        '8.0', '8.2', '8.3', '8.6',
        '9.5',
        '10.0', '10.2'
    ]}
}
for v in ['2.0', '2.1', '2.3', '2.4', '2.5', '2.6', '2.7', '2.8', '2.9']:
    SPECS_LIGHTHOUSE[v]["install"] = [
        "npm i -g yarn",
        "yarn",
        "yarn install-all",
        "yarn build-all",
    ]
for v in ['1.0', '1.1', '1.2', '1.4', '1.5', '1.6']:
    SPECS_LIGHTHOUSE[v]["docker_specs"]["node_version"] = "8.17.0"
    SPECS_LIGHTHOUSE[v]["install"] = [
        "npm install",
        "npm run install-all",
    ]

SPECS_PRETTIER = {
    **{k: {
        "install": [
            "npm i -g yarn",
            "yarn",
        ],
        "test_cmd": "yarn test",
        "docker_specs": {
            "node_version": "20.16.0",
        }
    } for k in [
        '0.0', '0.11', '0.13', '0.15', '0.16', '0.20', '1.11',
        '1.4', '1.5', '1.6', '1.7', '1.8', '2.1', '2.3',
        '2.6', '2.9', '3.0', '3.3', '3.4'
    ]}
}
# Modern Yarn does not consume the standard Docker proxy variables. Bridge them
# only for the networked build command; the YARN_* values are not persisted in the
# resulting image. This matters on builders whose DNS permits external registries
# only through an authenticated forward proxy.
for v in ['3.0', '3.4']:
    SPECS_PRETTIER[v]["install"][-1] = (
        'if [ -n "${HTTP_PROXY:-}" ]; then export YARN_HTTP_PROXY="$HTTP_PROXY"; fi; '
        'if [ -n "${HTTPS_PROXY:-}" ]; then export YARN_HTTPS_PROXY="$HTTPS_PROXY"; fi; '
        "yarn"
    )
# The v2.2 gold patch adds meriyah. Do not preinstall that gold-only dependency in
# the solver-visible image: the evaluator supplies a private union cache after the
# agent submits, and eval.sh performs a strict offline install from that cache.
SPECS_PRETTIER['2.2'] = {
    "install": [
        "npm i -g yarn",
        "yarn",
    ],
    "test_cmd": "yarn test",
    "docker_specs": {
        "node_version": "20.16.0",
    }
}

PIP_INSTALLS_QUARTOCLI = [
    "pip3 install --user pipenv",
    "pip3 install nbformat",
    "pip3 install nbclient",
    "pip3 install pandocfilters",
    "pip3 install shiny",
    "pip3 install pyyaml",
    "pip3 install setuptools",
    "pip3 install numpy",
    "pip3 install seaborn",
    "pip3 install matplotlib",
    "pip3 install bokeh",
    "pip3 install bokeh_sampledata",
    "pip3 install ipyleaflet",
    "pip3 install pandas",
    "pip3 install itables",
    "pip3 install pexpect",
    "pip3 install ptyprocess",
    "pip3 install appnope",
    "pip3 install ipykernel",
]
# quarto renders PDFs with xelatex; TeX Live 2026 drift breaks it, so pin to a frozen 2024 tree
# ftp.math.utah.edu is unreachable, which silently broke every package install
TEXLIVE_2024_REPO = (
    "https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/2024/tlnet-final"
)
PIN_TINYTEX_2024 = [
    "rm -rf /root/.TinyTeX /opt/TinyTeX",
    "wget -qO /tmp/install-tinytex.sh https://tinytex.yihui.org/install-bin-unix.sh",
    "TINYTEX_VERSION=2024.12 sh /tmp/install-tinytex.sh",
    f'"$(echo /root/.TinyTeX/bin/*)"/tlmgr option repository {TEXLIVE_2024_REPO}',
    # babel-french unpacked directly: `tlmgr update --self` against the frozen repo breaks the tree
    f"curl -sSL {TEXLIVE_2024_REPO}/archive/babel-french.tar.xz -o /tmp/babel-french.tar.xz || true",
    "tar -xJf /tmp/babel-french.tar.xz -C /root/.TinyTeX/texmf-dist tex/generic/babel-french || true",
    '"$(echo /root/.TinyTeX/bin/*)"/mktexlsr || true',
    # the frozen 2024 repo is signed with an expired key, which tlmgr refuses by default
    "rm -f /usr/local/bin/tlmgr",
    'printf \'#!/bin/sh\\nexec "$(echo /root/.TinyTeX/bin/*)"/tlmgr --verify-repo=none "$@"\\n\''
    " > /usr/local/bin/tlmgr && chmod 755 /usr/local/bin/tlmgr",
    'tex_ver="$("$(echo /root/.TinyTeX/bin/*)"/xelatex --version)"; '
    'case "$tex_ver" in *"TeX Live 2024"*) echo "TinyTeX pinned to TL2024 OK";; '
    '*) echo "TinyTeX pin FAILED, got: $tex_ver"; exit 1;; esac',
]

# quarto before ~v1.3 resolves the TeX engine through PATH; later versions locate TinyTeX themselves.
# The installer points sys_bin at /root/bin, so `tlmgr path add` links nothing usable.
QUARTO_TEX_ON_PATH = [
    'for b in /root/.TinyTeX/bin/*/*; do ln -sf "$b" /usr/local/bin/; done',
    # the frozen 2024 repo is signed with an expired key; tlmgr aborts unless verification is off.
    # rm first: the loop above left a symlink, and writing through it would clobber the real tlmgr
    "rm -f /usr/local/bin/tlmgr",
    'printf \'#!/bin/sh\\nexec "$(echo /root/.TinyTeX/bin/*)"/tlmgr --verify-repo=none "$@"\\n\''
    " > /usr/local/bin/tlmgr && chmod 755 /usr/local/bin/tlmgr",
    'hash -r; tex_ver="$(xelatex --version)"; '
    'case "$tex_ver" in *"TeX Live 2024"*) echo "xelatex on PATH OK";; '
    '*) echo "xelatex not resolvable via PATH, got: $tex_ver"; exit 1;; esac',
]

# Per-instance steps keyed by instance_id so that regenerating cannot silently drop
# a fix. "install_post" runs after the repo's install commands at build time;
# "eval_pre" runs in eval.sh just before the test command.
ALIBABA_FUSION_INSTANCES = (94, 101, 114, 665, 717, 870, 877, 895, 966, 1063, 1064, 1067, 1500, 1509, 1586, 1708, 1720, 1742, 1788, 1807, 2131, 2164, 2355, 2860, 2919, 2923, 2984, 3034, 3198, 3218, 3345, 3445, 3454, 3724, 3947, 4021, 4182, 4806, 4859)

INSTANCE_OVERRIDES = {
    f"quarto-dev__quarto-cli-{n}": {"install_post": QUARTO_TEX_ON_PATH}
    for n in (896, 1029, 1373, 1650, 2583, 2689, 2756, 3853, 4025, 4064, 4184)
}

# alibaba-fusion defines a --no-sandbox launcher (ChromeTravis) but only selects it
# behind TRAVIS or CI depending on the version, and neither is set here, so karma falls
# back to plain Chrome and cannot start its sandbox. Point the default at the launcher
# instead; this avoids relaxing container seccomp, which breaks openlayers' WebGL tests.
_ALIBABA_USE_NOSANDBOX_LAUNCHER = [
    "sed -i \"s/browsers: \\['Chrome'\\]/browsers: ['ChromeTravis']/\" scripts/test/karma.js || true",
    # A single-component run has runAll false, so karma gets singleRun: false and
    # sits in watch mode forever after the tests pass, leaving the result dependent
    # on a timeout killing it. Force only the config field -- rewriting the derived
    # `singleRun` variable would also flip `autoWatch: !singleRun`, whose changed
    # teardown timing makes cascader-select fail on a null focusInput.
    "sed -i \"s/singleRun: singleRun,/singleRun: true,/\" scripts/test/karma.js || true",
]
# Chrome is installed unpinned from google-chrome-stable, so its version drifts upward on
# every rebuild. Chrome 151 breaks these two Heatmap/WebGL tests (getSupportedExtensions
# returns undefined); they passed under the older Chrome present in the previous build.
# Pin the same Chrome for Testing build already used for openlayers v7.4.
INSTANCE_OVERRIDES.update({
    f"openlayers__openlayers-{n}": {"install_pre": _CHROME_120_INSTALL}
    for n in (11545, 14932)
})

# OpenLayers' rendering harness launches the configured executable through its bundled
# Puppeteer. Chrome 151 closes the DevTools target before any case runs for these six
# versions. Use the exact browser revision declared by each installed Puppeteer release;
# these immutable archive URLs are also checked by the offline-grading unit tests.
_OPENLAYERS_PUPPETEER_BROWSERS = {
    14414: _chromium_snapshot_install("1069273"),
    14659: _chromium_snapshot_install("1108766"),
    15168: _chrome_for_testing_install("116.0.5845.96"),
    15234: _chrome_for_testing_install("117.0.5938.92"),
    15365: _chrome_for_testing_install("119.0.6045.105"),
    15825: _chrome_for_testing_install("124.0.6367.91"),
}
INSTANCE_OVERRIDES.update({
    f"openlayers__openlayers-{number}": {"install_pre": install}
    for number, install in _OPENLAYERS_PUPPETEER_BROWSERS.items()
})

# eslint 17618 builds native re2 from source; the bundled node-gyp 13 loads an undici
# calling webidl.util.markAsUncloneable, which node 21.6.2 lacks. Pin a node-gyp that
# supports this node.
# re2 has no prebuilt for node 21's ABI (linux-x64-120 is a 404), so it must build from
# source, and the hoisted node-gyp 13 crashes on node 21. re2 invokes its own local
# node-gyp, ignoring npm_config_node_gyp, so install deps without scripts first, swap in
# a node-gyp that supports this node, then run the native builds.
INSTANCE_OVERRIDES.update({
    "eslint__eslint-17618": {
        # re2 has no prebuilt for node 21's ABI and resolves its own node-gyp 13
        # internally (ignoring npm_config_node_gyp and the .bin shim), and node-gyp 13
        # needs an API added in node 22. Move this instance to node 22, which eslint of
        # this era supports, so the source build succeeds.
        "docker_specs": {"node_version": "22.11.0"},
        "install": ["npm install"]
    }
})

INSTANCE_OVERRIDES.update({
    f"alibaba-fusion__next-{n}": {"eval_pre": _ALIBABA_USE_NOSANDBOX_LAUNCHER}
    for n in ALIBABA_FUSION_INSTANCES
})

# test/unit/util/audio-context.test.js throws an unhandled rejection from
# web-audio-test-api, which Node 20 treats as fatal; that kills the jest process
# before the graded button.test.jsx reports. The offending file is not graded.
INSTANCE_OVERRIDES["scratchfoundation__scratch-gui-8492"] = {
    "eval_pre": ["export NODE_OPTIONS=--unhandled-rejections=warn"]
}

SPECS_QUARTOCLI = {
    None : {
        "apt-pkgs": ["libffi-dev", "zip", "unzip", "python3", "python3-pip", "python3.10-distutils", "r-base-core",
                     "poppler-utils", "libxml2-utils"],
        "install": INSTALL_JULIA + ["ls .",
                    "[ -f configure.sh ] || ./configure-linux.sh",
                    "[ -f configure-linux.sh ] || ./configure.sh",
                    "cd tests", "./configure-test-env.sh || true", "cd ..",
                    ] + PIN_TINYTEX_2024 + PIP_INSTALLS_QUARTOCLI,
        "test_cmd": [ # test generates files that add future test cases -- run tests fairly
            "cp -r tests/ tests_tmp/", 
            "cd tests", 
            "QUARTO_TESTS_NO_CONFIG=\"true\" ./run-tests.sh",
            "cd ..",
            "rm -rf tests/", 
            "mv tests_tmp/ tests/", 
        ],
        "docker_specs": {
            "run_args": {
                "cap_add": ["SYS_ADMIN"],
            }
        }
    } 
}

MAP_REPO_VERSION_TO_SPECS_JS = {
    # Dev split repos
    "Automattic/wp-calypso": SPECS_CALYPSO,
    "chartjs/Chart.js": SPECS_CHART_JS,
    "markedjs/marked": SPECS_MARKED,
    "processing/p5.js": SPECS_P5_JS,
    "diegomura/react-pdf": SPECS_REACT_PDF,
    # Multilingual JS repos
    "babel/babel": SPECS_BABEL,
    "vuejs/core": SPECS_VUEJS,
    "facebook/docusaurus": SPECS_DOCUSAURUS,
    "immutable-js/immutable-js": SPECS_IMMUTABLEJS,
    "mrdoob/three.js": SPECS_THREEJS,
    "preactjs/preact": SPECS_PREACT,
    "axios/axios": SPECS_AXIOS,
    # Test split repos (from SWE-bench/private)
    "alibaba-fusion/next": SPECS_NEXT,
    "bpmn-io/bpmn-js": SPECS_BPMN_JS,
    "carbon-design-system/carbon": SPECS_CARBON,
    "eslint/eslint": SPECS_ESLINT,
    "GoogleChrome/lighthouse": SPECS_LIGHTHOUSE,
    "grommet/grommet": SPECS_GROMMET,
    "highlightjs/highlight.js": SPECS_HIGHLIGHTJS,
    "openlayers/openlayers": SPECS_OPENLAYERS,
    "prettier/prettier": SPECS_PRETTIER,
    "PrismJS/prism": SPECS_PRISM,
    "quarto-dev/quarto-cli": SPECS_QUARTOCLI,
    "scratchfoundation/scratch-gui": SPECS_SCRATCH,
}

# The eval script re-syncs dependencies as root before dropping to chromeuser, which
# creates a root-owned /testbed/build; the later `shx mkdir -p build/ol` then fails with
# permission denied. eval_script lives in the dataset, so pre-create the directory
# world-writable at build time instead.
INSTANCE_OVERRIDES.setdefault("openlayers__openlayers-14932", {})["install_post"] = [
    "mkdir -p /home/chromeuser/.cache/puppeteer/chrome/linux-115.0.5790.98",
    (
        "wget -q https://storage.googleapis.com/chrome-for-testing-public/"
        "115.0.5790.98/linux64/chrome-linux64.zip -O /tmp/chrome-115.zip"
    ),
    (
        "python3 -c \"import zipfile; "
        "zipfile.ZipFile('/tmp/chrome-115.zip').extractall("
        "'/home/chromeuser/.cache/puppeteer/chrome/linux-115.0.5790.98')\""
    ),
    "rm /tmp/chrome-115.zip",
    "chmod -R 755 /home/chromeuser/.cache/puppeteer/chrome/linux-115.0.5790.98/chrome-linux64",
    "chown -R chromeuser:chromeuser /home/chromeuser/.cache/puppeteer",
    "mkdir -p /testbed/build",
    "chmod 777 /testbed/build",
]

# Chrome dies on the container's 64MB /dev/shm, which Cypress reports only as "browser
# never connected". Rewrite the pinned-Chrome wrapper for these two instances to disable
# shm usage; scoped so the other 1.27 instances that pass are untouched.
for _n in (4806, 4859):
    INSTANCE_OVERRIDES.setdefault(f"alibaba-fusion__next-{_n}", {})["install_post"] = [
        "printf '#!/bin/bash\\nexec /opt/chrome-linux64/chrome --no-sandbox"
        " --disable-dev-shm-usage \"$@\"\\n' > /usr/bin/google-chrome",
        "chmod +x /usr/bin/google-chrome",
        "cp /usr/bin/google-chrome /usr/bin/google-chrome-stable",
    ]
