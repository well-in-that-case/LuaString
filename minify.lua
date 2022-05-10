---@diagnostic disable: need-check-nil

--[[
    Uses 'luamin' to minify LuaString with an over 83% compression ratio.
    https://www.npmjs.com/package/luamin
    https://github.com/mathiasbynens/luamin
--]]

local function read(c)
    local handle = io.popen(c)
    local result = handle:read("*a")
    handle:close()
    return result
end

local exists = string.find(read("luamin"), "luamin -f foo.lua", 1, true)
if exists == nil then
    read("npm install -g luamin")
end

io.open("bin/minified_luastring.lua", "w"):write(read("luamin -f src/luastring.lua")):close()