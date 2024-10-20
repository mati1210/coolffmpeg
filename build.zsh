#!/bin/zsh -e
zmodload zsh/parameter
SCRIPTDIR=${0:h:A}
fpath=( $SCRIPTDIR/functions $fpath )

## CONFIG

# prefix directory
FFPREFIX=${${FFPREFIX:-$SCRIPTDIR/prefix}:A}

# build directory
FFBUILD=${${FFBUILD:-$SCRIPTDIR/build}:A}

# source directory
FFSRC=${${FFSRC:-$SCRIPTDIR/src}:A}

# libs to include
: ${LIBS:="opus svt-av1 dav1d vvenc fdk-aac jxl x264"}

# default to building with all cores
: ${MAKEFLAGS:= -j$(nproc)}

# compiler flags
: ${TGTARCH:=native}
: ${CFLAGS:="-O3 -march=$TGTARCH -pipe -flto"}
: ${CXXFLAGS:=$CFLAGS}

## END CONFIG

export MAKEFLAGS C{,XX}FLAGS PKG_CONFIG_PATH="$FFPREFIX/lib/pkgconfig"
mkdir -p $FFBUILD $FFPREFIX/{bin,lib/pkgconfig,include} $FFSRC
autoload fetchgit needscmd

needscmd git aria2c
fetch() {
	local file=$1 url=$2
	if [[ ! -e $FFSRC/$file ]] { aria2c -UWget -s4 -x4 $url --dir / -o $FFSRC/$file }
}

RESET=1 fetchgit ffmpeg https://git.ffmpeg.org/ffmpeg.git master

typeset -U \
	ffmpegopts=(
		--prefix=$FFPREFIX
		--pkg-config-flags="--static"
		--extra-cflags="$CFLAGS -I$FFPREFIX/include"
		--extra-ldflags="-L$FFPREFIX/lib"
		--extra-libs="-lpthread -lm -lz -lstdc++"
		--extra-ldexeflags="-static"

		--enable-{pic,lto}
		--disable-{stripping,ffprobe,doc,autodetect}
	) \
	ffmpegpatches=() \
	LIBS=( ${=LIBS} ) \
	PREPARED=() \
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
autoload -Uz cmake_wrapper

prepare $LIBS
build $LIBS

pushd $FFBUILD/ffmpeg
for patch ( $ffmpegpatches ) {
	git apply $FFSRC/$patch
}
./configure $ffmpegopts
make install
popd
