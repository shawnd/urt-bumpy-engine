#!/bin/sh

# ----------------------------------------------
# VERSION
# ----------------------------------------------

# Q3_VERSION=`grep '^VERSION_NUMBER=' Makefile | sed -e 's/.*=\(.*\)/\1/'`

Q3_VERSION="1.36"
URT_VERSION="4.1"
PASSPORT_VERSION="0.4"

# ----------------------------------------------
# START
# ----------------------------------------------

MYDIR=`dirname "$0"`

cd "$MYDIR"

if [ ! -f Makefile ]; then
	echo "This script must be run from the ioquake3 build directory"
	exit 1
fi

if [ "$1" = '' ]
then
	echo "usage: make-kalish mac|linux|windows quake|standalone|passport|all client|server|all test debug noextra"
	exit 0
fi

if [ "$1" = 'sg' ] 
then
	echo "$0 linux all server noextra"
	$0 linux all server noextra
	exit 0
fi

if [ "$2" = 'passport' ] || [ "$2" = 'all' ] || [ "$2" = '' ]
then
	BUILD_PASSPORT=1
else
	BUILD_PASSPORT=0
fi

if [ "$2" = 'standalone' ] || [ "$2" = 'all' ] || [ "$2" = '' ]
then
	BUILD_STANDALONE=1
else
	BUILD_STANDALONE=0
fi

if [ "$3" = 'client' ] || [ "$3" = 'all' ] || [ "$3" = '' ]
then
	BUILD_CLIENT=1
else
	BUILD_CLIENT=0
fi

if [ "$3" = 'server' ] || [ "$3" = 'all' ] || [ "$3" = '' ]
then
	BUILD_SERVER=1
else
	BUILD_SERVER=0
fi

if [ "$4" = 'test' ] || [ "$5" = 'test' ] || [ "$6" = 'test' ]
then
	BUILD_PASSPORT_TEST_CODE=1
else
	BUILD_PASSPORT_TEST_CODE=0
fi

if [ "$4" = 'debug' ] || [ "$5" = 'debug' ] || [ "$6" = 'debug' ]
then
	DEBUG=1
else
	DEBUG=0
fi

if [ "$4" = 'noextra' ] || [ "$5" = 'noextra' ] || [ "$6" = 'noextra' ]
then
	USE_CURSES=0
	USE_VOIP=0
else
	USE_CURSES=1
	USE_VOIP=1
fi


# ----------------------------------------------
# NAME
# ----------------------------------------------

if [ "$2" = 'passport' ] || [ "$2" = 'all' ] || [ "$2" = '' ]
then
	if [ "$2" = 'standalone' ] || [ "$2" = 'all' ] || [ "$2" = '' ]
	then
		BUILD_VERSION=$Q3_VERSION"_UrT."$URT_VERSION"_pp."$PASSPORT_VERSION
	else
		BUILD_VERSION=$Q3_VERSION"_pp."$PASSPORT_VERSION
	fi
else
	if [ "$2" = 'standalone' ] || [ "$2" = 'all' ] || [ "$2" = '' ]
	then
		BUILD_VERSION=$Q3_VERSION"_UrT."$URT_VERSION
	else
		BUILD_VERSION=$Q3_VERSION
	fi
fi

if [ $BUILD_PASSPORT -eq 1 ]; then 
	if [ $BUILD_STANDALONE -eq 1 ]; then 
		BUILD_DED_NAME="ioUrTded" 	
		BUILD_NAME="ioUrbanTerror" 	
		BUILD_PKGINFO="APPLIOURT"
		BUILD_ICNS="misc/iourbanterror.icns" 
	else
		BUILD_DED_NAME="ioq3[pp]ded"
		BUILD_NAME="ioquake3[pp]"
		BUILD_PKGINFO="APPLIOPP"
		BUILD_ICNS="misc/ioquake3[pp].icns"
	fi
	export BUILD_PASSPORT=$BUILD_PASSPORT
