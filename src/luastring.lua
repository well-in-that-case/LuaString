--[[
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
--]]

--- An extension of string operations for Lua. LuaString is:
-- <ul>
-- <li>Zero-dependency.</li>
-- <li>Permissive (via MIT).</li>
-- <li>A pure Lua implementation.</li>
-- <li>Fully compatible with ANSI C, LuaJIT, and Lua 5.1+.</li>
-- <li>Designed for maintainability, compatibility, and portability.</li>
-- </ul>
-- <br>
-- The fully-featured module is less than 6kb if you vouch for the <a href="https://github.com/well-in-that-case/LuaString/blob/main/bin/minified_luastring.lua">minified file.</a>
-- <h1>License</h1>
-- LuaString is licensed under MIT. <a href="https://github.com/well-in-that-case/LuaString/blob/main/LICENSE">View the terms here.</a>
-- <br><br><i>LuaString is an extension of the <code>string</code> library:</i>
-- @usage
-- local string = require("luastring")
local luastring = {}

local ascii_punctuation = {
    ["!"] = 0, ['"'] = 0, ["#"] = 0,
    ["$"] = 0, ["%"] = 0, ["&"] = 0,
    ["'"] = 0, ["("] = 0, [")"] = 0,
    ["*"] = 0, ["+"] = 0, [","] = 0,
    ["-"] = 0, ["."] = 0, ["/"] = 0,
    [":"] = 0, [";"] = 0, ["<"] = 0,
    ["="] = 0, [">"] = 0, ["?"] = 0,
    ["@"] = 0, ["["] = 0, ["]"] = 0,
    ["^"] = 0, ["_"] = 0, ["`"] = 0,
    ["{"] = 0, ["|"] = 0, ["}"] = 0,
    ["~"] = 0, ["\\"] = 0
}

local ascii_whitespace = {
    ["\f"] = 0,
    ["\r"] = 0, [" "] = 0,
    ["\t"] = 0, ["\v"] = 0,
    ["\n"] = 0, ["\r\n"] = 0,
}

local ascii_hexdigits = {
    ["a"] = 0, ["b"] = 0, ["c"] = 0,
    ["d"] = 0, ["e"] = 0, ["f"] = 0,
    ["A"] = 0, ["B"] = 0, ["C"] = 0,
    ["D"] = 0, ["E"] = 0, ["F"] = 0
}

local ascii_digits = {}
local ascii_octals = {}
local ascii_letters = {}
local ascii_printable = {}
local ascii_lowercase = {}
local ascii_uppercase = {}

-- Seems redundant, but we can avoid creating a new string further below with a little hardcoding.
local luabools = {
    ["true"] = true,
    [" true"] = true,
    ["true "] = true,
    ["false"] = false,
    [" false"] = false,
    ["false "] = false
}

-- Postfixes used to convert strings like "1K" into "1000".
-- Only supports thousands to quintillions until I find a better way to automate it.
local numeric_postfixes = {
    ["k"] = 10^3,
    ["m"] = 10^6,
    ["b"] = 10^9,
    ["t"] = 10^12,
    ["q"] = 10^15,
}

local strrep = string.rep
local strsub = string.sub
local strchr = string.char
local strgsub = string.gsub
local strfind = string.find
local mathciel = math.ceil
local strlower = string.lower
local strupper = string.upper
local tostring = tostring
local strgmatch = string.gmatch
local mathrandom = math.random
local strreverse = string.reverse
local tableconcat = table.concat

-- Extend 'string'
for key, func in pairs(string) do
    luastring[key] = func
end

-- Populate 'ascii_octals'
for i = 0, 7 do
    ascii_octals[i] = 0
    ascii_octals[tostring(i)] = 0
end

-- Populate 'ascii_uppercase'
for i = 65, 90 do
    ascii_uppercase[strchr(i)] = 0
end

-- Populate 'ascii_lowercase'
for i = 97, 122 do
    ascii_lowercase[strchr(i)] = 0
end

-- Populate 'ascii_digits' & partially 'ascii_hexdigits'
for i = 0, 9 do
    local s = tostring(i)
    ascii_digits[i] = 0
    ascii_digits[s] = 0
    ascii_hexdigits[i] = 0
    ascii_hexdigits[s] = 0
end

-- Populate 'ascii_printable' with all the character codes between 26 & 132.
for i = 26, 132 do
    local char = strchr(i)
    ascii_printable[i] = char
    ascii_printable[char] = i
end

