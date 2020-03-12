#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Functional Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nbp = require('navbar_python')


-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

-- read a file and returns all the content (to simulatte access to buffer)
local function buffer_from_file(path)
    local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end



TestBuffer = {} --class

function TestBuffer:setUp()
    -- set up tests
    self.a = 1
end

function TestBuffer:test_can_display_buffer_by_lines()
    -- Test that we can access a buffer and display it's content line by line.

    -- Read content from a file and store it in a table like a buffer
    buffer = buffer_from_file('../data/python_file.py')
    assert(#buffer ~= 0)

    -- Split the content of the buffer into lines to be processed later.
    local lines = nbp.split(buffer, "\n")

    -- Rebuild the buffer using the lines
    local rebuild = table.concat(lines, '\n')

    -- Make sure we have not lost anything
    assert(buffer == rebuild)
end

-- class TestBuffer




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
