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
    lu.assertEquals(node:tree2('bare', 0),  '. ')
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree2('bare', 0, true), '')

    -- A root without children returns '. /'
    node = self.nList['root']
    lu.assertEquals(node:tree2('bare', 0), '. ' .. nbp.ROOT)
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree2('bare', 0, true), '')

    -- A single node without children return the name of the node with some
    -- indent.
    node = self.nList['simple']
    lu.assertEquals(node:tree2('bare', 0), '. Simple')
    -- If hide_me is set to true, returns ''
    lu.assertEquals(node:tree2('bare', 0, true), '')

    -- A node with children returns the tree properly indented, the lead
    -- character is 'v' for open node and '>' for closed nodes.
    node = self.nList['child1']
    lu.assertEquals(node:tree2('bare', 0), 'v Children 1 with Children\n  . Children A\n  . Children B')
    -- If hide_me is set to true, returns only the chidren.
    lu.assertEquals(node:tree2('bare', 0, true), '. Children A\n. Children B')

    -- A node with children and some children have children too.
    node = self.nList['with_children']
    treestr1 = 'v With Children\n  v Children 1 with Children\n    . Children A\n    . Children B\n  . Children 2\n  . Children 3'
    lu.assertEquals(node:tree2('bare', 0), treestr1)
    -- If hide_me is set to true, returns only the chidren.
    treestr2 = 'v Children 1 with Children\n  . Children A\n  . Children B\n. Children 2\n. Children 3'
    lu.assertEquals(node:tree2('bare', 0, true), treestr2)

    -- A node with children and some children have children too.
    treestr_ascii = '- With Children\n  - Children 1 with Children\n  | . Children A\n  | L Children B\n  . Children 2\n  L Children 3'
    lu.assertEquals(node:tree2('ascii'), treestr_ascii)

    treestr_box = '└ With Children\n  ├ Children 1 with Children\n  │ ├ Children A\n  │ └ Children B\n  ├ Children 2\n  └ Children 3'
    lu.assertEquals(node:tree2('box'), treestr_box)
end

-- class TestNode

--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
