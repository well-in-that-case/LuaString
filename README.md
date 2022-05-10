# LuaString
An exhaustive extension of string operations for Lua. Designed for maintainability, compatibility, and portability. LuaString is fully compatible with ANSI C, LuaJIT, and Lua 5.1+.

Read the <a href="https://well-in-that-case.github.io/LuaString/">documentation</a> here.

# Size
At the time of writing, the fully-featued LuaString is less than 6kb after minification.

You can view the minified file <a href="https://github.com/well-in-that-case/LuaString/blob/main/bin/minified_luastring.lua">here</a> or inside the `bin` folder.

# Performance
The performance standard for LuaString is to meet or exceed the runtime performance of Penlight. On average, LuaString seems ~30% faster on all fronts. There will be official benchmark specifications once LuaString continues to mature.

# LuaString Vs Penlight
Penlight is over 2 MB of data on disk. As a result, it has very demanding maintainability. It's relatively slow because of the eager usage of function calls and unnecessary auxillary helper functions creating further overhead. The documentation is minimal (to counter the insane maintainability). This is no fault of Penlight, but users shouldn't need to have megabytes of modules lying around when they only need a certain part of it. There is no popular stand-alone string extension, so hopefully LuaString will take this spot.

Penlight also requires the compilation of C libraries. This restricts usage for many constrained environments that cannot package some 140MB+ C/C++ compilers around. Additionally, it also prevents most sandboxed environments from using Penlight. Furthermore, this dependency suffers the massive disadvantage of absolving ANSI C compatibility.

# Reflection of Motive
Mostly a note to the contributors of Penlight: I download that module at least once a week, I don't have any issues with it. It's naturally limited by size, and I enjoy instilling competition because I believe that's what incentivizes products and modules to improve.