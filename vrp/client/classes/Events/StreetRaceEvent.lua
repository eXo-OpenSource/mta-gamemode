-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/StreetRaceEvent.lua
-- *  PURPOSE:     Streetrace event class
-- *
-- ****************************************************************************
StreetRaceEvent = inherit(Event)

function StreetRaceEvent:constructor()
	-- Add to Helpmenu
  HelpTextManager:getSingleton():addText(_"Events", _(HelpTextTitles.Events.StreetRace):gsub("Event: ", ""), "events.streetrace")
end

function StreetRaceEvent:onStart()

end

function StreetRaceEvent:destructor()

end
