LUAIXP = ext/luaixp

CFLAGS = -O2 -ggdb -Wall
LDLIBS = -llua -lixp

all: main

main: main.c $(LUAIXP)/lixp_*.c

clean:
	rm -f main
