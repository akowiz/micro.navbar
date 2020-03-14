#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nbp = require('navbar_python')


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
        lu.assertEquals(expected, result)
    end
end
-- class TestSplit


TestNode = {} --  class

function TestNode:setUp()
    -- Set up our tests
    local no_children = nbp.Node:new("No Children")
    local with_children = nbp.Node:new("With Children")
    local child1 = nbp.Node:new("Children 1 with Children")
    local child2 = nbp.Node:new("Children 2")
    local child3 = nbp.Node:new("Children 3")
    local childA = nbp.Node:new("Children A")
    local childB = nbp.Node:new("Children B")

    table.insert(with_children.children, child1)
    table.insert(with_children.children, child2)
    table.insert(with_children.children, child3)
    table.insert(child1.children, childA)
    table.insert(child1.children, childB)

    self.nList = {
        no_children,
        with_children,
        child1,
        child2,
        child3,
        childA,
        childB,
    }
end

function TestNode:test_append_child()
    local parent = nbp.Node:new("Parent")
    local children = parent.children
    lu.assertEquals(children, {})

    for i=1,5 do
        local node = nbp.Node:new("Node"..i)
        parent:append(node)
        lu.assertEquals(#children, i)
        lu.assertEquals(parent, node.parent)
        lu.assertEquals(children[#children], node)
    end
end

function TestNode:test_count_children()
    local no_children = self.nList[1].children
    lu.assertEquals(#no_children, 0)

    local with_children = self.nList[2].children
    lu.assertEquals(#with_children, 3)

    local child1 = self.nList[3].children
    lu.assertEquals(#child1, 2)
end

-- class TestNode



--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
