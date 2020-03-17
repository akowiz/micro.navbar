#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

local lu = require('luaunit')
local nbp = require('navbar_python')


-------------------------------------------------------------------------------

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
        lu.assertEquals(result, expected)
    end
end

-- class TestSplit

-------------------------------------------------------------------------------

TestMatchPythonItem = {}    -- class

function TestMatchPythonItem:setUp()
    self.pList = {
        { 'CONST1=12',      nbp.Node:new('CONST1', nbp.T_CONSTANT, 0) },
        { "CONST2='abc'",   nbp.Node:new('CONST2', nbp.T_CONSTANT, 0) },
        { " CONST3='abc'",  nil },
        { "CONST4=='abc'",  nil },
        { "CONST5!='abc'",  nil },
        { "CONST6>='abc'",  nil },

        { 'class C1:',      nbp.Node:new('C1', nbp.T_CLASS, 0) },
        { 'class C2(C1):',  nbp.Node:new('C2', nbp.T_CLASS, 0) },
        { '  class C3:',    nbp.Node:new('C3', nbp.T_CLASS, 2) },
        { '    class C4:',  nbp.Node:new('C4', nbp.T_CLASS, 4) },
        { 'class C5',       nil },
        { 'classC6',        nil },

        { 'def F1():',      nbp.Node:new('F1', nbp.T_FUNCTION, 0) },
        { '  def F2():',    nbp.Node:new('F2', nbp.T_FUNCTION, 2) },
        { '    def F3():',  nbp.Node:new('F3', nbp.T_FUNCTION, 4) },
        { 'def F4:',        nil },
        { 'def F5',         nil },
        { 'defF6',          nil },
    }
end

function TestMatchPythonItem:test_recognize_python()
    for k, v in ipairs(self.pList) do
        local str = v[1]
        local expected = v[2]
        local result = nbp.match_python_item(str)
        lu.assertEquals(result, expected)
    end
end

-- class TestMatchPythonItem

-------------------------------------------------------------------------------

TestNode = {}   -- class

function TestNode:setUp()
    -- Set up our tests
    local no_children = nbp.Node:new("No Children")
    local with_children = nbp.Node:new("With Children")
    local child1 = nbp.Node:new("Children 1 with Children")
    local child2 = nbp.Node:new("Children 2")
    local child3 = nbp.Node:new("Children 3")
    local childA = nbp.Node:new("Children A")
    local childB = nbp.Node:new("Children B")

    local linear = nbp.Node:new(nbp.ROOT)
    local linear1 = nbp.Node:new('Path1')
    linear:append(linear1)
    local linear2 = nbp.Node:new('Path2')
    linear1:append(linear2)

    with_children:append(child1)
    with_children:append(child2)
    with_children:append(child3)
    child1:append(childA)
    child1:append(childB)

    self.nList = {
        empty =         nbp.Node:new(),
        root =          nbp.Node:new(nbp.ROOT),
        simple =        nbp.Node:new("Simple", nbp.T_CLASS, 4, 42, true),
        no_children =   no_children,
        with_children = with_children,
        linear =        linear,
        child1 =        child1,
        child2 =        child2,
        child3 =        child3,
        childA =        childA,
        childB =        childB,
    }
end

function TestNode:test_default()
    local node = self.nList['empty']
    assert(node.name == '', 'name not empty')
    assert(node.indent == 0, 'indent not 0')
    assert(node.kind == nbp.T_NONE, 'kind not T_NONE')
    assert(node.line == 0, 'line not 0')
    assert(node.closed == false, 'closed not false')
    assert(nbp.isempty(node.children), 'children not empty')
    assert(node.parent == nil, 'parent not nil')
end

function TestNode:test_simple()
    local node = self.nList['simple']
    assert(node.name == 'Simple', 'wrong name')
    assert(node.indent == 4, 'wrong indent')
    assert(node.kind == nbp.T_CLASS, 'wrong kind')
    assert(node.line == 42, 'wrong line')
    assert(node.closed == true, 'wrong closed')
    assert(nbp.isempty(node.children), 'wrong children')
    assert(node.parent == nil, 'wrong parent')
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
    local no_children = self.nList['no_children'].children
    lu.assertEquals(#no_children, 0)

    local with_children = self.nList['with_children'].children
    lu.assertEquals(#with_children, 3)

    local child1 = self.nList['child1'].children
    lu.assertEquals(#child1, 2)
end

function TestNode:test_display_tree()
    local node
    local root
    local treestr

    -- An empty node returns '  ' = lead .. repeat*spacing .. space .. name
    -- with lead = ' ', repeat='', name=''
    node = self.nList['empty']
    lu.assertEquals(node:tree('bare', 0),  '. ')
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree('bare', 0, true), '')

    -- A root without children returns '. /'
    node = self.nList['root']
    lu.assertEquals(node:tree('bare', 0), '. ' .. nbp.ROOT)
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree('bare', 0, true), '')

    -- A single node without children return the name of the node with some
    -- indent.
    node = self.nList['simple']
    lu.assertEquals(node:tree('bare', 0), '. Simple')
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree('bare', 0, true), '')

    -- A node with children returns the tree properly indented, the lead
    -- character is 'v' for open node and '>' for closed nodes.
    node = self.nList['child1']
    lu.assertEquals(node:tree('bare', 0), 'v Children 1 with Children\n  . Children A\n  . Children B')
    -- If hide_me is set to true, returns only the chidren.
    lu.assertEquals(node:tree('bare', 0, true), '. Children A\n. Children B')

    -- A node with a single child, which has a single child
    node = self.nList['linear']
    treestr = 'v /\n  v Path1\n    . Path2'
    lu.assertEquals(node:tree('bare', 0), treestr)

    -- A node with children and some children have children too.
    node = self.nList['with_children']
    treestr = 'v With Children\n  v Children 1 with Children\n    . Children A\n    . Children B\n  . Children 2\n  . Children 3'
    lu.assertEquals(node:tree('bare', 0), treestr)
    -- If hide_me is set to true, returns only the chidren.
    treestr = 'v Children 1 with Children\n  . Children A\n  . Children B\n. Children 2\n. Children 3'
    lu.assertEquals(node:tree('bare', 0, true), treestr)

    -- A node with children and some children have children too.
    treestr = '- With Children\n  - Children 1 with Children\n  | . Children A\n  | L Children B\n  . Children 2\n  L Children 3'
    lu.assertEquals(node:tree('ascii'), treestr)

    treestr = '▾ With Children\n  ├ Children 1 with Children\n  │ ├ Children A\n  │ └ Children B\n  ├ Children 2\n  └ Children 3'
    lu.assertEquals(node:tree('box'), treestr)

    self.nList['with_children'].children[1].closed = true
    treestr = 'v With Children\n  > Children 1 with Children\n  . Children 2\n  . Children 3'
    lu.assertEquals(node:tree('bare', 0), treestr)

    -- print('\n' .. self.nList['with_children']:tree('box', 0))

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
        local nvb = nbp.tree_to_navbar(nbp.export_structure_python(pythonstr))
        lu.assertEquals(nvb:tree('bare', 0, true), expected[k])
    end
end

--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
