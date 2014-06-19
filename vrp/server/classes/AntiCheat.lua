-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiCheat.lua
-- *  PURPOSE:     Anticheat class
-- *
-- ****************************************************************************
AntiCheat = inherit(Singleton)

function AntiCheat:constructor()
	-- Disable clientside synced element data setting entirely (even though we don't store anything important via elementdatas)
	addEventHandler("onElementDataChange", root,
		function(name, oldValue)
			-- Serverside changes are okay
			if not client then
				return
			end
			
			setElementData(source, name, oldValue)
		end
	)
end
