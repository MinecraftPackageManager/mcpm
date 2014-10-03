--[[
    SEx Serializer for Lua 5.1 and Lua 5.2
    Copyright (C) 2014  SoniEx2

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
  ]]

-- TODO: refactor

local serializers = {}

function serializers.string(str, p, s)
  return string.format("%s%q%s", p, str, s)
end

local function nbn(obj, p, s)
  return p .. tostring(obj) .. s
end

serializers.number = nbn
serializers.boolean = nbn
serializers.nil = nbn

function serializers.function(func, p, s)
  -- return dummy function
  local s,r = pcall(string.dump,func)
  if not s then
    return p .. "function() --[[..skipped..]] end" .. s
  else
    return p .. "function() --[[.." .. string.format("%q",r):gsub("]]",("\\" .. string.byte("]")):rep(2)) .. "..]] end" .. s
  end
end

function serializers.thread(co, p, s)
  return p .. "coroutine" .. s
end

function serializers.userdata(ud, p, s)
  return p .. "userdata" .. s
end

function serializers.table(tbl, p, s)
  
end

local function serialize(obj, prefix, suffix)
  return serializers[type(obj)](obj, prefix, suffix)
end

return serialize