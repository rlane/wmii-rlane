#include <stdio.h>
#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int luaopen_ixp (lua_State *L);

lua_State *L;

void usage(const char *progname) {
	printf("usage: %s script.lua\n", progname);
}

int main(int argc, char **argv) {
	if (argc != 2) {
		usage(argv[0]);
		return 1;
	}

	const char *wmii_address = getenv("WMII_ADDRESS");
	if (!wmii_address) {
		fprintf(stderr, "WMII_ADDRESS must be set.\n");
		return 1;
	}
	fprintf(stderr, "using WMII_ADDRESS %s\n", wmii_address);

	L = luaL_newstate();
	luaL_openlibs(L);
	luaopen_ixp(L);
	lua_pushstring(L, wmii_address);
	lua_setglobal(L, "WMII_ADDRESS");

	if (luaL_dofile(L, argv[1])) {
		fprintf(stderr, "error executing Lua script: %s\n", lua_tostring(L, -1));
		return 1;
	}

	return 0;
}
