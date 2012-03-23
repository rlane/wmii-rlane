#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <libgen.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int luaopen_ixp (lua_State *L);

lua_State *L, *Lt;
char *home;

int api_spawn(lua_State *L) {
	const char *str = lua_tostring(L, -1);
	if (fork() == 0) {
		setsid();
		chdir(home);
		execl("/bin/sh", "/bin/sh", "-c", str, NULL);
		perror("execl");
		exit(1);
	}
	return 0;
}

int api_action(lua_State *L) {
	const char *str = lua_tostring(L, -1);
	if (fork() == 0) {
		execl(str, str, NULL);
		perror("execl");
		exit(1);
	}
	return 0;
}

void sigchld(int signum) {
	while (waitpid(-1, NULL, WNOHANG) > 0);
}

void sigalrm(int signum) {
	lua_getglobal(Lt, "timer");
	lua_call(Lt, 0, 0);
}

void usage(const char *progname) {
	printf("usage: %s\n", progname);
}

int main(int argc, char **argv) {
	if (argc != 1) {
		usage(argv[0]);
		return 1;
	}

	signal(SIGCHLD, sigchld);
	signal(SIGALRM, sigalrm);

	home = getenv("HOME");
	if (!home) {
		fprintf(stderr, "HOME not set");
		return 1;
	}

	char bin[BUFSIZ];
	if (readlink("/proc/self/exe", bin, sizeof(bin)) < 0) {
		perror("readlink");
		return 1;
	}

	if (chdir(dirname(bin))) {
		perror("chdir");
		return 1;
	}

	const char *wmii_address = getenv("WMII_ADDRESS");
	if (!wmii_address) {
                wmii_address = "unix!/s/wmii";
		fprintf(stderr, "WMII_ADDRESS not set, using %s\n", wmii_address);
	}
	fprintf(stderr, "using WMII_ADDRESS %s\n", wmii_address);

	Lt = luaL_newstate();
	luaL_openlibs(Lt);
	luaopen_ixp(Lt);
	lua_pushstring(Lt, wmii_address);
	lua_setglobal(Lt, "WMII_ADDRESS");

	if (luaL_dofile(Lt, "timer.lua")) {
		fprintf(stderr, "error executing Lua script: %s\n", lua_tostring(L, -1));
		return 1;
	}

	struct itimerval t;
	t.it_interval.tv_sec = 20;
	t.it_interval.tv_usec = 0;
	t.it_value = t.it_interval;
	if (setitimer(ITIMER_REAL, &t, NULL) < 0) {
		perror("setitimer");
		return 1;
	}

	L = luaL_newstate();
	luaL_openlibs(L);
	luaopen_ixp(L);
	lua_pushstring(L, wmii_address);
	lua_setglobal(L, "WMII_ADDRESS");

	lua_pushcfunction(L, api_spawn);
	lua_setglobal(L, "spawn");

	lua_pushcfunction(L, api_action);
	lua_setglobal(L, "action");

	if (luaL_dofile(L, "script.lua")) {
		fprintf(stderr, "error executing Lua script: %s\n", lua_tostring(L, -1));
		return 1;
	}

	return 0;
}
