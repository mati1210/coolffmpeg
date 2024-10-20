dav1d_prepare(){
    needscmd meson
    fetchgit dav1d https://code.videolan.org/videolan/dav1d master
}


dav1d_run(){
	pushd $FFBUILD/dav1d
	local opts=(
		--prefix $FFPREFIX
		--default-library static

		-Denable_{tools,tests}=false
	)
	if (( $+CROSSCOMPILE )) {
		opts+=(
			--cross-file $CROSSCOMPILE
		)
	}
	meson setup $opts build
	meson compile -C build
	meson install -C build
	popd
	ffmpegopts+='--enable-libdav1d'
}
