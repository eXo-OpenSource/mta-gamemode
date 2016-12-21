-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/BarShop.lua
-- *  PURPOSE:     BarShop Class
-- *
-- ****************************************************************************
BarShop = inherit(Shop)

function BarShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "Bar"
	self.m_Items = SHOP_ITEMS["Bar"]

	self.m_SoundUrl = ""

	self.m_MusicGUIBind = bind(self.openMusicGUI, self)

	if self.m_Marker then
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onBarMarkerHit, self))

		self.m_SoundCol = createColSphere(self.m_Marker:getPosition(), 50)
		self.m_SoundCol:setDimension(self.m_Dimension)
		self.m_SoundCol:setInterior(self.m_Interior)
		addEventHandler("onColShapeHit", self.m_SoundCol, bind(self.onEnter, self))
		addEventHandler("onColShapeLeave", self.m_SoundCol, bind(self.onExit, self))
	end

end

function BarShop:onBarMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if self.m_Marker then
			if not self.m_Marker.m_Disable then
				hitElement:triggerEvent("showBarGUI")
				triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
			end
		else
			hitElement:triggerEvent("showBarGUI")
			triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
		end
	end
end

function BarShop:onEnter(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		hitElement:sendInfo(_("Drücke 'm' um das Musikpanel zu öffnen!", hitElement))
		bindKey(hitElement, "m", "down", self.m_MusicGUIBind)
		if self.m_SoundUrl ~= "" then
			hitElement:triggerEvent("barUpdateMusic", self.m_SoundUrl)
		end
	end
end

function BarShop:onExit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		unbindKey(hitElement, "m", "down", self.m_MusicGUIBind)
		hitElement:triggerEvent("barUpdateMusic")
	end
end

function BarShop:getPlayerInBar()
	return self.m_SoundCol:getElementsWithin("player")
end

function BarShop:openMusicGUI(player)
	player:triggerEvent("barOpenMusicGUI", self.m_Id, self.m_SoundUrl)
end

function BarShop:changeMusic(player, stream)
	self.m_SoundUrl = stream
	for index, playerItem in pairs(self:getPlayerInBar()) do
		playerItem:sendShortMessage(_("%s hat die Musik in der Bar gewechselt!", playerItem, player:getName()))
		playerItem:triggerEvent("barUpdateMusic", self.m_SoundUrl)
	end
end

function BarShop:stopMusic(player)
	self.m_SoundUrl = ""
	for index, playerItem in pairs(self:getPlayerInBar()) do
		playerItem:sendShortMessage(_("%s hat die Musik in der Bar gestoppt!", playerItem, player:getName()))
		playerItem:triggerEvent("barUpdateMusic")
	end
end