--- String Predicates
-- @section predicates

--- Checks if every byte of this string is a valid ASCII digit.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.isdigit("123456789") == true)
-- assert(luastring.isdigit("1234567 9") == false)
-- assert(luastring.isdigit("1234567.9") == false)
-- assert(luastring.isdigit("12345678a") == false)
-- @treturn boolean
function luastring.isdigit(str)
    return strfind(str,'^%d+$') == 1
end

--- Checks if every byte of this string is within the valid ASCII byte range.
-- As such, presense of emojis, invisible characters, and other multi-byte characters will return <code>false</code>.
-- @tparam string str The string to check for ASCII compatibility.
-- @usage
-- assert(luastring.isascii("Hello, World!") == true)
-- assert(luastring.isacsii("Hello, World! 🙂") == false)
-- @treturn boolean
function luastring.isascii(str)
    return strfind(str, "[\128-\255]") == nil
end

--- Checks if every byte of this string is a lowercase alphabetic character.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.islower("helloworld") == true)
-- assert(luastring.islower("hell9world") == false)
-- assert(luastring.islower("hell world") == false)
-- @treturn boolean
function luastring.islower(str)
    return strfind(str, "^%l+$") == 1
end

--- Checks if every byte of this string is an alphabetic character.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.isalpha("abcdefghi") == true)
-- assert(luastring.isalpha("abcdef9hi") == false)
-- assert(luastring.isalpha("abcdef.hi") == false)
-- assert(luastring.isalpha("abcdef hi") == false)
-- @treturn boolean
function luastring.isalpha(str)
    return strfind(str,'^%a+$') == 1
end

--- Checks if every byte of this string is an uppercase alphabetic character.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.isupper("HELLOZWORLD") == true)
-- assert(luastring.isupper("HELLO WORLD") == false)
-- assert(luastring.isupper("HELLO1WORLD") == false)
-- assert(luastring.isupper("HELLOoWORLD") == false)
-- @treturn boolean
function luastring.isupper(str)
    return strfind(str, "^%u+$") == 1
end

--- Checks if every byte of this string is an alphanumeric character.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.isalnum("abcde12345") == true)
-- assert(luastring.isalnum("abcde 2345") == false)
-- assert(luastring.isalnum("abcde.2345") == false)
-- @treturn boolean
function luastring.isalnum(str)
    return strfind(str,'^%w+$') == 1
end

--- Checks if this string is a valid Lua identifier.
-- For example: it does not begin with a number, fully alphanumeric, contains at least one alphabetic character, may contain an underscore.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.isidentifier("Hello, World!") == false)
-- assert(luastring.isidentifier("Hello_World!") == false)
-- assert(luastring.isidentifier("Hello_World") == true)
-- @treturn boolean
function luastring.isidentifier(str)
    if tonumber(strsub(str, 1, 1)) ~= nil then
        return false
    elseif strfind(str, "[^a-zA-Z0-9_]") then
        return false
    else
        return true
    end
end

--- Find the index of the first occurance of <code>substr</code> inside of <code>str</code>.
-- This is syntactic sugar for a plain-text search.
-- It's unwise to use syntactic sugar if you're desperate for performance, as it'll add one function call.
-- @tparam string str The string to search.
-- @tparam string substr The substring to search <code>str</code> for.
function luastring.lfind(str, substr)
    local idx, _ = strfind(str, substr, 1, true)
    if idx then
        return idx - 1
    else
        return nil
    end
end

--- Find the index of the last occurance of <code>substr</code> inside of <code>str</code>.
-- @tparam string str The string to search.
-- @tparam string substr The substring to search <code>str</code> for.
-- @treturn number This will return <code>0</code> if nothing was found, otherwise the starting index of the substring.
-- @usage
-- local str = "hello hello hello hello hello hello"
-- local lastidx = luastring.rfind(str, "hello")
-- assert(lastidx == 31) -- Lua indices advance us by 1.
-- assert(str:sub(lastidx) == "hello")
-- @treturn number
function luastring.rfind(str, substr)
    str = strreverse(str)
    substr = strreverse(substr)
    return #str - (#substr - strfind(str, substr, 1, true))
end

--- Checks if this string is entirely composed of ASCII whitespace characters.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.iswhitespace(" \t \n\r\n\r") == true)
-- assert(luastring.iswhitespace("\t\n\r\nabc/") == false)
-- @treturn boolean
function luastring.iswhitespace(str)
    return strfind(str, "^%s+$") == 1
