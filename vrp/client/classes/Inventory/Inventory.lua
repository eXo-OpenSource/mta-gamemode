-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory class
-- *
-- ****************************************************************************

Inventory = inherit(Singleton)

function Inventory:constructor()
	self.InventoryKey = "i"
	self.Show = false
	self.m_ImagePath = "files/images/Inventory/"
	self.m_btn_inventar = {["Items"]= {}, ["Essen"]={}, ["Objekte"]={},  ["Drogen"]={}}
	self.m_startMoveButton = {}

	self.m_item = {}
	self.m_sitem = {}
	self.m_itemFront = {}

	self.m_BlipSize = 1.1
	self.m_TextSize = 0.8
	self.m_InfoBlipAlpha = 0

	local tabs = {["Items"]= {}, ["Essen"]={}, ["Objekte"]={},  ["Drogen"]={}}
	self.m_ItemPlaceR = tabs
	self.m_ItemPlaceG = tabs
	self.m_ItemPlaceB = tabs

	self.m_BagCurrent = "Items"
	self.m_BagOld = "Items"

	self.m_lockItemUseState = {}

	self.m_RenderInventar = bind(self.renderInventar, self)
	self.m_onButtonInvEnter = bind(self.onButtonInvEnter, self)
	self.m_onButtonInvLeave = bind(self.onButtonInvLeave, self)
	self.m_onInvClick = bind(self.onInvClick, self)
	self.m_onItemMouseOver = bind(self.onItemMouseOver, self)
	self.m_onItemMouseLeave = bind(self.onItemMouseLeave, self)
	self.m_MoveGUI = bind(self.MoveGUI, self)
	self.m_moveInfoWindow = bind(self.moveInfoWindow, self)
	self.m_onClickAndDropDown = bind(self.onClickAndDropDown, self)
	self.m_onClickAndDropUp = bind(self.onClickAndDropUp, self)
	self.m_onCloseClick = bind(self.onCloseClick, self)
	self.m_onMoveClick = bind(self.onMoveClick, self)
	self.m_onStopMove = bind(self.onStopMove, self)
	self.m_onResetClick = bind(self.onResetClick, self)
	self.m_onClientDragAndDropMove = bind(self.onClientDragAndDropMove, self)


	addRemoteEvents{"loadPlayerInventarClient", "setInventoryCoordinates", "onPlayerItemUse", "syncInventoryFromServer"}
	addEventHandler("loadPlayerInventarClient",  root,  bind(self.Event_loadPlayerInventarClient,  self))
	addEventHandler("syncInventoryFromServer",  root,  bind(self.Event_syncInventoryFromServer,  self))

	addEventHandler("setInventoryCoordinates", root,  bind(self.Event_setInventoryCoordinates,  self))
	addEventHandler("onPlayerItemUse", root,  bind(self.Event_onItemClick,  self))

end

function Inventory:destructor()

end

function Inventory:Event_syncInventoryFromServer(bag, items)
	self.m_Bag = bag
	self.m_Items = items
end

function Inventory:Event_loadPlayerInventarClient(slots, itemData)
	self.m_Slots = slots
	self.m_ItemData = itemData
	bindKey(self.InventoryKey, "down", bind(self.toggle,  self))
end

function Inventory:toggle()
	if self.Show == true then
		self:hide()
	else
		self:show()
	end
end

function Inventory:getRealItemName(name)
	local nstring, w = string.gsub(name, "Drogen/", "")
	return nstring
end

function Inventory:getPlaceMouseOver()
	local mx, my =  getCursorPosition()
	for i=0, self.m_SlotsCurrent-1, 1 do
		if(self.m_btn_inventar[self.m_BagCurrent][i]) then
			local x, y = guiGetPosition(self.m_btn_inventar[self.m_BagCurrent][i], true)
			local bx, by = guiGetSize(self.m_btn_inventar[self.m_BagCurrent][i], true)
			bx, by = bx +x ,  by +y
			if(mx > x and mx < bx and my > y and my < by) then
				return self.m_btn_inventar[self.m_BagCurrent][i]
			end
		end
	end
	return false
end

function Inventory:onItemMouseOver()
	local src = false
	for i=0, self.m_SlotsCurrent-1, 1 do
		if(source == self.m_btn_inventar[self.m_BagCurrent][i]) then
			src = true
		end
	end
	if(src ~= true) then
		return 0
	end

	if(self.m_showInfoBlip == true) then
		return false
	end
	if(not self.m_lockItemUseState[self.m_BagCurrent] or not self.m_lockItemUseState[self.m_BagCurrent][tonumber(guiGetText(source))]) then
		self:setItemRGB(tonumber(guiGetText(source)), 255, 255, 0)
	end

	self.m_InfoBlipTimer = setTimer(function(button)
		self:showInfoBlipFunc(button)
	end, 500, 1, source)
end

function Inventory:onItemMouseLeave()
	local src = false
	for i=0, self.m_SlotsCurrent-1, 1 do
		if(source == self.m_btn_inventar[self.m_BagCurrent][i]) then
			src = true
		end
	end
	if(src ~= true ) then
		return false
	end
	if(( ( self.m_lockItemUseState[self.m_BagCurrent] and self.m_lockItemUseState[self.m_BagCurrent][tonumber(guiGetText(source))] ) )) then

	else
		self:setItemRGB(tonumber(guiGetText(source)),  110, 110, 110 )
	end

	if(self.m_showInfoBlip) then
		self.m_showInfoBlip = false
		self.m_InfoBlipAlpha = 0
		removeEventHandler("onClientMouseMove", root, self.moveInfoWindow)
	end
	if isTimer(self.m_InfoBlipTimer) then killTimer(self.m_InfoBlipTimer) end
