# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

RUN mkdir -p /build/out

ENV HOST=x86_64-w64-mingw32
ENV LIBFFI_VER=3.4.6
ENV DLFCN_VER=1.4.1

WORKDIR /build
ADD https://github.com/libffi/libffi/releases/download/v${LIBFFI_VER}/libffi-${LIBFFI_VER}.tar.gz \
    libffi.tar.gz
RUN tar -xf libffi.tar.gz
WORKDIR /build/libffi-${LIBFFI_VER}
RUN ./configure --prefix="/build" --host=${HOST} --enable-static --disable-symvers
RUN make && make install

WORKDIR /build
RUN git clone --depth 1 -b v${DLFCN_VER} https://github.com/dlfcn-win32/dlfcn-win32.git
WORKDIR /build/dlfcn-win32
RUN ./configure --prefix="/build" --cc=${HOST}-clang --cross-prefix="${HOST}-" --enable-static
RUN make && make install

WORKDIR /build
ARG BRANCH=develop
ARG NATIVE=0
ARG REPLXX=1
ARG VERSION=""
ARG EXE_OPTS=""
ARG DLL_OPTS=""
# disable caching for git clone
ADD https://worldtimeapi.org/api/timezone/Etc/UTC /tmp/time.json
RUN git clone --recurse-submodules --depth 1 -b ${BRANCH} https://github.com/dzaima/CBQN.git
WORKDIR /build/CBQN
COPY ./bqnres.rc ./bqnres.rc
COPY ./BQN.exe.manifest ./BQN.exe.manifest
COPY ./BQN.ico ./BQN.ico
RUN ${HOST}-windres bqnres.rc -o bqnres.o
RUN build/build static-bin replxx=${REPLXX} singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${EXE_OPTS} \
    f="-I/build/include/" lf="-L/build/lib/" lf="bqnres.o" lf="-Wl,--Xlink=-Brepro" \
    CC=${HOST}-clang CXX=${HOST}-clang++
RUN build/build static-bin shared singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${DLL_OPTS} \
    f="-I/build/include/" lf="-L/build/lib/" lf="-Wl,--output-def=cbqn.def,--Xlink=-Brepro" \
    CC=${HOST}-clang
RUN ${HOST}-dlltool -D cbqn.dll -d cbqn.def -l cbqn.lib

WORKDIR /build/out
RUN cp /build/CBQN/BQN.exe .
RUN mkdir libcbqn
RUN cp /build/CBQN/cbqn.lib /build/CBQN/cbqn.dll /build/CBQN/include/bqnffi.h ./libcbqn/
COPY ./licenses/ ./licenses/
COPY ./release.txt ./readme.txt
RUN zip -r bqn.zip .
