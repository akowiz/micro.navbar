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
        self.s = 'hop'
        self.t1 = {1,2,3}
        self.t2 = {one=1,two=2,three=3}
        self.t3 = {1,2,three=3}
    end

    function TestBuffer:test1_read()
        assert(1 == 1)
    end

    function TestBuffer:test2_read()
        lu.assertEquals(1, 1)
    end

-- class TestBuffer




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
