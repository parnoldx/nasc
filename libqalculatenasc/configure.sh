#! /bin/sh

# local options:  ac_help is the help message that describes them
# and LOCAL_AC_OPTIONS is the script that interprets them.  LOCAL_AC_OPTIONS
# is a script that's processed with eval, so you need to be very careful to
# make certain that what you quote is what you want to quote.

# load in the configuration file
#
ac_help='--enable-amalloc	Enable memory allocation debugging
--with-tabstops=N	Set tabstops to N characters (default is 4)
--with-dl=X		Use Discount, Extra, or Both types of definition list
--with-id-anchor	Use id= anchors for table-of-contents links
--with-github-tags	Allow `_` and `-` in <> tags
--with-fenced-code	Allow fenced code blocks
--enable-all-features	Turn on all stable optional features
--shared		Build shared libraries (default is static)'

LOCAL_AC_OPTIONS='
set=`locals $*`;
if [ "$set" ]; then
    eval $set
    shift 1
else
    ac_error=T;
fi'

locals() {
    K=`echo $1 | $AC_UPPERCASE`
    case "$K" in
    --SHARED)
                echo TRY_SHARED=T
                ;;
    --ENABLE-ALL|--ENABLE-ALL-FEATURES)
		echo WITH_AMALLOC=T
		;;
    --ENABLE-*)	enable=`echo $K | sed -e 's/--ENABLE-//' | tr '-' '_'`
		echo WITH_${enable}=T ;;
    esac
}

TARGET=libqalculatenasc

SCRIPTDIR="$(dirname $0)"
. $SCRIPTDIR/configure.inc

AC_INIT $TARGET

__DL=`echo "$WITH_DL" | $AC_UPPERCASE`

test "$WITH_FENCED_CODE" && AC_DEFINE "WITH_FENCED_CODE" 1
test "$WITH_ID_ANCHOR" && AC_DEFINE 'WITH_ID_ANCHOR' 1
test "$WITH_GITHUB_TAGS" && AC_DEFINE 'WITH_GITHUB_TAGS' 1

AC_PROG_CC

test "$TRY_SHARED" && AC_COMPILER_PIC && AC_CC_SHLIBS

if [ "IS_BROKEN_CC" ]; then
    case "$AC_CC $AC_CFLAGS" in
    *-pedantic*) ;;
    *)  # hack around deficiencies in gcc and clang
	#
	AC_DEFINE 'while(x)' 'while( (x) != 0 )'
	AC_DEFINE 'if(x)' 'if( (x) != 0 )'

	if [ "$IS_CLANG" ]; then
	    AC_CC="$AC_CC -Wno-implicit-int"
	elif [ "$IS_GCC" ]; then
	    AC_CC="$AC_CC -Wno-return-type -Wno-implicit-int"
	fi ;;
    esac
fi

AC_SCALAR_TYPES sub hdr
AC_CHECK_BASENAME

AC_DEFINE 'TABSTOP' $TABSTOP
AC_SUB    'TABSTOP' $TABSTOP



AC_OUTPUT Makefile
