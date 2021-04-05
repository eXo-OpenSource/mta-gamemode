-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/classes/POParser.lua
-- *  PURPOSE:     	Gettext .po parser
-- *
-- ****************************************************************************
POParser = inherit(Object)

function POParser:constructor(poPath)
	self.m_Strings = {}

	local file = File.Open(poPath, true)
	local lines = split(assert(file:getContent(), "Reading the translation file failed"), "\n")
	--[[
	local lastKey
	for i, line in ipairs(lines) do
		local pos = line:find(' ')
		if pos then
			local instruction = line:sub(1, pos-1)
			local argument = line:sub(pos+1)
			
			if instruction == "msgid" then
				-- Remove ""
				argument = argument:sub(2, #argument-2)
				
				self.m_Strings[argument] = false
				lastKey = argument
			elseif instruction == "msgstr" then
				-- Remove ""
				argument = argument:sub(2, #argument-2)
				self.m_Strings[lastKey] = argument
			end
		end
	end
	]]

	local lastKey
	local lastInstruction
	for i, line in ipairs(lines) do
		if line:sub(0, 5) == "msgid" then
			lastInstruction = line:sub(0, 5)
			lastKey = line:sub(8, -3)
			self.m_Strings[lastKey] = false
		elseif line:sub(0, 6) == "msgstr" then
			lastInstruction = line:sub(0, 6)
			self.m_Strings[lastKey] = line:sub(9, -3)
		elseif line:sub(0, 1) == "\"" then
			local value = line:sub(2, -3)
			if lastKey then
				if self.m_Strings[lastKey] then
					self.m_Strings[lastKey] = self.m_Strings[lastKey] .. value
				else
					self.m_Strings[lastKey] = value
				end
			end
		else
			lastKey = nil
			lastInstruction = nil
		end
	end


	file:close()
end

function POParser:translate(str)
	return self.m_Strings[str]
end
