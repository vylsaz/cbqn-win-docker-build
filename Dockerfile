# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

WORKDIR /build
RUN apt-get update && apt-get install -y zstd

RUN mkdir -p download include lib bin

WORKDIR /build/download
RUN wget -O libffi.tar.zst https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-libffi-3.4.4-1-any.pkg.tar.zst
RUN tar -xf libffi.tar.zst
RUN cp -a mingw64/lib/* /build/lib
RUN cp -a mingw64/include/* /build/include

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
# disable caching for git clone
ADD https://worldtimeapi.org/api/timezone/Etc/UTC /tmp/time.json
RUN git clone --depth 1 --branch $BRANCH https://github.com/dzaima/CBQN.git
WORKDIR /build/CBQN
COPY ./bqnres.rc ./bqnres.rc
COPY ./BQN.exe.manifest ./BQN.exe.manifest
COPY ./BQN.ico ./BQN.ico
RUN x86_64-w64-mingw32-windres bqnres.rc -o bqnres.o
RUN build/build static-bin replxx singeli native=$NATIVE os=windows FFI=1 \
    v=$VERSION lf+="bqnres.o" f="-I/build/include/" lf+="-L/build/lib/" \
    CC=x86_64-w64-mingw32-clang CXX=x86_64-w64-mingw32-clang++

ENTRYPOINT ["cp", "/build/CBQN/BQN.exe"]
CMD ["/opt/mount"]
