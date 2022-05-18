# LuaString
An exhaustive extension of string operations for Lua. Designed for maintainability, compatibility, and portability. LuaString is fully compatible with ANSI C, LuaJIT, and Lua 5.1+.

Read the <a href="https://well-in-that-case.github.io/LuaString/">documentation</a> here.<br>
Automatically install this module from <a href="https://luarocks.org/modules/well-in-that-case/luastring">Luarocks</a>:
```
luarocks install --local luastring
```

# Size
At the time of writing, the fully-featued LuaString is less than 6kb after minification.

You can view the minified file <a href="https://github.com/well-in-that-case/LuaString/blob/main/bin/minified_luastring.lua">here</a> or inside the `bin` folder.

# Modular
Penlight requires management of inter-laced dependencies that provide functionality to each small individual extension. LuaString does not, which makes it awfully simple to extract any code you need without the bloat. As usual though, you must follow LuaString's LICENSE (found in the LICENSE file) when using any of LuaString's licensed code.

# Features
LuaString is the most expansive extension for the `string` type so far. It takes what Penlight does, does it better (in my opinion), then builds on top of it. It's all the positives of Penlight with none of the negatives, you can't really go wrong with it. 

# Advantageous Size
LuaString is 70x smaller than Penlight if you use the normal file, and 366x smaller then Penlight if you use the minified file. Penlight compared to LuaString is like the entire Python standard library compared to an `str` instance. This is a prime advantage of LuaString.

# Performance
The performance standard for LuaString is to meet or exceed the runtime performance of Penlight. On average, LuaString seems ~30% faster on all fronts. There will never be official benchmarks posted in this repository, since this would make the module more difficult to maintain, although you're more than welcome to take advantage of the profiling module inside of this directory. Anyway, this performance increase is not due to algorithimic changes. It's simply because LuaString avoids various assertions, assuming the user will follow the documentatiuon. There will be errors for incorrect types, but it'll be from C. This makes LuaString less user-friendly to people very new to coding — that are prone to making simple errors, like passing an incorrect parameter type — but, it will hardly affect the experience of most people.

# Reflection of Motive
Mostly a note to the contributors of Penlight: I download that module at least once a week, I don't have any issues with it. It's naturally limited by size, and I enjoy instilling competition because I believe that's what incentivizes products and modules to improve.