else
	if [ $BUILD_STANDALONE -eq 1 ]; then 
		BUILD_DED_NAME="ioUrTded"
		BUILD_NAME="ioUrbanTerror"
		BUILD_PKGINFO="APPLIOURT"
		BUILD_ICNS="misc/iourbanterror.icns"
	else
		BUILD_DED_NAME="ioq3ded"
		BUILD_NAME="ioquake3"
		BUILD_PKGINFO="APPLIOQ3"
		BUILD_ICNS="misc/quake3.icns"
	fi
fi

echo "----------------------------------------------"
echo " IO MAKE"
echo "----------------------------------------------"
echo " PLATFORM:      $1" 
echo " VERSION:       $BUILD_VERSION" 
if [ $BUILD_CLIENT -eq 1 ]; then
echo " BUILD CLIENT:  $BUILD_NAME"
fi
if [ $BUILD_SERVER -eq 1 ]; then
echo " BUILD SERVER:  $BUILD_DED_NAME"
fi
if [ $DEBUG -eq 1 ]; then
echo " BUILD DEBUG:   yes"
fi
echo "----------------------------------------------"

#exit 0

# ----------------------------------------------
# export
# ----------------------------------------------


export USE_SVN=0

export USE_CURSES=$USE_CURSES
export USE_VOIP=$USE_VOIP

export BUILD_VERSION=$BUILD_VERSION

export BUILD_CLIENT_TTY=0

export BUILD_PASSPORT=$BUILD_PASSPORT
export BUILD_PASSPORT_TEST_CODE=$BUILD_PASSPORT_TEST_CODE
export BUILD_STANDALONE=$BUILD_STANDALONE

export BUILD_DED_NAME=$BUILD_DED_NAME
export BUILD_NAME=$BUILD_NAME

export BUILD_SERVER=$BUILD_SERVER
export BUILD_CLIENT=$BUILD_CLIENT

# ----------------------------------------------
# WINDOWS
# ----------------------------------------------

if [ "$1" = 'windows' ] 
then
	export USE_CURSES=0
	export USE_FREETYPE=0
	
	export BUILD_CLIENT_SMP=1
	export BUILD_GAME_QVM=0
	export BUILD_MISSIONPACK=0
	export BUILD_GAME_SO=0
	#export CC=i586-mingw32msvc-gcc
	#export WINDRES=i586-mingw32msvc-windres
	export PLATFORM=mingw32

	if [ -d build/release-mingw32-x86 ]; then
		rm -r build/release-mingw32-x86
	fi
	if [ $DEBUG -eq 0 ]
	then
		exec make
	else
		exec make debug
	fi
fi

# ----------------------------------------------
# LINUX
# ----------------------------------------------

if [ "$1" = 'linux' ] 
then
	export BUILD_CLIENT_SMP=1
	export BUILD_GAME_QVM=0
	export BUILD_MISSIONPACK=0
	export BUILD_GAME_SO=0

	if [ -d build/release-linux-x86 ]; then
		rm -r build/release-linux-x86
	fi
	if [ $DEBUG -eq 0 ]
	then
		exec make -j5
	else
		exec make  -j5 debug
	fi
fi

# ----------------------------------------------
# MAC
# ----------------------------------------------


if [ "$1" = 'mac' ] || [ "$1" = 'mac6' ] || [ "$1" = 'mac5' ] || [ "$1" = 'mac4' ] || [ "$1" = 'mac3' ] || [ "$1" = 'mac2' ]
then

USE_CURSES=0

BUILD_CLIENT_SMP=0

export BUILD_GAME_QVM=1
export BUILD_MISSIONPACK=1
export BUILD_GAME_SO=1

if [ $BUILD_CLIENT_SMP -eq 0 ]
then
	BUILD_SMP=""
	export BUILD_CLIENT_SMP=1
else
	BUILD_SMP="-smp"
fi

APPBUNDLE=$BUILD_NAME.app
BINARY=$BUILD_NAME.ub
DEDBIN=$BUILD_DED_NAME.ub
PKGINFO=$BUILD_PKGINFO
ICNS=$BUILD_ICNS
DESTDIR=build/release-darwin-ub$ADD
BASEDIR=baseq3
MPACKDIR=missionpack

BIN_OBJ="
	build/release-darwin-ppc$ADD/$BUILD_NAME$BUILD_SMP.ppc
	build/release-darwin-x86$ADD/$BUILD_NAME$BUILD_SMP.x86
