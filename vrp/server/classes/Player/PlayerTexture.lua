-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Player/PlayerTexture.lua
-- *  PURPOSE:     Player Texture Class
-- *
-- ****************************************************************************
PlayerTexture = inherit(Object)
PlayerTexture.Map = {}

function PlayerTexture:constructor(player, path, texture, force, isPreview, previewer)
	if player and isElement(player) then
		self.m_Id = #PlayerTexture.Map+1
		--self.m_Optional = not self:checkOptional(vehicle)
		self.m_Optional = false
		self.m_Player = player
		self.m_Path = path
		if texture then
			self.m_Texture = texture
		end
		--elseif VEHICLE_SPECIAL_TEXTURE[vehicle:getModel()] then
		--	self.m_Texture = VEHICLE_SPECIAL_TEXTURE[vehicle:getModel()]
		--else
		--	self.m_Texture = "vehiclegrunge256"
		--end

		PlayerTexture.Map[self.m_Id] = self
		if force then
			if self.m_Player and isElement(self.m_Player) then
				if not isPreview then
					PlayerTexture.sendToClient(root, {{player = self.m_Player, textureName = self.m_Texture, texturePath = self.m_Path, optional = self.m_Optional, isRequested = false}})
				else
					PlayerTexture.sendToClient(previewer, {{player = self.m_Player, textureName = self.m_Texture, texturePath = self.m_Path, optional = self.m_Optional, isRequested = false}})
				end
			end
		end
		-- add destruction handler
		self.m_OnElementChange = bind(self.Event_onModelChange, self)
		addEventHandler("onElementModelChange", self.m_Player, self.m_OnElementChange)
	else
		delete(self)
	end
end

function PlayerTexture:getTextureName()
	return self.m_Texture
end

function PlayerTexture:getPath()
	return self.m_Path
end

function PlayerTexture:Event_onModelChange( oldModel ) 
	local newModel = getElementModel(source) 
	if newModel ~= oldModel then 
		delete(self)
	end
end

function PlayerTexture:checkOptional(vehicle)
	local nOptional = VehicleManager:getSingleton().NonOptionalTextures
	for i = 1,#nOptional do
		if instanceof(vehicle, nOptional[i]) then
			return true
		end
	end
	return false
end

function PlayerTexture:destructor()
	PlayerTexture.Map[self.m_Id] = nil
	if self.m_Player and isElement(self.m_Player) then
		triggerClientEvent(root, "removeElementTexture",  self.m_Player, self.m_Texture)
	end
end

function PlayerTexture.sendToClient(target, ...)
	triggerClientEvent(target == root and PlayerManager:getSingleton():getReadyPlayers() or target, "changeElementTexture", target, ...)
end

function PlayerTexture.requestTextures(target)
	local playerTab = {}
	for index, instance in pairs(PlayerTexture.Map) do
		if instance.m_Player and isElement(instance.m_Player) then
			playerTab[#playerTab+1] = {player = instance.m_Player, textureName = instance.m_Texture, texturePath = instance.m_Path, optional = instance.m_Optional, isRequested = true}
		end
	end
	PlayerTexture.sendToClient(target, playerTab)
end

