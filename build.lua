local COMPILER = "mingw32-g++"
local OBJECT_NAME = "profiler"
local HEADER_PATH = [[]]
local LIBRARY_PATH = [[]]

local c1 = [[%s -O2 -c -o %s.o -I"%s" %s.cpp]]
local c2 = [[%s -shared -o %s.dll %s.o "%s" -lm]]

c1 = c1:format(COMPILER, OBJECT_NAME, HEADER_PATH, OBJECT_NAME)
c2 = c2:format(COMPILER, OBJECT_NAME, OBJECT_NAME, LIBRARY_PATH)

os.execute(c1)
os.execute(c2)