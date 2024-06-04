#!/bin/zsh -e
zmodload zsh/parameter
SCRIPTDIR=${0:h:A}

## CONFIG

# prefix directory
FFPREFIX=${${FFPREFIX:-$SCRIPTDIR/prefix}:A}

# build directory
FFBUILD=${${FFBUILD:-$SCRIPTDIR/build}:A}

# source directory
FFSRC=${${FFSRC:-$SCRIPTDIR/src}:A}

# libs to include
: ${LIBS:="opus svt-av1 vvc fdk-aac"}

## END CONFIG

export MAKEFLAGS=${MAKEFLAGS:- -j$(nproc)}
export C{,XX}FLAGS="-O3 -march=native -pipe -flto"
export PKG_CONFIG_PATH="$FFPREFIX/lib/pkgconfig"

needscmd() {
	for command ( $@ ) {
		if (( $+commands[$command] )) { continue }

		echo program $command not found!
		exit 1
	}
}
needscmd git aria2c

fetch() {
	local file=$1 url=$2
	if [[ ! -e $FFSRC/$file ]] { aria2c -UWget -s4 -x4 $url --dir / -o $FFSRC/$file }
}

fetchgit() {
	local name=$1 url=$2 branch=$3
	local src=$FFSRC/$name build=$FFBUILD/$name
	if [[ ! -d $src ]] {
		git clone --bare $url $src
	} else {
		git -C $src fetch --all -p
	}

	(( $+RESET )) && rm -rf $build
	if [[ ! -d $build ]] {
		git clone $src $build -b $branch
	} else {
		git -C $build pull
	}
}
mkdir -p $FFBUILD $FFPREFIX/{bin,lib/pkgconfig,include} $FFSRC
RESET=1 fetchgit ffmpeg https://git.ffmpeg.org/ffmpeg.git master

typeset -U ffmpegopts=(
	--prefix=$FFPREFIX
	--pkg-config-flags="--static"
	--extra-cflags="$CFLAGS -I$FFPREFIX/include"
	--extra-ldflags="-L$FFPREFIX/lib"
	--extra-libs="-lpthread -lm -lz"
	--extra-ldexeflags="-static"

	--enable-{pic,lto}
	--disable-{stripping,ffprobe,doc,autodetect}
) ffmpegpatches=()

typeset -U LIBS=( ${=LIBS} )
PREPARED=()
BUILT=()
prepare() {
	for lib ( $@ ) {
		(( $PREPARED[(Ie)$lib] )) && continue

		source $SCRIPTDIR/libs/$lib.zsh
		${lib}_prepare
		PREPARED+=$lib
		LIBS=( $lib $LIBS )
	}
}
build() {
	for lib ( $@ ) {
		# if already built, continue
		(( $BUILT[(Ie)$lib] )) && continue

		${lib}_run
		BUILT+=$lib
	}
}
prepare $LIBS
build $LIBS

pushd $FFBUILD/ffmpeg
for patch ( $ffmpegpatches ) {
	git apply $FFSRC/$patch
}
./configure $ffmpegopts
make install
popd
