local function assert_eq(a, b) assert(a == b, ("%s != %s"):format(a, b)) end
local function it(t, f) print("Performing '" .. t .. "' test."); f() end
local function desc(t, f) print(t); f() end
local L = require("src.luastring")

desc("LuaString Unit Testing\n======================", function ()
    it("isdigit", function ()
        assert_eq(L.isdigit("hello world"), false)
        assert_eq(L.isdigit("helloworld"), false)
        assert_eq(L.isdigit("hello.world"), false)
        assert_eq(L.isdigit("1hello2world3"), false)
        assert_eq(L.isdigit("123"), true)
        assert_eq(L.isdigit("123."), false)
        assert_eq(L.isdigit("23428394023948"), true)
    end)
end)

print("Successfully completed all tests.")