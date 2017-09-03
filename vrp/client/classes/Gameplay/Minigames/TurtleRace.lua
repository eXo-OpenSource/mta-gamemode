-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRace = inherit(Singleton)

function TurtleRace.load()
	local ped = Ped.create(198, Vector3(318, -1820, 4.19), 270)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Krötenprofi Diana", "TURTLE RACE!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			TurtleRaceGUI:new()
		end
	)
end

function TurtleRace:constructor()
end

function TurtleRace:destructor()
end