end

--- Counts how many times <code>substr</code> appears inside <code>str</code>.
-- @tparam string str The string to check.
-- @tparam string substr The substring you're checking for.
-- @usage
-- assert(luastring.count("hello world!", "l") == 3)
-- assert(luastring.count("hello world!", "z") == 0)
-- @treturn number
function luastring.count(str, substr)
    local last, where = strfind(str, substr, 1, true)
    if last == nil then
        return 0
    else
        local result = 0
        while where ~= nil do
            last, where = strfind(str, substr, where + 1, true)
            result = result + 1
        end
        return result
    end
end

--- Checks if this string is <code>nil</code> or an empty string.
-- @tparam string str The string to check.
-- @usage
-- assert(luastring.nil_or_empty("") == true)
-- assert(luastring.nil_or_empty(nil) == true)
-- @treturn boolean This returns <code>true</code> if the string is nil or empty.
function luastring.nil_or_empty(str)
    return str == nil or str == ""
end

--- Checks if this string contains the substring <code>substr</code>.
-- This is roughly syntactic sugar for a plain-text string search.
-- @tparam string str The string to check.
-- @tparam string substr The substring you may or may not expect <code>str</code> to contain.
-- @usage
-- assert(luastring.contains("hello world", "rld") == true)
-- assert(luastring.contains("hello world", "abc") == false)
-- @treturn boolean
function luastring.contains(str, substr)
    return strfind(str, substr, 1, true) ~= nil
end