end

function Inventory:onCloseClick(button)
	if(button == "left") then
		self:hide()
	end
end

function Inventory:MoveGUI(mx, my)
	self.m_X, self.m_Y = mx - self.m_mouseDistX,  my - self.m_mouseDistY
	self.m_SlotsCurrent = self.m_Slots[self.m_BagCurrent]
	local lineCurrent, lineOld, place
	for i=0, self.m_SlotsCurrent-1, 1 do
		lineCurrent = math.floor(i/7)
		if(lineCurrent ~= lineOld) then
			place = 0
		end
		local id
		if self.m_Bag[self.m_BagCurrent] then
			id = self.m_Bag[self.m_BagCurrent][i]
			if(id) then
				self.m_item[id]= { ["x"]= self.m_X+10 + 40 * place + 5 * place, ["y"]=self.m_Y+10 + 40 * lineCurrent + 5 * lineCurrent }
			end
		end
		guiSetPosition ( self.m_btn_inventar[self.m_BagCurrent][i],  self.m_X+10 + 40 * place + 5 * place, self.m_Y+10 + 40 * lineCurrent+ 5 * lineCurrent,  false )
		self.m_sitem[i]= { ["x"]= self.m_X+10 + 40 * place + 5 * place, ["y"]=self.m_Y+10 + 40 * lineCurrent + 5 * lineCurrent }
		lineOld = lineCurrent
		place = place + 1
	end
	guiSetPosition ( self.m_btn_Items,  self.m_X+2, self.m_Y-48,  false )
	guiSetPosition ( self.m_btn_Objekte , self.m_X+2 + 82, self.m_Y-48,  false )
	guiSetPosition ( self.m_btn_Essen ,  self.m_X+2 + 82*2, self.m_Y-48,  false )
	guiSetPosition ( self.m_btn_Drogen,  self.m_X+2 + 82*3, self.m_Y-48,  false )
	guiSetPosition ( self.m_btn_Close ,  self.m_X+self.m_BX + 1, self.m_Y-49,  false )
	guiSetPosition ( self.m_btn_Move,  self.m_X+self.m_BX + 1, self.m_Y-49+18,  false )
	guiSetPosition ( self.m_btn_Reset,  self.m_X+self.m_BX + 1, self.m_Y-49+36,  false )

end

function Inventory:onMoveClick(button, mx, my)
	if(button == "left") then
		self.m_mouseDistX, self.m_mouseDistY = mx - self.m_X,  my - self.m_Y
		addEventHandler("onClientMouseMove", root, self.m_MoveGUI)
	end
end

function Inventory:onStopMove(button)
	if(button == "left") then
		removeEventHandler("onClientMouseMove", root, self.m_MoveGUI)
	end
end

function Inventory:onResetClick(button)
	if(button == "left") then
		self.m_X, self.m_Y = screenWidth/2 - self.m_BX/2, screenHeight/2 - self.m_BY/2
		self.m_SlotsCurrent = self.m_Slots[self.m_BagCurrent]
		local line, oline, place
		for i=0, self.m_SlotsCurrent-1, 1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				place = 0
			end
			local id
			if(	self.m_Bag[self.m_BagCurrent] ) then
				id = self.m_Bag[self.m_BagCurrent][i]
				if(id) then
					self.m_item[id]= { ["x"]= self.m_X+10 + 40 * place + 5 * place, ["y"]=self.m_Y+10 + 40 * line + 5 * line }
				end
			end
			guiSetPosition ( self.m_btn_inventar[self.m_BagCurrent][i],  self.m_X+10 + 40 * place + 5 * place, self.m_Y+10 + 40 * line + 5 * line,  false )
			self.m_sitem[i]= { ["x"]= self.m_X+10 + 40 * place + 5 * place, ["y"]=self.m_Y+10 + 40 * line + 5 * line }
			oline = line
			place = place + 1
		end
		guiSetPosition ( self.m_btn_Items,  self.m_X+2, self.m_Y-48,  false )
		guiSetPosition ( self.m_btn_Objekte , self.m_X+2 + 82, self.m_Y-48,  false )
		guiSetPosition ( self.m_btn_Essen ,  self.m_X+2 + 82*2, self.m_Y-48,  false )
		guiSetPosition ( self.m_btn_Drogen,  self.m_X+2 + 82*3, self.m_Y-48,  false )
		guiSetPosition ( self.m_btn_Close ,  self.m_X+self.m_BX + 1, self.m_Y-49,  false )
		guiSetPosition ( self.m_btn_Move,  self.m_X+self.m_BX + 1, self.m_Y-49+18,  false )
		guiSetPosition ( self.m_btn_Reset,  self.m_X+self.m_BX + 1, self.m_Y-49+36,  false )
	end
end

