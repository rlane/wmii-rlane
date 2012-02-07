#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int luaopen_ixp (lua_State *L);

lua_State *L;

int api_spawn(lua_State *L) {
	const char *str = lua_tostring(L, -1);
	if (fork() == 0) {
		setsid();
		execl("/bin/sh", "/bin/sh", "-c", str, NULL);
		abort();
	}
	return 0;
}

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

	lua_pushcfunction(L, api_spawn);
	lua_setglobal(L, "spawn");

	if (luaL_dofile(L, argv[1])) {
		fprintf(stderr, "error executing Lua script: %s\n", lua_tostring(L, -1));
		return 1;
	}

	return 0;
}
