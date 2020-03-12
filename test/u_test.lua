#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nb = require('navbar_python')


TestBuffer = {} --class

function TestBuffer:setUp()
    -- set up tests
    self.a = 1
end

function TestBuffer:test1_read()

    assert(self.a == 1)
end

function TestBuffer:test2_read()
    lu.assertEquals(self.a, 1)
end

-- class TestBuffer




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
