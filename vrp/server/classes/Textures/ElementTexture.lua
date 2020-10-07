-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Textures/ElementTexture.lua
-- *  PURPOSE:     Element Texture class
-- *
-- ****************************************************************************
ElementTexture = inherit(Object)
ElementTexture.Map = {}

function ElementTexture:constructor(element, path, texture, checkForDuplicate, isPreview, player, forceTexture, forceMaximumTexture)
	if element and isElement(element) then
		if checkForDuplicate then
			if ElementTexture.checkForDuplicate(element, path, texture) then
				return false
			end
		end

		self.m_Id = #ElementTexture.Map+1
		self.m_Force = forceTexture
		self.m_ForceMaximum = forceMaximumTexture
		self.m_Element = element
		self.m_Path = path
		self.m_Texture = texture

		ElementTexture.Map[self.m_Id] = self
		if self.m_Element and isElement(self.m_Element) then
			if not isPreview then
				ElementTexture.sendToClient(root, {{element = self.m_Element, textureName = self.m_Texture, texturePath = self.m_Path, forceTexture = self.m_Force, forceMaximumTexture = self.m_ForceMaximum}})
			else
				ElementTexture.sendToClient(player, {{element = self.m_Element, textureName = self.m_Texture, texturePath = self.m_Path, forceTexture = self.m_Force, forceMaximumTexture = self.m_ForceMaximum}})
			end
		end
		-- add destruction handler
		addEventHandler("onElementDestroy", self.m_Element, bind(delete, self))
	else
		delete(self)
	end
end

function ElementTexture:destructor()
	ElementTexture.Map[self.m_Id] = nil
	if self.m_Element and isElement(self.m_Element) then
		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "removeElementTexture",  self.m_Element, self.m_Texture)
	end
end

function ElementTexture.checkForDuplicate(element, path, texture)
	for index, texture in pairs(ElementTexture.Map) do
		if texture.m_Element == element and texture.m_Path == path and texture.m_Texture == texture then
			return true
		end
	end
	return false
end

function ElementTexture.sendToClient(target, ...)
	triggerClientEvent(target == root and PlayerManager:getSingleton():getReadyPlayers() or target, "changeElementTexture", target, ...)
end

function ElementTexture.requestTextures(target)
	local elementTable = {}
	for index, instance in pairs(ElementTexture.Map) do
		if instance.m_Element and isElement(instance.m_Element) then
			elementTable[#elementTable+1] = {element = instance.m_Element, textureName = instance.m_Texture, texturePath = instance.m_Path, forceTexture = instance.m_Force, forceMaximumTexture = instance.m_ForceMaximum}
		end
	end
	ElementTexture.sendToClient(target, elementTable)
end