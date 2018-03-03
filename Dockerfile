FROM ataber/circleci_ruby_base

RUN apt-get update \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes --fix-missing \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    language-pack-ja \
    wget \
    curl \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    g++ \
    libpq-dev \
    vim \
    dtach \
    libxslt1-dev \
    redis-tools \
    xvfb \
    tzdata \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN gem install bundler

# Emscripten install
ENV EMCC_SDK_VERSION 1.37.35
ENV EMCC_SDK_ARCH 32
ENV EMCC_BINARYEN_VERSION 1.37.35
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates build-essential curl git-core cmake default-jdk python \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -y nodejs \
    && npm -g up \
    && curl https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz > emsdk-portable.tar.gz \
    && tar xzf emsdk-portable.tar.gz \
    && rm emsdk-portable.tar.gz \
    && cd emsdk-portable \
    && ./emsdk update \
    && ./emsdk install --build=MinSizeRel sdk-tag-$EMCC_SDK_VERSION-${EMCC_SDK_ARCH}bit \
    && mkdir -p /clang \
    && cp -r /emsdk-portable/clang/tag-e$EMCC_SDK_VERSION/build_tag-e${EMCC_SDK_VERSION}_${EMCC_SDK_ARCH}/bin /clang \
    && mkdir -p /clang/src \
    && cp /emsdk-portable/clang/tag-e$EMCC_SDK_VERSION/src/emscripten-version.txt /clang/src/ \
    && mkdir -p /emscripten \
    && cp -r /emsdk-portable/emscripten/tag-$EMCC_SDK_VERSION/* /emscripten \
    && cp -r /emsdk-portable/emscripten/tag-${EMCC_SDK_VERSION}_${EMCC_SDK_ARCH}bit_optimizer/optimizer /emscripten/ \
    && echo "import os\nLLVM_ROOT='/clang/bin/'\nNODE_JS='nodejs'\nEMSCRIPTEN_ROOT='/emscripten'\nEMSCRIPTEN_NATIVE_OPTIMIZER='/emscripten/optimizer'\nSPIDERMONKEY_ENGINE = ''\nV8_ENGINE = ''\nTEMP_DIR = '/tmp'\nCOMPILER_ENGINE = NODE_JS\nJS_ENGINES = [NODE_JS]\n" > ~/.emscripten \
    && rm -rf /emsdk-portable \
    && rm -rf /emscripten/tests \
    && rm -rf /emscripten/site \
    && for prog in em++ em-config emar emcc emconfigure emmake emranlib emrun emscons; do \
           ln -sf /emscripten/$prog /usr/local/bin; done \
    && apt-get -y --purge remove curl git-core build-essential gcc ca-certificates \
    && apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && echo "Installed ... testing"

RUN apt-get install -y curl ca-certificates
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash \
    && apt-get install -y nodejs

RUN apt-get update --fix-missing && \
    apt-get -y upgrade && \
    apt-get install -y git cmake build-essential autoconf automake libtool make gcc g++ && rm -rf /var/lib/apt/lists/*
