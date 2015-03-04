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
	self.m_DrawCursor = false
	
	addEventHandler("onClientClick", root,
		function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
			if state == "up" then
				self.m_ClickInfo = {button = button, absoluteX = absoluteX, absoluteY = absoluteY, element = element}
			end
		end
	)

	addEventHandler("onClientCursorMove", root,
		function(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
			-- Do not draw if cursor is not visible and is not on top of any GUI element
			if not isCursorShowing() or GUIElement.getHoveredElement() then
				self.m_DrawCursor = false
				setCursorAlpha(255)
				return
			end
		
			local element = getElementBehindCursor(worldX, worldY, worldZ)
			if not element then
				self.m_DrawCursor = false
				setCursorAlpha(255)
				return
			end

			local clickInfo = {button = "left", absoluteX = absX, absoluteY = absY, element = element}

			-- ClickHandler:dispatchClick returns true if there is a special mouse event available, false otherwise
			self.m_DrawCursor = self:dispatchClick(clickInfo)
			if self.m_DrawCursor then
				setCursorAlpha(0)
			else
				setCursorAlpha(255)
			end
		end
	)

	addEventHandler("onClientRender", root,
		function()
			if self.m_DrawCursor then
				local cx, cy = getCursorPosition()
				
				if cx then
					-- Convert relative coordinates to absolute ones
					cx, cy = cx * screenWidth, cy * screenHeight

					dxDrawImage(cx-18/2, cy-32/2, 24, 24, "files/images/Mouse.png", 0, 0, 0, Color.White, true)
				end
			end	
		end
	)
end

function ClickHandler:invokeClick()
	if self.m_ClickInfo then
		self:dispatchClick(self.m_ClickInfo, true)
	end
	self.m_ClickInfo = false
end

function ClickHandler:clearClickInfo()
	self.m_ClickInfo = false
end

function ClickHandler:checkModels(model, ...)
	for k, v in pairs({...}) do
		if v == model then
			return true
		end
	end
	return false
end

function ClickHandler:dispatchClick(clickInfo, trigger)
	-- Disabled clickhandler as long as the player is not logged in
	if not localPlayer:isLoggedIn() then return end

	-- Close all currently open menus
	if trigger then self:clearMouseMenus() end
	
	-- Process CEF clicks
	if not trigger and WebUIManager:getInstance():isPositionWithinWindow(clickInfo.absoluteX, clickInfo.absoluteY) then
		return false
	end
	if trigger and WebUIManager:getInstance():invokeClick(clickInfo.button, "up", clickInfo.absoluteX, clickInfo.absoluteY) then
		return false
	end
	
	local element, button = clickInfo.element, clickInfo.button
	if not element or not isElement(element) then
		return false
	end
	local elementType = getElementType(element)
	local model = getElementModel(element)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local x, y, z = getElementPosition(element)
	local range = getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z)
	
	-- Phase 1: Check per-element handlers
	if element == localPlayer then
		if trigger then
			if button == "left" then
				SelfGUI:getSingleton():open()
			elseif button == "right" then
			end
		end
		return true
	end
	
	-- Phase 2: Check for world items
	if getElementData(element, "worlditem") then
		if trigger then
			if button == "left" then
				triggerServerEvent("worldItemClick", element)
			elseif button == "right" then
			end
		end
		return true
	end
	
	-- Phase 3: Check models
	if self:checkModels(model, 1775, 1776, 1209) then
		if trigger then
			if button == "left" then
				self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
			end
		end
		return true
	end
	if model == 2942 and range <= 8 then
		if trigger then
			if button == "left" then
				BankGUI:getSingleton():show()
			elseif button == "right" then
			end
		end
		return true
	end
	if model == 2886 then -- Keypad
		if trigger then
			if button == "left" then
				triggerServerEvent("keypadClick", element)
			end
		end
		return true
	end
	
	-- Phase 4: Check element types
	if self.m_Menu[elementType] then
		if trigger then
			if button == "left" then
				self:addMouseMenu(self.m_Menu[elementType]:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
			end
		end
		return true
	end

	return false
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
