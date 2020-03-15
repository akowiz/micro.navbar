#!/bin/env lua

--- @module navbar.navbar_python
local nbp = {}


nbp.T_NONE = 0
nbp.T_CLASS = 1
nbp.T_FUNCTION = 2
nbp.T_CONSTANT = 3

nbp.ROOT = '/'
nbp.STEP = 2

nbp.DEBUG = true


-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

-- Split function with a python semantic
--   see http://lua-users.org/wiki/SplitJoin
function string:split(sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if self:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = self:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = self:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = self:sub(nStart)
   end

   return aRecord
end

function nbp.isempty(table)
    return next(table) == nil
end

function nbp.kind_to_str(kind)
    local ret = 'None'
    if kind == nbp.T_CLASS then
        ret = 'Class'
    elseif kind == nbp.T_FUNCTION then
        ret = 'Function'
    elseif kind == nbp.T_CONSTANT then
        ret = 'Constant'
    end
    return ret
end

function nbp.match_python_item(line)
    local indent = 0
    local name
    local kind
    local ret = nil

    -- match a function
    indent, name = string.match(line, "^(%s*)def%s*([_%a%d]-)%s*%(")
    if name then
        kind = nbp.T_FUNCTION
        indent = indent:len()
        goto mpi_continue
    end

    -- match a class
    indent, name = string.match(line, "^(%s*)class%s*([_%a%d]-)%s*[(:]")
    if name then
        kind = nbp.T_CLASS
        indent = indent:len()
        goto mpi_continue
    end

    -- match a constant
    name = string.match(line, "^([_%a%d]-)%s*=[^=]")
    if name then
        kind = nbp.T_CONSTANT
        goto mpi_continue
    end

    ::mpi_continue::

    if name then
        ret = nbp.Node:new(name, kind, indent)
    end

    return ret
end

-------------------------------------------------------------------------------
-- Data Structures
-------------------------------------------------------------------------------

-- Class Node

nbp.Node = { name='', kind=nbp.T_NONE, line=0, indent=0, closed=false,
             parent=nil, children={} }

function nbp.Node:new(n, k, i, l, c)
    local o = {}
    self.__index = self
    setmetatable(o, nbp.Node)

    o.name = n or nbp.Node.name
    o.kind = k or nbp.Node.kind
    o.indent = i or nbp.Node.indent
    o.line = l or nbp.Node.line
    o.closed = c or nbp.Node.closed
    o.children = {}
    o.parent = nil

    return o
end

function nbp.Node:__lt(node)
    -- allow us to sort the nodes by kind, and then by name
    return (self.kind < node.kind) or ((self.kind == node.kind) and (self.name < node.name))
end

function nbp.Node:__repr()
    -- allow us to display the nodes in a readable way.
    return 'Node(' .. table.concat({self.kind, self.name, self.line, self.indent}, ', ') .. ')'
end

function nbp.Node:__tostring()
    -- method to display the current object as a string
    return self:__repr()
end

function nbp.Node:append(node)
    -- append node as a children of the current object.
    if nbp.DEBUG then
        local kind = nbp.kind_to_str(node.kind)
        print(kind .. ' ' .. tostring(node) .. ' added to ' .. tostring(self))
    end
    node.parent = self
    table.insert(self.children, node)
end

function nbp.tree_style(stylename)
    ret = {}
    if     stylename == 'bare' then
        ret['last_item'] = ' '
        ret['default'] = ' '
        ret['item_single'] = ' '
        ret['item_open'] = 'v'
        ret['item_closed'] = '>'

    elseif stylename == 'ascii' then
        ret['last_item'] = 'L'
        ret['default'] = '|'
        ret['item_single'] = '|'
        ret['item_open'] = 'v'
        ret['item_closed'] = '>'

    elseif stylename == 'box' then
        ret['last_item'] = '└'
        ret['default'] = '│'
        ret['item_single'] = '├'
        ret['item_open'] = '├'
        ret['item_closed'] = '╞'

    end
    return ret
end

function nbp.Node:tree_recurse(style, indent, last)
    -- method to display the current node and its children as a string.
    local lead = style['item_single']
    local name
    local names = {}

    if last then
        lead = style['last_item']
    end

    names[1] = '' -- placeholder
    if #self.children > 0 then
        if self.closed then
            lead = style['item_closed']
        else
            lead = style['item_open']
        end
        table.sort(self.children)
        for k, v in ipairs(self.children) do
            local last = (k == #self.children)
            names[#names+1] = v:tree_recurse(style, indent + nbp.STEP, last)
        end
    end

    if self.name == nbp.ROOT then
        name = nbp.ROOT
    else
        name = string.rep(style['default']..' ', (indent - nbp.STEP)/nbp.STEP) .. lead .. ' ' .. self.name
    end
    names[1] = name

    return table.concat(names, "\n")
end

function nbp.Node:tree(style)
    style = style or 'bare'
    style = nbp.tree_style(style)
    return self:tree_recurse(style, 0, false)
end

-- Node Class

-------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------

-- Export the python structure of a buffer containing python code
function nbp.export_structure_python(str)
    local root = nbp.Node:new(nbp.ROOT) -- root of our tree

    local parents = {}                  -- table of parents indexed by indent
    local parent = nil                  -- the active parent
    local current_indent = 0            -- the current indent

    -- Extract structure from the buffer

    local lines = str:split('\n')
    for nb, line in ipairs(lines) do
        -- print(nb, line)
        local indent, name = string.match(line, "^(%s*)class%s*([_%a%d]-)%s*[(:]")
        if name then
            indent = indent:len()
            local node = nbp.Node:new(name, nbp.T_CLASS, indent, nb)
            -- print("cin: "..current_indent.." in: "..indent.." node: "..tostring(node))
            if (indent == current_indent) then
                -- We use the same parent as previously
                if (indent == 0) then
                    root:append(node)
                else
                    parent:append(node)
                end
            elseif (indent > current_indent) then
                -- Leaving current parent
                parent = parents[current_indent]
                parent:append(node)
                current_indent = indent
            else
                -- Leaving current parent
                if (indent == 0) then
                    root:append(node)
                    parent = nil
                else
                    parent = parents[indent].parent
                    parent:append(node)
                end
                current_indent = indent
            end
            -- We update the current parent for this level
            parents[indent] = node
            goto continue
        end

        local indent, name = string.match(line, "^(%s*)def%s*([_%a%d]-)%s*%(")
        if name then
            indent = indent:len()
            local node = nbp.Node:new(name, nbp.T_FUNCTION, indent, nb)
            -- print("cin: "..current_indent.." in: "..indent.." node: "..tostring(node))

            if (indent == current_indent) then
                -- We use the same parent as previously
                if (indent == 0) then
                    root:append(node)
                else
                    node.parent = parent
                    parent:append(node)
                end
            elseif (indent > current_indent) then
                parent = parents[current_indent]
                parent:append(node)
                current_indent = indent
            else
                -- Leaving current parent
                if (indent == 0) then
                    root:append(node)
                    parent = nil
                else
                    parent = parents[indent].parent
                    parent:append(node)
                end
                current_indent = indent
            end
            parents[indent] = node
            goto continue
        end

        local name = string.match(line, "^([_%a%d]-)%s*=[^=]")
        if name then
            -- Notes: we only considers constants with indent of 0
            local indent = 0
            local node = nbp.Node:new(name, nbp.T_CONSTANT, indent, nb)
            -- print("cin: "..current_indent.." in: "..indent.." node: "..tostring(node))
            root:append(node)
        end

        ::continue::
    end

    return root
end


-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

return nbp
