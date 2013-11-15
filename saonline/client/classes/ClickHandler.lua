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
			if not element or not isElement(element) then
				return
			end
		
			local elementType = getElementType(element)
			if self.m_Menu[elementType] --[[and not element == localPlayer]] then
				local mouseMenu = self.m_Menu[elementType]:new(absoluteX, absoluteY)
				mouseMenu:setElement(element)
				table.insert(self.m_OpenMenus, mouseMenu)
			end
		end
	end
end
