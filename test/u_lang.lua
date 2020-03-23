#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lg  = require('lang')


-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests

    self.nList = {
        empty  = lg.Node(),
        simple = lg.Node("Simple", lg.T_CLASS, 42, true),
    }
end

function TestNode:test_default()
    local node = self.nList['empty']

    assert(node.name == '', 'name not empty')
    assert(node.kind == lg.T_NONE, 'kind not T_NONE')
    assert(node.line == -1, 'line not -1')
    assert(node.closed == false, 'closed not false')
    assert(gen.is_empty(node:get_children()), 'children not empty')
    assert(node.parent == nil, 'parent not nil')
end

function TestNode:test_simple()
    local node = self.nList['simple']

    assert(node.name == 'Simple', 'wrong name')
    assert(node.kind == lg.T_CLASS, 'wrong kind')
    assert(node.line == 42, 'wrong line')
    assert(node.closed == true, 'wrong closed')
    assert(gen.is_empty(node:get_children()), 'wrong children')
    assert(node.parent == nil, 'wrong parent')
end

-- class TestNode


-------------------------------------------------------------------------------

TestTreeLine = {} -- class

function TestTreeLine:setUp()
    local rootc = lg.Node('Root C')
    rootc:append(lg.Node('Child A'))

    self.tlList = {
        empty  = lg.TreeLine(),
        simple = lg.TreeLine(lg.Node('Simple')),
        root   = lg.TreeLine(lg.Node('Root'), '', 'root'),
        full   = lg.TreeLine(lg.Node('Full'), '  ', 'nth_key'),
        rootc  = lg.TreeLine(rootc, '', 'root_open'),
    }
end

function TestTreeLine:test_as_str()
    local expected = {
        empty  = '',
        simple = 'Simple',
        root   = '. Root',
        full   = '  . Full',
        rootc  = 'v Root C',
    }
    for k, v in pairs(self.tlList) do
        lu.assertEquals(tostring(v), expected[k])
    end
end

-- class TestListTree


-------------------------------------------------------------------------------

TestListTree = {} -- class

function TestListTree:setUp()
    local no_children = lg.Node("No Children")
    local with_children = lg.Node("With Children")
    local child1 = lg.Node("Children 1 with Children")
    local child2 = lg.Node("Children 2")
    local child3 = lg.Node("Children 3")
    local childA = lg.Node("Children A")
    local childB = lg.Node("Children B")

    local linear0 = lg.Node('/')
    local linear1 = lg.Node('Path1')
    local linear2 = lg.Node('Path2')
    linear0:append(linear1)
    linear1:append(linear2)

    local simple = lg.Node("Simple")

    with_children:append(child1)
    with_children:append(child2)
    with_children:append(child3)
    child1:append(childA)
    child1:append(childB)

    self.nList = {
        empty =         lg.Node(),
        simple =        simple,
        no_children =   no_children,
        with_children = with_children,
        linear =        linear0,
        child1 =        child1,
        child2 =        child2,
        child3 =        child3,
        childA =        childA,
        childB =        childB,
    }
end

function TestListTree:test_tree_to_navbar()
    local tl_list

    expected = {
        empty =         { '. ', },
        simple =        { '. Simple', },
        no_children =   { '. No Children', },
        with_children = {
            'v With Children',
            '  v Children 1 with Children',
            '    . Children A',
            '    . Children B',
            '  . Children 2',
            '  . Children 3',
        },
        linear = {
            'v /',
            '  v Path1',
            '    . Path2',
        },
        child1 = {
            'v Children 1 with Children',
            '  . Children A',
            '  . Children B',
        },
        child2 = { '. Children 2', },
        child3 = { '. Children 3', },
        childA = { '. Children A', },
        childB = { '. Children B', },
    }
    for k, t in pairs(expected) do
        -- print('processing ' .. k)
        tl_list = lg.tree_to_navbar(self.nList[k])
        for i, line in ipairs(tl_list) do
            lu.assertEquals(tostring(tl_list[i]), t[i])
        end
    end
end

-- class TestListTree


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
