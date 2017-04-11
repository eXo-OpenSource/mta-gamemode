-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Slotmachine.lua
-- *  PURPOSE:     Slotmachine Events - from iLife
-- *
-- ****************************************************************************

addRemoteEvents{"onSlotmachineSoundPlay", "onSlotmachineJackpot"}

addEventHandler("onSlotmachineSoundPlay", localPlayer,
	function(x, y, z, filename, int, dim)
		local sound = playSound3D("files/audio/Slotmachines/"..filename..".mp3", x, y, z)
		setSoundMaxDistance(sound, 50)
		setElementInterior(sound, int or 0)
		setElementDimension(sound, dim or 0)
		return sound
	end
)

addEventHandler("onSlotmachineJackpot", localPlayer, function(x, y, z)
	setTimer(function()
		for i = 1, 10, 1 do
			fxAddSparks(x, y, z, 0, 0, 2, 5, 20, 0, 0, 0, false, 0.5, 5)
		end
	end, 300, 10)
end)

for index, object in pairs(getElementsByType("object")) do
	if object:getModel() == 2326 then
		object.texture = {}
		for i = 1, 9, 1 do
			object.texture[i] = TextureReplace:new("slot_fr_"..i, "files/images/Events/Easter/slot_"..i..".png", false, 64, 64, object)
		end
	elseif object:getModel() == 2325 and object:getData("Easter") then
		object.texture = TextureReplace:new("slot5_ind", "files/images/Events/Easter/slotmachine.jpg", false, 200, 200, object)
	end
end