function Inventory:renderInventar()
	dxDrawImage(self.m_X, self.m_Y-95, 50, 50, ":vrp/files/images/logo.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(self.m_X, self.m_Y-50, 82.0, 50.0, tocolor(self.m_R["Rahmen"], self.m_G["Rahmen"], self.m_B["Rahmen"], 255), false)
	dxDrawRectangle(self.m_X+2, self.m_Y-48, 80.0, 48.0, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(self.m_X+2.0, self.m_Y-48, 80.0, 48.0, tocolor(self.m_R["Items"], self.m_G["Items"], self.m_B["Items"], 200), false)
	dxDrawImage(self.m_X+20, self.m_Y-48, 48.0, 48.0, self.m_ImagePath.."items.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(self.m_X + 82, self.m_Y-50, 82.0, 50.0, tocolor(self.m_R["Rahmen"], self.m_G["Rahmen"], self.m_B["Rahmen"], 255), false)
	dxDrawRectangle(self.m_X+2 + 82, self.m_Y-48, 80.0, 48.0, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(self.m_X+2 + 82, self.m_Y-48, 80.0, 48.0, tocolor(self.m_R["Objekte"], self.m_G["Objekte"], self.m_B["Objekte"], 200), false)
	dxDrawImage(self.m_X+20 + 82, self.m_Y-48, 48.0, 48.0, self.m_ImagePath.."items/Objekte.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(self.m_X + 82*2, self.m_Y-50, 82.0, 50.0, tocolor(self.m_R["Rahmen"], self.m_G["Rahmen"], self.m_B["Rahmen"], 255), false)
	dxDrawRectangle(self.m_X+2 + 82*2, self.m_Y-48, 80.0, 48.0, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(self.m_X+2 + 82*2, self.m_Y-48, 80.0, 48.0, tocolor(self.m_R["Essen"], self.m_G["Essen"], self.m_B["Essen"], 200), false)
	dxDrawImage(self.m_X+20 + 82*2, self.m_Y-48, 48.0, 48.0, self.m_ImagePath.."food.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(self.m_X + 82*3, self.m_Y-50, 84.0, 50.0, tocolor(self.m_R["Rahmen"], self.m_G["Rahmen"], self.m_B["Rahmen"], 255), false)
	dxDrawRectangle(self.m_X+2 + 82*3, self.m_Y-48, 80.0, 48.0, tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(self.m_X+2 + 82*3, self.m_Y-48, 80.0, 48.0, tocolor(self.m_R["Drogen"], self.m_G["Drogen"], self.m_B["Drogen"], 200), false)
	dxDrawImage(self.m_X+20 + 82*3, self.m_Y-48, 48.0, 48.0, self.m_ImagePath.."drogen.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(self.m_X+self.m_BX , self.m_Y-50, 20.0, 56.0, tocolor(0, 0, 0, 200), false)

	dxDrawRectangle(self.m_X, self.m_Y, self.m_BX, self.m_BY, tocolor(self.m_R["Rahmen"], self.m_G["Rahmen"], self.m_B["Rahmen"], 255), false)
	dxDrawRectangle(self.m_X+2, self.m_Y+2, self.m_BX-4, self.m_BY-4, tocolor(50, 200, 255, 255), false)
	dxDrawText("Verwende Items mit der linken Maustaste\nZum Verschieben benutze die rechte Maustaste!", self.m_X, self.m_Y+self.m_BY+2, self.m_X+self.m_BX, self.m_Y+self.m_BY+4, tocolor(255, 255, 255, 255),  1.2,  "defauld-bold", "center", "top")
	dxDrawText("Mit /handel [NAME] kannst du mit deinen Items handeln!", self.m_X, self.m_Y+self.m_BY+45, self.m_X+self.m_BX, self.m_Y+self.m_BY+55, tocolor(50, 200, 255, 255),  0.9,  "defauld-bold", "center", "bottom")

	dxDrawImage(self.m_X+self.m_BX + 1, self.m_Y-49, 18, 18, self.pClose, 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)
	dxDrawImage(self.m_X+self.m_BX + 1, self.m_Y-49+18, 18.0, 18.0, self.pMove, 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)
	dxDrawImage(self.m_X+self.m_BX + 1, self.m_Y-49+36, 18.0, 18.0, self.pReset, 0.0, 0.0, 0.0, tocolor(255, 255, 255, 255), false)

	local line,oline,place
	for i=0, self.m_SlotsCurrent-1, 1 do
		line = math.floor(i/7)
		if(line ~= oline) then
			place = 0
		end
		if(not self.m_ItemPlaceR[self.m_BagCurrent][i]) then
			if(not self.m_lockItemUseState[self.m_BagCurrent] or not self.m_lockItemUseState[self.m_BagCurrent][i]) then
				self:setItemRGB(i, 110, 110, 110)
			end
		end
		dxDrawRectangle(self.m_X+10 + 40 * place + 5 * place, self.m_Y+10 + 40 * line + 5 * line, 40, 40, tocolor(self.m_ItemPlaceR[self.m_BagCurrent][i], self.m_ItemPlaceG[self.m_BagCurrent][i], self.m_ItemPlaceB[self.m_BagCurrent][i], 200), false)
		local id = self.m_Bag[self.m_BagCurrent][i]
		if(id) then
			local rx, gx, bx = self.m_ItemPlaceR[self.m_BagCurrent][i] - 10, self.m_ItemPlaceG[self.m_BagCurrent][i]- 10, self.m_ItemPlaceB[self.m_BagCurrent][i]- 10
			local a = 255
			if (rx == 100) then
				rx, gx, bx = 255, 255, 255
				a = 180
			end
			local itemName = self.m_Items[id]["Objekt"]
			if itemName then
				local icon = self.m_ItemData[itemName]["Icon"]
				dxDrawImage(self.m_item[id]["x"], self.m_item[id]["y"], 40, 40, self.m_ImagePath.."items/"..icon, 0.0, 0.0, 0.0, tocolor(rx, gx, bx, 255), self.m_itemFront[id])
				dxDrawText(tostring(self.m_Items[id]["Menge"]), self.m_item[id]["x"] + 40 - dxGetTextWidth (tostring(self.m_Items[id]["Menge"] ,  0.85,  "defauld-bold")), self.m_item[id]["y"] + 27.25, 40, 40, tocolor(rx, gx, bx, a), 0.85, "default-bold", "left", "top", false, false, self.m_itemFront[id])
			end
		end
		oline = line
		place = place + 1
	end

	if(self.m_showInfoBlip == true) then
		self:showInfo(self.m_BlipItemName, self.m_BlipItemText, IBx, IBy, Itx, Ity, Iobx, Ioby, Ibx, Iby)
	end
end

function Inventory:onClientDragAndDropMove()
	local mx, my = getCursorPosition ()
	local x, y = self.m_startMoveButton["x"], self.m_startMoveButton["y"]
	local fx, fy = self.m_startMoveButton["bx"] + x, self.m_startMoveButton["by"] + y
	local button = self.m_startMoveButton["object"]
	local place
	if(self.m_Bag[self.m_BagCurrent] ~= false) then
		place = self.m_Bag[self.m_BagCurrent][tonumber(guiGetText(button))]
	else
		place = nil
	end

	if(self.m_showInfoBlip) then
		self.m_showInfoBlip = false
		self.m_InfoBlipAlpha = 0
		removeEventHandler("onClientMouseMove", root, self.m_moveInfoWindow)
	end
	if isTimer(self.m_InfoBlipTimer) then killTimer(self.m_InfoBlipTimer) end
	if(self:getPlaceMouseOver() ~= button) then
		triggerEvent("onClientMouseLeave", button)
	end
	if(place) then

		local place = tonumber(guiGetText(button))

		local fullx, fully = guiGetScreenSize()
		mx, my = mx*fullx, my*fully
		if(	self.m_Bag[self.m_BagCurrent] ) then
			id = self.m_Bag[self.m_BagCurrent][place]
			if(id) then
				self.m_item[tonumber(id)] = { ["x"]= mx, ["y"]=my }
			end
		end

		if(isElement(self:getPlaceMouseOver())) then
			triggerEvent("onClientMouseEnter", self:getPlaceMouseOver())
			if(isElement(self.m_lastOver) and self.m_lastOver ~= self:getPlaceMouseOver()) then
				triggerEvent("onClientMouseLeave", self.m_lastOver)
			end
			self.m_lastOver = self:getPlaceMouseOver()
		elseif(isElement(self.m_lastOver)) then
			triggerEvent("onClientMouseLeave", self.m_lastOver)
			self.m_lastOver = nil
		end
	else
		self.m_startMoveButton = nil
		removeEventHandler("onClientPreRender", root, self.m_onClientDragAndDropMove)
	end
end

function Inventory:onClickAndDropDown(button)
	local id

	if(self.m_Bag[self.m_BagCurrent]) then
		id = self.m_Bag[self.m_BagCurrent][tonumber(guiGetText(source))]
	end

	if button == "left" then
		if(id) then
			local itemname = self.m_Items[id]["Objekt"]
			local item = self.m_Items[id]
			if item then
				triggerEvent("onPlayerItemUse", localPlayer, id, self.m_BagCurrent, tonumber(guiGetText(source)))
			end
		end
		return false
	else
		local src
		for i=0, self.m_SlotsCurrent-1, 1 do
			if(source == self.m_btn_inventar[self.m_BagCurrent][i]) then
				src = true
			end
		end
		if(src ~= true) then
			if(source ~= self.m_btn_Move and (source == self.m_btn_Items or source == self.m_btn_Objekte or source == self.m_btn_Essen or source == self.m_btn_Drogen or source == self.m_btn_Close or source == self.m_btn_Reset) ) then
				self.m_startMoveButton = { ["object"] = source }
				self.m_startMoveButton["x"], self.m_startMoveButton["y"] = guiGetPosition ( source,  true )
				self.m_startMoveButton["bx"], self.m_startMoveButton["by"] = guiGetSize ( source,  true )
				addEventHandler("onClientPreRender", root, self.m_onClientDragAndDropMove)
				return false
			end
			return false
		end

		if(id) then
			self.m_itemFront[id] = true
		end

		self.m_startMoveButton = { ["object"] = source }
		self.m_startMoveButton["x"], self.m_startMoveButton["y"] = guiGetPosition ( source,  true )
		self.m_startMoveButton["bx"], self.m_startMoveButton["by"] = guiGetSize ( source,  true )
		addEventHandler("onClientPreRender", root, self.m_onClientDragAndDropMove)
	end
end

function Inventory:onClickAndDropUp(button)
	local src
	for i=0, self.m_SlotsCurrent-1, 1 do
		if(source == self.m_btn_inventar[self.m_BagCurrent][i]) then
			src = true
		end
	end

	if self.m_startMoveButton and self.m_startMoveButton["object"] then
		local place = false
		local splace = tonumber(guiGetText(self.m_startMoveButton["object"]))

		if(src ~= true) then
			if(source ~= self.m_btn_Move and (source == self.m_btn_Items or source == self.m_btn_Objekte or source == self.m_btn_Essen or source == self.m_btn_Drogen or source == self.m_btn_Close or source == self.m_btn_Reset) ) then

				removeEventHandler("onClientPreRender", root, self.m_onClientDragAndDropMove)
				self.m_startMoveButton = nil
				self.m_lastOver = nil

				self:inventarSetItemToPlace(id, splace)
				--return false
			end
			self:inventarSetItemToPlace(id, splace)
			--return false
		end

		if self:getPlaceMouseOver() then
			place = tonumber(guiGetText(self:getPlaceMouseOver()))
			local nid = self.m_Bag[self.m_BagCurrent][place]
			if(nid) then
				local oPlace = tonumber(guiGetText(self.m_startMoveButton["object"]))

				local id = self.m_Bag[self.m_BagCurrent][splace]
				local itemname_moved = self.m_Items[id]["Objekt"]
				local itemname_old = self.m_Items[nid]["Objekt"]
				if id ~= nid then
					if itemname_moved == itemname_old then
						local itemmenge_moved = self.m_Items[id]["Menge"]
						local itemmenge_old = self.m_Items[nid]["Menge"]
						local gesamt = itemmenge_moved+itemmenge_old
						if self.m_ItemData[itemname_moved]["Stack_max"] >= gesamt then
							triggerServerEvent("c_stackItems", localPlayer, id, nid, place)
						else
							outputChatBox("Der Stack von Item '"..itemname_moved.."' darf nur "..self.m_ItemData[itemname_moved]["Stack_max"].." betragen!", 255, 0, 0)
						end
					else
						outputChatBox("Du kannst nur gleiche Items stapeln!", 255, 0, 0)
					end
				end

				self:inventarSetItemToPlace(id, place)
				self:inventarSetItemToPlace(nid, splace)

				if(self.m_lockItemUseState[self.m_BagCurrent] and self.m_lockItemUseState[self.m_BagCurrent][splace]) then
					self:setItemsRGBDefault(self.m_BagCurrent)
					self:setItemRGB(splace, 50, 200, 255)
					self.m_lockItemUseState[self.m_BagCurrent] = {[splace]=true}
				end
				triggerServerEvent("changePlaces", localPlayer, self.m_BagCurrent, oPlace, place)
			else
				local id = self.m_Bag[self.m_BagCurrent][splace]
				if(self.m_lockItemUseState[self.m_BagCurrent] and self.m_lockItemUseState[self.m_BagCurrent][splace]) then
					self:setItemsRGBDefault(self.m_BagCurrent)
					self:setItemRGB(tonumber(place), 50, 200, 255)
					self.m_lockItemUseState[self.m_BagCurrent] = {[tonumber(place)]=true}

				end

				self:inventarSetItemToPlace(id, place)
				triggerServerEvent("c_setItemPlace", localPlayer, self.m_BagCurrent, splace, tonumber(place))
			end
		else
			local mx, my = getCursorPosition ( )
			mx, my = mx *screenWidth, my*screenHeight

			if(mx >= self.m_X and mx <= self.m_X+self.m_BX and my >= self.m_Y-50 and my <= self.m_Y+self.m_BY) then
				local id = self.m_Bag[self.m_BagCurrent][splace]
				self:inventarSetItemToPlace(id, splace)
				if(self.m_lockItemUseState[self.m_BagCurrent] and self.m_lockItemUseState[self.m_BagCurrent][splace]) then
					self:setItemsRGBDefault(self.m_BagCurrent)

				--	outputChatBox("To Green")
					--setItemRGB(splace, 0, 255, 0, true)
					--self.m_lockItemUseState[self.m_BagCurrent] = {[splace] = true}
				end
			else
				local id = self.m_Bag[self.m_BagCurrent][splace]
				local itemname = self.m_Items[id]["Objekt"]
				if self.m_ItemData[itemname]["Wegwerf"] == 1 then
					--triggerServerEvent("layItemInWorld_c", localPlayer, localPlayer, self.m_BagCurrent, id)
					triggerServerEvent("throwItem", localPlayer, itemname, self.m_BagCurrent, id, splace)
				else
					self:inventarSetItemToPlace(id, splace)
					outputChatBox("Dieses Item kann nicht weggeworfen werden!", 255, 0, 0)
				end
			end
		end
	end
	removeEventHandler("onClientPreRender", root, self.m_onClientDragAndDropMove)
	self.m_startMoveButton = nil
	self.m_lastOver = nil

	local id
	if(self.m_Bag[self.m_BagCurrent]) then id = self.m_Bag[self.m_BagCurrent][guiGetText(source)] end
	if(id) then	self.m_itemFront[id] = false end
end

function Inventory:show()
	if self.Show == false then
		self.Show = true
		showCursor ( true , false)
		toggleControl ( "fire",  false)
		triggerServerEvent("refreshInventory", localPlayer)

		self.m_screenGUI = guiCreateStaticImage(0, 0, screenWidth, screenHeight, "files/images/Logo.png", false)
		guiSetAlpha(self.m_screenGUI, 0)
		self.pClose, self.pMove, self.pReset = self.m_ImagePath.."closeinv.png", self.m_ImagePath.."moveinv.png", self.m_ImagePath.."reset.png"
		self.m_R, self.m_G, self.m_B = { ["Items"]=50, ["Essen"]=50, ["Objekte"]=50, ["Drogen"]=50,  ["Rahmen"]=255} ,  { ["Items"]=200, ["Essen"]=200, ["Objekte"]=200, ["Drogen"]=200 , ["Rahmen"]=255} ,  { ["Items"]=255, ["Essen"]=255, ["Objekte"]=255, ["Drogen"]=255, ["Rahmen"]=255 }

		self.m_SlotsCurrent = self.m_Slots[self.m_BagCurrent]
		lines = math.ceil(self.m_SlotsCurrent/7)
		self.m_BX, self.m_BY = 330,  20 - 4 + 45*lines --543, 266
		if(not self.m_X and not self.m_Y) then
			self.m_X, self.m_Y = screenWidth/2 - self.m_BX/2, screenHeight/2 - self.m_BY/2
		end
		self.m_R[self.m_BagCurrent], self.m_G[self.m_BagCurrent], self.m_B[self.m_BagCurrent] = 100, 130, 140
		self.m_R["o"..self.m_BagCurrent], self.m_G["o"..self.m_BagCurrent], self.m_B["o"..self.m_BagCurrent] = 0, 255, 0
		local line
		local oline
		local place

		for i=0, self.m_SlotsCurrent-1, 1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				place = 0
			end
			self.m_btn_inventar[self.m_BagCurrent][i] = guiCreateButton (self.m_X+10 + 40 * place + 5 * place, self.m_Y+10 + 40 * line + 5 * line, 40, 40,  i.."",  false)
			guiSetAlpha(self.m_btn_inventar[self.m_BagCurrent][i], 0)
			local id
			if(	self.m_Bag[self.m_BagCurrent] ) then
				id = self.m_Bag[self.m_BagCurrent][i]
				if(id) then
					self.m_item[id]= { ["x"]= self.m_X+10 + 40 * place + 5 * place , ["y"]=self.m_Y+10 + 40 * line + 5 * line }
					self.m_itemFront[id] = false
				end
			end
			if(not self.m_lockItemUseState[self.m_BagCurrent] or not self.m_lockItemUseState[self.m_BagCurrent][tonumber(i)]) then
				self:setItemRGB(i, 110, 110, 110)
			end
			self.m_sitem[i]= { ["x"]= self.m_X+10 + 40 * place + 5 * place, ["y"]=self.m_Y+10 + 40 * line + 5 * line }
			oline = line
			place = place + 1
		end

		self.m_btn_Items = guiCreateButton (self.m_X+2, self.m_Y-48, 80.0, 48.0,  "",  false)
		guiSetAlpha(self.m_btn_Items, 0)
		self.m_btn_Objekte = guiCreateButton ( self.m_X+2 + 82, self.m_Y-48,  80.0, 48.0,  "",  false )
		guiSetAlpha(self.m_btn_Objekte, 0)
		self.m_btn_Essen = guiCreateButton ( self.m_X+2 + 82*2, self.m_Y-48,  80.0, 48.0,  "",  false )
		guiSetAlpha(self.m_btn_Essen, 0)
		self.m_btn_Drogen = guiCreateButton ( self.m_X+2 + 82*3, self.m_Y-48,  80.0, 48.0,  "",  false )
		guiSetAlpha(self.m_btn_Drogen, 0)
		self.m_btn_Close = guiCreateButton ( self.m_X+self.m_BX + 1, self.m_Y-49,  18, 18,  "",  false  )
		guiSetAlpha(self.m_btn_Close, 0)
		self.m_btn_Move = guiCreateButton ( self.m_X+self.m_BX + 1, self.m_Y-49+18,  18, 18,  "",  false )
		guiSetAlpha(self.m_btn_Move, 0)
		self.m_btn_Reset = guiCreateButton ( self.m_X+self.m_BX + 1, self.m_Y-49+36,  18, 18,  "",  false )
		guiSetAlpha(self.m_btn_Reset, 0)


		addEventHandler("onClientMouseEnter", root, self.m_onButtonInvEnter)
		addEventHandler("onClientMouseLeave", root, self.m_onButtonInvLeave)
		addEventHandler("onClientGUIClick", root, self.m_onInvClick)

		addEventHandler("onClientMouseEnter", root, self.m_onItemMouseOver)
		addEventHandler("onClientMouseLeave", root, self.m_onItemMouseLeave)

		addEventHandler("onClientGUIClick", self.m_btn_Close, self.m_onCloseClick)
		addEventHandler("onClientGUIMouseDown", self.m_btn_Move, self.m_onMoveClick)
		addEventHandler("onClientGUIMouseUp", self.m_btn_Move, self.m_onStopMove)
		addEventHandler("onClientGUIClick", self.m_btn_Reset, self.m_onResetClick)

		addEventHandler("onClientGUIMouseDown", root, self.m_onClickAndDropDown)
		addEventHandler("onClientGUIMouseUp", root, self.m_onClickAndDropUp)


		addEventHandler("onClientRender", root, self.m_RenderInventar)
	end
end

function Inventory:hide()

	if self.Show == true then
		self.Show = false
		showCursor ( false )
		toggleControl ( "fire",  true)

		removeEventHandler("onClientRender", root, self.m_RenderInventar)
		removeEventHandler("onClientMouseEnter", root, self.m_onButtonInvEnter)
		removeEventHandler("onClientMouseLeave", root, self.m_onButtonInvLeave)
		removeEventHandler("onClientGUIClick", root, self.m_onInvClick)

		removeEventHandler("onClientMouseEnter", root, self.m_onItemMouseOver)
		removeEventHandler("onClientMouseLeave", root, self.m_onItemMouseLeave)

		removeEventHandler("onClientGUIMouseDown", root, self.m_onClickAndDropDown)
		removeEventHandler("onClientGUIMouseUp", root, self.m_onClickAndDropUp)

		destroyElement(self.m_screenGUI)
		destroyElement(self.m_btn_Items)
		destroyElement(self.m_btn_Objekte)
		destroyElement(self.m_btn_Essen)
		destroyElement(self.m_btn_Drogen)
		destroyElement(self.m_btn_Close)
		destroyElement(self.m_btn_Move)
		destroyElement(self.m_btn_Reset)
		self.m_btn_Items = nil
		self.m_sitem = {}
		self.m_item = {}
		if(isTimer(self.m_InfoBlipTimer) and getTimerDetails(self.m_InfoBlipTimer)) then
			killTimer(self.m_InfoBlipTimer)
		end
		if(self.m_callCheck == true) then
			local slots = self.m_Slots[self.m_BagOld]
			for i=0, slots-1, 1 do
				destroyElement(self.m_btn_inventar[self.m_BagOld][i])
			end
			self.m_callCheck = false
		else
			local slots = self.m_Slots[self.m_BagCurrent]
			for i=0, slots-1, 1 do
				destroyElement(self.m_btn_inventar[self.m_BagCurrent][i])
			end
		end

		self.m_showInfoBlip = false
		self.m_InfoBlipAlpha = 0
	end
end

function Inventory:onInvClick(button)
	if button == "left" then
		if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen) then
			return 0
		end
		self.m_BagOld = self.m_BagCurrent
		if( source == self.m_btn_Items and self.m_BagCurrent ~= "Items") then
			self.m_BagCurrent = "Items"
		elseif( source == self.m_btn_Objekte and self.m_BagCurrent ~= "Objekte") then
			self.m_BagCurrent = "Objekte"
		elseif( source == self.m_btn_Essen and self.m_BagCurrent ~= "Essen") then
			self.m_BagCurrent = "Essen"
		elseif( source == self.m_btn_Drogen and self.m_BagCurrent ~= "Drogen") then
			self.m_BagCurrent = "Drogen"
		else
			return 0
		end
		self.m_R[self.m_BagOld], self.m_G[self.m_BagOld], self.m_B[self.m_BagOld] = 110, 110, 110
		self.m_callCheck = true
		self:hide()
		self:show()
	end
end

function Inventory:onButtonInvEnter()
	if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen and source ~= self.m_btn_Close and source ~= self.m_btn_Move and source ~= self.m_btn_Reset) then
		return 1
	end

	if( source == self.m_btn_Items) then
		if(self.m_BagCurrent == "Items") then
			return 0
		end
		self.m_R["oItems"], self.m_G["oItems"], self.m_B["oItems"] = self.m_R["Items"], self.m_G["Items"], self.m_B["Items"]
		self.m_R["Items"], self.m_G["Items"], self.m_B["Items"] = 100, 130, 140
	elseif( source == self.m_btn_Objekte) then
		if(self.m_BagCurrent == "Objekte") then
			return 0
		end
		self.m_R["oObjekte"], self.m_G["oObjekte"], self.m_B["oObjekte"] = self.m_R["Objekte"], self.m_G["Objekte"], self.m_B["Objekte"]
		self.m_R["Objekte"], self.m_G["Objekte"], self.m_B["Objekte"] = 100, 130, 140
	elseif( source == self.m_btn_Essen) then
		if(self.m_BagCurrent == "Essen") then
			return 0
		end
		self.m_R["oEssen"], self.m_G["oEssen"], self.m_B["oEssen"] = self.m_R["Essen"], self.m_G["Essen"], self.m_B["Essen"]
		self.m_R["Essen"], self.m_G["Essen"], self.m_B["Essen"] = 100, 130, 140
	elseif( source == self.m_btn_Drogen) then
		if(self.m_BagCurrent == "Drogen") then
			return 0
		end
		self.m_R["oDrogen"], self.m_G["oDrogen"], self.m_B["oDrogen"] = self.m_R["Drogen"], self.m_G["Drogen"], self.m_B["Drogen"]
		self.m_R["Drogen"], self.m_G["Drogen"], self.m_B["Drogen"] = 100, 130, 140
	elseif( source == self.m_btn_Close) then
		self.pClose = self.m_ImagePath.."closeinvS.png"
	elseif( source == self.m_btn_Move) then
		self.pMove = self.m_ImagePath.."moveinvS.png"
	elseif( source == self.m_btn_Reset) then
		self.pReset = self.m_ImagePath.."resetS.png"
	end
end

function Inventory:onButtonInvLeave()
	if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen and source ~= self.m_btn_Close and source ~= self.m_btn_Move and source ~= self.m_btn_Reset) then
		return 1
	end
	if( source == self.m_btn_Items) then
		if(self.m_BagCurrent == "Items") then
			return 0
		end
		self.m_R["Items"], self.m_G["Items"], self.m_B["Items"] = self.m_R["oItems"], self.m_G["oItems"], self.m_B["oItems"]
	elseif( source == self.m_btn_Objekte) then
		if(self.m_BagCurrent == "Objekte") then
			return 0
		end
		self.m_R["Objekte"], self.m_G["Objekte"], self.m_B["Objekte"] = self.m_R["oObjekte"], self.m_G["oObjekte"], self.m_B["oObjekte"]
	elseif( source == self.m_btn_Essen) then
		if(self.m_BagCurrent == "Essen") then
			return 0
		end
		self.m_R["Essen"], self.m_G["Essen"], self.m_B["Essen"] = self.m_R["oEssen"], self.m_G["oEssen"], self.m_B["oEssen"]
	elseif( source == self.m_btn_Drogen) then
		if(self.m_BagCurrent == "Drogen") then
			return 0
		end
		self.m_R["Drogen"], self.m_G["Drogen"], self.m_B["Drogen"] = self.m_R["oDrogen"], self.m_G["oDrogen"], self.m_B["oDrogen"]
	elseif( source == self.m_btn_Close) then
		self.pClose = self.m_ImagePath.."closeinv.png"
	elseif( source == self.m_btn_Move) then
		self.pMove = self.m_ImagePath.."moveinv.png"
	elseif( source == self.m_btn_Reset) then
		self.pReset = self.m_ImagePath.."reset.png"
	end

end

function Inventory:inventarSetItemToPlace(id, place)
	self.m_item[tonumber(id)] = {["x"]=self.m_sitem[tonumber(place)]["x"], ["y"]=self.m_sitem[tonumber(place)]["y"]}
end

function Inventory:Event_setInventoryCoordinates(place, bag)
	if(bag == self.m_BagCurrent) then
		if self.m_X then
			local id = self.m_Bag[self.m_BagCurrent][place]
			local line = math.floor(place/7)
			if(place ~= 0) then
				place = place/(place/7) - 1
			end
			self.m_item[id]= { ["x"]= self.m_X+10 + 40 * place + 5 * place , ["y"]=self.m_Y+10 + 40 * line + 5 * line }
		end
	end
end


function Inventory:setItemRGB(place, r, g, b)
	if r then self.m_ItemPlaceR[self.m_BagCurrent][place] = r end
	if g then self.m_ItemPlaceG[self.m_BagCurrent][place] = g end
	if b then self.m_ItemPlaceB[self.m_BagCurrent][place] = b end
end


function Inventory:makeStringToLines(string, xpos, breite, schrift, scale)
	local fullString = {}
	local lastSpace
	for line = 0, 100, 1 do
		fullString[line] = ""
		if string then
			for i=1,  string.len(string),  1 do
				if(dxGetTextWidth ( fullString[line],  scale,  schrift ) < breite - xpos) then
					fullString[line] = fullString[line]..string.char( string.byte(string, i))
					if(string.char( string.byte(string, i)) == " ") then
						lastSpace = i
					end
				else
					break
				end
			end
			if(fullString[line] == fullString[line - 1]) then
				fullString[line] = nil
				break
			end
		end
	end
	return table.getn(fullString) + 1
end

function Inventory:getInfoClip(string, xpos, ypos, breite, hoehe, schrift, scale)
	while(dxGetFontHeight(scale, schrift) * self:makeStringToLines(string, xpos, breite, schrift, scale) >= hoehe - ypos) do
		breite = breite + 3
		hoehe = hoehe + 2.5
	end
	return breite, hoehe
end

function Inventory:showInfo(name, info, x, y, tx, ty, obx, oby, bx, by)
	if not bx then bx = 0 end
			if not by then by = 0 end

	if(self.m_InfoBlipAlpha < 250) then
		self.m_InfoBlipAlpha = self.m_InfoBlipAlpha + 10
	else
		self.m_InfoBlipAlpha = 255
	end
	dxDrawImage(x, y, bx + 13 - tx, by + 31 - ty, self.m_ImagePath.."infoblubf.png", 0.0, 0.0, 0.0, tocolor(255, 255, 255, self.m_InfoBlipAlpha), true)
	dxDrawText(name, x, y+3, bx , y + 20, tocolor(0, 0, 0, self.m_InfoBlipAlpha), self.m_BlipSize, "default-bold", "center", "top", false, true, true)
	dxDrawText(info, tx, ty, bx, by, tocolor(0, 0, 0, self.m_InfoBlipAlpha), self.m_TextSize, "default-bold", "left", "top", false, true, true)
end
function Inventory:showInfo2()
	self:showInfo(self.m_BlipItemName, self.m_BlipItemText, 1035, 448, Itx, Ity, Iobx, Ioby, Ibx, Iby)
end

function Inventory:Event_onItemClick(itemId, bag, place)
	if(not self.m_lockItemUseState[bag] or not self.m_lockItemUseState[bag][place]) then
		local itemName = self.m_Items[itemId]["Objekt"]
		local itemDelete = false
		if self.m_ItemData[itemName]["Verbraucht"] == 1 then itemDelete = true end
		triggerServerEvent("onPlayerItemUseServer", localPlayer, itemId, bag, itemName, place, itemDelete)
	end
end

function Inventory:setItemsRGBDefault(bag, setFalse)
	local max = self.m_Slots[bag]
	for i=0, max, 1 do
		self:setItemRGB(i, 110, 110, 110)
	end
	if(not setFalse) then
		if(self.m_lockItemUseState[bag]) then
			self.m_lockItemUseState[bag] = nil
		end
	end
end

function Inventory:moveInfoWindow(x, y)
	self:setInventarBlipPos(x+5, y+8)
end

function Inventory:showInfoBlipFunc(button)
	if(self.m_showInfoBlip == true) then
		return false
	end
	if(self.m_Bag[self.m_BagCurrent] == false) then
		self.m_showInfoBlip = "close"
		return false
	end
	local id = self.m_Bag[self.m_BagCurrent][tonumber(guiGetText(button))]
	if(id == nil) then
		self.m_showInfoBlip = "close"
		return 0
	end
	if id then
		local name = self.m_Items[id]["Objekt"]
		if name then
			local text = self.m_ItemData[name]["Info"]
			itemName,  itemText = self:getRealItemName(name), text


			local fx, fy = guiGetScreenSize()
			local mx, my = getCursorPosition ()
			self:setInventarBlipData(itemName, text, mx * fx + 5, my *fy + 8)

			self.m_showInfoBlip = true
			if not isEventHandlerAdded("onClientMouseMove",root,self.m_moveInfoWindow) then
				addEventHandler("onClientMouseMove", root, self.m_moveInfoWindow)
			end
		end
	end
end

function Inventory:setInventarBlipData(itemName, itemText, x, y)
	self.m_BlipItemName = self:getRealItemName(itemName)
	self.m_BlipItemText = itemText
	if not self.m_BlipItemText then self.m_BlipItemText = "kein Text" end
	IBx, IBy = x, y
	self.m_BlipSize = 1.1
	self.m_TextSize = 0.8
	Itx, Ity = IBx + 8, IBy + 20
	Iobx, Ioby = Itx + 137, Ity --1255, 523
	Ibx, Iby = self:getInfoClip(self.m_BlipItemText, Itx, Ity, Iobx, Ioby , "default-bold", self.m_TextSize)
end

function Inventory:setInventarBlipPos(x, y)
	self.m_BlipItemName = itemName
	self.m_BlipItemText =  itemText
	if not self.m_BlipItemText then self.m_BlipItemText = "kein Text" end
	IBx, IBy = x, y
	self.m_BlipSize = 1.1
	self.m_TextSize = 0.8
	Itx, Ity = IBx + 8, IBy + 20
	Iobx, Ioby = Itx + 137, Ity --1255, 523
	Ibx, Iby = self:getInfoClip(self.m_BlipItemText, Itx, Ity, Iobx, Ioby , "default-bold", self.m_TextSize)
end
