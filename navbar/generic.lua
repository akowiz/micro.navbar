#!/bin/env lua

--- @module navbar.generic
local gen = {}


-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

--- split function with a python semantic.
--   see http://lua-users.org/wiki/SplitJoin
-- @tparam string sep The character to use for the slit.
-- @tparam int max The maximun number of split.
-- @tparam string regex The regex to use for the split instead of sSeparator.
-- @return A table of string.
function string:split(sep, max, regex)
   assert(sep ~= '')
   assert(max == nil or max >= 1)

   local record = {}

   if self:len() > 0 then
      local plain = not regex
      max = max or -1

      local field, start = 1, 1
      local first, last = self:find(sep, start, plain)
      while first and max ~= 0 do
         record[field] = self:sub(start, first-1)
         field = field + 1
         start = last + 1
         first, last = self:find(sep, start, plain)
         max = max-1
      end
      record[field] = self:sub(start)
   end

   return record
end

--- Return true if table == {}, false otherwise.
-- @tparam table table A table.
-- @return true if the table is {}, false otherwise.
function gen.is_empty(table)
    return next(table) == nil
end

--- Return a Class object
--
-- @usage local Rectangle = gen.Class()
-- function Rectangle:__init(l, h) self.l = l or 0; self.h = h or 0 end
-- function Rectangle:surface() return self.l * self.h end
-- local Square = gen.Class(Rectangle)
-- function Square.__init(l) Rectangle.__init(self, l, l)
--
-- @param ... The list of classes this class inherit from (can be empty).
-- @return Class object.
function gen.class(...)
    -- "cls" is the new class
    print('\n')
    local cls, bases = {}, {...}

    -- copy base class contents into the new class
    for i, base in ipairs(bases) do
        for k, v in pairs(base) do
            cls[k] = v
        end
    end

    -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
    -- so you can do an "instance of" check using my_instance.is_a[MyClass]
    cls.__index, cls.is_a = cls, {[cls] = true}
    for i, base in ipairs(bases) do
        for c in pairs(base.is_a) do
            cls.is_a[c] = true
        end
        cls.is_a[base] = true
    end

    -- the class's __call metamethod
    setmetatable(cls, {__call = function (c, ...)
        local instance = setmetatable({}, c)
        -- run the init method if it's there
        local init = instance.__init
        if init then init(instance, ...) end
        return instance
    end})

    -- return the new class table, that's ready to fill with methods
    return cls
end

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

return gen
