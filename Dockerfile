FROM apol/asdk:clang

#RUN /opt/helpers/build-cmake kirigami kde:kirigami

RUN mkdir /opt/android-toolchain/
ENV STANDALONE_CC=clang
ENV STANDALONE_CXX=clang++
ENV STANDALONE_EXTRA=--stl=libc++

ENV LOCAL_DEPS /opt/localdeps/
RUN mkdir $LOCAL_DEPS
ENV PKG_CONFIG_PATH $LOCAL_DEPS/lib/pkgconfig/

RUN cd && git clone https://github.com/bitcoin-core/secp256k1 --single-branch && cd secp256k1 \
    && /opt/helpers/build-standalone "./autogen.sh && ./configure --host=${ANDROID_NDK_TOOLCHAIN_PREFIX} --disable-shared --enable-module-recovery --prefix=$LOCAL_DEPS && make -j`nproc` && make install" \
    && cd .. && rm -rf secp256k1

RUN cd && git clone https://github.com/moritz-wundke/Boost-for-Android && cd Boost-for-Android \
    && /opt/helpers/build-standalone "./build-android.sh --arch=armeabi-v7a ${ANDROID_NDK_ROOT}" \
    && cp -r build/out/armeabi-v7a/include/boost-1_66/boost/ $LOCAL_DEPS/include/ \
    && cp build/out/armeabi-v7a/lib/*.a $LOCAL_DEPS/lib/ \
    && cd .. && rm -rf Boost-For-Android

COPY libbitcoin-configure.ac-diff /home/user/
RUN cd && git clone https://github.com/libbitcoin/libbitcoin && cd libbitcoin \
    && patch configure.ac < /home/user/libbitcoin-configure.ac-diff \
    && /opt/helpers/build-standalone "./autogen.sh && ./configure --host=${ANDROID_NDK_TOOLCHAIN_PREFIX} --disable-shared --with-boost=$LOCAL_DEPS --prefix=$LOCAL_DEPS && make -j`nproc` && make install" \
    && cd .. && rm -rf libbitcoin

WORKDIR /home/user/

