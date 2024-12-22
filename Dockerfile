# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

ARG BRANCH=develop
ARG NATIVE=0
ARG REPLXX=1
ARG VERSION=""
ARG EXE_OPTS=""
ARG DLL_OPTS=""

ENV HOST=x86_64-w64-mingw32
ENV LIBFFI_VER=3.4.6
ENV DLFCN_VER=1.4.1

WORKDIR /build
ADD https://github.com/libffi/libffi/releases/download/v${LIBFFI_VER}/libffi-${LIBFFI_VER}.tar.gz \
    libffi.tar.gz
ADD https://github.com/dlfcn-win32/dlfcn-win32/archive/v${DLFCN_VER}.tar.gz dlfcn-win32.tar.gz
RUN tar -xf libffi.tar.gz
RUN tar -xf dlfcn-win32.tar.gz
WORKDIR /build/libffi-${LIBFFI_VER}
RUN ./configure --prefix="/build" --host=${HOST} --enable-static --disable-symvers
RUN make && make install
WORKDIR /build/dlfcn-win32-${DLFCN_VER}
RUN ./configure --prefix="/build" --cc=${HOST}-clang --cross-prefix="${HOST}-" --enable-static
RUN make && make install

WORKDIR /build
# disable caching for git clone
ADD https://api.github.com/repos/dzaima/CBQN/branches/develop /tmp/bustcache.json
RUN git clone --recurse-submodules --depth 1 -b ${BRANCH} https://github.com/dzaima/CBQN.git
WORKDIR /build/CBQN
COPY ./bqnres.rc ./bqnres.rc
COPY ./BQN.exe.manifest ./BQN.exe.manifest
COPY ./BQN.ico ./BQN.ico
RUN ${HOST}-windres bqnres.rc -o bqnres.o
RUN build/build static-bin replxx=${REPLXX} singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${EXE_OPTS} CC=${HOST}-clang CXX=${HOST}-clang++ \
    f="-I/build/include/" lf="-L/build/lib/ bqnres.o -Wl,--Xlink=-Brepro"
RUN build/build static-bin shared singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${DLL_OPTS} CC=${HOST}-clang \
    f="-I/build/include/" lf="-L/build/lib/ -Wl,--output-def=cbqn.def,--Xlink=-Brepro"
RUN ${HOST}-dlltool -D cbqn.dll -d cbqn.def -l cbqn.lib

RUN mkdir -p /build/out/libcbqn
WORKDIR /build/out
RUN cp /build/CBQN/BQN.exe .
RUN cp /build/CBQN/cbqn.lib /build/CBQN/cbqn.dll /build/CBQN/include/bqnffi.h ./libcbqn/
COPY ./licenses/ ./licenses/
COPY ./release.txt ./readme.txt
RUN zip -r bqn.zip .
