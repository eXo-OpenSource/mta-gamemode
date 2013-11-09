-- ****************************************************************************
-- *
-- *  PROJECT:     	Open MTA:DayZ
-- *  FILE:        	shared/classes/POParser.lua
-- *  PURPOSE:     	Gettext .po parser
-- *
-- ****************************************************************************
POParser = inherit(Object)

function POParser:constructor(poPath)
	self.m_Strings = {}

	local file = File.Open(poPath, true)
	local lines = split(assert(file:getContent(), "Reading the translation file failed"), "\n")
	
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
end

function POParser:translate(str)
	return self.m_Strings[str]
end
