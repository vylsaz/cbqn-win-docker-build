# syntax=docker/dockerfile:1
ARG UBUNTU_VER=22.04
FROM ubuntu:${UBUNTU_VER}

RUN apt-get update -qq && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -qqy --no-install-recommends \
    build-essential ca-certificates git xz-utils zip && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

ARG UBUNTU_VER
ARG CRT=msvcrt
ARG BRANCH=develop
ARG NATIVE=0
ARG REPLXX=1
ARG VERSION=""
ARG EXE_OPTS=""
ARG DLL_OPTS=""
ARG LIB_OPTS=""

ENV HOST=x86_64-w64-mingw32
ENV LLVM_MINGW_VER=20250430
ENV LIBFFI_VER=3.4.8
ENV DLFCN_VER=1.4.2

RUN mkdir -p /opt/llvm-mingw
WORKDIR /opt
ADD https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VER}/llvm-mingw-${LLVM_MINGW_VER}-${CRT}-ubuntu-${UBUNTU_VER}-x86_64.tar.xz \
    llvm-mingw.tar.xz
RUN tar -xf llvm-mingw.tar.xz -C llvm-mingw --strip-components=1
ENV PATH="/opt/llvm-mingw/bin:$PATH"

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
RUN echo "  * uses ${CRT}" >> ./readme.txt

WORKDIR /build
COPY ./build.sh ./build.sh
RUN chmod +x ./build.sh && ./build.sh
