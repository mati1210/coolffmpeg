x264_prepare() {
    fetchgit x264 https://code.videolan.org/videolan/x264 master
}

x264_run() {
    pushd $FFBUILD/x264

	local opts=(
		--prefix=$FFPREFIX
		--disable-cli
		--enable-static
	)
	./configure $opts
	make
	make install

	ffmpegopts+=(--enable-gpl --enable-libx264)
    popd
}
