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
  HelpTextManager:getSingleton():addText(_"Events", _(HelpTextTitles.Events.DMRace):gsub("Event: ", ""), _(HelpTexts.Events.DMRace))
end

function DMRaceEvent:destructor()

end

function DMRaceEvent:onStart()

end
