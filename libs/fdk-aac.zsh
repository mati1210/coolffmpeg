fdk-aac_prepare() {
    needscmd cmake
    fetchgit fdk-aac https://github.com/mstorsjo/fdk-aac master
}

fdk-aac_run(){
    pushd $FFBUILD/fdk-aac

	local opts=(
		-DCMAKE_INSTALL_PREFIX=$FFPREFIX
		-DCMAKE_BUILD_TYPE=Release
		-DBUILD_SHARED_LIBS=OFF
		-Wno-dev
	)

	cmake -B build -S . $opts
	cmake --build build
	cmake --install build

	ffmpegopts+='--enable-libfdk-aac'
	popd
}
