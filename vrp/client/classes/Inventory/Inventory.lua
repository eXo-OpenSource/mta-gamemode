-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUIUI.lua
-- *  PURPOSE:     HUD UI class
-- *
-- ****************************************************************************
--TODO: delete file, and write new ;)

Inventory = inherit(Singleton)

function Inventory:constructor()
	self.InventoryKey = "i"
	self.Show = false
	self.m_ImagePath = "files/images/Inventory/"
	self.m_btn_inventar = {["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}}
	self.m_startMoveButton = {}

	self.m_item = {}
	self.m_sitem = {}
	self.m_itemFront = {}

	local tabs = {["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}}
	self.m_itemPlatzR = tabs
	self.m_itemPlatzG = tabs
	self.m_itemPlatzB = tabs

	self.m_aktuel = "Items"
	self.m_oldaktuel = "Items"


	addRemoteEvents{"loadPlayerInventarClient","loadItemDataFromServer","setIKoords_c",onPlayerItemUse}
	addEventHandler("loadPlayerInventarClient", root, bind(self.Event_loadPlayerInventarClient, self))
	addEventHandler("loadItemDataFromServer", root, bind(self.Event_loadItemDataFromServer, self))
	addEventHandler("setIKoords_c",root, bind(self.Event_setInventarKoordinaten, self))
	addEventHandler("onPlayerItemUse",root, bind(self.Event_onItemClick, self))
	addEventHandler("onClientClick",root,bind(self.onClick, self))

end

function Inventory:destructor()

end

function Inventory:Event_loadPlayerInventarClient()
	bindKey(self.InventoryKey,"down",bind(self.toggle, self))
end

function Inventory:toggle()
	if self.Show == true then
		self.Show = false
		self:hide()
	else
		self.Show = true
		self:show()
	end
end

function Inventory:getRealItemName(name)
	local nstring,w = string.gsub(name,"Drogen/","")
	return self:refreshStringManuel(nstring)
end

function Inventory:Event_loadItemDataFromServer(itemdata)
	self.m_ItemData = itemdata
end

function Inventory:getPlaceMouseOver()
	local mx,my =  getCursorPosition()
	for i=0,self.m_slots-1,1 do
		if(self.m_btn_inventar[self.m_aktuel][i]) then
			local x,y = guiGetPosition(self.m_btn_inventar[self.m_aktuel][i],true)
			local bx,by = guiGetSize(self.m_btn_inventar[self.m_aktuel][i],true)
			bx,by = bx +x , by +y
			if(mx > x and mx < bx and my > y and my < by) then
				return self.m_btn_inventar[self.m_aktuel][i]
			end
		end
	end
	return false
end

-- Direct X Drawing
local x,y,bx,by, slots
local pClose,pMove,pReset
local r,g,b
local spawnLock,callCheck, mouseDistX,mouseDistY







function Inventory:onItemMouseOver()
	local src = false
	for i=0,self.m_slots-1,1 do
		if(source == self.m_btn_inventar[self.m_aktuel][i]) then
			src = true
		end
	end
	if(src ~= true) then
		return 0
	end

	if(showInfoBlip == true) then
		return false
	end
	if(not lockItemUseState[self.m_aktuel] or not lockItemUseState[self.m_aktuel][tonumber(guiGetText(source))]) then
		self:setItemRGB(tonumber(guiGetText(source)),255,255,0)
	end

	InfoBlipTimer = setTimer(function(button)
		self:showInfoBlipFunc(button)
	end,500,1,source)
end

function Inventory:onItemMouseLeave()
	local src = false
	for i=0,self.m_slots-1,1 do
		if(source == self.m_btn_inventar[self.m_aktuel][i]) then
			src = true
		end
	end
	if(src ~= true ) then
		return false
	end
	if(( ( lockItemUseState[self.m_aktuel] and lockItemUseState[self.m_aktuel][tonumber(guiGetText(source))] ) )) then

	else
		self:setItemRGB(tonumber(guiGetText(source)), 110,110,110 )
	end

	if(showInfoBlip) then
		showInfoBlip = false
		InventarBlipAlpha = 0
		removeEventHandler("onClientMouseMove",root,self.moveInfoWindow)
	end
	killTimer(InfoBlipTimer)
end

function Inventory:onCloseClick(button)
	if(button == "left") then
		self:hide()
	end
end

function Inventory:MoveGUI(mx,my)
	x,y = mx - mouseDistX, my - mouseDistY
	self.m_slots = tonumber(getElementData(localPlayer,"Inventar_c")[self.m_aktuel.."Platz"])
	local line,oline,platz
	for i=0,self.m_slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then
			platz = 0
		end
		local id
		if(	getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") ) then
			id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[i.."_id"]
			if(id) then
				self.m_item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			end
		end
		guiSetPosition ( self.m_btn_inventar[self.m_aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
		self.m_sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end
	guiSetPosition ( self.m_btn_Items, x+2,y-48, false )
	guiSetPosition ( self.m_btn_Objekte ,x+2 + 82,y-48, false )
	guiSetPosition ( self.m_btn_Essen , x+2 + 82*2,y-48, false )
	guiSetPosition ( self.m_btn_Drogen,  x+2 + 82*3,y-48, false )
	guiSetPosition ( self.m_btn_Close , x+bx + 1,y-49, false )
	guiSetPosition ( self.m_btn_Move, x+bx + 1,y-49+18, false )
	guiSetPosition ( self.m_btn_Reset, x+bx + 1,y-49+36, false )

end

function Inventory:onMoveClick(button,mx,my)
	if(button == "left") then
		mouseDistX,mouseDistY = mx - x, my - y
		addEventHandler("onClientMouseMove",root,bind(self.MoveGUI,self))
	end
end

function Inventory:onStopMove(button)
	if(button == "left") then
		removeEventHandler("onClientMouseMove",root,bind(self.MoveGUI,self))
	end
end

function Inventory:onResetClick(button)
	if(button == "left") then
		x,y = screenWidth/2 - bx/2,screenHeight/2 - by/2
		self.m_slots = tonumber(getElementData(localPlayer,"Inventar_c")[self.m_aktuel.."Platz"])
		local line,oline,platz
		for i=0,self.m_slots-1,1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				platz = 0
			end
			local id
			if(	getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") ) then
				id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[i.."_id"]
				if(id) then
					self.m_item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
				end
			end
			guiSetPosition ( self.m_btn_inventar[self.m_aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
			self.m_sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			oline = line
			platz = platz + 1
		end
		guiSetPosition ( self.m_btn_Items, x+2,y-48, false )
		guiSetPosition ( self.m_btn_Objekte ,x+2 + 82,y-48, false )
		guiSetPosition ( self.m_btn_Essen , x+2 + 82*2,y-48, false )
		guiSetPosition ( self.m_btn_Drogen,  x+2 + 82*3,y-48, false )
		guiSetPosition ( self.m_btn_Close , x+bx + 1,y-49, false )
		guiSetPosition ( self.m_btn_Move, x+bx + 1,y-49+18, false )
		guiSetPosition ( self.m_btn_Reset, x+bx + 1,y-49+36, false )
	end
end

function Inventory:renderInventar()
		dxDrawImage(x,y-95,50,50,":vrp/files/images/logo.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2.0,y-48,80.0,48.0,tocolor(r["Items"],g["Items"],b["Items"],200),false)
		dxDrawImage(x+20,y-48,48.0,48.0,self.m_ImagePath.."items.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(r["Objekte"],g["Objekte"],b["Objekte"],200),false)
		dxDrawImage(x+20 + 82,y-48,48.0,48.0,self.m_ImagePath.."items/Objekte.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82*2,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(r["Essen"],g["Essen"],b["Essen"],200),false)
		dxDrawImage(x+20 + 82*2,y-48,48.0,48.0,self.m_ImagePath.."food.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82*3,y-50,84.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(r["Drogen"],g["Drogen"],b["Drogen"],200),false)
		dxDrawImage(x+20 + 82*3,y-48,48.0,48.0,self.m_ImagePath.."drogen.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)


		dxDrawRectangle(x+bx ,y-50,20.0,56.0,tocolor(0,0,0,200),false)

		dxDrawRectangle(x,y,bx,by,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
		dxDrawRectangle(x+2,y+2,bx-4,by-4,tocolor(50,200,255,255),false)
		dxDrawText("Verwende Items mit der linken Maustaste\nZum Verschieben benutze die rechte Maustaste!",x,y+by+2,x+bx,y+by+4,tocolor(255,255,255,255), 1.2, "defauld-bold","center","top")
		dxDrawText("Mit /handel [NAME] kannst du mit deinen Items handeln!",x,y+by+45,x+bx,y+by+55,tocolor(50,200,255,255), 0.9, "defauld-bold","center","bottom")

		dxDrawImage(x+bx + 1,y-49,18,18,pClose,0.0,0.0,0.0,tocolor(255,255,255,255),false)
		dxDrawImage(x+bx + 1,y-49+18,18.0,18.0,pMove,0.0,0.0,0.0,tocolor(255,255,255,255),false)
		dxDrawImage(x+bx + 1,y-49+36,18.0,18.0,pReset,0.0,0.0,0.0,tocolor(255,255,255,255),false)

		local line
		local oline
		local platz
		for i=0,self.m_slots-1,1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				platz = 0
			end
			if(not self.m_itemPlatzR[self.m_aktuel][i]) then
				if(not lockItemUseState[self.m_aktuel] or not lockItemUseState[self.m_aktuel][i]) then
					self:setItemRGB(i,110,110,110)
				end
			end
			dxDrawRectangle(x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40,tocolor(self.m_itemPlatzR[self.m_aktuel][i],self.m_itemPlatzG[self.m_aktuel][i],self.m_itemPlatzB[self.m_aktuel][i],200),false)
			local item_table_aktuell = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")
			if item_table_aktuell then
				local id = item_table_aktuell[tostring(i).."_id"]

				if(id) then
					local rx,gx,bx = self.m_itemPlatzR[self.m_aktuel][i] - 10,self.m_itemPlatzG[self.m_aktuel][i]- 10,self.m_itemPlatzB[self.m_aktuel][i]- 10
					local a = 255
					if (rx == 100) then
						rx,gx,bx = 255,255,255
						a = 180
					end
					local item_table = getElementData(localPlayer,"Item_c")
					local itemname = item_table[id]
					if itemname then
						local icon = self.m_ItemData[itemname]["Icon"]

						if item_table then
							dxDrawImage(self.m_item[id]["x"],self.m_item[id]["y"],40,40,self.m_ImagePath.."items/"..icon,0.0,0.0,0.0,tocolor(rx,gx,bx,255),self.m_itemFront[id])
							dxDrawText(tostring(getElementData(localPlayer,"Item_c")[tostring(id).."_Menge"]),self.m_item[id]["x"] + 40 - dxGetTextWidth (tostring(getElementData(localPlayer,"Item_c")[tostring(id).."_Menge"] , 0.85, "defauld-bold")),self.m_item[id]["y"] + 27.25,40,40,tocolor(rx,gx,bx,a),0.85,"default-bold","left","top",false,false,self.m_itemFront[id])
						end
					end
				end
			end
			oline = line
			platz = platz + 1
		end

		if(showInfoBlip == true) then

			self:showInfo(IBUeber,IBtext,IBx,IBy,Itx,Ity,Iobx,Ioby,Ibx,Iby)
		end


end

function Inventory:onClientDragAndDropMove()
	local mx,my = getCursorPosition ()
	local x,y = self.m_startMoveButton["x"],self.m_startMoveButton["y"]
	local fx,fy = self.m_startMoveButton["bx"] + x,self.m_startMoveButton["by"] + y
	--if(mx < x or mx >screenWidth or my < y or my > screenHeight) then
		local button = self.m_startMoveButton["object"]
		local platz
		if(getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") ~= false) then
			platz = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[guiGetText(button).."_id"]
		else
			platz = nil
		end

		if(showInfoBlip) then
			showInfoBlip = false
			InventarBlipAlpha = 0
			removeEventHandler("onClientMouseMove",root,bind(self.moveInfoWindow,self))
		end
		killTimer(InfoBlipTimer)
		if(self:getPlaceMouseOver() ~= button) then
			triggerEvent("onClientMouseLeave",button)
		end
		if(platz) then

			local place = guiGetText(button)

			local fullx,fully = guiGetScreenSize()
			mx,my = mx*fullx,my*fully
			if(	getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") ) then
				id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[place.."_id"]
				if(id) then
					self.m_item[tonumber(id)] = { ["x"]= mx,["y"]=my }
				end
			end

			if(isElement(self:getPlaceMouseOver())) then
				triggerEvent("onClientMouseEnter",self:getPlaceMouseOver())
				if(isElement(self.m_lastOver) and self.m_lastOver ~= self:getPlaceMouseOver()) then
					triggerEvent("onClientMouseLeave",self.m_lastOver)
				end
				self.m_lastOver = self:getPlaceMouseOver()
			elseif(isElement(self.m_lastOver)) then
				triggerEvent("onClientMouseLeave",self.m_lastOver)
				self.m_lastOver = nil
			end
		else
			self.m_startMoveButton = nil
			removeEventHandler("onClientPreRender",root,bind(self.onClientDragAndDropMove,self))
		end
	--end
end

function Inventory:onClickAndDropDown(button)
	local id

	if(getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")) then
		id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[guiGetText(source).."_id"]
	end

	if button == "left" then
		if(id) then
			local itemname = getElementData(localPlayer,"Item_c")
			local item = itemname[id]
			if item then
				triggerEvent("onPlayerItemUse",localPlayer,getElementData(localPlayer,"Item_c")[id],id,self.m_aktuel,tonumber(guiGetText(source)))
			end
		end
		return false
	else

		local src
		for i=0,self.m_slots-1,1 do
			if(source == self.m_btn_inventar[self.m_aktuel][i]) then
				src = true
			end
		end
		if(src ~= true) then
			if(source ~= self.m_btn_Move and (source == self.m_btn_Items or source == self.m_btn_Objekte or source == self.m_btn_Essen or source == self.m_btn_Drogen or source == self.m_btn_Close or source == self.m_btn_Reset) ) then
				self.m_startMoveButton = { ["object"] = source }
				self.m_startMoveButton["x"],self.m_startMoveButton["y"] = guiGetPosition ( source, true )
				self.m_startMoveButton["bx"],self.m_startMoveButton["by"] = guiGetSize ( source, true )
				addEventHandler("onClientPreRender",root,bind(self.onClientDragAndDropMove,self))
				return false
			end
			return false
		end


		if(id) then
			self.m_itemFront[id] = true
		end
		self.m_startMoveButton = { ["object"] = source }
		self.m_startMoveButton["x"],self.m_startMoveButton["y"] = guiGetPosition ( source, true )
		self.m_startMoveButton["bx"],self.m_startMoveButton["by"] = guiGetSize ( source, true )
		addEventHandler("onClientPreRender",root,bind(self.onClientDragAndDropMove,self))
	end
end

function Inventory:onClickAndDropUp(button)

	local src
	for i=0,self.m_slots-1,1 do
		if(source == self.m_btn_inventar[self.m_aktuel][i]) then
			src = true
		end
	end

	if(self.m_startMoveButton) then
		local place = false
		local splace = tonumber(guiGetText(self.m_startMoveButton["object"]))
		local item_table = getElementData(localPlayer,"Item_c")

		if(src ~= true) then
			if(source ~= self.m_btn_Move and (source == self.m_btn_Items or source == self.m_btn_Objekte or source == self.m_btn_Essen or source == self.m_btn_Drogen or source == self.m_btn_Close or source == self.m_btn_Reset) ) then

				self.m_startMoveButton = nil
				self.m_lastOver = nil
				removeEventHandler("onClientPreRender",root,bind(self.onClientDragAndDropMove,self))
				self:inventarSetItemToPlace(id,splace)
				--return false
			end
			self:inventarSetItemToPlace(id,splace)
			--return false
		end

		if self:getPlaceMouseOver() then
			place = tonumber(guiGetText(self:getPlaceMouseOver()))
			local nid = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[place.."_id"]
			if(nid) then
				local oPlace = guiGetText(self.m_startMoveButton["object"])


				local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[splace.."_id"]

				local itemname_moved = item_table[id]
				local itemname_old = item_table[nid]
				if id ~= nid then
					if itemname_moved == itemname_old then
						local itemmenge_moved = tonumber(getElementData(localPlayer,"Item_c")[tostring(id).."_Menge"])
						local itemmenge_old = tonumber(getElementData(localPlayer,"Item_c")[tostring(nid).."_Menge"])
						local gesamt = itemmenge_moved+itemmenge_old
						if self.m_ItemData[itemname_moved]["Stack_max"] >= gesamt then
							triggerServerEvent("c_stackItems",localPlayer,id,nid,place)
						else
							outputChatBox("Der Stack von Item '"..itemname_moved.."' darf nur "..self.m_ItemData[itemname_moved]["Stack_max"].." betragen!",255,0,0)
						end
					else
						outputChatBox("Du kannst nur gleiche Items stapeln!",255,0,0)
					end
				end

				self:inventarSetItemToPlace(id,place)
				self:inventarSetItemToPlace(nid,splace)

				if(lockItemUseState[self.m_aktuel] and lockItemUseState[self.m_aktuel][splace]) then
					self:setItemsRGBDefault(self.m_aktuel)
					self:setItemRGB(splace,50,200,255)
					lockItemUseState[self.m_aktuel] = {[splace]=true}
				end
				triggerServerEvent("changePlaces",localPlayer,self.m_aktuel,oPlace,place)
			else
				local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[splace.."_id"]
				if(lockItemUseState[self.m_aktuel] and lockItemUseState[self.m_aktuel][splace]) then
					self:setItemsRGBDefault(self.m_aktuel)
					self:setItemRGB(tonumber(place),50,200,255)
					lockItemUseState[self.m_aktuel] = {[tonumber(place)]=true}

				end

				self:inventarSetItemToPlace(id,place)
				triggerServerEvent("c_setItemPlace",localPlayer,self.m_aktuel,splace,tonumber(place))
			end
		else
			local mx,my = getCursorPosition ( )
			mx,my = mx *screenWidth,my*screenHeight

			if(mx >= x and mx <= x+bx and my >= y-50 and my <= y+by) then
				local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[splace.."_id"]
				self:inventarSetItemToPlace(id,splace)
				if(lockItemUseState[self.m_aktuel] and lockItemUseState[self.m_aktuel][splace]) then
					self:setItemsRGBDefault(self.m_aktuel)

				--	outputChatBox("To Green")
					--setItemRGB(splace,0,255,0,true)
					--lockItemUseState[self.m_aktuel] = {[splace] = true}
				end
			else
				local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[splace.."_id"]
				local itemname = getElementData(localPlayer,"Item_c")
				if tonumber(self.m_ItemData[(itemname[id])]["Wegwerf"]) == 1 then
					--triggerServerEvent("layItemInWorld_c",localPlayer,localPlayer,self.m_aktuel,id)
					triggerServerEvent("wegwerfItem",localPlayer,itemname[id],self.m_aktuel,id,splace)
				else
					self:inventarSetItemToPlace(id,splace)
					outputChatBox("Dieses Item kann nicht weggeworfen werden!",255,0,0)
				end
			end
		end
	end

	self.m_startMoveButton = nil
	self.m_lastOver = nil
	removeEventHandler("onClientPreRender",root,bind(self.onClientDragAndDropMove,self))

	local id
	if(getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")) then
		id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[guiGetText(source).."_id"]
	end
	if(id) then
		self.m_itemFront[id] = false
	end
end

function Inventory:show()

	showCursor ( true ,false)
	toggleControl ( "fire", false)

	pClose,pMove,pReset = self.m_ImagePath.."closeinv.png",self.m_ImagePath.."moveinv.png",self.m_ImagePath.."reset.png"
	r,g,b = { ["Items"]=50,["Essen"]=50,["Objekte"]=50,["Drogen"]=50, ["Rahmen"]=255} , { ["Items"]=200,["Essen"]=200,["Objekte"]=200,["Drogen"]=200 ,["Rahmen"]=255} , { ["Items"]=255,["Essen"]=255,["Objekte"]=255,["Drogen"]=255,["Rahmen"]=255 }

	self.m_slots = tonumber(getElementData(localPlayer,"Inventar_c")[self.m_aktuel.."Platz"])
	lines = math.ceil(self.m_slots/7)
	bx,by = 330, 20 - 4 + 45*lines --543,266
	if(not x and not y) then
		x,y = screenWidth/2 - bx/2,screenHeight/2 - by/2
	end
	r[self.m_aktuel],g[self.m_aktuel],b[self.m_aktuel] = 100,130,140
	r["o"..self.m_aktuel],g["o"..self.m_aktuel],b["o"..self.m_aktuel] = 0,255,0
	local line
	local oline
	local platz

	for i=0,self.m_slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then
			platz = 0
		end
		self.m_btn_inventar[self.m_aktuel][i] = guiCreateButton (x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40, i.."", false)
		guiSetAlpha(self.m_btn_inventar[self.m_aktuel][i],0)
		local id
		if(	getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") ) then
			id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[i.."_id"]
			if(id) then
				self.m_item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
				self.m_itemFront[id] = false
			end
		end
		if(not lockItemUseState[self.m_aktuel] or not lockItemUseState[self.m_aktuel][tonumber(i)]) then
			self:setItemRGB(i,110,110,110)
		end
		self.m_sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end

	self.m_btn_Items = guiCreateButton (x+2,y-48,80.0,48.0, "", false)
	guiSetAlpha(self.m_btn_Items,0)
	self.m_btn_Objekte = guiCreateButton ( x+2 + 82,y-48, 80.0,48.0, "", false )
	guiSetAlpha(self.m_btn_Objekte,0)
	self.m_btn_Essen = guiCreateButton ( x+2 + 82*2,y-48, 80.0,48.0, "", false )
	guiSetAlpha(self.m_btn_Essen,0)
	self.m_btn_Drogen = guiCreateButton ( x+2 + 82*3,y-48, 80.0,48.0, "", false )
	guiSetAlpha(self.m_btn_Drogen,0)
	self.m_btn_Close = guiCreateButton ( x+bx + 1,y-49, 18,18, "", false  )
	guiSetAlpha(self.m_btn_Close,0)
	self.m_btn_Move = guiCreateButton ( x+bx + 1,y-49+18, 18,18, "", false )
	guiSetAlpha(self.m_btn_Move,0)
	self.m_btn_Reset = guiCreateButton ( x+bx + 1,y-49+36, 18,18, "", false )
	guiSetAlpha(self.m_btn_Reset,0)


	addEventHandler("onClientMouseEnter",root,bind(self.onButtonInvEnter,self))
	addEventHandler("onClientMouseLeave",root,bind(self.onButtonInvLeave,self))
	addEventHandler("onClientGUIClick",root,bind(self.onInvClick,self))

	addEventHandler("onClientMouseEnter",root,bind(self.onItemMouseOver,self))
	addEventHandler("onClientMouseLeave",root,bind(self.onItemMouseLeave,self))

	addEventHandler("onClientGUIClick",self.m_btn_Close,bind(self.onCloseClick,self))
	addEventHandler("onClientGUIMouseDown",self.m_btn_Move,bind(self.onMoveClick,self))
	addEventHandler("onClientGUIMouseUp",self.m_btn_Move,bind(self.onStopMove,self))
	addEventHandler("onClientGUIClick",self.m_btn_Reset,bind(self.onResetClick,self))

	addEventHandler("onClientGUIMouseDown",root,bind(self.onClickAndDropDown,self))
	addEventHandler("onClientGUIMouseUp",root,bind(self.onClickAndDropUp,self))


	addEventHandler("onClientRender",root,bind(self.renderInventar,self))
end

function Inventory:hide()
	if(not self.m_btn_Items) then
		return false
	end
	showCursor ( false )

	removeEventHandler("onClientRender",root,bind(self.renderInventar,self))
	removeEventHandler("onClientMouseEnter",root,bind(self.onButtonInvEnter,self))
	removeEventHandler("onClientMouseLeave",root,bind(self.onButtonInvLeave,self))
	removeEventHandler("onClientGUIClick",root,bind(self.onInvClick,self))
	removeEventHandler("onClientMouseEnter",root,bind(self.onItemMouseOver,self))
	removeEventHandler("onClientMouseLeave",root,bind(self.onItemMouseLeave,self))
	removeEventHandler("onClientGUIClick", self.m_btn_Close,bind(self.onCloseClick,self))
	removeEventHandler("onClientGUIMouseDown",self.m_btn_Move,bind(self.onMoveClick,self))
	removeEventHandler("onClientGUIMouseUp",self.m_btn_Move,bind(self.onStopMove,self))
	removeEventHandler("onClientMouseMove",root,bind(self.MoveGUI,self))
	removeEventHandler("onClientMouseMove",root,bind(self.moveInfoWindow,self))
	removeEventHandler("onClientGUIMouseDown",root,bind(self.onClickAndDropDown,self))
	removeEventHandler("onClientGUIMouseUp",root,bind(self.onClickAndDropUp,self))

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
	if(isTimer(InfoBlipTimer) and getTimerDetails(InfoBlipTimer)) then
		killTimer(InfoBlipTimer)
	end
	if(callCheck == true) then
		local slots = tonumber(getElementData(localPlayer,"Inventar_c")[self.m_oldaktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(self.m_btn_inventar[self.m_oldaktuel][i])
		end
		callCheck = false
	else
		local slots = tonumber(getElementData(localPlayer,"Inventar_c")[self.m_aktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(self.m_btn_inventar[self.m_aktuel][i])
		end
	end

	showInfoBlip = false
	InventarBlipAlpha = 0

end

function Inventory:onInvClick(button)
	if button == "left" then

		if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen) then
			return 0
		end
		self.m_oldaktuel = self.m_aktuel
		if( source == self.m_btn_Items and self.m_aktuel ~= "Items") then
			self.m_aktuel = "Items"
		elseif( source == self.m_btn_Objekte and self.m_aktuel ~= "Objekte") then
			self.m_aktuel = "Objekte"
		elseif( source == self.m_btn_Essen and self.m_aktuel ~= "Essen") then
			self.m_aktuel = "Essen"
		elseif( source == self.m_btn_Drogen and self.m_aktuel ~= "Drogen") then
			self.m_aktuel = "Drogen"
		else
			return 0
		end
		r[self.m_oldaktuel],g[self.m_oldaktuel],b[self.m_oldaktuel] = 110,110,110
		callCheck = true
		self:hide()
		self:show()
	end
end

function Inventory:onButtonInvEnter()
	if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen and source ~= self.m_btn_Close and source ~= self.m_btn_Move and source ~= self.m_btn_Reset) then
		return 1
	end

	if( source == self.m_btn_Items) then
		if(self.m_aktuel == "Items") then
			return 0
		end
		r["oItems"],g["oItems"],b["oItems"] = r["Items"],g["Items"],b["Items"]
		r["Items"],g["Items"],b["Items"] = 100,130,140
	elseif( source == self.m_btn_Objekte) then
		if(self.m_aktuel == "Objekte") then
			return 0
		end
		r["oObjekte"],g["oObjekte"],b["oObjekte"] = r["Objekte"],g["Objekte"],b["Objekte"]
		r["Objekte"],g["Objekte"],b["Objekte"] = 100,130,140
	elseif( source == self.m_btn_Essen) then
		if(self.m_aktuel == "Essen") then
			return 0
		end
		r["oEssen"],g["oEssen"],b["oEssen"] = r["Essen"],g["Essen"],b["Essen"]
		r["Essen"],g["Essen"],b["Essen"] = 100,130,140
	elseif( source == self.m_btn_Drogen) then
		if(self.m_aktuel == "Drogen") then
			return 0
		end
		r["oDrogen"],g["oDrogen"],b["oDrogen"] = r["Drogen"],g["Drogen"],b["Drogen"]
		r["Drogen"],g["Drogen"],b["Drogen"] = 100,130,140
	elseif( source == self.m_btn_Close) then
		pClose = self.m_ImagePath.."closeinvS.png"
	elseif( source == self.m_btn_Move) then
		pMove = self.m_ImagePath.."moveinvS.png"
	elseif( source == self.m_btn_Reset) then
		pReset = self.m_ImagePath.."resetS.png"
	end
end

function Inventory:onButtonInvLeave()
	if(source ~= self.m_btn_Items and source ~= self.m_btn_Objekte and source ~= self.m_btn_Essen and source ~= self.m_btn_Drogen and source ~= self.m_btn_Close and source ~= self.m_btn_Move and source ~= self.m_btn_Reset) then
		return 1
	end
	if( source == self.m_btn_Items) then
		if(self.m_aktuel == "Items") then
			return 0
		end
		r["Items"],g["Items"],b["Items"] = r["oItems"],g["oItems"],b["oItems"]
	elseif( source == self.m_btn_Objekte) then
		if(self.m_aktuel == "Objekte") then
			return 0
		end
		r["Objekte"],g["Objekte"],b["Objekte"] = r["oObjekte"],g["oObjekte"],b["oObjekte"]
	elseif( source == self.m_btn_Essen) then
		if(self.m_aktuel == "Essen") then
			return 0
		end
		r["Essen"],g["Essen"],b["Essen"] = r["oEssen"],g["oEssen"],b["oEssen"]
	elseif( source == self.m_btn_Drogen) then
		if(self.m_aktuel == "Drogen") then
			return 0
		end
		r["Drogen"],g["Drogen"],b["Drogen"] = r["oDrogen"],g["oDrogen"],b["oDrogen"]
	elseif( source == self.m_btn_Close) then
		pClose = self.m_ImagePath.."closeinv.png"
	elseif( source == self.m_btn_Move) then
		pMove = self.m_ImagePath.."moveinv.png"
	elseif( source == self.m_btn_Reset) then
		pReset = self.m_ImagePath.."reset.png"
	end

end

function Inventory:inventarSetItemToPlace(id,platz)
	self.m_item[tonumber(id)] = {["x"]=self.m_sitem[tonumber(platz)]["x"],["y"]=self.m_sitem[tonumber(platz)]["y"]}
end




function Inventory:Event_setInventarKoordinaten(platz,tasche)
	if(tasche == self.m_aktuel) then
		if x then
			local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[platz.."_id"]
			local line = math.floor(platz/7)
			if(platz ~= 0) then
				platz = platz/(platz/7) - 1
			end
			self.m_item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
		end
	end
end


function Inventory:setItemRGB(platz,r,g,b)
	if(r) then
		self.m_itemPlatzR[self.m_aktuel][platz] = r
	end

	if(g) then
		self.m_itemPlatzG[self.m_aktuel][platz] = g
	end

	if(b) then
		self.m_itemPlatzB[self.m_aktuel][platz] = b
	end
end

lockItemUseState = {}

function Inventory:makeStringToLines(string,xpos,breite,schrift,scale)
	local fullstring = {}

	local lastSpace
	for line = 0,100,1 do
		fullstring[line] = ""
		if string then
			for i=1, string.len(string), 1 do
				if(dxGetTextWidth ( fullstring[line], scale, schrift ) < breite - xpos) then
					fullstring[line] = fullstring[line]..string.char( string.byte(string,i))
					if(string.char( string.byte(string,i)) == " ") then
						lastSpace = i
					end
				else
					break
				end
			end
			if(fullstring[line] == fullstring[line - 1]) then
				fullstring[line] = nil
				break
			end
		end
	end
	return table.getn(fullstring) + 1

end

function Inventory:getInfoClip(string,xpos,ypos,breite,hoehe,schrift,scale)
	local bx
	while(dxGetFontHeight(scale,schrift) * self:makeStringToLines(string,xpos,breite,schrift,scale) >= hoehe - ypos) do
		breite = breite + 3
		hoehe = hoehe + 2.5
	end
	return breite,hoehe
end

   	  --  dxDrawImage(1035.0,448.0,225.0,86.0,"images/infoblubf.png",0.0,0.0,0.0,tocolor(255,255,255,255),true)
       -- dxDrawText("Girokontokarte",1042.0,454.0,1206.0,481.0,tocolor(0,0,0,255),1.0,"default-bold","left","top",false,false,true)
		local ueberSize = 1.1
		local textSize = 0.8

		-- Pic verändern + Einfaden
function Inventory:showInfo(name,info,x,y,tx,ty,obx,oby,bx,by)
		if not bx then bx = 0 end
				if not by then by = 0 end

		if(InventarBlipAlpha < 250) then
			InventarBlipAlpha = InventarBlipAlpha + 10
		else
			InventarBlipAlpha = 255
		end
		dxDrawImage(x,y,bx + 13 - tx,by + 31 - ty,self.m_ImagePath.."infoblubf.png",0.0,0.0,0.0,tocolor(255,255,255,InventarBlipAlpha),true)
		dxDrawText(name,x,y+3,bx ,y + 20,tocolor(0,0,0,InventarBlipAlpha),ueberSize,"default-bold","center","top",false,true,true)
        dxDrawText(info,tx,ty,bx,by,tocolor(0,0,0,InventarBlipAlpha),textSize,"default-bold","left","top",false,true,true)

end
function Inventory:showInfo2()
	self:showInfo(IBUeber,IBtext,1035,448,Itx,Ity,Iobx,Ioby,Ibx,Iby)
end
InventarBlipAlpha = 0

function Inventory:Event_onItemClick(itemname,itemid,tasche,platz)
	if(not lockItemUseState[tasche] or not lockItemUseState[tasche][platz]) then
		local verbraucht = self.m_ItemData[itemname]["Verbraucht"]
		if verbraucht == 1 then delete = true
	elseif verbraucht == 2 then delete = false
	elseif verbraucht == 0 then delete = false
		end
			triggerServerEvent("onPlayerItemUseServer",localPlayer,itemid,tasche,itemname,platz,delete)
	end

end


function Inventory:setItemsRGBDefault(tasche,setFalse)
	local max = getElementData(localPlayer,"Inventar_c")[tasche.."Platz"]
	for i=0,max,1 do
		self:setItemRGB(i,110,110,110)
	end

	if(not setFalse) then
		if(lockItemUseState[tasche]) then
			lockItemUseState[tasche] = nil
		end
	end
end

function Inventory:moveInfoWindow(x,y)
	self:setInventarBlipPos(x+5,y+8)
end

function Inventory:showInfoBlipFunc(button)
	if(showInfoBlip == true) then
		return false
	end

	if(getElementData(localPlayer,"Item_"..self.m_aktuel.."_c") == false) then
		showInfoBlip = "close"
		return false
	end
	local id = getElementData(localPlayer,"Item_"..self.m_aktuel.."_c")[guiGetText(button).."_id"]
	if(id == nil) then
		showInfoBlip = "close"
		return 0
	end

	local itemtable = getElementData(localPlayer,"Item_c")
	if itemtable then
		if id then
			local name = itemtable[tonumber(id)]
			if name then
				local text = self.m_ItemData[name]["Info"]
				aname, atext = self:getRealItemName(name),text


				local fx,fy = guiGetScreenSize()
				local mx,my = getCursorPosition ()
				self:setInventarBlipData(aname,text,mx * fx + 5,my *fy + 8)

				showInfoBlip = true

				addEventHandler("onClientMouseMove",root,bind(self.moveInfoWindow,self))
			end
		end
	end
end

function Inventory:setInventarBlipData(uber,text,x,y)
	IBUeber = self:getRealItemName(uber)
	IBtext = text
	if not IBtext then IBtext = "kein Text" end
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = self:getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
end

function Inventory:setInventarBlipPos(x,y)
	IBUeber = aname
	IBtext =  atext
	if not IBtext then IBtext = "kein Text" end
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = self:getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
end

_killTimer = killTimer
function killTimer(theTimer)
	if(isTimer(theTimer) and getTimerDetails ( theTimer )) then
		return _killTimer(theTimer)
	else
		return false
	end
end

local mouseState = "up"

function Inventory:getMouseState()
	return mouseState
end

function Inventory:onClick(button,state)
	mouseState = state
end

a = "ä"
o = "ö"
u = "ü"
s = "ß"
A = "Ä"
O = "Ö"
U = "Ü"

function Inventory:refreshString(string)
	local nstring,w = string.gsub(string,"Ü","Ue")
	local nstring,w = string.gsub(nstring,"Ö","Oe")
	local nstring,w = string.gsub(nstring,"Ä","Ae")
	local nstring,w = string.gsub(nstring,"ü","ue")
	local nstring,w = string.gsub(nstring,"ö","oe")
	local nstring,w = string.gsub(nstring,"ä","ae")
	local nstring,w = string.gsub(nstring,"ß","sz")
	return nstring
end


function Inventory:refreshStringManuel(string)
	local nstring,w = string.gsub(string,"Ue",""..U.."")
	local nstring,w = string.gsub(nstring,"Oe",""..O.."")
	local nstring,w = string.gsub(nstring,"Ae",""..A.."")
	local nstring,w = string.gsub(nstring,"ue",""..u.."")
	local nstring,w = string.gsub(nstring,"oe",""..o.."")
	local nstring,w = string.gsub(nstring,"ae",""..a.."")
	local nstring,w = string.gsub(nstring,"*sz",""..s.."")
	return nstring
end
