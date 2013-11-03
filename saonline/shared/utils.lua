-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        shared/utils.lua
-- *  PURPOSE:     Useful stuff
-- *
-- *****************************************************************************

local __enums = {}
function enum(targetVar, name)
	if __enums[name] then
		__enums[name].maxNum = __enums[name].maxNum+1
	else
		__enums[name] = {maxNum = 1}
	end
	
	-- Register in global namespace
	_G[targetVar] = __enums[name].maxNum
	
	-- Register mainly for addons
	__enums[name][__enums[name].maxNum] = targetVar
	
	return __enums[name]
end

function getEnums()
	return __enums
end

function enumFields(name)
	local i = 0
	local maxNum = __enums[name].maxNum
	return (
		function()
			i = i + 1
			if i ~= maxNum then
				return i, __enums[name][i]
			end
		end
	)
end

function table.size(tab)
	local i = 0
	for _ in pairs(tab) do
		i = i + 1
	end
	return i
end

function table.find(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.findAll(tab, value)
	local result = {}
	for k, v in pairs(tab) do
		if v == value then
			table.insert(result, k)
		end
	end
	return result
end

function outputDebug(errmsg)
	if DEBUG then
		outputDebugString((triggerServerEvent and "CLIENT " or "SERVER ")..tostring(errmsg))
	end
end

_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		outputDebugString( tostring(result), 1 )	-- Output error message
	end
	return state,result
end

-- key-sorted pairs
function kspairs(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
 
	local i = 0 
	local iter = function ()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
 
	return iter
end

function chance(chance)
	assert(chance >= 0 and chance <= 100, "Bad Chance (Range 0-100)")
	return math.random(0, 100) <= chance 
end

function table.append(table1, table2)
	for k, v in pairs(table2) do
		table1[#table1+1] = v
	end
	return table1
end