--- Checks if this string ends with <code>substr</code>.
-- @tparam string str The string to check.
-- @tparam string substr The substring to check the end of <code>str</code> for.
-- @usage
-- assert(luastring.endswith("hello world", "world") == true)
-- assert(luastring.endswith("hello world", "truck") == false)
-- @treturn boolean
function luastring.endswith(str, substr)
    return strsub(str, #str - #substr + 1) == substr
end

--- Checks if this string begins with <code>substr</code>.
-- @tparam string str The string to check.
-- @tparam string substr The substring to check the start of <code>str</code> for.
-- @usage
-- assert(luastring.startswith("hello world", "hello") == true)
-- assert(luastring.startswith("hello world", "truck") == false)
-- @treturn boolean
function luastring.startswith(str, substr)
    return strsub(str, 1, #substr) == substr
end

--- Substring Operations
-- @section substring

--- Creates a table with an element for each character of <code>str</code>.
-- @tparam string str The string to deconstruct.
-- @usage
-- for index, value in ipairs(luastring.sequence("hello")) do
--     print(index, value) -- 1 h ...
-- end
-- @treturn table This table will be empty for empty strings.
function luastring.sequence(str)
    local res = {}
    for i = 1, #str do
        res[i] = strsub(str, i, i)
    end
    return res
end

--- Split a string by each line.
-- @tparam string str The string with the lines to split.
-- @usage
-- local str = [[
--     str1
--     str2
--     str3
-- ]]
-- local lines = luastring.split_lines(str)
-- for index, value in ipairs(lines) do
--     print(("%d: %s"):format(index, value)) -- 1: str1 ...
-- end
-- @treturn table
function luastring.split_lines(str)
    local res = {}
    local len = 0
    for line in strgmatch(str, "[^\n\r\x80-\xFF]+") do
        len = len + 1
        res[len] = line
    end
    return res
end

--- Split a string by a substring.
-- @tparam string str The string to split.
-- @tparam string substr The substring to split the string upon. Any length is valid.
-- @usage
-- assert(luastring.split("hello world", " ") == { "hello", "world" })
-- assert(luastring.split("hello world, goodbye!", ", ") == { "hello world", "goodbye!" })
-- @treturn boolean
function luastring.split(str, substr)
    local result = {}
    local resultSize = 0

    for substr in strgmatch(str, "([^" .. substr .. "]+)") do
        resultSize = resultSize + 1
        result[resultSize] = substr
    end

    return result
end

--- Split a string using a pattern.
-- @tparam string str The string to split.
-- @tparam string pattern The Lua <a href="https://www.lua.org/pil/20.2.html">pattern</a> used for matching.
-- @usage
-- assert(luastring.splitv("hello world", "%S+") == { "hello", "world" })
-- @treturn table This will return an empty table if no matches are made.
function luastring.splitv(str, pattern)
    local res = {}
    local len = 0
    for w in strgmatch(str, pattern) do
        len = len + 1
        res[len] = w
    end
    return res
end

--- Returns one part of the string before the first <code>substr</code> & one after.
-- @tparam string str The string to partition.
-- @tparam string substr The substring to partition the string upon.
-- @usage
-- local before, after = luastring.partition("hello.wor.ld", ".")
-- assert(before == "hello")
-- assert(after == "wor.ld")
--
-- local before, after = luastring.partition("doesn't contain", "!")
-- assert(before == "doesn't contain")
-- assert(after == nil)
-- @treturn string,string|string,nil
function luastring.partition(str, substr)
    local _, where = strfind(str, substr, 1, true)
    if where == nil then
        return str
    else
        return strsub(str, 1, where - 1), strsub(str, where + 1)
    end
end

--- Returns one part of the string before the last <code>substr</code> & one after.
-- @tparam string str The string to partition.
-- @tparam string substr The substring to partition the string upon.
-- @usage
-- local before, after = luastring.rpartition("hello?there?world", "?")
-- assert(before == "hello?there")
-- assert(after == "world")
--
-- local before, after = luastring.rpartition("hello?there?world", ".")
-- assert(before == "hello?there?world")
-- assert(after == nil)
-- @treturn string,string|string,nil
function luastring.rpartition(str, substr)
    local _, where = strfind(strreverse(str), strreverse(substr), 1, true)
    if where == nil then
        return str
    else
        local offset = #str - where
        return strsub(str, 1, offset), strsub(str, offset + 2)
    end
end

--- Position-agnostic, keyword-defined string formatting.
-- Keyword format specifiers are defined with <code>{this syntax}</code>.
-- If you pass a string as the <code>substitutes</code> argument, then it will serve as a cover-all substitute.
-- If a lookup or callback returns <code>nil</code>, then the keyword is left unchanged.
-- @tparam string str The string to format.
-- @tparam table|string|function substitutes Table or callback to recieve each keyword.
-- @usage
-- -- Lookup table example.
-- local str1 = luastring.expand("{t1} {t2}", { t1 = "hello", t2 = "world" })
-- assert(str1 == "hello world")
--
-- -- Callback example.
-- local str2 = luastring.expand("{t1} {t2} {t3}", function (keyword)
--     if keyword == "t1" then
--         return "Keyword1"
--     elseif keyword == "t2" then
--         return "Keyword2"
--     end
-- end)
-- assert(str2 == "Keyword1 Keyword2 {t3}")
--
-- -- String example.
-- local str3 = luastring.expand("{t1} {t2} {t3}", "abc")
-- assert(str3 == "abc abc abc")
function luastring.expand(str, substitutes)
    local res, _ = strgsub(str, "{(.-)}", substitutes)
    return res
end

--- Very similar to <a href="#sequence">sequence</a>, but allows you to specify a range.
-- @tparam string str The string to destruct.
-- @tparam number|nil min The minimum index to begin from. By default, it's 1.
-- @tparam number|nil max The maximum index to include. By default, it's <code>#str</code>.
-- @usage
-- for index, value in ipairs(luastring.subsequence("hello world", 7)) do
--     print(index, value) -- 7 w ...
-- end
-- @treturn table
function luastring.subsequence(str, min, max)
    min = min or 1
    max = max or #str
    local res = {}
    local len = 0
    for i = min, max do
        local char = strsub(str, i, i)
        if char then
            len = len + 1
            res[len] = char
        elseif char == "" then
            break
        end
    end
    return res
end

--- Returns the substring between <code>substr1</code> & <code>substr2</code>.
-- @tparam string str The string to search.
-- @tparam string substr1 The first substring to start with.
-- @tparam string substr2 The last substring to end with.
-- @usage
-- local str = "I want to get the text between START&and&END"
-- assert(luastring.between_substr(str, "START", "END") == "&and&")
-- assert(luastring.between_substr(str, "DONT", "XIST") == nil)
-- @treturn string|nil Returns <code>nil</code> if nothing was found between the substrings.
function luastring.between_substr(str, substr1, substr2)
    local _1, substr1_idx = strfind(str, substr1, 1, true)
    local _2, substr2_idx = strfind(str, substr2, substr1_idx, true)
    if substr1_idx ~= nil and substr2_idx ~= nil then
        return strsub(str, substr1_idx + 1, substr2_idx - #substr2)
    end
end

--- String Parsing
-- @section parsing

--- Creates a new title-case string from <code>str</code>.
-- There's no universal title-case specification, but this will capitalize the first letter of any word that is not: <code>"of", "the", "at"</code>, excluding from the first word.
-- @tparam string str The string to convert.
-- @usage
-- assert(luastring.title("the paranormal of the activity") == "The Paranormal of the Activity")
-- @treturn string
function luastring.title(str)
    local res = {}
    local reslen = 1
    local wordcount = 0

    for word in strgmatch(str, "%S+") do
        wordcount = wordcount + 1
        word = strlower(word)

        if word == "the" and wordcount == 1 then
            res[reslen] = "The "
            reslen = reslen + 1
        elseif word == "at" and wordcount == 1 then
            res[reslen] = "At "
            reslen = reslen + 1
        else
            if word == "of" then
                res[reslen] = "of "
                reslen = reslen + 1
            elseif word == "the" then
                res[reslen] = "the "
                reslen = reslen + 1
            elseif word == "at" then
                res[reslen] = "at "
                reslen = reslen + 1
            else
                res[reslen] = strupper(strsub(word, 1, 1)) .. strsub(word, 2) .. " "
                reslen = reslen + 1
            end
        end
    end

    return tableconcat(res)
end

--- Converts a string to a boolean, if possible.
-- This optionally will parse integers too.
-- @tparam string|number str The string or number to convert.
-- @tparam boolean ints Whether or not to process integral values.
-- @usage
-- assert(luastring.tobool("true") == true)
-- assert(luastring.tobool("0", true) == true)
-- assert(luastring.tobool(1, true) == false)
-- @treturn boolean|nil Returns <code>nil</code> if no conversion could be made.
function luastring.tobool(str, ints)
    local c1 = luabools[str] or luabools[strlower(str)]
    if c1 ~= nil then
        return c1
    elseif ints == true then
        local n = tonumber(str)
        if n == 0 then
            return false
        elseif n == 1 then
            return true
        end
    end
end

--- Compares two strings with agnostic capitalization.
-- @tparam string s1 The first string to compare.
-- @tparam string s2 The second string to compare against <code>s1</code>.
-- @usage
-- assert(luastring.casefold("HELLO", "hello") == true)
-- assert(luastring.casefold("HELLO", "truCk") == false)
-- @treturn boolean
function luastring.casefold(s1, s2)
    return strlower(s1) == strlower(s2)
end

--- Converts <code>"1k"</code> into <code>"1000"</code>.
-- This returns a float by default. It only supports thousands to quintillions ("k" to "q") currently.
-- @tparam string str The numeric string to convert.
-- @tparam boolean floor A boolean specifying whether or not to round-down the result.
-- @usage
-- assert(luastring.postfix("1k") == 1000.0)
-- assert(luastring.postfix("1k", true) == 1000)
-- @treturn number|nil
-- <ul>
-- <li>Returns <code>nil</code> when the conversion fails.</li>
-- <li>The string may not be number-coercible prior to the suffix.</li>
-- </ul>
function luastring.postfix(str, floor)
    local suffix = strlower(strsub(str, -1))
    local beside = strsub(str, 1, #str - 1)
    local numb = tonumber(beside)
    local res = numeric_postfixes[suffix]
    if res == nil or numb == nil then
        return nil
    else
        if floor then
            return math.floor(res * numb)
        else
            return res * numb
        end
    end
end

--- Converts a number like <code>1000</code> into <code>"1,000"</code>.
-- @tparam string|number num The number to format.
-- @usage
-- assert(luastring.format_num(-100000) == "-100,000")
-- assert(luastring.format_num(10000000) == "10,000,000")
-- @treturn string
function luastring.format_num(num)
    -- http://lua-users.org/wiki/FormattingNumbers
    local k
    local formatted = tostring(num)
    while true do
        formatted, k = strgsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

--- String Justification
-- @section justification

--- Inserts <code>char</code> into the start of the string until the length meets <code>len</code>.
-- This doesn't do anything if the <code>len</code> exceeds the length of <code>str</code>.
-- @tparam string str The string to justify.
-- @tparam string character The single-length character to justify <code>str</code> with.
-- @tparam number len This should be set to the integeral length you expect <code>str</code> to be after justification.
-- @usage
-- assert(luastring.ljustify("hello", "*", 10) == "*****hello")
-- assert(luastring.ljustify("hello", "*", 5) == "hello")
-- @treturn string
function luastring.ljustify(str, character, len)
    return strrep(character, len - #str) .. str
end

--- Inserts <code>char</code> into the end of the string until the length meets <code>len</code>.
-- This doesn't do anything if the <code>len</code> exceeds the length of <code>str</code>.
-- @tparam string str The string to justify.
-- @tparam string character The single-length character to justify <code>str</code> with.
-- @tparam number len This should be set to the integeral length you expect <code>str</code> to be after justification.
-- @usage
-- assert(luastring.rjustify("hello", "*", 10) == "hello*****")
-- assert(luastring.rjustify("hello", "*", 5) == "hello")
-- @treturn string
function luastring.rjustify(str, character, len)
    return str .. strrep(character, len - #str)
end

--- Inserts <code>char</code> into the start & end of the string until the length meets <code>len</code>.
-- Since this is two-sided justification, the padding length will always round up.
-- This doesn't do anything if the <code>len</code> exceeds the length of <code>str</code>.
-- @tparam string str The string to justify.
-- @tparam string character The single-length character to justify <code>str</code> with.
-- @tparam number len This should be set to the integeral length you expect <code>str</code> to be after justification.
-- @usage
-- assert(luastring.lrjustify("hello", "*", 10) == "***hello***")
-- assert(luastring.lrjustify("hello", "*", 12) == "****hello****")
-- @treturn string
function luastring.lrjustify(str, character, len)
    local justification = strrep(character, mathciel((len - #str) / 2))
    return justification .. str .. justification
end

--- String Modification
-- @section modification

--- Strips any character from within <code>chars</code> from both sides of the string.
-- This stops once a character not meant to be removed is discovered.
-- @tparam string str The string to strip.
-- @tparam string chars A string of characters to strip from <code>str</code>.
-- @usage
-- assert(luastring.strip("?hello world?", "?") == "hello world")
-- assert(luastring.strip("!?hello world?!", "?!") == "hello world")
-- @treturn string
function luastring.strip(str, chars)
    local _, where = strfind(str, "[^" .. chars .. "+]")
    str = strsub(str, (where or #str))
    local tmp = strreverse(str)
    _, where = strfind(tmp, "[^" .. chars .. "+]")
    if where == nil then
        return str
    else
        return strsub(str, 1, #tmp - where + 1)
    end
end

--- Strips any character from within <code>chars</code> from the left-side of the string.
-- This stops once a character not meant to be removed is discovered.
-- @tparam string str The string to strip.
-- @tparam string chars A string of characters to strip from <code>str</code>.
-- @usage
-- assert(luastring.lstrip("???!!!hello world???!!!", "!?") == "hello world???!!!")
-- assert(luastring.lstrip("???!!!hello world???!!!", "?|") == "!!!hello world???!!!")
-- assert(luastring.lstrip("?b??!!hello world???!!!", "?|") == "b??!!hello world???!!!")
-- @treturn string
function luastring.lstrip(str, chars)
    local _, where = strfind(str, "[^" .. chars .. "+]")
    return strsub(str, (where or #str))
end

--- Strips any character from within <code>chars</code> from the right-side of the string.
-- This stops once a character not meant to be removed is discovered.
-- @tparam string str The string to strip.
-- @tparam string chars A string of characters to strip from <code>str</code>.
-- @usage
-- assert(luastring.rstrip("!!!hello world!!!", "!") == "!!!hello world")
-- assert(luastring.rstrip("???hello world???", ".") == "???hello world???")
-- @treturn string
function luastring.rstrip(str, chars)
    local tmp = strreverse(str)
    local _, where = strfind(tmp, "[^" .. chars .. "+]")
    if where == nil then
        return str
    else
        return strsub(str, 1, #tmp - where + 1)
    end
end

--- Replaces only the first occurance of <code>old</code> with <code>new</code>.
-- @tparam string str The string to partially replace.
-- @tparam string old The old substring you wish to replace.
-- @tparam string new The new substring to replace <code>old</code> with.
-- @usage
-- assert(luastring.replace_first("world world", "world", "hello") == "hello world")
-- assert(luastring.replace_first("world world", "truck", "hello") == "world world")
-- @treturn string The original string is returned if no replacement was made.
function luastring.replace_first(str, old, new)
    local state = 1
    local result, _ = string.gsub(str, old, function (s)
        if state == 1 then
            state = 0
            return new
        else
            return s
        end
    end)
    if result then
        str = result
    end
    return str
end

--- Truncates a string from the left to meet the <code>length</code> specification.
-- Optionally prepending an ellipsis to the truncated string.
-- @tparam string str The string to truncate, if needed.
-- @tparam number length An integral number describing the desired length of <code>str</code>.
-- @tparam boolean|nil ellipsis A boolean specifying whether or not to append an ellipsis to the truncated result.
-- @usage
-- assert(luastring.ltruncate("Hello, World!", 5) == ", World!")
-- assert(luastring.ltruncate("Hello, World!", 5, true) == "..., World!")
-- @treturn string The string remains unchanged if it doesn't exceed <code>length</code>.
function luastring.ltruncate(str, length, ellipsis)
    if #str > length then
        if ellipsis == true then
            return "..." .. strsub(str, length - #str)
        else
            return strsub(str, length - #str)
        end
    else
        return str
    end
end

--- Truncates a string from the right to meet the <code>length</code> specification.
-- Optionally appending an ellipsis to the truncated string.
-- @tparam string str The string to truncate, if needed.
-- @tparam number length An integral number describing the desired length of <code>str</code>.
-- @tparam boolean|nil ellipsis A boolean specifying whether or not to append an ellipsis to the truncated result.
-- @usage
-- assert(luastring.rtruncate("hello world", 5) == "hello")
-- assert(luastring.rtruncate("hello world", 5, true) == "hello...")
-- @treturn string The string remains unchanged if it doesn't exceed <code>length</code>.
function luastring.rtruncate(str, length, ellipsis)
    if #str > length then
        if ellipsis == true then
            return strsub(str, 1, length) .. "..."
        else
            return strsub(str, 1, length)
        end
    else
        return str
    end
end

--- Translates <code>str</code> in accordance with the translation table you create.
-- Translation tables are character maps.
-- This loops over each character and requests your translation table for an alternate representation.
-- @tparam string str The string to translate.
-- @tparam table translation_table The translation table for this string. Example below.
-- @usage
-- local translation_table = {
--     [","] = "Z", ["!"] = "?", ["W"] = "R"
-- }
-- local translated = luastring.translate("Hello, World!", translation_table)
-- assert(translated == "HelloZ Rorld?")
-- @treturn string Returns the original string if no translation was made.
function luastring.translate(str, translation_table)
    local res, _ = strgsub(str, ".", translation_table)
    return res
end

--- Replaces several occurances of <code>old</code> inside <code>str</code> with <code>new</code>.
-- @tparam string str The string to partially replace.
-- @tparam string old The old substring you wish to replace.
-- @tparam string new The new substring to replace <code>old</code> with.
-- @tparam number limit The amount of times to replace <code>old</code>.
-- @usage
-- assert(luastring.replace_many("world world world", "world", "hello", 2) == "hello hello world")
-- assert(luastring.replace_many("world world world", "truck", "hello", 2) == "world world world")
-- @treturn string
function luastring.replace_many(str, old, new, limit)
    local state = 0
    local result, _ = strgsub(str, old, function (s)
        if state < limit then
            state = state + 1
            return new
        else
            return s
        end
    end)
    if result then
        str = result
    end
    return str
end

--- String Generation
-- @section generation

--- Generates a random string from printable ASCII characters.
-- The ASCII printable range can be observed from <a href="#ascii_printable">the 32-126 byte range</a>.
-- @tparam number length The desired length of your randomized string.
-- @tparam table excluded_chars A character map of characters to exclude from the randomized string. Example below.
-- @usage
-- local excluded_chars = {
--     [" "] = 0, -- Exclude spaces.
--     ["'"] = 0, -- Exclude single-width commas.
-- }
-- local randomized = luastring.randomstring(41, excluded_chars)
-- print(randomized) -- *@K@iuX}jN?atGfi|4?};wipr[~o6ORKHdou*OPZ8
-- @treturn string
function luastring.randomstring(length, excluded_chars)
    local res = {}

    if excluded_chars then
        for i = 1, length do
            local char = ascii_printable[mathrandom(32, 126)]
            while excluded_chars[char] ~= nil do
                char = ascii_printable[mathrandom(32, 126)]
            end
            res[i] = char
        end
    else
        for i = 1, length do
            res[i] = ascii_printable[mathrandom(32, 126)]
        end
    end

    return tableconcat(res)
end

--- Iterators
-- @section iterators

--- An iterator for every line inside this string.
-- @tparam string str The string to iterate.
-- @usage
-- local str = "hello\nworld"
-- for word in luastring.lines(str) do
--     print(word)
-- end
-- @treturn function
function luastring.lines(str)
    return strgmatch(str, "[^\n\r]+")
end

--- An iterator for every byte (or in ASCII, character) inside of this string.
-- This function loops backward from the end of the string.
-- @tparam string str The string to loop over.
-- @usage
-- local str = "hello world"
-- for letter in luastring.iter_end(str) do
--     print(letter)
-- end
-- @treturn function
function luastring.iter_end(str)
    local last = #str + 1
    return function ()
        last = last - 1
        local c = strsub(str, last, last)
        if c ~= "" then
            return c
        end
    end
end

--- An iterator for every byte (or in ASCII, character) inside of this string.
-- This function loops forward from the start of the string.
-- @tparam string str The string to loop over.
-- @usage
-- local str = "hello world"
-- for letter in luastring.iter_begin(str) do
--     print(letter)
-- end
-- @treturn function
function luastring.iter_begin(str)
    local last = 0
    return function ()
        last = last + 1
        local c = strsub(str, last, last)
        if c ~= "" then
            return c
        end
    end
end

--- Map a callback to chunks of <code>str</code>.
-- @tparam string str The string to map across.
-- @tparam number size The size of each chunk.
-- @tparam function callback The callback to run with each chunk. It recieves one string argument.
-- @usage
-- local str = "chunk1chunk2chunk3"
-- local chunks = {}
-- luastring.map(str, 6, function (chunk) chunks[#chunks + 1] = chunk end)
-- assert(chunks[1] == "chunk1")
-- assert(chunks[2] == "chunk2")
-- assert(chunks[3] == "chunk3")
-- @treturn nil This function has no return.
function luastring.map(str, size, callback)
    for i = 1, #str, size do
        callback(strsub(str, i, i + size - 1))
    end
end

--- Helper Functions
-- @section helper

--- Copy a 1D table.
-- Largely in case you'd like to slightly modify
-- <code>ascii_punctuation</code> (or another table) for functions such as <code>randomstring</code>.
-- @tparam table t1 The table to copy.
-- @treturn table
function luastring.copy_table(t1)
    local res = {}
    for key, value in pairs(t1) do
        res[key] = value
    end
    return res
end

--- Merges two tables into a new table.
-- Largely useful for character exclusions in the <code>randomstring</code> function.
-- @tparam table t1 The first table to merge.
-- @tparam table t2 The table to merge with <code>t1</code>.
-- @treturn table
function luastring.merge_table(t1, t2)
    local res = {}
    for key, value in pairs(t1) do
        res[key] = value
    end
    for key, value in pairs(t2) do
        res[key] = value
    end
    return res
end

--- Constants
-- @section fields

--- A map of ASCII punctuation characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_punctuation = {
--     [","] = 0, ["?"] = 0, ["."] = 0 ...
-- }
luastring.ascii_punctuation = ascii_punctuation

--- A map of ASCII whitespace characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_whitespace = {
--     ["\n"] = 0, ["\t"] = 0, [" "] = 0 ...
-- }
luastring.ascii_whitespace = ascii_whitespace

--- A map of lowercase characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_lowercase = {
--     ["a"] = 0, ["b"] = 0, ["c"] = 0 ...
-- }
luastring.ascii_lowercase = ascii_lowercase

--- A map of uppercase characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_uppercase = {
--     ["A"] = 0, ["B"] = 0, ["C"] = 0 ...
-- }
luastring.ascii_uppercase = ascii_uppercase

--- A map of printable ASCII characters (32-126 byte range).
-- Organized in the following sense to provide O(1) lookups.
-- This also maps character codes to their character.
-- @usage
-- luastring.ascii_printable = {
--     ["|"] = 0, ["A"] = 0, ["3"] = 0 ...
-- }
luastring.ascii_printable = ascii_printable

--- A map of alphabetic characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_letters = {
--     ["a"] = 0, ["A"] = 0, ["b"] = 0 ...
-- }
luastring.ascii_letters = ascii_letters

--- A map of hexadecimal characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_hexdigits = {
--     ["0"] = 0, ["E"] = 0, ["F"] = 0 ...
-- }
luastring.hexdigits = ascii_hexdigits

--- A map of numeric octal numbers.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_whitespace = {
--     ["6"] = 0, ["7"] = 0, ["8"] = 0 ...
-- }
luastring.octals = ascii_octals

--- A map of numeric characters.
-- Organized in the following sense to provide O(1) lookups.
-- @usage
-- luastring.ascii_digits = {
--     ["1"] = 0, ["2"] = 0, ["3"] = 0 ...
-- }
luastring.digits = ascii_digits

return luastring