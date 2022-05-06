local function assert_eq(a, b) assert(a == b, ("%s != %s"):format(tostring(a), tostring(b))) end
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

    it("isascii", function ()
        assert(L.isascii("hello world") == true)
        assert(L.isascii("hello.world") == true)
        assert(L.isascii("hello1world") == true)
        assert(L.isascii("hello📙world") == false)
    end)

    it("islower", function ()
        assert(L.islower("hello world") == false)
        assert(L.islower("helloworld") == true)
        assert(L.islower("hello1world") == false)
    end)

    it("isalpha", function ()
        assert(L.isalpha("hello world") == false)
        assert(L.isalpha("helloworld") == true)
        assert(L.isalpha("hello1world") == false)
        assert(L.isalpha("hello?world") == false)
    end)

    it("isupper", function ()
        assert(L.isupper("HELLOWORLD") == true)
        assert(L.isupper("HELLO WORLD") == false)
        assert(L.isupper("HELLO?WORLD") == false)
    end)

    it("isalnum", function ()
        assert(L.isalnum("abc123") == true)
        assert(L.isalnum("abc 123") == false)
        assert(L.isalnum("abc?123") == false)
    end)

    it("isidentifier", function ()
        assert(L.isidentifier("hello world") == false)
        assert(L.isidentifier("hello_world") == true)
        assert(L.isidentifier("1hello_world") == false)
        assert(L.isidentifier("_1hello_wor.ld") == false)
        assert(L.isidentifier("_1hello_world_0") == true)
    end)

    it("lfind", function ()
        assert(L.lfind("hello world", "world") == 6)
        assert(L.lfind("hello world", "truck") == nil)
    end)

    it("rfind", function ()
        local s = "hello hello hello hello hello hello"
        local lastidx = L.rfind(s, "hello")
        assert(lastidx == 31)
        assert(s:sub(lastidx) == "hello")
    end)

    it("iswhitespace", function ()
        assert(L.iswhitespace("   \t   \f \n \r\n") == true)
        assert(L.iswhitespace("\t\f   \r\n \r \n \t z") == false)
    end)

    it("count", function ()
        assert(L.count("hello world", "l") == 3)
        assert(L.count("hello world", "truck") == 0)
    end)

    it("nil_or_empty", function ()
        assert(L.nil_or_empty(nil) == true)
        assert(L.nil_or_empty("") == true)
        assert(L.nil_or_empty("a") == false)
    end)

    it("contains", function ()
        assert(L.contains("hello world", "world") == true)
        assert(L.contains("hello world", "z") == false)
    end)

    it("endswith", function ()
        assert(L.endswith("hello world", "rld") == true)
        assert(L.endswith("hello world", "trc") == false)
    end)

    it("startswith", function ()
        assert(L.startswith("hello world", "hello") == true)
        assert(L.startswith("hello world", "truck") == false)
    end)

    it("commaify", function ()
        assert(L.commaify(1000) == "1,000")
        assert(L.commaify(10000) == "10,000")
        assert(L.commaify(100000) == "100,000")
    end)

    it("tobool", function ()
        assert(L.tobool("true") == true)
        assert(L.tobool(" true") == true)
        assert(L.tobool("false") == false)
        assert(L.tobool("0", true) == false)
        assert(L.tobool("1", true) == true)
    end)

    it("strip", function ()
        assert(L.strip("???hello world???", "?") == "hello world")
        assert(L.strip("123hello world123", "123") == "hello world")
    end)

    it("lstrip", function ()
        assert(L.lstrip("???hello world???", "?") == "hello world???")
        assert(L.lstrip("12hello world12", "12") == "hello world12")
    end)

    it("rstrip", function ()
        assert(L.rstrip("???hello world???", "?") == "???hello world")
    end)

    it("splitv", function ()
        local t = L.splitv("hello world, how are you?", "%S+")
        assert(t[1] == "hello")
        assert(t[2] == "world,")
        assert(t[3] == "how")
        assert(t[4] == "are")
        assert(t[5] == "you?")
    end)

    it("split", function ()
        local t = L.split("hello world abc", " ")
        assert(t[1] == "hello")
        assert(t[2] == "world")
        assert(t[3] == "abc")
    end)

    it("partition", function ()
        local before, after = L.partition("hello.wor.ld", ".")
        assert(before == "hello")
        assert(after == "wor.ld")
    end)

    it("rpartition", function ()
        local before, after = L.rpartition("hello.wor.ld", ".")
        assert(before == "hello.wor")
        assert(after == "ld")
    end)

    it("ljustify", function ()
        assert(L.ljustify("hello", "*", 10) == "*****hello")
    end)

    it("rjustify", function ()
        assert(L.rjustify("hello", "*", 10) == "hello*****")
    end)

    it("rtruncate", function ()
        assert(L.rtruncate("hello world", 5) == "hello")
        assert(L.rtruncate("hello world", 5, true) == "hello...")
    end)

    it("ltruncate", function ()
        assert(L.ltruncate("hello world", 6) == "world")
        assert(L.ltruncate("hello world", 6, true) == "...world")
    end)

    it("translate", function ()
        local translation_table = {
            ["!"] = "Z", ["?"] = "R"
        }
        assert(L.translate("Hello? World!", translation_table) == "HelloR WorldZ")
    end)

    it("randomstring", function ()
        assert(#(L.randomstring(41)) == 41)
    end)
end)

print("Successfully completed all tests.")