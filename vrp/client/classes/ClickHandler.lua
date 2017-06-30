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

	self.m_ClickableModels = {
		[2922] = function(element) triggerServerEvent("keypadClick", element) end;
		[2977] = function(element) GunBoxGUI:new() end;
		[2942] = function(element) BankGUI:getSingleton():show() end;
		[1775] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;
		[1776] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;
		[1209] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;

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

					dxDrawImage(cx-18/2, cy-32/2, 24, 24, "files/images/GUI/Mouse.png", 0, 0, 0, Color.White, true)
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
	-- Focus if no element was clicked
	if trigger then Browser.focus(nil) guiSetInputEnabled(false) end

	-- Disabled clickhandler as long as the player is not logged in
	if not localPlayer:isLoggedIn() then return end
	if localPlayer.m_ObjectPlacerActive then return end
	if localPlayer.m_InChessGame then return end

	-- Close all currently open menus
	if trigger then self:clearMouseMenus() end

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
		--if trigger then
		--	if button == "left" then
			--	SelfGUI:getSingleton():open()
		--	elseif button == "right" then
		--	end
		--end
		return false
	end

	-- Phase 2: Check for world items
	if getElementData(element, "worlditem") then
		if trigger then
			if button == "left" then
				self:addMouseMenu(WorldItemMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
				--triggerServerEvent("worldItemClick", element)
			elseif button == "right" then
			end
		end
		return true
	end

	-- Phase 3: Check for clickable NPC
	if getElementData(element, "clickable") then
		if range < 10 then
			if trigger then
				if button == "left" then
					if getElementType(element) == "ped" then
						if getElementData(element, "BeggarId") then
							self:addMouseMenu(BeggarPedMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
						elseif element:getData("BugChecker") then
							self:addMouseMenu(BugCheckerPedMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
						elseif element:getData("Job") then
							element:getData("Job"):onPedClick()
						elseif element:getData("Townhall:onClick") then
							element:getData("Townhall:onClick")()
						elseif element:getData("onClickEvent") then
							element:getData("onClickEvent")()
						end
					elseif getElementType(element) == "object" then
						if getElementData(element, "bankPC") then
							self:addMouseMenu(BankPcMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
						end
					end

				end
			end
			return true
		end
	end

	-- Phase 4: Check models
	if self.m_ClickableModels[model] then
		if range < 10 then
			if trigger then
				if button == "left" then
					self.m_ClickableModels[model](element, clickInfo)
				end
			end
			return true
		end
	end

	-- Phase 5: Check element types
	if self.m_Menu[elementType] then
		if range < 10 and not localPlayer.m_inTuning then
			if trigger then
				if button == "left" then
					self:addMouseMenu(self.m_Menu[elementType]:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
				end
			end
			return true
		end
	end
	-- check vehicle attachments
	if getElementData(element, "vehicle-attachment") and isElement(getElementData(element, "vehicle-attachment")) then
		if range < 10 and not localPlayer.m_inTuning then
			if trigger then
				if button == "left" then
					self:addMouseMenu(self.m_Menu["vehicle"]:new(clickInfo.absoluteX, clickInfo.absoluteY, getElementData(element, "vehicle-attachment")), getElementData(element, "vehicle-attachment"))
				end
			end
			return true
		end
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