"
BIN_DEDOBJ="
	build/release-darwin-ub$ADD/$BUILD_DED_NAME.ppc
	build/release-darwin-x86$ADD/$BUILD_DED_NAME.x86
"
BASE_OBJ="
	build/release-darwin-ppc$ADD/$BASEDIR/cgameppc.dylib
	build/release-darwin-x86$ADD/$BASEDIR/cgamex86.dylib
	build/release-darwin-ppc$ADD/$BASEDIR/uippc.dylib
	build/release-darwin-x86$ADD/$BASEDIR/uix86.dylib
	build/release-darwin-ppc$ADD/$BASEDIR/qagameppc.dylib
	build/release-darwin-x86$ADD/$BASEDIR/qagamex86.dylib
"
MPACK_OBJ="
	build/release-darwin-ppc$ADD/$MPACKDIR/cgameppc.dylib
	build/release-darwin-x86$ADD/$MPACKDIR/cgamex86.dylib
	build/release-darwin-ppc$ADD/$MPACKDIR/uippc.dylib
	build/release-darwin-x86$ADD/$MPACKDIR/uix86.dylib
	build/release-darwin-ppc$ADD/$MPACKDIR/qagameppc.dylib
	build/release-darwin-x86$ADD/$MPACKDIR/qagamex86.dylib
"

# We only care if we're >= 10.4, not if we're specifically Tiger.
# "8" is the Darwin major kernel version.
#TIGERHOST=`uname -r | grep ^8.`
TIGERHOST=`uname -r |perl -w -p -e 's/\A(\d+)\..*\Z/$1/; $_ = (($_ >= 8) ? "1" : "0");'`


unset PPC_CLIENT_SDK
PPC_CLIENT_CC=gcc
unset PPC_CLIENT_CFLAGS
unset PPC_CLIENT_LDFLAGS
unset PPC_SERVER_SDK
unset PPC_SERVER_CFLAGS
unset PPC_SERVER_LDFLAGS
unset X86_SDK
unset X86_CFLAGS
unset X86_LDFLAGS

# we want to use the oldest available SDK for max compatiblity

if [ -d /Developer/SDKs/MacOSX10.6.sdk ]; then
	if [ "$1" = 'mac' ] || [ "$1" = 'mac6' ]; then
		PPC_CLIENT_SDK=/Developer/SDKs/MacOSX10.6.sdk
		PPC_CLIENT_CC=gcc-4.2
		PPC_CLIENT_CFLAGS="-arch ppc -isysroot /Developer/SDKs/MacOSX10.6.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1050"
		PPC_CLIENT_LDFLAGS="-arch ppc \
				-isysroot /Developer/SDKs/MacOSX10.6.sdk \
				-mmacosx-version-min=10.6"
		PPC_SERVER_SDK=/Developer/SDKs/MacOSX10.6.sdk
		PPC_SERVER_CFLAGS=$PPC_CLIENT_CFLAGS
		PPC_SERVER_LDFLAGS=$PPC_CLIENT_LDFLAGS
	
		X86_SDK=/Developer/SDKs/MacOSX10.6.sdk
		X86_CFLAGS="-arch i386 -isysroot /Developer/SDKs/MacOSX10.6.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1050"
		X86_LDFLAGS="-arch i386 \
				-isysroot /Developer/SDKs/MacOSX10.6.sdk \
				-mmacosx-version-min=10.6"
		X86_ENV="CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS"
	fi
fi

if [ -d /Developer/SDKs/MacOSX10.5.sdk ]; then
	if [ "$1" = 'mac' ] || [ "$1" = 'mac5' ]; then
		PPC_CLIENT_SDK=/Developer/SDKs/MacOSX10.5.sdk
		PPC_CLIENT_CC=gcc-4.0
		PPC_CLIENT_CFLAGS="-arch ppc -isysroot /Developer/SDKs/MacOSX10.5.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1050"
		PPC_CLIENT_LDFLAGS="-arch ppc \
				-isysroot /Developer/SDKs/MacOSX10.5.sdk \
				-mmacosx-version-min=10.5"
		PPC_SERVER_SDK=/Developer/SDKs/MacOSX10.5.sdk
		PPC_SERVER_CFLAGS=$PPC_CLIENT_CFLAGS
		PPC_SERVER_LDFLAGS=$PPC_CLIENT_LDFLAGS
	
		X86_SDK=/Developer/SDKs/MacOSX10.5.sdk
		X86_CFLAGS="-arch i386 -isysroot /Developer/SDKs/MacOSX10.5.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1050"
		X86_LDFLAGS="-arch i386 \
				-isysroot /Developer/SDKs/MacOSX10.5.sdk \
				-mmacosx-version-min=10.5"
		X86_ENV="CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS"
	fi
