-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Fishing = {}

function Fishing.load()
	local ped = Ped.create(161, Vector3(368.27, -2072.03, 8.02), 180)
	Blip:new("Fishing.png", 368.27, -2072.03, 600)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Lutz", "Verkaufe mir deinen Fang!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			triggerServerEvent("fishingPedClick", localPlayer)
		end
	)
end
