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

# Install z3 version 13.13.4
RUN wget -qO z3.zip https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip && \
    unzip z3.zip && \
    cp z3-4.13.4-x64-glibc-2.35/bin/z3 /bin/z3 && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.a /lib/libz3.a && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.so /lib/libz3.so && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3java.so /lib/libz3java.so && \
    rm -rf z3-4.13.4-x64-glibc-2.35 && \
    rm z3.zip

COPY --from=issy-img /usr/bin/issy /usr/bin/issy
COPY --from=issy-img /usr/bin/call-muval /usr/bin/call-muval
COPY --from=issy-img /muval /muval

## Copy spot files
COPY --from=issy-img /usr/bin/aut* /usr/bin/dstar2tgba /usr/bin/genaut /usr/bin/genltl /usr/bin/ltl* /usr/bin/rand* /usr/bin/
COPY --from=issy-img /usr/include/bddx.h /usr/include/bvecx.h /usr/include/fddx.h /usr/include/
COPY --from=issy-img /usr/include/spot /usr/include
COPY --from=issy-img /usr/lib/libbddx* /usr/lib/libspot* /usr/lib/

RUN wget -qO sweap.zip https://github.com/shaunazzopardi/sweap/archive/12a2d634061cefd845103886b4efd1baaa6a147d.zip  && \
    unzip sweap.zip && \
    mv /sweap-12a2d634061cefd845103886b4efd1baaa6a147d /sweap

WORKDIR /sweap
RUN pip install --break-system-packages -r requirements.txt && \
    pip install --break-system-packages pysmt --pre --force && \
    # swig 4.3.1 required by repycudd
    pip install --break-system-packages 'swig==4.3.1'

RUN pysmt-install --msat --confirm-agreement && \
    pysmt-install --z3 --confirm-agreement && \
    pysmt-install --bdd --confirm-agreement

WORKDIR /
COPY --chmod=0755 sweap-wrapper.sh /bin/sweap
COPY libmathsat5j.so /sweap/binaries/CPAchecker-2.3-unix/lib/java/runtime/libmathsat5j.so
# COPY scripts /scripts
RUN pip install --break-system-packages -r /sweap/benchmarks/scripts/requirements.txt && \
    pip install --break-system-packages pyarrow

# COPY Makefile /
COPY LICENSE /LICENSE


ARG SEMML_REF=main
ARG SEMML_XMX=30G
RUN rm -rf /sweap/binaries/semml && \
    test ! -e /sweap/binaries/semml && \
    git clone --depth 1 --branch "${SEMML_REF}" https://gitlab.com/live-lab/software/semml.git /sweap/binaries/semml && \
    cd /sweap/binaries/semml && \
    git checkout e2650bc88f7a6bdabb52e61f0571039583075c2f && \    
    sed -E -i "s/-Xmx[0-9]+[KMG]/-Xmx${SEMML_XMX}/g" build.gradle.kts && \
    python3 build.py --target executable && \
    python3 semml.py --help >/dev/null


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

RUN wget --content-disposition https://nuxmv.fbk.eu/theme/download.php\?file\=nuXmv-2.1.0-linux64.tar.xz  && \
    tar -xvf nuXmv-2.1.0-linux64.tar.xz && \
    mv /nuXmv-2.1.0-linux64/bin/nuXmv /bin/nuxmv && \
    mv /nuXmv-2.1.0-linux64/LICENSE.txt /sweap/binaries/LICENSE-nuxmv && \
    ln -s /bin/nuxmv /bin/nuXmv && \
    rm -rf nuXmv-2.1.0-linux64*
