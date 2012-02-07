LUAIXP = ext/luaixp

CFLAGS = -O2 -ggdb -Wall
LDLIBS = -llua -lixp

all: wmiirc

wmiirc: wmiirc.c $(LUAIXP)/lixp_*.c

clean:
	rm -f wmiirc
