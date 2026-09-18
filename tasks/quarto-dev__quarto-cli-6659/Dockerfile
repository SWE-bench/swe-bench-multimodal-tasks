
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    software-properties-common \
    wget \
    gnupg \
    jq \
    ca-certificates \
    dbus \
    ffmpeg \
    imagemagick \
    unzip \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg \
        fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 dbus dbus-x11 \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# Pin Chrome. The apt repo only ever serves the current stable, so an unpinned install
# silently changes version on every rebuild -- Chrome 151 broke openlayers' WebGL and
# Cypress's browser connection that way. Chrome for Testing archives every build, so this
# stays reproducible. Keep both binary names: 160 eval scripts reference one or the other.
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/151.0.7922.137/linux64/chrome-linux64.zip -O /tmp/chrome.zip \
    && unzip -q /tmp/chrome.zip -d /opt/chrome-pinned \
    && rm /tmp/chrome.zip \
    && printf '#!/bin/bash\nexec /opt/chrome-pinned/chrome-linux64/chrome "$@"\n' > /usr/bin/google-chrome \
    && chmod +x /usr/bin/google-chrome \
    && cp /usr/bin/google-chrome /usr/bin/google-chrome-stable

ENV NVM_DIR /usr/local/nvm

RUN mkdir -p $NVM_DIR
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.3/install.sh | bash
RUN apt-get update && apt-get install -y \
    procps \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdrm2 \
    libgbm1 libgconf-2-4 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 \
    libnss3 libpango-1.0-0 libpangocairo-1.0-0 libxcomposite1 \
    libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 libxss1 libxshmfence1 libglu1 \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN /usr/bin/google-chrome
RUN echo "CHROME_BIN=$CHROME_BIN" >> /etc/environment
RUN mkdir -p /run/dbus

ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"

RUN dbus-daemon --system --fork

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# puppeteer v20+ renamed the variable; without it install.mjs hangs fetching Chrome
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV OPENSSL_CONF /etc/ssl

RUN useradd -m chromeuser

USER chromeuser

WORKDIR /home/chromeuser

USER root

ENV NODE_VERSION 18.17.1
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN <<EOF_01667795d52d
#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y libffi-dev zip unzip python3 python3-pip python3.10-distutils r-base-core poppler-utils libxml2-utils
rm -rf /var/lib/apt/lists/*
export NODE_VERSION=18.17.1
source $NVM_DIR/nvm.sh
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default
add-apt-repository ppa:deadsnakes/ppa
apt-get update
apt-get install -y python3.9
ln -sf /usr/bin/python3.9 /usr/bin/python
apt-get install -y python2
echo "export NODE_PATH=$NVM_DIR/v18.17.1/lib/node_modules" >> /etc/environment
echo "export PATH=$NVM_DIR/versions/node/v18.17.1/bin:$PATH" >> /etc/environment
source $NVM_DIR/nvm.sh && node -v
source $NVM_DIR/nvm.sh && npm -v
python -V
python2 -V
EOF_01667795d52d


RUN <<EOF_bc8098def98d
#!/bin/bash
set -euxo pipefail
(mkdir -p /testbed && cd /testbed && git init -q . && git remote add origin https://github.com/quarto-dev/quarto-cli && git fetch -q --depth 1 origin 657c02e77bcf1764e462ef130e09b75411635593 && git reset -q --hard FETCH_HEAD) || (rm -rf /testbed && git clone -o origin https://github.com/quarto-dev/quarto-cli /testbed)
cd /testbed
git reset --hard 657c02e77bcf1764e462ef130e09b75411635593
git remote remove origin
BASE_COMMIT=$(git rev-parse 657c02e77bcf1764e462ef130e09b75411635593^{commit})
for tag in $(git tag -l); do TAG_COMMIT=$(git rev-parse -q --verify "$tag^{commit}" 2>/dev/null || true); if [ -z "$TAG_COMMIT" ] || ! git merge-base --is-ancestor "$TAG_COMMIT" "$BASE_COMMIT"; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
rm -f .git/ORIG_HEAD .git/FETCH_HEAD
git reflog expire --expire=now --all
git gc --prune=now --aggressive
EXTRA_REF_COMMITS=$(git rev-list --all --not "$BASE_COMMIT" | wc -l)
[ "$EXTRA_REF_COMMITS" -eq 0 ] || exit 1
EXTRA_STORED_COMMITS=$(comm -23 <(git cat-file --batch-all-objects --batch-check="%(objecttype) %(objectname)" | awk '$1 == "commit" {print $2}' | sort) <(git rev-list "$BASE_COMMIT" | sort) | wc -l)
[ "$EXTRA_STORED_COMMITS" -eq 0 ] || exit 1
UNREACHABLE_OBJECTS=$(git fsck --unreachable --no-reflogs 2>/dev/null | wc -l)
[ "$UNREACHABLE_OBJECTS" -eq 0 ] || exit 1
chmod -R 777 /testbed
cd - || true
cd /testbed
git clean -fdxq
source $NVM_DIR/nvm.sh
wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz
tar zxvf julia-1.9.3-linux-x86_64.tar.gz
mv julia-1.9.3/ /opt/
ln -s /opt/julia-1.9.3/bin/julia /usr/local/bin/julia
ls .
[ -f configure.sh ] || ./configure-linux.sh
[ -f configure-linux.sh ] || ./configure.sh
cd tests
./configure-test-env.sh || true
cd ..
rm -rf /root/.TinyTeX /opt/TinyTeX
wget -qO /tmp/install-tinytex.sh https://tinytex.yihui.org/install-bin-unix.sh
TINYTEX_VERSION=2024.12 sh /tmp/install-tinytex.sh
"$(echo /root/.TinyTeX/bin/*)"/tlmgr option repository https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/2024/tlnet-final
curl -sSL https://ftp.tu-chemnitz.de/pub/tug/historic/systems/texlive/2024/tlnet-final/archive/babel-french.tar.xz -o /tmp/babel-french.tar.xz || true
tar -xJf /tmp/babel-french.tar.xz -C /root/.TinyTeX/texmf-dist tex/generic/babel-french || true
"$(echo /root/.TinyTeX/bin/*)"/mktexlsr || true
rm -f /usr/local/bin/tlmgr
printf '#!/bin/sh\nexec "$(echo /root/.TinyTeX/bin/*)"/tlmgr --verify-repo=none "$@"\n' > /usr/local/bin/tlmgr && chmod 755 /usr/local/bin/tlmgr
tex_ver="$("$(echo /root/.TinyTeX/bin/*)"/xelatex --version)"; case "$tex_ver" in *"TeX Live 2024"*) echo "TinyTeX pinned to TL2024 OK";; *) echo "TinyTeX pin FAILED, got: $tex_ver"; exit 1;; esac
pip3 install --user pipenv
pip3 install nbformat
pip3 install nbclient
pip3 install pandocfilters
pip3 install shiny
pip3 install pyyaml
pip3 install setuptools
pip3 install numpy
pip3 install seaborn
pip3 install matplotlib
pip3 install bokeh
pip3 install bokeh_sampledata
pip3 install ipyleaflet
pip3 install pandas
pip3 install itables
pip3 install pexpect
pip3 install ptyprocess
pip3 install appnope
pip3 install ipykernel
chmod -R 777 /testbed
EOF_bc8098def98d


COPY ["problem_assets", "/problem_assets"]

WORKDIR /testbed