fi

if [ -d /Developer/SDKs/MacOSX10.4u.sdk ]; then
	if [ "$1" = 'mac' ] || [ "$1" = 'mac4' ]; then
		export CC="gcc-4.0" 
		export CXX="g++-4.0" 
		PPC_CLIENT_SDK=/Developer/SDKs/MacOSX10.4u.sdk
		PPC_CLIENT_CC=gcc-4.0
		PPC_CLIENT_CFLAGS="-arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1040"
		PPC_CLIENT_LDFLAGS="-arch ppc \
				-isysroot /Developer/SDKs/MacOSX10.4u.sdk \
				-mmacosx-version-min=10.4"
		PPC_SERVER_SDK=/Developer/SDKs/MacOSX10.4u.sdk
		PPC_SERVER_CFLAGS=$PPC_CLIENT_CFLAGS
		PPC_SERVER_LDFLAGS=$PPC_CLIENT_LDFLAGS
	
		X86_SDK=/Developer/SDKs/MacOSX10.4u.sdk
		X86_CFLAGS="-arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1040"
		X86_LDFLAGS="-arch i386 \
				-isysroot /Developer/SDKs/MacOSX10.4u.sdk \
				-mmacosx-version-min=10.4"
		X86_ENV="CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS"
	fi
fi
	
if [ -d /Developer/SDKs/MacOSX10.3.9.sdk ] && [ $TIGERHOST ]; then
	if [ "$1" = 'mac' ] || [ "$1" = 'mac3' ]; then
		PPC_CLIENT_SDK=/Developer/SDKs/MacOSX10.3.9.sdk
		PPC_CLIENT_CC=gcc-4.0
		PPC_CLIENT_CFLAGS="-arch ppc -isysroot /Developer/SDKs/MacOSX10.3.9.sdk \
				-DMAC_OS_X_VERSION_MIN_REQUIRED=1030"
		PPC_CLIENT_LDFLAGS="-arch ppc \
				-isysroot /Developer/SDKs/MacOSX10.3.9.sdk \
				-mmacosx-version-min=10.3"
		PPC_SERVER_SDK=/Developer/SDKs/MacOSX10.3.9.sdk
		PPC_SERVER_CFLAGS=$PPC_CLIENT_CFLAGS
		PPC_SERVER_LDFLAGS=$PPC_CLIENT_LDFLAGS
	fi
fi
	
if [ -d /Developer/SDKs/MacOSX10.2.8.sdk ] && [ -x /usr/bin/gcc-3.3 ] && [ $TIGERHOST ]; then
	if [ "$1" = 'mac' ] || [ "$1" = 'mac2' ]; then
		PPC_CLIENT_SDK=/Developer/SDKs/MacOSX10.2.8.sdk
		PPC_CLIENT_CC=gcc-3.3
		PPC_CLIENT_CFLAGS="-arch ppc \
			-nostdinc \
			-F/Developer/SDKs/MacOSX10.2.8.sdk/System/Library/Frameworks \
			-I/Developer/SDKs/MacOSX10.2.8.sdk/usr/include/gcc/darwin/3.3 \
			-isystem /Developer/SDKs/MacOSX10.2.8.sdk/usr/include \
			-DMAC_OS_X_VERSION_MIN_REQUIRED=1020"
		PPC_CLIENT_LDFLAGS="-arch ppc \
			-L/Developer/SDKs/MacOSX10.2.8.sdk/usr/lib/gcc/darwin/3.3 \
			-F/Developer/SDKs/MacOSX10.2.8.sdk/System/Library/Frameworks \
			-Wl,-syslibroot,/Developer/SDKs/MacOSX10.2.8.sdk,-m"
	fi
