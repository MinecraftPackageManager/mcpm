--[[
    ComputerCraft API wrapper for Lua 5.1.
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

local M = {}

local deepcopy, shallowcopy
do -- table copy https://gist.github.com/SoniEx2/fc5d3614614e4e3fe131
  local next,type,rawset = next,type,rawset

  local function deep(inp,copies)
    if type(inp) ~= "table" then
      return inp
    end
    local out = {}
    copies = (type(copies) == "table") and copies or {}
    copies[inp] = out -- use normal assignment so we use copies' metatable (if any)
    for key,value in next,inp do -- skip metatables by using next directly
      -- we want a copy of the key and the value
      -- if one is not available on the copies table, we have to make one
      -- we can't do normal assignment here because metatabled copies tables might set metatables
      -- out[copies[key] or deep(key,copies)]=copies[value] or deep(value,copies)
      rawset(out,copies[key] or deep(key,copies),copies[value] or deep(value,copies))
    end
    return out
  end

  local function shallow(inp)
    local out = {}
    for key,value in next,inp do -- skip metatables by using next directly
      out[key] = value
    end
    return out
  end
-- set table.copy.shallow and table.copy.deep
-- we could also set the metatable so that calling it calls table.copy.deep
-- (or turn it into table.copy(table,deep) where deep is a boolean)
  shallowcopy,deepcopy=shallow,deep
end

local ccEnv = deepcopy(_G)

local function prepareEnv(ccEnv, eventQueue)
  local type,error,pcall,require,setfenv,getfenv = type,error,pcall,require,setfenv,getfenv
  local cyield = coroutine.yield
  local oldenv = getfenv()
  
  -- make it so every new function has ccEnv as the env
  setfenv(1,ccEnv)
  
  eventQueue.n = 0
  eventQueue.c = 1
  
  ccEnv.string.dump = nil
  ccEnv.debug = nil
  ccEnv.require = nil
  ccEnv.package = nil
  
  ccEnv.getfenv = function(f)
    if getfenv(f) == getfenv(0) then
      return ccEnv
    elseif type(f) == "number" then
      return getfenv(f+1)
    else
      return getfenv(f)
    end
  end
  
  ccEnv.getmetatable = function(t)
    if type(t) == string then
      error("Attempt to get the string metatable")
    end
  end
  
  ccEnv.os.pullEventRaw = cyield
  
  ccEnv.os.queueEvent = function(n,a,b,c,d,e)
    local x = eventQueue.n
    eventQueue[x] = {n,a,b,c,d,e}
    eventQueue.n = x + 1
  end
  
  ccEnv.os.pullEvent = function(_evt)
    while true do
      local a,b,c,d,e,f = cyield()
      if a == _evt then
        return a,b,c,d,e,f
      elseif a == "terminate" then
        error("Terminated")
      end
    end
  end
  
  if pcall(require,"socket") then
    -- enable HTTP API
    
  end
  
  setfenv(1,oldenv)
end

local eventQueue = {}
prepareEnv(ccEnv, eventQueue)

function M.runCC(func, env)
  setfenv(func, ccEnv)
  -- loop
  while true do
    
  end
end

return M
