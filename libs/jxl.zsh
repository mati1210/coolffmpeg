jxl_prepare(){
    needscmd cmake
    fetchgit libjxl https://github.com/libjxl/libjxl main

    # submodules
    fetchgit skcms https://skia.googlesource.com/skcms main
    fetchgit sjpeg https://github.com/webmproject/sjpeg main
    fetchgit highway https://github.com/google/highway master
    fetchgit brotli https://github.com/google/brotli master

	for submodule ( skcms sjpeg highway brotli ) {
		git -C $FFBUILD/libjxl config --local submodule.third_party/$submodule.url $FFBUILD/$submodule
	}
    git -C $FFBUILD/libjxl -c protocol.file.allow='always' submodule update
}


jxl_run(){
	local opts=(
		-DCMAKE_BUILD_TYPE=None
		-DBUILD_{SHARED_LIBS,TESTING}=OFF
		-DJPEGXL_ENABLE_{BENCHMARK,FUZZERS,PLUGINS,EXAMPLES,VIEWERS,JNI,MANPAGES,DOXYGEN,JPEGLI,TOOLS}:BOOL=false
		-DJPEGXL_STATIC:BOOL=true
	)
	cmake_wrapper $FFBUILD/libjxl $opts
	ffmpegopts+='--enable-libjxl'
}
