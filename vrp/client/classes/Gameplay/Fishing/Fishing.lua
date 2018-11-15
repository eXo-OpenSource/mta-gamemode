-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Fishing = {}
addRemoteEvents{"onFishingStart", "onFishingStop", "onFishingBadCatch", "onFishingUpdateBaits"}

function Fishing.load()
	--LS
	local ped = Ped.create(161, Vector3(393.03, -1905.04, 7.87), 0)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Lutz", "Verkaufe mir deinen Fang!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			FishingPedGUI:new()
		end
	)

	--Bayside
	local ped = Ped.create(161, Vector3(-2058.39, -2463.71, 31.18), 145)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Heinz", "Verkaufe mir deinen Fang!", 0, 1.3)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			FishingPedGUI:new()
		end
	)
	--Tierra Robada
	local ped = Ped.create(161, Vector3(-1353.93, 2056.65, 53.12), 270)

	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Bernd", "Verkaufe mir deinen Fang!", 0, 1.3)
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

function Fishing.BadCatch()
	setTimer(
		function()
			if FishingRod:isInstantiated() then
				FishingRod:getSingleton():reset()
				FishingRod:getSingleton().Sound:play("caught")
			end
		end, 50, 1
	)
end
addEventHandler("onFishingBadCatch", root, Fishing.BadCatch)

function Fishing.updateBaits(...)
		if FishingRod:isInstantiated() then
			FishingRod:getSingleton():updateBaits(...)
		end
end
addEventHandler("onFishingUpdateBaits", root, Fishing.updateBaits)
