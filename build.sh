set -xe

cd /build
tar -xf libffi.tar.gz
tar -xf dlfcn-win32.tar.gz
cd /build/libffi-${LIBFFI_VER}
./configure --prefix="/build" --host=${HOST} --enable-static --disable-shared --disable-symvers
make && make install
cd /build/dlfcn-win32-${DLFCN_VER}
./configure --prefix="/build" --cc=${HOST}-clang --cross-prefix="${HOST}-" --enable-static --disable-shared
make && make install

cd /build/CBQN
${HOST}-windres bqnres.rc -o bqnres.o
build/build static-bin replxx=${REPLXX} singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${EXE_OPTS} CC=${HOST}-clang CXX=${HOST}-clang++ \
    f="-I/build/include/" lf="-L/build/lib/ bqnres.o -Wl,--Xlink=-Brepro"
build/build static-bin shared singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${DLL_OPTS} CC=${HOST}-clang \
    f="-I/build/include/" lf="-L/build/lib/ -Wl,--output-def=cbqn.def,--Xlink=-Brepro"
${HOST}-dlltool -D cbqn.dll -d cbqn.def -l cbqn.lib
build/build static-lib singeli os=windows FFI=1 \
    native=${NATIVE} v=${VERSION} ${LIB_OPTS} CC=${HOST}-clang \
    f="-I/build/include/" OUTPUT=libcbqn1.a
${HOST}-ar -M <libcbqn.mri

mkdir -p /build/out/bqn/libcbqn
cp /build/CBQN/cbqn.lib /build/CBQN/cbqn.dll /build/CBQN/libcbqn.a \
    /build/CBQN/include/bqnffi.h /build/out/bqn/libcbqn
cp /build/CBQN/BQN.exe /build/out/bqn
cd /build/out
zip -r ./bqn.zip ./bqn
