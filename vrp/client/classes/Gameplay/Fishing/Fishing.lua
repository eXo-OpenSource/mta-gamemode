-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Fishing = {}
addRemoteEvents{"onFishingStart", "onFishingStop"}

function Fishing.load()
	local ped = Ped.create(161, Vector3(396.63, -1893.72, 7.88), 150)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Lutz", "Verkaufe mir deinen Fang!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			FishingPedGUI:new()
		end
	)
end

function Fishing.start(...)
	if not FishingRod:isInstantiated() then
		FishingRod:new(...)

		localPlayer:setWeaponSlot(0)
		toggleControl("next_weapon", false)
		toggleControl("previous_weapon", false)
	end
end
addEventHandler("onFishingStart", root, Fishing.start)

function Fishing.stop()
	if FishingRod:isInstantiated() then delete(FishingRod:getSingleton()) end
	if BobberBar:isInstantiated() then delete(BobberBar:getSingleton()) end

	toggleControl("next_weapon", true)
	toggleControl("previous_weapon", true)
end
addEventHandler("onFishingStop", root, Fishing.stop)
