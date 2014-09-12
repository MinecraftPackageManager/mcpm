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
M.shallowcopy, M.deepcopy = shallowcopy, deepcopy
local ccEnv = deepcopy(_G)

-- Prepare a _G clone
M.prepareEnv = function(ccEnv, eventQueue)
  local type,error,pcall,require,setfenv,getfenv,getmetatable = type,error,pcall,require,setfenv,getfenv,getmetatable
  local cyield = coroutine.yield
  local oldenv = getfenv()
  
  -- make it so every new function has ccEnv as the env
  setfenv(1,ccEnv)
  
  -- setup eventQueue
  eventQueue.count = 0
  eventQueue.current = 1
  function eventQueue:push(evt,p1,p2,p3,p4,p5)
    local newcount = self.count + 1
    self[newcount] = {evt, p1, p2, p3, p4, p5}
    self.count = newcount
  end
  function eventQueue:pop()
    if self.count < self.current then
      return nil
    else
      local current = self.current
      self.current = current + 1
      return self[current]
    end
  end
  
  -- setup environment
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
    if type(t) == "string" then
      error("Attempt to get the string metatable")
    end
    return getmetatable(t)
  end
  
  ccEnv.os.pullEventRaw = cyield
  
  ccEnv.os.queueEvent = function(evt,p1,p2,p3,p4,p5)
    if n == nil then error() end -- todo test this
    eventQueue:push(evt,p1,p2,p3,p4,p5)
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
    print("ccapi doesn't support HTTP API yet")
  end
  
  setfenv(1,oldenv)
end

local eventQueue = {}
M.prepareEnv(ccEnv, eventQueue)

local function scan(t, what, callback)
  local toScan = {t}
  while next(toScan) do
    local k,v = next(toScan)
    toScan[k] = nil
    if type(v) == "table" then
      for x,y in pairs(v) do
        if type(y) == what then
          y = callback(y)
        end
        if type(y) == "table" then
          table.insert(toScan, y)
        end
        v[x] = y
      end
    else
      error(string.format("Table expected, got %s (%s)", type(v), v))
    end
  end
end

function M.runCC(func, env)
  scan(env, "function", function(f)
      return setfenv(function(...) return f(...) end, env)
    end)
  setfenv(func, env)
  -- main loop
  while true do
    
  end
end

return M
