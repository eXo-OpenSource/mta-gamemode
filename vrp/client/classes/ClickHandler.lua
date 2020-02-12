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
		[2977] = function(element) GunBoxGUI:new(element) end;
		[FERRIS_IDS.Gond] = function(element) FerrisWheel.onClientClickedGond(element) end;
		[2942] = function(element) BankGUI:getSingleton():show() end;
		[1775] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;
		[1776] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;
		[1209] = function(element, clickInfo) self:addMouseMenu(VendingMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end;
		[1676] = function(element, clickInfo) if element:getData("Name") and not localPlayer:getPrivateSync("hasMechanicFuelNozzle") then self:addMouseMenu(GasStationMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element) end end;
	}

	self.m_ClickInfo = false
	self.m_DrawCursor = false
	self.m_LastWorldModel = 0

	addEventHandler("onClientClick", root,
		function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
			if state == "up" then
				self.m_ClickInfo = {button = button, absoluteX = absoluteX, absoluteY = absoluteY, element = element, worldX = worldX, worldY = worldY, worldZ = worldZ}
			end
		end
	)

	addEventHandler("onClientCursorMove", root,
		function(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
			if not self.m_Rendered then return false end -- only update if client rendered a new frame (hack to get the args from onClientCursorMove but every onClientRender)
			self.m_Rendered = false
			-- Do not draw if cursor is not visible and is not on top of any GUI element
			if not isCursorShowing() or GUIElement.getHoveredElement() or GUIItemDragging:getSingleton():isDragging() then
				self.m_DrawCursor = false
				setCursorAlpha(255)
				return
			end

			local element = getElementBehindCursor(worldX, worldY, worldZ)
			if not MapEditor:isInstantiated() then
				if not element then
					self.m_DrawCursor = false
					setCursorAlpha(255)
					return
				end
			end

			local clickInfo = {button = "left", absoluteX = absX, absoluteY = absY, element = element, worldX = worldX, worldY = worldY, worldZ = worldZ}

			-- ClickHandler:dispatchClick returns true if there is a special mouse event available, false otherwise
			self.m_DrawCursor, self.m_WorldModelInfo = self:dispatchClick(clickInfo)
			if self.m_DrawCursor then
				setCursorAlpha(0)
			else
				setCursorAlpha(255)
			end
		end
	)

	addEventHandler("onClientRender", root,
		function()
			self.m_Rendered = true
			if self.m_DrawCursor then
				local cx, cy = getCursorPosition()

				if cx then
					-- Convert relative coordinates to absolute ones
					cx, cy = cx * screenWidth, cy * screenHeight

					dxDrawImage(cx-18/2, cy-32/2, 24, 24, "files/images/GUI/Mouse.png", 0, 0, 0, Color.White, true)
					if self.m_WorldModelInfo then
						local model = self.m_WorldModelInfo[1]
						local text = "Standart Map Objekt löschen:\nID:#EE1111 "..tostring(model).."#FFFFFF, Name:#EE1111 "..tostring(self.m_LastWorldModelName)
						local back = "Standart Map Objekt löschen:\nID: "..tostring(model)..", Name: "..tostring(self.m_LastWorldModelName)


						dxDrawText(back, (cx-18/2)+23, (cy-32/2), 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)
						dxDrawText(back, (cx-18/2)+23, (cy-32/2)-1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)

						dxDrawText(back, (cx-18/2)+24, (cy-32/2)-1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)
						dxDrawText(back, (cx-18/2)+25, (cy-32/2)-1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)

						dxDrawText(back, (cx-18/2)+25, (cy-32/2), 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)
						dxDrawText(back, (cx-18/2)+25, (cy-32/2)+1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)

						dxDrawText(back, (cx-18/2)+24, (cy-32/2)+1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)
						dxDrawText(back, (cx-18/2)+23, (cy-32/2)+1, 24, 24, Color.Black, 1.0, "default-bold", "left", "top", false, false, false, true)

						dxDrawText(text, (cx-18/2)+24, cy-32/2, 24, 24, Color.White, 1.0, "default-bold", "left", "top", false, false, false, true)

					end
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

	--check for WorldObjects for MapEditor
	if MapEditor:isInstantiated() then
		if MapEditor:getSingleton():getRemovingMode() then
			local worldModelId, wX, wY, wZ, wrX, wrY, wrZ, worldLODModelId = getWorldObjectBehindCursor(clickInfo.worldX, clickInfo.worldY, clickInfo.worldZ)
			if worldModelId then
				if clickInfo.element then
					return false
				end
				if worldModelId ~= self.m_LastWorldModel then
					self.m_LastWorldModel = worldModelId
					self.m_LastWorldModelName = MapEditor:getSingleton():getWorldModelName(worldModelId)
				end
				self.m_WorldObjectInfos = {worldModelId, wX, wY, wZ, wrX, wrY, wrZ, worldLODModelId} -- gets requested from Map Editor
				return true, self.m_WorldObjectInfos
			end
		end
	end

	local element, button = clickInfo.element, clickInfo.button
	if not element or not isElement(element) then
		return false
	end
	local elementType = getElementType(element)
	local model = getElementModel(element)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local x, y, z = getElementPosition(element)
	local range = localPlayer:getPrivateSync("isSpecting") and 0 or getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z)

	-- Phase 1: Check per-element handlers
	if element == localPlayer and button ~= "right" then
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
			end
		end
		return true
	end
	if getElementData(element, "worlditem_attachment") then
		if trigger then
			if button == "left" then
				local ele = getElementData(element, "worlditem_attachment")
				self:addMouseMenu(WorldItemMouseMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, ele), ele)
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
						elseif element:getData("onClickEvent") then
							element:getData("onClickEvent")()
						elseif element:getModel() == 1895 then -- Wheel of Fortune?
							triggerServerEvent("WheelOfFortuneClicked", element)
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
				else
					if self.m_Menu[elementType] == PlayerMouseMenu then
						self:addInspectMenu(InspectMenu:new(clickInfo.absoluteX, clickInfo.absoluteY, element), element)
					end
					return false
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
	-- check map editor things
	if MapEditor:isInstantiated() then

		if getElementData(element, "MapEditor:object") then
			if getElementData(element, "MapEditor:mapId") == MapEditor:getSingleton():getEditingMap() then
				return true
			end
		end

	end

	return false
end

function ClickHandler:addMouseMenu(menu, element)
	menu:setElement(element)
	table.insert(self.m_OpenMenus, menu)
end

function ClickHandler:addInspectMenu(menu, element)
	menu:setElement(element)
	table.insert(self.m_OpenMenus, menu)
end

function ClickHandler:clearMouseMenus()
	for k, menu in ipairs(self.m_OpenMenus) do
		delete(menu)
	end
	self.m_OpenMenus = {}
end
