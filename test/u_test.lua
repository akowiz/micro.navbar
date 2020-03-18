#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lgp = require('lang_python')

-------------------------------------------------------------------------------

TestMatchPythonItem = {}    -- class

function TestMatchPythonItem:setUp()
    self.pList = {
        { 'CONST1=12',      lgp.Node('CONST1', lgp.T_CONSTANT, 0) },
        { "CONST2='abc'",   lgp.Node('CONST2', lgp.T_CONSTANT, 0) },
        { " CONST3='abc'",  nil },
        { "CONST4=='abc'",  nil },
        { "CONST5!='abc'",  nil },
        { "CONST6>='abc'",  nil },

        { 'class C1:',      lgp.Node('C1', lgp.T_CLASS, 0) },
        { 'class C2(C1):',  lgp.Node('C2', lgp.T_CLASS, 0) },
        { '  class C3:',    lgp.Node('C3', lgp.T_CLASS, 2) },
        { '    class C4:',  lgp.Node('C4', lgp.T_CLASS, 4) },
        { 'class C5',       nil },
        { 'classC6',        nil },

        { 'def F1():',      lgp.Node('F1', lgp.T_FUNCTION, 0) },
        { '  def F2():',    lgp.Node('F2', lgp.T_FUNCTION, 2) },
        { '    def F3():',  lgp.Node('F3', lgp.T_FUNCTION, 4) },
        { 'def F4:',        nil },
        { 'def F5',         nil },
        { 'defF6',          nil },
    }
end

function TestMatchPythonItem:test_recognize_python()
    for k, v in ipairs(self.pList) do
        local str = v[1]
        local expected = v[2]
        local result = lgp.match_python_item(str)
        lu.assertEquals(result, expected)
    end
end

-- class TestMatchPythonItem

-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests

    self.nList = {
        empty  = lgp.Node(),
        simple = lgp.Node("Simple", lgp.T_CLASS, 4, 42, true),
    }
end

function TestNode:test_default()
    local node = self.nList['empty']

    assert(node.name == '', 'name not empty')
    assert(node.indent == 0, 'indent not 0')
    assert(node.kind == lgp.T_NONE, 'kind not T_NONE')
    assert(node.line == 0, 'line not 0')
    assert(node.closed == false, 'closed not false')
    assert(gen.is_empty(node:get_children()), 'children not empty')
    assert(node.parent == nil, 'parent not nil')
end

function TestNode:test_simple()
    local node = self.nList['simple']

    assert(node.name == 'Simple', 'wrong name')
    assert(node.indent == 4, 'wrong indent')
    assert(node.kind == lgp.T_CLASS, 'wrong kind')
    assert(node.line == 42, 'wrong line')
    assert(node.closed == true, 'wrong closed')
    assert(gen.is_empty(node:get_children()), 'wrong children')
    assert(node.parent == nil, 'wrong parent')
end

-- class TestNode

-------------------------------------------------------------------------------

TestBuffer = {}   -- class

function TestBuffer:setUp()
    -- Set up our tests
    self.bList = {}

    self.bList['classes_only'] = 'class A:\n\n\tclass B_inner:\n\nclass D(A):\n\nclass C(A):\n\nclass L:\n'
    self.bList['functions_only'] = 'def F3(c):\n\ndef F4(d):\n\ndef F1(a):\n\n\tdef F1_inner():\n\ndef F2(b):\n\n'
    self.bList['variables_only'] = 'A = 1\n\n\tA_ignored = 11\n\nD=4\n\nC\t=\t3\n\nB = None\n\n'
    self.bList['root_items'] = 'def F1():\nclass C1():\nV1 = 1\nclass C2():\nV2 = 2\ndef F2():\n'
    self.bList['full'] =
        'VAR1 = 1\nVAR2 = 2\n\n' ..
        'class A:\n\tdef __init__(self):\n\tdef __str__(self):\n\tdef __repr__(self):\n' ..
        'class C:\n\tdef __init__(self):\n\tdef do_something(self):\n' ..
        'VAR3 = 3\nVAR4 = 4\n\n' ..
        'class B(A):\n\tdef __init__(self):\n' ..
        'def F3():\n' ..
        'def F1():\n' ..
        'def F2():\n\tdef F2_inner():\n'
end

function TestBuffer:test_export_python_structure()
    local expected = {}

    expected['classes_only'] = 'v Classes\n  v A\n    . B_inner\n  . C\n  . D\n  . L\n. Functions\n. Variables'
    expected['functions_only'] = '. Classes\nv Functions\n  v F1\n    . F1_inner\n  . F2\n  . F3\n  . F4\n. Variables'
    expected['variables_only'] = '. Classes\n. Functions\nv Variables\n  . A\n  . B\n  . C\n  . D'
    expected['root_items'] = 'v Classes\n  . C1\n  . C2\nv Functions\n  . F1\n  . F2\nv Variables\n  . V1\n  . V2'
    expected['full'] =
        'v Classes\n' ..
        '  v A\n    . __init__\n    . __repr__\n    . __str__\n' ..
        '  v B\n    . __init__\n' ..
        '  v C\n    . __init__\n    . do_something\n' ..
        'v Functions\n' ..
        '  . F1\n' ..
        '  v F2\n    . F2_inner\n' ..
        '  . F3\n' ..
        'v Variables\n' ..
        '  . VAR1\n' ..
        '  . VAR2\n' ..
        '  . VAR3\n' ..
        '  . VAR4'

    for k, v in pairs(expected) do
        local pythonstr = self.bList[k]
        local nvb = lgp.tree_to_navbar(lgp.export_structure_python(pythonstr))
        lu.assertEquals(nvb:tree('bare', 0, true), expected[k])
    end
end


--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
