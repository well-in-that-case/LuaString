/*
MIT License

Copyright (c) 2022 Ryan Starrett

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
    'profiler.cpp' is a small Lua extension module, tailored to my OS for high-resolution benchmarking.
    All the contents in this file are licensed under the MIT License, found above, or in the LICENSE file.
*/

#include <lua.hpp>
#include <Windows.h>

static int once(lua_State *L) {
    auto n = lua_gettop(L) - 1;
    LARGE_INTEGER freq;
    LARGE_INTEGER start;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&start);
    lua_call(L, n, 0);
    LARGE_INTEGER end;
    QueryPerformanceCounter(&end);
    lua_pushnumber(L, static_cast<double>(end.QuadPart - start.QuadPart) / freq.QuadPart);
    return 1;
}

static const struct luaL_Reg exports[] = {
    {"once", once},
    {NULL, NULL}
};

extern "C" __declspec(dllexport) int luaopen_profiler(lua_State *L) {
    luaL_newlib(L, exports);
    return 1;
}
