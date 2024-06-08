fdk-aac_prepare() {
    needscmd cmake
    fetchgit fdk-aac https://github.com/mstorsjo/fdk-aac master
}

fdk-aac_run(){
	local opts=(
		-DCMAKE_BUILD_TYPE=Release
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_wrapper $FFBUILD/fdk-aac $opts
	ffmpegopts+='--enable-libfdk-aac'
}
