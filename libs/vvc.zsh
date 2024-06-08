vvc_prepare() {
    needscmd cmake
    local lib
    for lib ( vv{enc,dec} ) {
        fetchgit $lib https://github.com/fraunhoferhhi/$lib master
    }
    fetch Add-support-for-H266-VVC.patch https://patchwork.ffmpeg.org/series/11673/mbox/
}

vvc_run() {
    local opts=(
        -DCMAKE_BUILD_TYPE=Release #doesn't work with build type none
   )
    for lib ( vv{enc,dec} ) {
        cmake_wrapper $FFBUILD/$lib $opts
        ffmpegopts+="--enable-lib$lib"
    }
    ffmpegpatches+='Add-support-for-H266-VVC.patch'
}
