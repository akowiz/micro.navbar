#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')

-------------------------------------------------------------------------------

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
