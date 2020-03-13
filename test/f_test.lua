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

    -- We expect a table in return with data in it
    lu.assertEvalToTrue(structure['classes'])
    lu.assertEvalToTrue(structure['functions'])
    lu.assertEvalToTrue(structure['constants'])

    -- From our test files, there should be at least 1 element in each category.
    lu.assertNotEquals(structure['classes'], {})
    lu.assertNotEquals(structure['functions'], {})
    lu.assertNotEquals(structure['constants'], {})

    -- We expect the items in structure to be nodes
    local class_root_1 = nbp.Node:new("Foo", nbp.T_CLASS, 34, 0, nil)
    local class_root_2 = nbp.Node:new("Bar", nbp.T_CLASS, 44, 0, nil)
    local func_root_1 = nbp.Node:new("combine_data", nbp.T_FUNCTION, 7, 0, nil)
    local func_root_2 = nbp.Node:new("display_something", nbp.T_FUNCTION, 10, 0, nil)
    local const_root_1 = nbp.Node:new("DM_NONE", nbp.T_CONSTANT, 4, 0, nil)
    local const_root_2 = nbp.Node:new("DEF_TITLE", nbp.T_CONSTANT, 5, 0, nil)

    -- We expect the items to be sorted by name
    lu.assertEquals(structure['classes'][1], class_root_2)
    lu.assertEquals(structure['classes'][2], class_root_1)
    lu.assertEquals(structure['functions'][1], func_root_1)
    lu.assertEquals(structure['functions'][2], func_root_2)
    lu.assertEquals(structure['constants'][1], const_root_2)
    lu.assertEquals(structure['constants'][2], const_root_1)
end

-- class TestBuffer


TestNode = {} -- class

function TestNode:setUp()
    -- Set-up function for our tests.

end

function TestNode:test_can_save_node()
    -- Test that we can store a node information into an object.

    local node0 = nbp.Node:new()
    lu.assertEquals(node0.kind, nbp.T_NONE)
    lu.assertEquals(node0.name, '')
    lu.assertEquals(node0.line, 0)
    lu.assertEquals(node0.indent, 0)
    lu.assertEquals(node0.parent, nil)

    local kind = nbp.T_CLASS
    local name = "TestClass"
    local line = 10
    local indent = 4
    local parent = nil

    local node1 = nbp.Node:new(name, kind, line, indent, parent)
    lu.assertEquals(node1.kind, kind)
    lu.assertEquals(node1.name, name)
    lu.assertEquals(node1.line, line)
    lu.assertEquals(node1.indent, indent)
    lu.assertEquals(node1.parent, parent)
end

-- class TestNode




--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
