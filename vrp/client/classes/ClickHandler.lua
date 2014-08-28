-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ClickHandler.lua
-- *  PURPOSE:     Class that handles clicks on elements
-- *
-- ****************************************************************************
ClickHandler = inherit(Singleton)

function ClickHandler:constructor()
	self.m_OpenMenus = {}
	self.m_Menu = {
		player = PlayerMouseMenu;
		vehicle = VehicleMouseMenu;
	}
	self.m_ClickInfo = false
	
	addEventHandler("onClientClick", root,
		function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
			if state == "up" then
				self.m_ClickInfo = {button = button, absoluteX = absoluteX, absoluteY = absoluteY, element = element}
			end
		end
	)
end

function ClickHandler:invokeClick()
	if self.m_ClickInfo then
		self:dispatchClick(self.m_ClickInfo)
	end
	self.m_ClickInfo = false
end

function ClickHandler:clearClickInfo()
	self.m_ClickInfo = false
end

function ClickHandler:checkModels(model, ...)
	for k, v in ipairs({...}) do
		if v == model then
			return true
		end
	end
	return false
end

function ClickHandler:dispatchClick(clickInfo)
	-- Close all currently open menus
	self:clearMouseMenus()
	
	local element, button = clickInfo.element, clickInfo.button
	if not element or not isElement(element) then
		return
	end
	local elementType = getElementType(element)
	local model = getElementModel(element)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local x, y, z = getElementPosition(element)
	local range = getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z)
	
	-- Phase 1: Check per-element handlers
	if element == localPlayer then
		SelfGUI:getSingleton():open()
		return
	end
	
	-- Phase 2: Check models
	if self:checkModels(model, 1775, 1776, 1209) then
		self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
		return
	end
	if model == 2942 and range <= 8 then
		BankGUI:getSingleton():show()
		return
	end
	if model == 2886 then -- Keypad
		triggerServerEvent("keypadClick", element)
	end
	
	-- Phase 3: Check element types
	if self.m_Menu[elementType] then
		self:addMouseMenu(self.m_Menu[elementType]:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
		return
	end
end

function ClickHandler:addMouseMenu(menu, element)
	menu:setElement(element)
	table.insert(self.m_OpenMenus, menu)
end

function ClickHandler:clearMouseMenus()
	for k, menu in ipairs(self.m_OpenMenus) do
		delete(menu)
	end
	self.m_OpenMenus = {}
end
