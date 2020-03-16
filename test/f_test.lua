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


-------------------------------------------------------------------------------
-- Tests
-------------------------------------------------------------------------------

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
    local root = nbp.export_structure_python(self.buffer)

    -- Sort the children ofroot
    table.sort(root.children)

    local classes = {}
    local functions = {}
    local constants = {}

    for k, v in ipairs(root.children) do
        if v.kind == nbp.T_CLASS then
            classes[#classes+1] = v
        elseif v.kind == nbp.T_FUNCTION then
            functions[#functions+1] = v
        elseif v.kind == nbp.T_CONSTANT then
            constants[#constants+1] = v
        end
    end

    -- We expect a table in return with data in it
    lu.assertEvalToTrue(classes)
    lu.assertEvalToTrue(functions)
    lu.assertEvalToTrue(constants)

    -- From our test files, there should be at least 1 element in each category.
    lu.assertNotEquals(classes, {})
    lu.assertNotEquals(functions, {})
    lu.assertNotEquals(constants, {})

    -- We expect the items in structure to be nodes
    local class_root_1 = nbp.Node:new("Foo", nbp.T_CLASS, 0, 34, nil)
    local class_root_2 = nbp.Node:new("Bar", nbp.T_CLASS, 0, 44, nil)
    local func_root_1 = nbp.Node:new("combine_data", nbp.T_FUNCTION, 0, 7, nil)
    local func_root_2 = nbp.Node:new("display_something", nbp.T_FUNCTION, 0, 10, nil)
    local const_root_1 = nbp.Node:new("DM_NONE", nbp.T_CONSTANT, 0, 4, nil)
    local const_root_2 = nbp.Node:new("DEF_TITLE", nbp.T_CONSTANT, 0, 5, nil)

    -- We expect the items to be sorted by name
    lu.assertEquals(classes[1].name, class_root_2.name)
    lu.assertEquals(classes[2].name, class_root_1.name)
    lu.assertEquals(functions[1].name, func_root_1.name)
    lu.assertEquals(functions[2].name, func_root_2.name)
    lu.assertEquals(constants[1].name, const_root_2.name)
    lu.assertEquals(constants[2].name, const_root_1.name)
end

-- class TestBuffer

-------------------------------------------------------------------------------

TestNode = {} -- class

function TestNode:setUp()
    -- Setup function for our tests.
    self.node0 = nbp.Node:new()
    self.node1 = nbp.Node:new('TestClass', nbp.T_CLASS,     4, 10, true)
    self.node2 = nbp.Node:new('TestFunc',  nbp.T_FUNCTION,  4, 20)
    self.root1 = nbp.Node:new(nbp.ROOT)

    local n1 = nbp.Node:new('TestClass', nbp.T_CLASS,    4, 10)
    local n2 = nbp.Node:new('TestFunc',  nbp.T_FUNCTION, 4)
    self.root2 = nbp.Node:new(nbp.ROOT)
    self.root2:append(n1)
    n1:append(n2)
end

function TestNode:test_can_display_node()
    -- Test that we can display a node and its children into a tree (string).

    -- The root node return '/' because it is a special case.
    lu.assertEquals(self.root1:tree('bare', 0), '. ' .. nbp.ROOT)

    -- A single node without children return the name of the node with some
    -- indent.
    lu.assertEquals(self.node1:tree('bare', 0), '. TestClass')
    lu.assertEquals(self.node2:tree('bare', 0), '. TestFunc')

    -- A node with children returns the tree properly indented, the lead
    -- character is 'v' for open node and '>' for closed nodes.
    lu.assertEquals(self.root2:tree('bare', 0), 'v /\n  v TestClass\n    . TestFunc')
end

-- class TestNode


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
