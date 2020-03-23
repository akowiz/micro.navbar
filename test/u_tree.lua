#!/bin/env lua

--------------------------------------------------------------------------------
-- Main Unit Test Script
--------------------------------------------------------------------------------

package.path = "navbar/?.lua;" .. package.path

local lu   = require('luaunit')
local gen  = require('generic')
local tree = require('tree')

-------------------------------------------------------------------------------

TestNodeSimple = {}   -- class

function TestNodeSimple:setUp()
    -- Set up our tests
    local no_children = tree.NodeSimple("No Children")
    local with_children = tree.NodeSimple("With Children")
    local child1 = tree.NodeSimple("Children 1 with Children")
    local child2 = tree.NodeSimple("Children 2")
    local child3 = tree.NodeSimple("Children 3")
    local childA = tree.NodeSimple("Children A")
    local childB = tree.NodeSimple("Children B")

    local linear0 = tree.NodeSimple('Root')
    local linear1 = tree.NodeSimple('Path1')
    local linear2 = tree.NodeSimple('Path2')
    linear0:append(linear1)
    linear1:append(linear2)

    local simple = tree.NodeSimple("Simple", true)

    with_children:append(child1)
    with_children:append(child2)
    with_children:append(child3)
    child1:append(childA)
    child1:append(childB)

    self.nList = {
        empty =         tree.NodeSimple(),
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

function TestNodeSimple:test_default()
    local node = self.nList['empty']
    assert(node.name == '', 'name not empty')
    assert(gen.is_empty(node:get_children()), 'children not empty')
    assert(node:get_parent() == nil, 'parent not nil')
end

function TestNodeSimple:test_simple()
    local node = self.nList['simple']
    assert(node.name == 'Simple', 'wrong name')
    assert(gen.is_empty(node:get_children()), 'wrong children')
    assert(node:get_parent() == nil, 'wrong parent')
end

function TestNodeSimple:test_append_child()
    local parent = tree.NodeSimple("Parent")
    local children = parent:get_children()
    lu.assertEquals(children, {})

    for i=1,5 do
        local node = tree.NodeSimple("Node"..i)
        parent:append(node)
        lu.assertEquals(#children, i)
        lu.assertEquals(parent, node:get_parent())
        lu.assertEquals(children[#children], node)
    end
end

function TestNodeSimple:test_count_children()
    local no_children = self.nList['no_children']:get_children()
    lu.assertEquals(#no_children, 0)

    local with_children = self.nList['with_children']:get_children()
    lu.assertEquals(#with_children, 3)

    local child1 = self.nList['child1']:get_children()
    lu.assertEquals(#child1, 2)
end

function TestNodeSimple:test_display_tree()
    local node
    local root
    local treestr

    -- An empty node returns '  ' = lead .. repeat*spacing .. space .. name
    -- with lead = ' ', repeat='', name=''
    node = self.nList['empty']
    lu.assertEquals(node:tree('bare', 0),  '. ')
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
    treestr = 'v Root\n  v Path1\n    . Path2'
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

    -- print('\n' .. self.nList['with_children']:tree('box', 0))

end

function TestNodeSimple:test_display_tree_with_closed_items()
    local node
    local root
    local treestr

    node = self.nList['empty']
    lu.assertEquals(node:tree('bare', 0, false), '. ')
    lu.assertEquals(node:tree('bare', 0, false, {''}), '. ') -- no children

    node = self.nList['simple']
    lu.assertEquals(node:tree('bare', 0, false), '. Simple')
    lu.assertEquals(node:tree('bare', 0, false, {'Simple'}), '. Simple') -- no children

    -- node = self.nList['linear']
    -- treestr = 'v Root\n  v Path1\n    . Path2'
    -- lu.assertEquals(node:tree('bare', 0, false), treestr)
    -- treestr = 'v Root\n  > Path1'
    -- lu.assertEquals(node:tree('bare', 0, false, {'Root/Path1'}), treestr)
end

function TestNodeSimple:test_get_abs_label()
    local node
    local expected = {
        empty = '',
        simple = 'Simple',
        no_children = 'No Children',
        with_children = 'With Children',
        linear = 'Root',
        child1 = 'With Children/Children 1 with Children',
        child2 = 'With Children/Children 2',
        child3 = 'With Children/Children 3',
        childA = 'With Children/Children 1 with Children/Children A',
        childB = 'With Children/Children 1 with Children/Children B',
    }
    for k, v in pairs(expected) do
        node = self.nList[k]
        lu.assertEquals(node:get_abs_label(), v)
    end
end

-- class TestNode



--------------------------------------------------------------------------------
-- Running the test
--------------------------------------------------------------------------------

local runner = lu.LuaUnit.new()
-- runner:setOutputType("junit", "junit_xml_file")
os.exit(runner:runSuite())
