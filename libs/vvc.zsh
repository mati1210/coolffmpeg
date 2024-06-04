vvc_prepare() {
    needscmd cmake
    local lib
    for lib ( vv{enc,dec} ) {
        fetchgit $lib https://github.com/fraunhoferhhi/$lib master
    }
    fetch Add-support-for-H266-VVC.patch https://patchwork.ffmpeg.org/series/11673/mbox/
}



vvc_run() {
    for lib ( vv{enc,dec} ) {
        pushd $FFBUILD/$lib

        local opts=(
            -DCMAKE_INSTALL_PREFIX=$FFPREFIX
            -DCMAKE_BUILD_TYPE=Release #TODO: doesn't work without Release
        )

        cmake -B build -S . $opts
        cmake --build build
        cmake --install build

        popd
        ffmpegopts+="--enable-lib$lib"
    }
    ffmpegpatches+='Add-support-for-H266-VVC.patch'
}