fi
	
if [ -z $PPC_CLIENT_SDK ] || [ -z $PPC_SERVER_SDK ] || [ -z $X86_SDK ]; then
	echo "\
ERROR: This script is for building a Universal Binary.  You cannot build
	   for a different architecture unless you have the proper Mac OS X SDKs
	   installed.  If you just want to to compile for your own system run
	   'make' instead of this script."
	exit 1
fi

echo "Building PPC Dedicated Server against \"$PPC_SERVER_SDK\""
echo "Building PPC Client against \"$PPC_CLIENT_SDK\""
echo "Building X86 Client/Dedicated Server against \"$X86_SDK\""
if [ "$PPC_CLIENT_SDK" != "/Developer/SDKs/MacOSX10.2.8.sdk" ] || \
	[ "$PPC_SERVER_SDK" != "/Developer/SDKs/MacOSX10.3.9.sdk" ] || \
	[ "$X86_SDK" != "/Developer/SDKs/MacOSX10.4u.sdk" ]; then
	echo "\
WARNING: in order to build a binary with maximum compatibility you must
		 build on Mac OS X 10.4 using Xcode 2.3 or 2.5 and have the
		 MacOSX10.2.8, MacOSX10.3.9, and MacOSX10.4u SDKs installed
		 from the Xcode install disk Packages folder."
fi
sleep 3

if [ ! -d $DESTDIR ]; then
	mkdir -p $DESTDIR
fi
	
# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

