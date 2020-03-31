#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lg  = require('lang')
local lgl = require('supported/lua')


-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests

    self.nList = {
        empty  = lgl.Node(),
        simple = lgl.Node("Simple", lg.T_CLASS, 42),
    }
end

function TestNode:test_default()
    local node = self.nList['empty']

    assert(node.name == '', 'name not empty')
    assert(node.kind == lg.T_NONE, 'kind not T_NONE')
    assert(node.line == -1, 'line not -1')
    assert(gen.is_empty(node:get_children()), 'children not empty')
    assert(node.parent == nil, 'parent not nil')
end

function TestNode:test_simple()
    local node = self.nList['simple']

    assert(node.name == 'Simple', 'wrong name')
    assert(node.kind == lg.T_CLASS, 'wrong kind')
    assert(node.line == 42, 'wrong line')
    assert(gen.is_empty(node:get_children()), 'wrong children')
    assert(node.parent == nil, 'wrong parent')
end

-- class TestNode


-------------------------------------------------------------------------------

TestMatchLuaItem = {}    -- class

function TestMatchLuaItem:setUp()
    self.pList = {
        { 'CONST1=12',              lgl.Node('CONST1', lg.T_VARIABLE) },
        { 'obj.CONST2=12',          lgl.Node('obj.CONST2', lg.T_VARIABLE) },
        { "local CONST3='abc'",     lgl.Node('CONST3', lg.T_VARIABLE) },
        { "local obj.CONST4='abc'", lgl.Node('obj.CONST4', lg.T_VARIABLE) },
        { " CONST5='abc'",          nil }, -- this is valid lua but we will ignore
        { "CONST6=='abc'",          nil },
        { "CONST7!='abc'",          nil },
        { "CONST8>='abc'",          nil },

        { 'function F1()',          lgl.Node('F1', lg.T_FUNCTION) },
        { 'function obj.F2()',      lgl.Node('obj.F2', lg.T_FUNCTION) },
        { 'local function F3()',    lgl.Node('F3', lg.T_FUNCTION) },
        { 'local function obj.F4()',lgl.Node('obj.F4', lg.T_FUNCTION) },
        { 'function F5',            nil }, -- this is valid lua but we will ignore
        { 'functionF6()',           nil },
        { 'function O1.O2:F7()',        lgl.Node('O1.O2:F7', lg.T_FUNCTION) },
        { 'local function O1.O2:F8()',  lgl.Node('O1.O2:F8', lg.T_FUNCTION) },
        { 'function tree.Node:do_some()',  lgl.Node('tree.Node:do_some', lg.T_FUNCTION) },
    }
end

function TestMatchLuaItem:test_recognize_lua()
    for k, v in ipairs(self.pList) do
        local str = v[1]
        local expected = v[2]
        local result = lgl.match_lua_item(str)
        lu.assertEquals(result, expected)
    end
end

-- class TestMatchLuaItem


-------------------------------------------------------------------------------

TestLuaBuffer = {}   -- class

function TestLuaBuffer:setUp()
    -- Set up our tests
    self.bList = {}

    self.bList['functions_only'] = 'function F3(c)\n\nfunction F4(d)\n\nfunction F1(a):\n\n\tfunction F1_inner():\n\nfunction F2(b):\n\n'
    self.bList['variables_only'] = 'A = 1\n\n\tA_ignored = 11\n\nD=4\n\nC\t=\t3\n\nlocal B = None\n\nmod.E = true\n\n'
    self.bList['root_items'] = 'function F1()\nclass C1()\nV1 = 1\nclass C2()\nV2 = 2\nlocal function F2()\n'
    self.bList['full'] =
        'VAR1 = 1\nlocal VAR2 = 2\n\n' ..
        'class A\n\tfunction A:__init__()\n\tfunction A:__str__()\n\tfunction A:__repr__()\n' ..
        'class C\n\tfunction C:__init__()\n\tfunction C:do_something()\n' ..
        'local VAR3 = 3\nVAR4 = 4\n\n' ..
        'class B(A)\n\tfunction B:__init__()\n' ..
        'function F3()\n' ..
        'local function F1()\n' ..
        'local function F2()\n\tlocal function F2_inner()\n'
    self.bList['normal'] =
        'local tree = {}\n' ..
        'local DBG = true\n' ..
        'tree.A = 1\n' ..
        'tree.B = 2\n' ..
        'function tree.Node:__init__()\n' ..
        'function tree.Node:do_some()\n' ..
        'tree.C = 3\n' ..
        ''
end

function TestLuaBuffer:test_export_structure()
    local expected = {}

    expected['functions_only'] = {
        '. Objects',
        '',
        'v Functions',
        '  . F1',
        '  . F1_inner',
        '  . F2',
        '  . F3',
        '  . F4',
        '',
        '. Variables',
        '',
    }
    expected['variables_only'] = {
        'v Objects',
        '  v mod',
        '    . E',
        '',
        '. Functions',
        '',
        'v Variables',
        '  . A',
        '  . B',
        '  . C',
        '  . D',
        '',
    }
    expected['root_items'] = {
        '. Objects',
        '',
        'v Functions',
        '  . F1',
        '  . F2',
        '',
        'v Variables',
        '  . V1',
        '  . V2',
        '',
    }
    expected['full']   = {
        'v Objects',
        '  v A',
        '    . __init__',
        '    . __repr__',
        '    . __str__',
        '  v B',
        '    . __init__',
        '  v C',
        '    . __init__',
        '    . do_something',
        '',
        'v Functions',
        '  . F1',
        '  . F2',
        '  . F3',
        '',
        'v Variables',
        '  . VAR1',
        '  . VAR2',
        '  . VAR3',
        '  . VAR4',
        '',
    }
    expected['normal']  = {
        'v Objects',
        '  v tree',
        '    v Node',
        '      . __init__',
        '      . do_some',
        '    . A',
        '    . B',
        '    . C',
        '',
        '. Functions',
        '',
        'v Variables',
        '  . DBG',
        '',
    }

    for k, v in pairs(expected) do
        local str = self.bList[k]
        local root = lgl.export_structure(str)

        for i, tl in ipairs(root:to_navbar()) do
            lu.assertEquals(tostring(tl), v[i])
        end
    end
end


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
