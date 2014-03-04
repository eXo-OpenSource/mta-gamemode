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
		--player = PlayerMouseMenu;
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
	for k, menu in ipairs(self.m_OpenMenus) do
		delete(menu)
	end
	
	local element, button = clickInfo.element, clickInfo.button
	if button == "right" then
		if not element or not isElement(element) then -- Elementdata: temp fix (Todo)
			return
		end
		
		local elementType = getElementType(element)
		local model = getElementModel(element)
		local mouseMenu
		
		if self.m_Menu[elementType] and element ~= localPlayer then
			if elementType ~= "vehicle" and getElementData(element, "OwnerName") then
				mouseMenu = self.m_Menu[elementType]:new(clickInfo.absoluteX, clickInfo.absoluteY, element)
			end
		end
		
		if self:checkModels(model, 1775, 1776, 1209) then
			mouseMenu = VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element)
		end
		
		if mouseMenu then
			mouseMenu:setElement(element)
			table.insert(self.m_OpenMenus, mouseMenu)
		end
		
	elseif button == "left" and element and isElement(element) then
		local model = getElementModel(element)
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local x, y, z = getElementPosition(element)
		local range = getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z)
		
		if model == 2942 and range <= 8 then -- Bank ATM
			BankGUI:new()
		end
		
		if element == localPlayer then
			SelfGUI:getSingleton():open()
		end
	end
end
