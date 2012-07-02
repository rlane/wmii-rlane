LUAIXP = ext/luaixp
PKGS=lua5.1

CFLAGS = -O2 -ggdb -Wall `pkg-config --cflags $(PKGS)`
LDLIBS = `pkg-config --libs $(PKGS)` -lixp

all: wmiirc

wmiirc: wmiirc.c $(LUAIXP)/lixp_*.c

clean:
	rm -f wmiirc
