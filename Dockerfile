# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

ARG BRANCH=develop
ARG NATIVE=0
ARG REPLXX=1
ARG VERSION=""
ARG EXE_OPTS=""
ARG DLL_OPTS=""
ARG LIB_OPTS=""

ENV HOST=x86_64-w64-mingw32
ENV LIBFFI_VER=3.5.2
ENV DLFCN_VER=1.4.2

WORKDIR /build
ADD https://github.com/libffi/libffi/releases/download/v${LIBFFI_VER}/libffi-${LIBFFI_VER}.tar.gz \
    libffi.tar.gz
ADD https://github.com/dlfcn-win32/dlfcn-win32/archive/v${DLFCN_VER}.tar.gz dlfcn-win32.tar.gz

# disable caching for git clone
ARG CACHEBUST="Set this variable to avoid caching"
RUN echo CACHEBUST=${CACHEBUST}
RUN git clone --recurse-submodules --depth 1 -b ${BRANCH} https://github.com/dzaima/CBQN.git

WORKDIR /build/CBQN
COPY ./bqnres.rc ./bqnres.rc
COPY ./BQN.exe.manifest ./BQN.exe.manifest
COPY ./BQN.ico ./BQN.ico
COPY ./libcbqn.mri ./libcbqn.mri

WORKDIR /build/out/bqn
COPY ./licenses/ ./licenses/
COPY ./release.txt ./readme.txt
RUN echo "  * uses UCRT" >> ./readme.txt

WORKDIR /build
COPY ./build.sh ./build.sh
RUN chmod +x ./build.sh && ./build.sh
