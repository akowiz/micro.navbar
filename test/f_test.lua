#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Functional Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nb = require('navbar_python')


TestBuffer = {} --class

function TestBuffer:setUp()
    -- set up tests
    self.a = 1
end

function TestBuffer:test1_read()
    --
    assert(1 == 1)
    lu.assertEquals(1, 1)
end

-- class TestBuffer




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
