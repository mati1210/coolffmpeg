svt-av1_prepare(){
    needscmd cmake
    fetchgit svt-av1 https://github.com/gianni-rosato/svt-av1-psy master
}


svt-av1_run(){
    pushd $FFBUILD/svt-av1

	local opts=(
		-DCMAKE_INSTALL_PREFIX=$FFPREFIX
		-DCMAKE_BUILD_TYPE=None
		-DBUILD_{DEC,APPS,SHARED_LIBS}=OFF
		-Wno-dev
	)

	cmake -B build -S . $opts
	cmake --build build
	cmake --install build

	ffmpegopts+='--enable-libsvtav1'
	popd
}
