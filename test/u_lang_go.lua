#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu  = require('luaunit')
local gen = require('generic')
local lg  = require('lang')
local lgg = require('supported/go')


-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests

    self.nList = {
        empty  = lgg.Node(),
        simple = lgg.Node("Simple", lg.T_CLASS, 42),
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

TestMatchGoItem = {}    -- class

function TestMatchGoItem:setUp()
    self.pList = {
        { 'const CONST1 int = 12',      lgg.Node('CONST1', lg.T_CONSTANT) },
        { "const CONST2=\"abc\"",       lgg.Node('CONST2', lg.T_CONSTANT) },
        { " const CONST3='def'",        nil }, -- only match at starts of line
        { "const CONST4 int=='abc'",    nil }, -- invalid go syntax
        { "const CONST5=='abc'",        nil }, -- invalid go syntax
        { "const CONST6>='abc'",        nil }, -- invalid go syntax

        { 'var V1 int = 12',        lgg.Node('V1', lg.T_VARIABLE) },
        { "var V2=\"abc\"",         lgg.Node('V2', lg.T_VARIABLE) },
        { "var V3",                 lgg.Node('V3', lg.T_VARIABLE) },
        { "var V4 int = 42",        lgg.Node('V4', lg.T_VARIABLE) },
        { "var V5\t=\t3",           lgg.Node('V5', lg.T_VARIABLE) },
        { " var V6='def'",          nil }, -- only match at starts of line
        { "var V7=='abc'",          nil }, -- invalid go syntax
        { "var V8>='abc'",          nil }, -- invalid go syntax

        { 'type S1 struct {}',      lgg.Node('S1', lg.T_STRUCTURE) },
        { ' type S2 struct {}',     lgg.Node('S2', lg.T_STRUCTURE) },
        { 'type S3 {}',             nil },
        { 'S4 struct {}',           nil },
        { 'struct S5 type {}',      nil },
        { 'type S6 struct',         lgg.Node('S6', lg.T_STRUCTURE) },
        { 'typeS7struct{}',         nil },

        { 'func F1() type',             lgg.Node('F1', lg.T_FUNCTION) },
        { '  func F2() type:',          nil }, -- only at start of line
        { '    func F3(param) type',    nil }, -- only at start of line
        { 'func F4',                    nil }, -- missing ()
        { 'funcF5()',                   nil },

        { 'func (name obj) M1() type',          lgg.Node('obj.M1', lg.T_FUNCTION) },
        { '  func (name obj) M2() type:',       nil }, -- only at start of line
        { '    func (name obj) M3(param) type', nil }, -- only at start of line
        { 'func(name obj)M4()',                 lgg.Node('obj.M4', lg.T_FUNCTION) },
        { 'func (name obj) M5',                 nil }, -- missing ()
        { 'func(name obj)M6',                   nil }, -- missing ()
    }
end

function TestMatchGoItem:test_recognize_go()
    for k, v in ipairs(self.pList) do
        local str = v[1]
        local expected = v[2]
        local result = lgg.match_go_item(str)
        lu.assertEquals(result, expected)
    end
end

-- class TestMatchGoItem


-------------------------------------------------------------------------------

TestGoBuffer = {}   -- class

function TestGoBuffer:setUp()
    -- Set up our tests
    self.bList = {}

    self.bList['struct_only'] = 'type A struct {}\n\ntype B struct {}:\n\ntype D struct{}\n\ntype E struct{}\n\ntype Z struct{}\n'
    self.bList['functions_only'] = 'func F3(c):\n\nfunc F4(d):\n\nfunc F1(a):\n\n\tfunc F1_inner():\n\nfunc F2(b):\n\n'
    self.bList['variables_only'] = 'var A = 1\n\n\tvar A_ignored = 11\n\nvar D=4\n\nvar C\t=\t3\n\nvar B = None\n\n'
    self.bList['root_items'] = 'func F1()\ntype S1 struct{}\nconst C1 = 1\nvar V1 = 1\ntype S2 struct {}\nvar V2 = 2\nfunc F2()\nconst C2=V2\n'
    self.bList['full'] =
        'var VAR1 = 1\nvar VAR2 = 2\n\n' ..
        'type A struct {}\nfunc (a A)__init__()\nfunc (a A)__str__():\nfunc (a A)__repr__()\n' ..
        'type C struct {}\nfunc (c C)__init__()\nfunc (c C)do_something():\n' ..
        'var VAR3 = 3\nvar VAR4 = 4\n\n' ..
        'type B struct {}\nfunc (b B)__init__():\n' ..
        'func F3()\n' ..
        'func F1()\n' ..
        'func F2()\n\ndef F2_inner():\n'
end

function TestGoBuffer:test_export_structure()
    local expected = {}

    expected['struct_only'] = {
        'v Structures',
        '  . A',
        '  . B',
        '  . D',
        '  . E',
        '  . Z',
        '',
        '. Functions',
        '',
        '. Variables',
        '',
        '. Constants',
        '',
    }
    expected['functions_only'] = {
        '. Structures',
        '',
        'v Functions',
        '  . F1',
        '  . F2',
        '  . F3',
        '  . F4',
        '',
        '. Variables',
        '',
        '. Constants',
        '',
    }
    expected['variables_only'] = {
        '. Structures',
        '',
        '. Functions',
        '',
        'v Variables',
        '  . A',
        '  . B',
        '  . C',
        '  . D',
        '',
        '. Constants',
        '',
    }
    expected['root_items'] = {
        'v Structures',
        '  . S1',
        '  . S2',
        '',
        'v Functions',
        '  . F1',
        '  . F2',
        '',
        'v Variables',
        '  . V1',
        '  . V2',
        '',
        'v Constants',
        '  . C1',
        '  . C2',
        '',
    }
    expected['full']   = {
        'v Structures',
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
        '. Constants',
        '',
    }

    for k, v in pairs(expected) do
        local str = self.bList[k]
        local root = lgg.export_structure(str)

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
