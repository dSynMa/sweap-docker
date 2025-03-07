FROM ubuntu:22.04@sha256:33d782143e3a76315de8570db1673fda6d5b17c854190b74e9e890d8e95c85cf AS rpgstela-img

# Install necessary packages
RUN apt-get update
RUN apt-get install -y \
        build-essential \
        g++ \
        wget \
        z3 \
        unzip \
        libgmp-dev \
        libffi-dev \
        git

# Install Haskell stack
RUN wget -qO- https://get.haskellstack.org/ | sh

# Download and extract artifact, remove unneeded stuff
RUN wget -q -O artifact.zip https://zenodo.org/records/10939871/files/artifact.zip?download=1 
RUN unzip artifact.zip && rm artifact.zip && rm rpg-stela-docker.tar && rm .dockerignore && rm -rf muval 

# Build Pestel
RUN cd pestel && make && cd ../
RUN cp pestel/pestel /bin && rm -rf pestel

# Build rpg-stela
RUN cd rpg-stela && make && cd ../
# RUN cp rpg-stela/builds/rpg-stela /bin && rm -rf rpg-stela && rm -rf .stack

################################################################################

FROM ubuntu:22.04@sha256:33d782143e3a76315de8570db1673fda6d5b17c854190b74e9e890d8e95c85cf as tslmt2rpg-img

WORKDIR /

# Install necessary packages
# FROM ubuntu:22.04@sha256:33d782143e3a76315de8570db1673fda6d5b17c854190b74e9e890d8e95c85cf as tslmt2rpg-img

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    g++ \
    wget \
    unzip \
    libblas-dev \
    liblapack-dev \
    libmpfr-dev \
    libgmp-dev \
    libglpk-dev \
    libffi-dev \
    bc \
    opam \
    pkg-config \
    python3-distutils

# Install z3 version 13.13.4
# RUN wget -qO z3.zip https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip && \
#     unzip z3.zip && \
#     cp z3-4.13.4-x64-glibc-2.35/bin/z3 /bin/z3 && \
#     rm -rf z3-4.13.4-x64-glibc-2.35 && \
#     rm z3.zip

# Install Haskell stack
RUN wget -qO- https://get.haskellstack.org/ | sh

# Download and extract artifact
RUN wget -qO artifact.zip https://zenodo.org/records/13939202/files/popl25-artifact-21.zip?download=1 && \
    unzip artifact.zip && rm artifact.zip && rm artifact.ova && rm README.md && rm LICENSE-INFORMATION && \
    unzip artifact-content.zip && rm artifact-content.zip && rm -rf artifact-content/binaries/ 

# Install Opam
RUN opam init --disable-sandboxing
RUN opam switch create 5.0.0 
RUN opam install dune 

# Build Spot
WORKDIR /artifact-content/src-spot
RUN ./configure --prefix /usr --disable-python && make && make install

# Build tslmt2rpg 
WORKDIR /artifact-content/src-tslmt2rpg
RUN make && cp builds/tslmt2rpg /bin && cp builds/rpgsolve /bin

# Build MuVal
WORKDIR /artifact-content/src-muval
RUN eval $(opam env) && opam install . --deps-only  --confirm-level=yes
RUN eval $(opam env) && dune build main.exe
WORKDIR /
RUN mkdir muval && \
    cp /artifact-content/src-muval/_build/default/main.exe /muval/muval && \
    cp -r /artifact-content/src-muval/config /muval

# Cleanup
RUN rm -rf /artifact-content


FROM ubuntu:22.04@sha256:33d782143e3a76315de8570db1673fda6d5b17c854190b74e9e890d8e95c85cf as final
WORKDIR /

RUN apt-get update && \
    apt-get install -y \
    git \
    libgmp-dev \
    openjdk-17-jre \
    wget \
    unzip \
    bc \
    pkg-config \
    python3-distutils \
    python3-pip

# Install z3 version 13.13.4
RUN wget -qO z3.zip https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip && \
    unzip z3.zip && \
    cp z3-4.13.4-x64-glibc-2.35/bin/z3 /bin/z3 && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.a /lib/libz3.a && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3.so /lib/libz3.so && \
    cp z3-4.13.4-x64-glibc-2.35/bin/libz3java.so /lib/libz3java.so && \
    rm -rf z3-4.13.4-x64-glibc-2.35 && \
    rm z3.zip

COPY --from=rpgstela-img /rpg-stela/builds/rpg-stela /bin/rpg-stela
COPY --from=rpgstela-img /bin/pestel /bin/pestel

COPY --from=tslmt2rpg-img /bin/rpgsolve /bin/rpgsolve
COPY --from=tslmt2rpg-img /bin/tslmt2rpg /bin/tslmt2rpg
COPY --from=tslmt2rpg-img /muval /muval

## Copy spot files
COPY --from=tslmt2rpg-img /usr/bin/aut* /usr/bin/dstar2tgba /usr/bin/genaut /usr/bin/genltl /usr/bin/ltl* /usr/bin/rand* /usr/bin
COPY --from=tslmt2rpg-img /usr/include/bddx.h /usr/include/bvecx.h /usr/include/fddx.h /usr/include
COPY --from=tslmt2rpg-img /usr/include/spot /usr/include
COPY --from=tslmt2rpg-img /usr/lib/libbddx* /usr/lib/libspot* /usr/lib


COPY tool-containers/tslmt2rpg/call-muval.sh /muval/call-muval.sh
RUN chmod +x /muval/call-muval.sh 
COPY tool-containers/tslmt2rpg/wrapper.sh /wrapper.sh
RUN sed 's/rpgsolve/rpgsolve --generate-program/' /wrapper.sh > wrapper-syn.sh
RUN chmod +x /wrapper*.sh

RUN git clone https://github.com/shaunazzopardi/sweap.git && cd sweap && git checkout docker

WORKDIR /sweap
RUN pip install -r requirements.txt && \
    pip install swig && \
    pysmt-install --msat --confirm-agreement && \
    pysmt-install --z3 --confirm-agreement && \
    pysmt-install --bdd --confirm-agreement && \
    chmod +x main.py


WORKDIR /
COPY --chmod=0755 sweap-wrapper.sh /bin/sweap
COPY LICENSES/ /LICENSES
COPY --chmod=0755 binaries/* /bin
COPY --chmod=0755 binaries/opt /bin/opt

RUN wget --content-disposition https://nuxmv.fbk.eu/theme/download.php\?file\=nuXmv-2.1.0-linux64.tar.xz  && \
    tar -xvf nuXmv-2.1.0-linux64.tar.xz && \
    mv /nuXmv-2.1.0-linux64/bin/nuXmv /bin/nuxmv && \
    ln -s /bin/nuxmv /bin/nuXmv && \
    rm -rf nuXmv-2.1.0-linux64*

COPY Makefile /
COPY scripts /scripts