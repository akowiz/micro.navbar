#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lg  = require('lang')
local lgp = require('lang_python')


-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests

    self.nList = {
        empty  = lgp.Node(),
        simple = lgp.Node("Simple", lg.T_CLASS, 4, 42),
    }
end

function TestNode:test_default()
    local node = self.nList['empty']

    assert(node.name == '', 'name not empty')
    assert(node.indent == 0, 'indent not 0')
    assert(node.kind == lg.T_NONE, 'kind not T_NONE')
    assert(node.line == -1, 'line not -1')
    assert(gen.is_empty(node:get_children()), 'children not empty')
    assert(node.parent == nil, 'parent not nil')
end

function TestNode:test_simple()
    local node = self.nList['simple']

    assert(node.name == 'Simple', 'wrong name')
    assert(node.indent == 4, 'wrong indent')
    assert(node.kind == lg.T_CLASS, 'wrong kind')
    assert(node.line == 42, 'wrong line')
    assert(gen.is_empty(node:get_children()), 'wrong children')
    assert(node.parent == nil, 'wrong parent')
end

-- class TestNode


-------------------------------------------------------------------------------

TestMatchPythonItem = {}    -- class

function TestMatchPythonItem:setUp()
    self.pList = {
        { 'CONST1=12',      lgp.Node('CONST1', lg.T_VARIABLE, 0) },
        { "CONST2='abc'",   lgp.Node('CONST2', lg.T_VARIABLE, 0) },
        { " CONST3='abc'",  nil },
        { "CONST4=='abc'",  nil },
        { "CONST5!='abc'",  nil },
        { "CONST6>='abc'",  nil },

        { 'class C1:',      lgp.Node('C1', lg.T_CLASS, 0) },
        { 'class C2(C1):',  lgp.Node('C2', lg.T_CLASS, 0) },
        { '  class C3:',    lgp.Node('C3', lg.T_CLASS, 2) },
        { '    class C4:',  lgp.Node('C4', lg.T_CLASS, 4) },
        { 'class C5',       nil },
        { 'classC6',        nil },

        { 'def F1():',      lgp.Node('F1', lg.T_FUNCTION, 0) },
        { '  def F2():',    lgp.Node('F2', lg.T_FUNCTION, 2) },
        { '    def F3():',  lgp.Node('F3', lg.T_FUNCTION, 4) },
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

TestPythonBuffer = {}   -- class

function TestPythonBuffer:setUp()
    -- Set up our tests
    self.bList = {}

    self.bList['classes_only'] = 'class A:\n\n\tclass B_inner:\n\nclass D(A):\n\nclass C(A):\n\nclass Z:\n'
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

function TestPythonBuffer:test_export_structure()
    local expected = {}

    expected['classes_only'] = {
        'v Classes',
        '  v A',
        '    . B_inner',
        '  . C',
        '  . D',
        '  . Z',
        '',
        '. Functions',
        '',
        '. Variables',
    }
    expected['functions_only'] = {
        '. Classes',
        '',
        'v Functions',
        '  v F1',
        '    . F1_inner',
        '  . F2',
        '  . F3',
        '  . F4',
        '',
        '. Variables',
    }
    expected['variables_only'] = {
        '. Classes',
        '',
        '. Functions',
        '',
        'v Variables',
        '  . A',
        '  . B',
        '  . C',
        '  . D',
    }
    expected['root_items'] = {
        'v Classes',
        '  . C1',
        '  . C2',
        '',
        'v Functions',
        '  . F1',
        '  . F2',
        '',
        'v Variables',
        '  . V1',
        '  . V2',
    }
    expected['full']   = {
        'v Classes',
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
        '  v F2',
        '    . F2_inner',
        '  . F3',
        '',
        'v Variables',
        '  . VAR1',
        '  . VAR2',
        '  . VAR3',
        '  . VAR4',
    }

    for k, v in pairs(expected) do
        local pythonstr = self.bList[k]
        local tl_list = lgp.tree_to_navbar(lgp.export_structure(pythonstr))

        for i, tl in ipairs(tl_list) do
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
