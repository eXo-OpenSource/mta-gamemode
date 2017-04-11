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

Easter = {}
Easter.Textures = {}
function Easter.updateTexture(texname, file, object)
	if not Easter.Textures[file] then
		Easter.Textures[file] = {}
		Easter.Textures[file].shader = dxCreateShader("files/shader/texreplace.fx")
		Easter.Textures[file].tex = dxCreateTexture(file)
		dxSetShaderValue(Easter.Textures[file].shader, "gTexture", Easter.Textures[file].tex)
	end

	engineApplyShaderToWorldTexture(Easter.Textures[file].shader, texname, object)
end

for index, object in pairs(getElementsByType("object")) do
	if object:getModel() == 2326 then
		object.texture = {}
		for i = 1, 9, 1 do
			Easter.updateTexture("slot_fr_"..i, "files/images/Events/Easter/slot_"..i..".png", object)
		end
	elseif object:getModel() == 2325 and object:getData("Easter") then
		Easter.updateTexture("slot5_ind", "files/images/Events/Easter/slotmachine.jpg", object)
	end
end
