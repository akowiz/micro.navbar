#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Functional Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nbp = require('navbar_python')


-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

-- Read a file and returns all the content (to simulatte access to buffer)
local function buffer_from_file(path)
    local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end



TestBuffer = {} --class


function TestBuffer:setUp()
    -- Set-up function for our tests.

    -- Read the content of our buffer from a file
    self.buffer = buffer_from_file('../data/python_file.py')
    assert(#self.buffer > 0)
end

function TestBuffer:test_can_display_buffer_by_lines()
    -- Test that we can access a buffer and display it's content line by line.

    -- Split the content of the buffer into lines to be processed later.
    local lines = self.buffer:split("\n")
    assert(lines ~= nil)
--[[
    for n, line in ipairs(lines) do
        print(line)
    end
--]]
    -- Rebuild the buffer using the lines
    local rebuild = table.concat(lines, '\n')

    -- Make sure we have not lost anything
    assert(self.buffer == rebuild)
end

function TestBuffer:test_can_display_python_structure()
    -- Test that we can extract the python structure from a buffer containing python code.
    local structure = self.buffer:export_structure_python()

    assert(structure['classes'] == true)
    assert(structure['functions'] == true)
    assert(structure['constants'] == true)

    assert(structure['classes'] ~= nil)
    assert(structure['functions'] ~= nil)
    assert(structure['constants'] ~= nil)
end

-- class TestBuffer




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
