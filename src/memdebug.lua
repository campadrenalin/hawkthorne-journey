-- memdebug.lua

-- Memory reporting and analysis module for finding leaks
-- Based on http://bitsquid.blogspot.com/2011/08/fixing-memory-issues-in-lua.html

local MemDebugger = {}
MemDebugger.__index = MemDebugger

MemDebugger.count_frequency = 1
MemDebugger.count_accumulation = 0

function MemDebugger:init()
  self.global_type_table_preload()
end

function MemDebugger:update(dt)
  self.count_accumulation = self.count_accumulation + dt
  if self.count_accumulation > self.count_frequency then
    self.count_accumulation = 0
    local counts = self.type_count()
    local output = "{"
    local is_first = true
    for label, count in pairs(counts) do
      if is_first then
        is_first = false
      else
        output = output .. ", "
      end

      output = output .. label .. " = " .. tostring(count)
    end

    print(output .. "}")
  end
end

function MemDebugger.count_all(f)
	local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function MemDebugger.type_count()
	local counts = {}
	local enumerate = function (o)
		local t = MemDebugger.type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	MemDebugger.count_all(enumerate)
	return counts
end

local global_type_table = nil
local preloaded_type_names = {
  'vendor/gamestate',
  --'vendor/TESound',
  'blackjackgame',
  'camera',
  'characterstrip',
  'cheat',
  'cheatscreen',
  'conf',
  'credits',
  'datastore',
  'dialog',
  'fonts',
  'game',
  'helper',
  'hud',
  'instructions',
  'inventory',
  'level',
  'player',
  'prompt',
  'queue',
  'overworld',
  'tunnelparticles',
  'verticalparticles',
  'window'
}

function MemDebugger.preloaded_types(names)
  local names = names or preloaded_type_names
  local types = {}
  for _, name in ipairs(names) do
    types[name] = require(name)
  end
  return types
end

function MemDebugger.global_type_table_clear()
  global_type_table = nil
end

function MemDebugger.global_type_table_get()
  return global_type_table
end

function MemDebugger.global_type_table_init(source)
	if global_type_table == nil then
		global_type_table = {}
  end
	for k,v in pairs(source or _G) do
		global_type_table[v] = k
	end
  global_type_table[0] = "table"
end

function MemDebugger.global_type_table_preload(names)
  MemDebugger.global_type_table_init(
    MemDebugger.preloaded_types(names)
  )
end

function MemDebugger.type_name(o)
  MemDebugger.global_type_table_init()
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end

return MemDebugger
