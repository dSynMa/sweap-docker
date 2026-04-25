FROM ubuntu:24.04@sha256:3afff29dffbc200d202546dc6c4f614edc3b109691e7ab4aa23d02b42ba86790 AS issy-img

# Adapted from https://github.com/phheim/issy/blob/main/containers/version-3/runner-full/Dockerfile
WORKDIR /

# Dependencies
RUN apt-get update \
 && apt-get install -y \
    build-essential \
    g++ \
    curl \
    unzip \
    libgmp-dev \
    libffi-dev \
 && apt-get clean

# Build Spot
RUN curl -L --output spot-2.12.2.tar.gz  http://www.lrde.epita.fr/dload/spot/spot-2.12.2.tar.gz \
 && tar xf spot-2.12.2.tar.gz \
 && rm spot-2.12.2.tar.gz \
 # Building & Installation \
 && cd spot-2.12.2 \
 && ./configure --prefix /usr --disable-python \
 && make \
 && make install \
 # Cleanup \
 && make clean \
 && cd ..

# Dependencies (MuVal)
RUN apt-get update \
 && apt-get install -y \
    libblas-dev \
    liblapack-dev \
    libmpfr-dev \
    libglpk-dev \
    bc \
    opam \
    pkg-config \
 && apt-get clean

# Build MuVal
RUN opam init --disable-sandboxing \
 && opam switch create 5.2.0 \
 && opam install dune

RUN curl -L --output out.zip https://github.com/hiroshi-unno/coar/archive/1d49999975b00f1430b3c9d10b90ab00b561e836.zip \
 && unzip out.zip \
 && rm -f out.zip \
 && mv coar-1d49999975b00f1430b3c9d10b90ab00b561e836 /muval

WORKDIR /muval

RUN eval $(opam env) && opam install . --deps-only  --confirm-level=yes
RUN eval $(opam env) && dune build main.exe

WORKDIR /

# Get Z3 (4.15.1)
RUN curl -L --output out.zip https://github.com/Z3Prover/z3/releases/download/z3-4.15.1/z3-4.15.1-x64-glibc-2.39.zip \
 && unzip out.zip \
 && cp z3-4.15.1-x64-glibc-2.39/bin/z3 /usr/bin/z3-4.15.1 \
 && rm -r z3-4.15.1-x64-glibc-2.39 out.zip

# Get Issy
RUN curl -L --output out.zip https://github.com/phheim/issy/releases/download/v3.0/issy-v3.zip \
 && unzip out.zip \
 && cp issy-v3/issy /usr/bin/issy-bin \
 && rm -rf issy-v3

# Get wrapper scripts
COPY issy-v3-runner-full-files/internal-wrapper.sh /usr/bin/issy
COPY issy-v3-runner-full-files/call-muval.sh /usr/bin/call-muval
RUN chmod +x /usr/bin/issy  \
 && chmod +x /usr/bin/call-muval

###############################################################################
FROM ubuntu:24.04@sha256:3afff29dffbc200d202546dc6c4f614edc3b109691e7ab4aa23d02b42ba86790 as semml-img
WORKDIR /

RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk-headless \
    python3-pip \
    python3-setuptools \
    unzip \
    wget


ARG SEMML_REV=e2650bc88f7a6bdabb52e61f0571039583075c2f
ARG SEMML_XMX=30G
RUN mkdir -p /binaries && \
    test ! -e /binaries/semml && \
    wget --content-disposition https://gitlab.com/live-lab/software/semml/-/archive/${SEMML_REV}/semml-${SEMML_REV}.zip && \
    unzip semml-${SEMML_REV}.zip && \
    pip install --break-system-packages 'pyyaml==6.0.2' && \
    mv semml-${SEMML_REV} /binaries/semml && \
    rm semml-${SEMML_REV}.zip && \
    cd /binaries/semml && \
    sed -E -i "s/-Xmx[0-9]+[KMG]/-Xmx${SEMML_XMX}/g" build.gradle.kts && \
    python3 build.py --target executable && \
    python3 semml.py --help >/dev/null

###############################################################################

FROM ubuntu:24.04@sha256:3afff29dffbc200d202546dc6c4f614edc3b109691e7ab4aa23d02b42ba86790 as final
WORKDIR /

