svt-av1_prepare(){
    needscmd cmake
    fetchgit svt-av1 https://github.com/gianni-rosato/svt-av1-psy master
}


svt-av1_run(){
	local opts=(
		-DCMAKE_BUILD_TYPE=None
		-DBUILD_{DEC,APPS,SHARED_LIBS}=OFF
	)
	cmake_wrapper $FFBUILD/svt-av1 $opts
	ffmpegopts+='--enable-libsvtav1'
}
