-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/Debugging.lua
-- *  PURPOSE:     Debugging class
-- *
-- ****************************************************************************
if DEBUG then

	Debugging = inherit(Singleton)

	function Debugging:constructor()
		addCommandHandler("dcrun", bind(Debugging.runString, self))
	end

	function Debugging:runString(cmd, ...)
		local codeString = table.concat({...}, " ")
		runString(codeString, root, player)
	end

end
