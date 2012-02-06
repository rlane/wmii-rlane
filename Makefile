LUAIXP = ext/luaixp

CFLAGS = -O2 -ggdb
LDLIBS = -llua -lixp

all: main

main: main.c $(LUAIXP)/lixp_*.c
