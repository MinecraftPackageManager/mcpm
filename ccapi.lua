--[[
  ComputerCraft API wrapper for Lua 5.1.
  For testing purposes only.
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

do
  local type,error = type,error
  local cyield = coroutine.yield
  
  ccEnv.string.dump = nil
  ccEnv.debug = nil
  
  ccEnv.getmetatable = function(t)
    if type(t) == string then
      error("Attempt to get the string metatable")
    end
  end
  
  ccEnv.os.pullEventRaw = cyield
  
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
  
end

function M.runCC(func)
  setfenv(func, ccEnv)
  -- TODO
end

return M