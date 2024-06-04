opus_prepare() {
    fetchgit opus https://github.com/xiph/opus main
    $FFBUILD/opus/autogen.sh
}

opus_run() {
    pushd $FFBUILD/opus

	local opts=(
		--prefix=$FFPREFIX
		--disable-{doc,extra-programs,shared}
		--enable-custom-modes

		# ml
		--enable-{dred,osce}
	)
	./autogen.sh
	./configure $opts
	make install

	ffmpegopts+='--enable-libopus'
    popd
}
