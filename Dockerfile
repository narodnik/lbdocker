FROM apol/asdk:clang

#RUN /opt/helpers/build-cmake kirigami kde:kirigami

RUN mkdir /opt/android-toolchain/
RUN ${ANDROID_NDK_ROOT}/build/tools/make-standalone-toolchain.sh --platform=android-16 --install-dir=/opt/android-toolchain/ --force --stl=libc++

ENV PATH ${PATH}:/opt/android-toolchain/bin/

ENV CC arm-linux-androideabi-clang
ENV CXX arm-linux-androideabi-clang++
ENV RANLIB /opt/android-toolchain/bin/arm-linux-androideabi-ranlib
ENV LD arm-linux-androideabi-ld
ENV AR arm-linux-androideabi-ar
ENV CROSS_COMPILE arm-linux-androideabi
ENV ANDROID_API 16
ENV CFLAGS -D__ANDROID_API__=$ANDROID_API

RUN sudo apt -y install autoconf libtool pkg-config
ENV LOCAL_DEPS /opt/localdeps/
RUN mkdir $LOCAL_DEPS
ENV PKG_CONFIG_PATH $LOCAL_DEPS/lib/pkgconfig/

WORKDIR /home/user/src/
RUN git clone https://github.com/bitcoin-core/secp256k1
WORKDIR secp256k1

RUN ./autogen.sh
RUN ./configure --host=${CROSS_COMPILE} --disable-shared --enable-module-recovery --prefix=$LOCAL_DEPS
RUN make
RUN sudo make install

WORKDIR /home/user/src/
RUN git clone https://github.com/moritz-wundke/Boost-for-Android
WORKDIR Boost-for-Android
RUN ./build-android.sh --arch=armeabi-v7a ${ANDROID_NDK_ROOT}
RUN sudo cp -r build/out/armeabi-v7a/include/boost-1_66/boost/ $LOCAL_DEPS/include/
RUN sudo cp build/out/armeabi-v7a/lib/*.a $LOCAL_DEPS/lib/

WORKDIR /home/user/src/
RUN git clone https://github.com/libbitcoin/libbitcoin
WORKDIR libbitcoin
COPY libbitcoin-configure.ac-diff .
RUN patch configure.ac < libbitcoin-configure.ac-diff
RUN ./autogen.sh
RUN ./configure --host=${CROSS_COMPILE} --disable-shared --with-boost=$LOCAL_DEPS --prefix=$LOCAL_DEPS
RUN make
RUN sudo make install

WORKDIR /home/user/

