-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/DMRaceEvent.lua
-- *  PURPOSE:     DM race event class
-- *
-- ****************************************************************************
DMRaceEvent = inherit(Event)

function DMRaceEvent:constructor()
  -- Add to Helpmenu
  HelpTextManager:getSingleton():addText(_"Events", _(HelpTextTitles.Events.DMRace):gsub("Event: ", ""), "events.dmrace")
end

function DMRaceEvent:destructor()
	for k, player in pairs(self.m_Players) do
		if player and player ~= localPlayer then
			setElementCollidableWith(localPlayer, player, true)
			setElementCollidableWith(player, localPlayer, true)
		end
	end
end

function DMRaceEvent:onStart()
	-- Apply Ghostmode
	setTimer(
		function()
			for k, player in pairs(self.m_Players) do
				if player ~= localPlayer then
					setElementCollidableWith(localPlayer, player, false)
					setElementCollidableWith(player, localPlayer, false)

					setElementCollidableWith(localPlayer.vehicle, player.vehicle, false)
					setElementCollidableWith(player.vehicle, localPlayer.vehicle, false)
				end
			end
		end, 1000, 1
	)
end
