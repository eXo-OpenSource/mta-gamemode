
-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Sewers.lua
-- *  PURPOSE:     Sewers class
-- *
-- ****************************************************************************
Sewers = inherit(Singleton)

Sewers.Textures = {  "newaterfal1_256", "LSV2" }
Sewers.TexturePath = "files/images/Textures/Sewers"
addRemoteEvents{"Sewers:applyTexture", "Sewers:removeTexture", "Sewers:getRadioLocation"}

function Sewers:constructor()

	self.m_ApplyInteriorTexture = bind(self.applyInteriorTexture, self)
	addEventHandler("Sewers:applyTexture", localPlayer, self.m_ApplyInteriorTexture)
	
	self.m_RemoveInteriorTexture = bind(self.removeInteriorTexture, self)
	addEventHandler("Sewers:removeTexture", localPlayer, self.m_RemoveInteriorTexture)
	addEventHandler("Sewers:getRadioLocation", localPlayer, bind(self.onGetRadioPosition, self))
end

function Sewers:applyInteriorTexture()
	if self.m_Applied then return end
	if self.m_InteriorTexture and #self.m_InteriorTexture > 0 then 
		self:removeInteriorTexture()
	end
	self.m_InteriorTexture = {}
	for i = 1, #Sewers.Textures do 
		if fileExists(Sewers.TexturePath.."/tex"..i..".jpg") then
			self.m_InteriorTexture[i] = StaticFileTextureReplacer:new(Sewers.TexturePath.."/tex"..i..".jpg", Sewers.Textures[i])
		end
	end

	self.m_SewerSound = playSound("files/audio/Ambient/sewer.mp3", true)
	self.m_Applied = true
	triggerServerEvent("Sewers:requestRadioLocation", localPlayer)
	for k, p in ipairs(getElementsByType("ped")) do 
		if p:getDimension() == localPlayer:getDimension() and getElementData(p, "SewerPed") then 
			setPedAnimation(p, "CLOTHES", "CLO_Pose_Loop", -1, true, false, false)
			p:setData("NPC:Immortal", true)
			local rx, ry, rz = getElementRotation(p)
			setElementRotation(p, 0, 0, rz-45)
		end
	end
	HUDRadar:getSingleton():hide()
end

function Sewers:onGetRadioPosition(x, y, z, dim)
	if self.m_Applied then
		self.m_SewerStorageMusic = playSound3D( "files/audio/Ambient/serpent_dance.ogg", x, y, z, true )
		self.m_SewerStorageMusic:setDimension(dim)
		self.m_SewerStorageMusic:setMaxDistance(40)
	end
end


function Sewers:removeInteriorTexture()
	if not self.m_Applied then return end
	if self.m_InteriorTexture then
		for i = 1, #self.m_InteriorTexture do 
			self.m_InteriorTexture[i]:delete()
		end	
	end
	if self.m_SewerSound then 
		stopSound(self.m_SewerSound)
	end
	if self.m_SewerStorageMusic then 
		stopSound(self.m_SewerStorageMusic)
	end
	self.m_Applied = false
	if self.m_PedTimer and isTimer(self.m_PedTimer) then 
		killTimer(self.m_PedTimer)
	end
	HUDRadar:getSingleton():show()
end
