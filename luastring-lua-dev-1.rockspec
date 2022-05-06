package = "LuaString"
version = "dev-1"
source = {
   url = "https://github.com/well-in-that-case/LuaString.git"
}
description = {
   summary = "An exhaustive extension of string operations for Lua.",
   homepage = "",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      luastring = "src/luastring.lua"
   }
}
