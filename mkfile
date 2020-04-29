</$objtype/mkfile

CFLAGS=$CFLAGS -p -D__plan9__ -DFE_STANDALONE -Isrc
BIN=/$objtype/bin
TARG=fe
OFILES=\
	fe.$O

default:V: all

</sys/src/cmd/mkone

fe.$O: src/fe.c
	$CC $CFLAGS $prereq
