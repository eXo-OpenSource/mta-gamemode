
-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Sewers.lua
-- *  PURPOSE:     Sewers class
-- *
-- ****************************************************************************
Sewers = inherit(Singleton)

Sewers.Textures = {  "newaterfal1_256", "LSV2"}
Sewers.CasinoTextures = {"cj_tickm", "concretenewb256", "cj_sprunk_front", "mp_gs_libwall", "cj_don_post_1", "cj_don_post_2", "cj_tv_screen", "cj_pokerscreen2"}
Sewers.TexturePath = "files/images/Textures/Sewers"
addRemoteEvents{"Sewers:applyTexture", "Sewers:removeTexture", "Sewers:getRadioLocation",
"Sewers:casinoApplyTexture", "Sewers:casinoRemoveTexture"}

function Sewers:constructor()

	self.m_ApplyInteriorTexture = bind(self.applyInteriorTexture, self)
	addEventHandler("Sewers:applyTexture", localPlayer, self.m_ApplyInteriorTexture)
	
	self.m_RemoveInteriorTexture = bind(self.removeInteriorTexture, self)
	addEventHandler("Sewers:removeTexture", localPlayer, self.m_RemoveInteriorTexture)
	addEventHandler("Sewers:getRadioLocation", localPlayer, bind(self.onGetRadioPosition, self))

	self.m_ApplyCasinoTexture = bind(self.applyCasinoTexture, self)
	addEventHandler("Sewers:casinoApplyTexture", localPlayer, self.m_ApplyCasinoTexture)
	
	self.m_RemoveCasinoTexture = bind(self.removeCasinoTexture, self)
	addEventHandler("Sewers:casinoRemoveTexture", localPlayer, self.m_RemoveCasinoTexture)
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

function Sewers:applyCasinoTexture()
	if self.m_AppliedCasino then return end
	if self.m_InteriorTextureCasino and #self.m_InteriorTextureCasino > 0 then 
		self:removeCasinoTexture()
	end
	self.m_InteriorTextureCasino = {}
	for i = 1, #Sewers.CasinoTextures do 
		if fileExists(Sewers.TexturePath.."/texCasino"..i..".jpg") then
			self.m_InteriorTextureCasino[i] = StaticFileTextureReplacer:new(Sewers.TexturePath.."/texCasino"..i..".jpg", Sewers.CasinoTextures[i])
		end
	end

	self.m_CasinoSound = playSound("files/audio/Ambient/spielo.ogg", true)
	self.m_AppliedCasino = true
	self:createCasinoPeds()
	HUDRadar:getSingleton():hide()
end

function Sewers:createCasinoPeds()
	self.m_Peds = {} 
	self.m_Peds[1] = createPed(179, 510.83, -1704.50, 800.72)
	self.m_Peds[2] = createPed(230, 513.75, -1703.08, 800.72)
	self.m_Peds[2]:setRotation(0, 0, 156)

	self.m_Peds[3] = createPed(261, 515.40, -1697.36, 800.72)
	self.m_Peds[3]:setRotation(0, 0, 135)

	self.m_Peds[4] = createPed(206, 515.28, -1698.77, 800.72)
	self.m_Peds[4]:setRotation(0, 0, 5.20)

	self.m_Peds[5] = createPed(262, 512.94, -1696.63, 800.72)
	self.m_Peds[5]:setRotation(0, 0, 170)

	self.m_Peds[6] = createPed(268, 505.49, -1706.19, 800.72)
	self.m_Peds[6]:setRotation(0, 0, 143)

	self.m_Peds[7] = createPed(2, 512.94, -1699.87, 800.72)
	self.m_Peds[7]:setRotation(0, 0, 0)

	self.m_Peds[8] = createPed(23, 511.72, -1699.03, 800.72)
	self.m_Peds[8]:setRotation(0, 0, 327)

	for i = 1, #self.m_Peds do 
		self.m_Peds[i]:setInterior(18)
		self.m_Peds[i]:setDimension(3)
		self.m_Peds[i]:setFrozen(true)
		self.m_Peds[i]:setCollisionsEnabled(false)
		self.m_Peds[i]:setData("NPC:Immortal", true)
	end

	self.m_Peds[1]:setAnimation("int_shop", "shop_loop")
	self.m_Peds[2]:setAnimation("bar", "barman_idle")
	self.m_Peds[3]:setAnimation("ped", "idle_chat")
	self.m_Peds[4]:setAnimation("cop_ambient", "coplook_think")
	self.m_Peds[5]:setAnimation("gangs", "leanidle")
	self.m_Peds[6]:setAnimation("car_chat", "car_talkm_loop")
	self.m_Peds[7]:setAnimation("sunbathe", "parksit_m_idlec")
	self.m_Peds[8]:setAnimation("sunbathe", "parksit_w_idleb")
end



function Sewers:removeCasinoTexture()
	if not self.m_AppliedCasino then return end
	if self.m_InteriorTextureCasino then
		for i = 1, #self.m_InteriorTextureCasino do 
			self.m_InteriorTextureCasino[i]:delete()
		end	
	end
	if self.m_CasinoSound then 
		stopSound(self.m_CasinoSound)
	end
	self.m_AppliedCasino = false
	for i = 1, #self.m_Peds do 
		self.m_Peds[i]:destroy()
	end
	HUDRadar:getSingleton():show()
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