RUN apt-get update && \
    apt-get install -y \
    libblas-dev \
    liblapack-dev \
    libmpfr-dev \
    libgmp-dev \
    libglpk-dev \
    libffi-dev \
    openjdk-17-jre-headless \
    wget \
    unzip \
    bc \
    time \
    pkg-config \
    python3-pip \
    python3-setuptools

COPY LICENSE /LICENSE
COPY --chmod=0755 sweap-wrapper.sh /bin/sweap
COPY --from=issy-img /usr/bin/issy /usr/bin/issy
COPY --from=issy-img /usr/bin/call-muval /usr/bin/call-muval
COPY --from=issy-img /muval /muval
COPY --from=issy-img /usr/bin/issy-bin /usr/bin/issy-bin
COPY --from=issy-img /usr/bin/z3-4.15.1 /usr/bin/z3-4.15.1
COPY --from=semml-img /binaries /binaries
RUN sed -i "s@/usr/bin/ltl2tgba@/usr/local/bin/ltl2tgba@g" /usr/bin/issy

# Install z3 version 13.13.4
RUN wget -qO z3.zip https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip && \
    unzip z3.zip && \
    cp z3-4.13.4-x64-glibc-2.35/bin/z3 /bin/z3 && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.a /lib/libz3.a && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.so /lib/libz3.so && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3java.so /lib/libz3java.so && \
    rm -rf z3-4.13.4-x64-glibc-2.35 && \
    rm z3.zip

RUN wget --content-disposition https://nuxmv.fbk.eu/theme/download.php\?file\=nuXmv-2.1.0-linux64.tar.xz  && \
    tar -xvf nuXmv-2.1.0-linux64.tar.xz && \
    mkdir -p /binaries && \
    mv /nuXmv-2.1.0-linux64/bin/nuXmv /bin/nuxmv && \
    mv /nuXmv-2.1.0-linux64/LICENSE.txt /binaries/LICENSE-nuxmv && \
    ln -s /bin/nuxmv /bin/nuXmv && \
    rm -rf nuXmv-2.1.0-linux64*


RUN pip install --break-system-packages pysmt --pre --force && \
    pip install --break-system-packages 'swig==4.3.1' && \
    pip install --break-system-packages pyarrow

RUN pysmt-install --msat --confirm-agreement && \
    pysmt-install --z3 --confirm-agreement && \
    pysmt-install --bdd --confirm-agreement


ARG SPOT_VERSION=2.14.5
RUN wget -qO spot.tar.gz https://www.lrde.epita.fr/dload/spot/spot-${SPOT_VERSION}.tar.gz && \
    tar -xzf spot.tar.gz && \
    cd spot-${SPOT_VERSION} && \
    ./configure --prefix=/usr/local PYTHON=/usr/bin/python3 --with-python-sys-prefix && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig && \
    PY_SITE="$(python3 -c 'import site; print(site.getsitepackages()[0])')" && \
    mkdir -p "$PY_SITE/spot" && \
    cp -a python/spot/*.py "$PY_SITE/spot/" && \
    find python/spot -type f -name "_*.so" -exec cp -a {} "$PY_SITE/spot/" \; && \
    cp -a python/buddy.py "$PY_SITE/" && \
    find python -type f -name "_buddy*.so" -exec cp -a {} "$PY_SITE/" \; && \
    python3 -c "import spot; print(spot.__file__)" && \
    cd / && \
    rm -rf spot-${SPOT_VERSION} spot.tar.gz

ARG SWEAP_REV=61c6fd8fd48aaf29e87a9101cf155a62cf1728e3
RUN wget -qO sweap.zip https://github.com/shaunazzopardi/sweap/archive/${SWEAP_REV}.zip  && \
    unzip sweap.zip && mv /sweap-${SWEAP_REV} /sweap && \
    mv /binaries/* /sweap/binaries

WORKDIR /sweap
RUN pip install --break-system-packages -r requirements.txt && \
    pip install --break-system-packages -r benchmarks/scripts/requirements.txt

COPY libmathsat5j.so /sweap/binaries/CPAchecker-2.3-unix/lib/java/runtime/libmathsat5j.so
RUN python3 -m compileall -q -o 0 -o 1 /sweap/src
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    pip cache purge

RUN ln -s /bin/nuxmv /sweap/binaries/nuxmv

