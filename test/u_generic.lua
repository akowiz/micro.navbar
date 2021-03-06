#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')

-------------------------------------------------------------------------------

TestString = {} -- class

function TestString:setUp()
    self.tList = {
        'start rl fhfkfkfkf',
        'star jgdfkjd start',
        'end jglkdjkdjg',
        'kjflsjmsj end',
        'jflsjf:fkjldkfj',
        'kjflksdjf.sffdk',
        ':.',
        'start:end',
    }
end

function TestString:test_string_starts_with()
    for k, v in ipairs(self.tList) do
        expected = (k == 1) or (k == 8)
        lu.assertEquals(v:starts_with('start'), expected)
    end
end

function TestString:test_string_ends_with()
    for k, v in ipairs(self.tList) do
        expected = (k == 4) or (k == 8)
        lu.assertEquals(v:ends_with('end'), expected)
    end
end

function TestString:test_string_contains_colon()
    for k, v in ipairs(self.tList) do
        expected = (k == 5) or (k == 7) or (k == 8)
        lu.assertEquals(v:contains(':'), expected)
    end
end

function TestString:test_string_contains_dot()
    for k, v in ipairs(self.tList) do
        expected = (k == 6) or (k == 7)
        lu.assertEquals(v:contains('.'), expected)
    end
end



TestSplit = {} -- class

function TestSplit:setUp()
    -- Set up tests
    self.tList = {
        { 'x!yy!zzz!@', '#', nil, {'x!yy!zzz!@'} },
        { 'x!yy!zzz!@', '!', nil, {'x', 'yy', 'zzz', '@'} },
        { 'x!yy!zzz!@', '!', 1,   {'x', 'yy!zzz!@'} },
        { 'x!yy!zzz!@', '!', 2,   {'x', 'yy', 'zzz!@'} },
        { 'x!yy!zzz!@', '!', 3,   {'x', 'yy', 'zzz', '@'} },
    }
end

function TestSplit:test_split_properly()
    for k, test in pairs(self.tList) do
        local input = test[1]
        local sep = test[2]
        local nmax = test[3]
        local expected = test[4]
        local result = input:split(sep, nmax)
        lu.assertEquals(result, expected)
    end
end


TestTableReverse = {} -- class

function TestTableReverse:setUp()
    self.tList = {
        empty =     {},
        numbers =   { 1, 2, 3, 4, 5, 6, 7, 8, 9, },
        strings =   { 'a', 'b', 'c', 'd', 'e', 'f', },
    }
end

function TestTableReverse:test_table_get_reversed()
    for k, tab in pairs(self.tList) do
        list = gen.table_deepcopy(tab)
        gen.table_reverse(list)
        for i, _ in ipairs(list) do
            lu.assertEquals(list[i], tab[#list-i+1])
        end
    end
end

TestIsEmpty = {} -- class

function TestIsEmpty:setUp()
    self.empty = {}
    self.not_empty1 = { name='tom' }
    self.not_empty2 = { [1] = 'toto' }
end

function TestIsEmpty:test_various_tables()
    lu.assertEquals(gen.is_empty(self.empty), true)
    lu.assertEquals(gen.is_empty(self.not_empty1), false)
    lu.assertEquals(gen.is_empty(self.not_empty2), false)
end


TestIsIn = {} -- class

function TestIsIn:setUp()
    self.empty = {}
    self.fruits = {'apple', 'pineapple', 'orange', 'kiwi', 'tomato'}
    self.vegetables = {'bean', 'asparagus', 'potato'}
end

function TestIsIn:test_table_has_value()
    local fruits_ok = {'apple', 'kiwi'}

    for k, v in pairs(fruits_ok) do
        lu.assertEquals(gen.is_in(v, self.empty), false)
        lu.assertEquals(gen.is_in(v, self.fruits), true)
        lu.assertEquals(gen.is_in(v, self.vegetables), false)
    end
end

--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
