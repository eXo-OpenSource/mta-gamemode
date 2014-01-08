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
	addEventHandler("onClientClick", root, bind(self.dispatchClick, self))
end

function ClickHandler:dispatchClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
	if state == "up" then
		-- Close all currently opened menus
		for k, menu in ipairs(self.m_OpenMenus) do
			delete(menu)
		end
	
		if button == "right" then
			if not element or not isElement(element) or not instanceof(element, Vehicle) then
				return
			end
		
			local elementType = getElementType(element)
			if self.m_Menu[elementType] --[[and not element == localPlayer]] then
				local mouseMenu = self.m_Menu[elementType]:new(absoluteX, absoluteY, element)
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
		end
	end
end
