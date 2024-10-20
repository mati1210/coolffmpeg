vvenc_prepare() {
    needscmd cmake
    fetchgit vvenc https://github.com/fraunhoferhhi/vvenc master
}

vvenc_run() {
    local opts=(
        -DCMAKE_BUILD_TYPE=Release #doesn't work with build type none
        -DVVENC_LIBRARY_ONLY=ON
   )
    cmake_wrapper $FFBUILD/vvenc $opts

    sed -i 's/-lgcc_s//g' $FFPREFIX/lib/pkgconfig/libvvenc.pc #fixes configure error
    ffmpegopts+="--enable-libvvenc"
}
