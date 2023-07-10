# syntax=docker/dockerfile:1
FROM mstorsjo/llvm-mingw:latest

WORKDIR /build
RUN apt-get update && \
    apt-get install -y zstd && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

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
RUN git clone --depth 1 --branch $BRANCH https://github.com/dzaima/CBQN.git
WORKDIR /build/CBQN
RUN build/build static-bin replxx singeli os=windows \
    FFI=1 f="-I/build/include/" lf+="-L/build/lib/" \
    CC=x86_64-w64-mingw32-clang CXX=x86_64-w64-mingw32-clang++

ENTRYPOINT ["cp", "/build/CBQN/BQN.exe"]
CMD ["/opt/mount"]