#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Functional Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lgp = require('lang_python')

local DEBUG = false

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
    self.buffer = buffer_from_file('data/python_file.py')
    assert(#self.buffer > 0)
end

function TestBuffer:test_can_display_buffer_by_lines()
    -- Test that we can access a buffer and display it's content line by line.

    -- Split the content of the buffer into lines to be processed later.
    local lines = self.buffer:split("\n")
    assert(lines ~= nil)

    -- for n, line in ipairs(lines) do
        -- print(line)
    -- end

    -- Rebuild the buffer using the lines
    local rebuild = table.concat(lines, '\n')

    -- Make sure we have not lost anything
    assert(self.buffer == rebuild)
end

function TestBuffer:test_can_display_python_structure()
    -- Test that we can extract the python structure from a buffer containing python code.
    local root = lgp.export_structure_python(self.buffer)

    -- Sort the children of root
    local children = root:get_children()
    table.sort(children)

    local classes = lgp.Node('Classes')
    local functions = lgp.Node('Functions')
    local variables = lgp.Node('Variables')

    for k, v in ipairs(children) do
        if v.kind == lgp.T_CLASS then
            classes:append(v)
        elseif v.kind == lgp.T_FUNCTION then
            functions:append(v)
        elseif v.kind == lgp.T_CONSTANT then
            variables:append(v)
        end
    end

    -- We expect a table in return with data in it
    lu.assertEvalToTrue(classes)
    lu.assertEvalToTrue(functions)
    lu.assertEvalToTrue(variables)

    -- From our test files, there should be at least 1 element in each category.
    -- lu.assertNotEquals(gen.is_empty(classes.children), false)
    -- lu.assertNotEquals(gen.is_empty(functions.children), false)
    -- lu.assertNotEquals(gen.is_empty(variables.children), false)

    -- We expect the items in structure to be nodes
    local class_root_1 = lgp.Node("Foo", lgp.T_CLASS, 0, 34)
    local class_root_2 = lgp.Node("Bar", lgp.T_CLASS, 0, 44)
    local func_root_1 = lgp.Node("combine_data", lgp.T_FUNCTION, 0, 7)
    local func_root_2 = lgp.Node("display_something", lgp.T_FUNCTION, 0, 10)
    local const_root_1 = lgp.Node("DM_NONE", lgp.T_CONSTANT, 0, 4)
    local const_root_2 = lgp.Node("DEF_TITLE", lgp.T_CONSTANT, 0, 5)

    -- We expect the items to be sorted by name
    local c_children = classes:get_children()
    local f_children = functions:get_children()
    local v_children = variables:get_children()
    lu.assertEquals(c_children[1].name, class_root_2.name)
    lu.assertEquals(c_children[2].name, class_root_1.name)
    lu.assertEquals(f_children[1].name, func_root_1.name)
    lu.assertEquals(f_children[2].name, func_root_2.name)
    lu.assertEquals(v_children[1].name, const_root_2.name)
    lu.assertEquals(v_children[2].name, const_root_1.name)

    if DEBUG then
        print('\n' .. classes:tree('box'))
        print('\n' .. functions:tree('box'))
        print('\n' .. variables:tree('box'))
        print()

        for _, obj in pairs({ classes, functions, variables }) do
            for k, v in ipairs(obj:list()) do
                print(v['node'].line, v['text'])
            end
        end
    end
end

-- class TestBuffer

-------------------------------------------------------------------------------

TestNode = {} -- class

function TestNode:setUp()
    -- Setup function for our tests.
    self.node0 = lgp.Node()
    self.node1 = lgp.Node('TestClass', lgp.T_CLASS,     4, 10, true)
    self.node2 = lgp.Node('TestFunc',  lgp.T_FUNCTION,  4, 20)
    self.root1 = lgp.Node('/')

    local n1 = lgp.Node('TestClass', lgp.T_CLASS,    4, 10)
    local n2 = lgp.Node('TestFunc',  lgp.T_FUNCTION, 4)
    self.root2 = lgp.Node('/')
    self.root2:append(n1)
    n1:append(n2)
end

function TestNode:test_can_display_node()
    -- Test that we can display a node and its children into a tree (string).

    -- The root node return '.. /'
    lu.assertEquals(self.root1:tree('bare', 0), '. ' .. '/')

    -- A single node without children return the name of the node with some
    -- indent.
    lu.assertEquals(self.node1:tree('bare', 0), '. TestClass')
    lu.assertEquals(self.node2:tree('bare', 0), '. TestFunc')

    -- A node with children returns the tree properly indented, the lead
    -- character is 'v' for open node and '>' for closed nodes.
    lu.assertEquals(self.root2:tree('bare', 0), 'v /\n  v TestClass\n    . TestFunc')
end

-- class TestNode
--]]


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit( runner:runSuite() )
