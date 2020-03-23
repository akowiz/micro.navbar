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


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
