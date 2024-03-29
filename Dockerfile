# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

WORKDIR /build
RUN apt-get update && apt-get install -y zstd

RUN mkdir -p download include lib bin out

WORKDIR /build/download
RUN wget -O libffi.tar.zst \
    https://repo.msys2.org/mingw/ucrt64/mingw-w64-ucrt-x86_64-libffi-3.4.4-1-any.pkg.tar.zst
RUN tar -xf libffi.tar.zst
RUN cp -a ucrt64/lib/* /build/lib
RUN cp -a ucrt64/include/* /build/include

WORKDIR /build
RUN git clone --depth 1 https://github.com/dlfcn-win32/dlfcn-win32.git
WORKDIR /build/dlfcn-win32
RUN ./configure --prefix="/build" --cc=x86_64-w64-mingw32-clang \
    --cross-prefix="x86_64-w64-mingw32-" --enable-shared
RUN make && make install

WORKDIR /build
ARG BRANCH=develop
ARG NATIVE=1
ARG VERSION=""
ARG DEBUG=0
# disable caching for git clone
ADD https://worldtimeapi.org/api/timezone/Etc/UTC /tmp/time.json
RUN git clone --recurse-submodules --depth 1 -b $BRANCH https://github.com/dzaima/CBQN.git
WORKDIR /build/CBQN
COPY ./bqnres.rc ./bqnres.rc
COPY ./BQN.exe.manifest ./BQN.exe.manifest
COPY ./BQN.ico ./BQN.ico
RUN x86_64-w64-mingw32-windres bqnres.rc -o bqnres.o
RUN build/build static-bin replxx singeli os=windows FFI=1 \
    native=$NATIVE debug=$DEBUG v=$VERSION \
    f="-I/build/include/" lf="-L/build/lib/" lf="bqnres.o" lf="-Wl,--Xlink=-Brepro" \
    CC=x86_64-w64-mingw32-clang CXX=x86_64-w64-mingw32-clang++
RUN build/build static-bin shared singeli os=windows FFI=1 \
    native=$NATIVE debug=$DEBUG \
    f="-I/build/include/" lf="-L/build/lib/" lf="-Wl,--output-def=cbqn.def,--Xlink=-Brepro" \
    CC=x86_64-w64-mingw32-clang
RUN x86_64-w64-mingw32-dlltool -D cbqn.dll -d cbqn.def -l cbqn.lib

WORKDIR /build/out
RUN cp /build/CBQN/BQN.exe .
RUN mkdir libcbqn
RUN cp /build/CBQN/cbqn.lib /build/CBQN/cbqn.dll /build/CBQN/include/bqnffi.h ./libcbqn/
COPY ./licenses/ ./licenses/
COPY ./release.txt ./readme.txt
RUN zip -r bqn.zip .

ENTRYPOINT ["cp", "/build/out/bqn.zip"]
CMD ["/opt/mount"]
