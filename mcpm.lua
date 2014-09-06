--[[
  So yeah, we're doing a package manager...
  ]]

local system = _VERSION

-- "easy" way to support new systems
local systems = {
  CC = "ComputerCraft"
  Lua52 = "Lua 5.2"
  Lua51 = "Lua 5.1"
}

-- dogecoin donation address
local dogecoinAddress = "DJphzV7NPn6AT36N4LxDN67fLCzGX3xNB7"

-- system detection code
if os.pullEventRaw then
  system = systems.CC
end

function getGithubHandlers() -- github stuff

  -- The github API has a JSON-P switch, we use it so we can get some of the HTTP response headers in ComputerCraft.
  -- This works by sending a JSON-P request with `jsonphackstart` as the callback, then findind the function call and grabbing everything inbetween.
  -- `.+` is greedy, so `jsonphackstart(")")`, when matched with the pattern below, returns `")"`
  local function prepareJsonHack(jsonString)
    return (jsonString:match("jsonphackstart%((.+)%)"))
  end
  
  if system == systems.CC then
    
  else
    
  end
  
end