if [ $BUILD_CLIENT -eq 1 ]
then
	
	#BUILD ALL
	
	# ppc dedicated server
	echo "Building Dedicated Server using $PPC_SERVER_SDK"
	sleep 2
	if [ -d build/release-darwin-ppc$ADD ]; then
		rm -r build/release-darwin-ppc$ADD
	fi
	(USE_VOIP=$USE_VOIP BUILD_DED_NAME=$BUILD_DED_NAME BUILD_PASSPORT=$BUILD_PASSPORT BUILD_STANDALONE=$BUILD_STANDALONE ARCH=ppc BUILD_CLIENT_SMP=0 BUILD_CLIENT=0 BUILD_GAME_VM=0 BUILD_GAME_SO=0 \
		CFLAGS=$PPC_SERVER_CFLAGS LDFLAGS=$PPC_SERVER_LDFLAGS make -j$NCPU) || exit 1;
	
	cp build/release-darwin-ppc$ADD/$BUILD_DED_NAME.ppc $DESTDIR
	
	# ppc client
	if [ -d build/release-darwin-ppc$ADD ]; then
		rm -r build/release-darwin-ppc$ADD
	fi
	(USE_VOIP=$USE_VOIP BUILD_DED_NAME=$BUILD_DED_NAME BUILD_PASSPORT=$BUILD_PASSPORT BUILD_STANDALONE=$BUILD_STANDALONE ARCH=ppc USE_OPENAL_DLOPEN=1 BUILD_SERVER=0 CC=$PPC_CLIENT_CC \
		CFLAGS=$PPC_CLIENT_CFLAGS LDFLAGS=$PPC_CLIENT_LDFLAGS make -j$NCPU) || exit 1;
	
	# intel client and server
	if [ -d build/release-darwin-x86$ADD ]; then
		rm -r build/release-darwin-x86$ADD
	fi
	(USE_VOIP=$USE_VOIP BUILD_DED_NAME=$BUILD_DED_NAME BUILD_PASSPORT=$BUILD_PASSPORT BUILD_STANDALONE=$BUILD_STANDALONE ARCH=x86 CFLAGS=$X86_CFLAGS LDFLAGS=$X86_LDFLAGS make -j$NCPU) || exit 1;
	
	echo "Creating .app bundle $DESTDIR/$APPBUNDLE"
	if [ ! -d $DESTDIR/$APPBUNDLE/Contents/MacOS/$BASEDIR ]; then
		mkdir -p $DESTDIR/$APPBUNDLE/Contents/MacOS/$BASEDIR || exit 1;
	fi
	if [ ! -d $DESTDIR/$APPBUNDLE/Contents/MacOS/$MPACKDIR ]; then
		mkdir -p $DESTDIR/$APPBUNDLE/Contents/MacOS/$MPACKDIR || exit 1;
	fi
	if [ ! -d $DESTDIR/$APPBUNDLE/Contents/Resources ]; then
		mkdir -p $DESTDIR/$APPBUNDLE/Contents/Resources
	fi
	cp $ICNS $DESTDIR/$APPBUNDLE/Contents/Resources/$BUILD_NAME.icns || exit 1;
	echo $PKGINFO > $DESTDIR/$APPBUNDLE/Contents/PkgInfo
	echo "
		<?xml version=\"1.0\" encoding=\"UTF-8\"?>
		<!DOCTYPE plist
			PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\"
			\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
		<plist version=\"1.0\">
		<dict>
			<key>CFBundleDevelopmentRegion</key>
			<string>English</string>
			<key>CFBundleExecutable</key>
			<string>$BINARY</string>
			<key>CFBundleGetInfoString</key>
			<string>$BUILD_NAME $BUILD_VERSION</string>
			<key>CFBundleIconFile</key>
			<string>$BUILD_NAME.icns</string>
			<key>CFBundleIdentifier</key>
			<string>org.ioquake.quake3</string>
			<key>CFBundleInfoDictionaryVersion</key>
			<string>6.0</string>
			<key>CFBundleName</key>
			<string>$BUILD_NAME</string>
			<key>CFBundlePackageType</key>
			<string>APPL</string>
			<key>CFBundleShortVersionString</key>
			<string>$Q3_VERSION</string>
			<key>CFBundleSignature</key>
			<string>$PKGINFO</string>
			<key>CFBundleVersion</key>
			<string>$BUILD_VERSION</string>
			<key>NSExtensions</key>
			<dict/>
			<key>NSPrincipalClass</key>
			<string>NSApplication</string>
		</dict>
		</plist>
		" > $DESTDIR/$APPBUNDLE/Contents/Info.plist
	
	lipo -create -o $DESTDIR/$APPBUNDLE/Contents/MacOS/$BINARY $BIN_OBJ
	lipo -create -o $DESTDIR/$APPBUNDLE/Contents/MacOS/$DEDBIN $BIN_DEDOBJ
	rm $DESTDIR/$BUILD_DED_NAME.ppc
	cp $BASE_OBJ $DESTDIR/$APPBUNDLE/Contents/MacOS/$BASEDIR/
	cp $MPACK_OBJ $DESTDIR/$APPBUNDLE/Contents/MacOS/$MPACKDIR/
	cp code/libs/macosx/*.dylib $DESTDIR/$APPBUNDLE/Contents/MacOS/
	
else
	
	#BUILD SERVER ONLY
	
	# ppc dedicated server
	echo "Building Dedicated Server using $PPC_SERVER_SDK"
	sleep 2
	
	if [ -d build/release-darwin-ppc$ADD ]; then
		rm -r build/release-darwin-ppc$ADD
	fi
	(USE_VOIP=$USE_VOIP BUILD_DED_NAME=$BUILD_DED_NAME BUILD_PASSPORT=$BUILD_PASSPORT BUILD_STANDALONE=$BUILD_STANDALONE ARCH=ppc BUILD_CLIENT_SMP=0 BUILD_CLIENT=0 BUILD_GAME_VM=0 BUILD_GAME_SO=0 \
		CFLAGS=$PPC_SERVER_CFLAGS LDFLAGS=$PPC_SERVER_LDFLAGS make -j$NCPU) || exit 1;
	cp build/release-darwin-ppc$ADD/$BUILD_DED_NAME.ppc $DESTDIR
	
	# intel server
	if [ -d build/release-darwin-x86$ADD ]; then
		rm -r build/release-darwin-x86$ADD
	fi
	(USE_VOIP=$USE_VOIP BUILD_DED_NAME=$BUILD_DED_NAME BUILD_PASSPORT=$BUILD_PASSPORT BUILD_STANDALONE=$BUILD_STANDALONE ARCH=x86 CFLAGS=$X86_CFLAGS BUILD_CLIENT=0 LDFLAGS=$X86_LDFLAGS make -j$NCPU) || exit 1;
fi

fi
