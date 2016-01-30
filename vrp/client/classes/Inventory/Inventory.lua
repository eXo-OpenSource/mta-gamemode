--TODO: delete file, and write new ;)

-- Direct X Drawing
lp = getLocalPlayer()

local inventarKey = "i"
aktuel,oldaktuel = "Items","Items"
local fx,fy = guiGetScreenSize()
local x,y,bx,by, slots
local btn_Items, btn_Essen, btn_Drogen, btn_Objekte, btn_Close, btn_Move, btn_Reset, btn_origin
local pClose,pMove,pReset
local r,g,b
local itemPlatzR,itemPlatzG,itemPlatzB = {["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}},{["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}},{["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}}
local btn_inventar = {["Items"]= {},["Essen"]={},["Objekte"]={}, ["Drogen"]={}}
local spawnLock,callCheck, mouseDistX,mouseDistY

local startMoveButton,lastOver
local item,sitem,itemFront = {},{},{}

function getRealItemName(name)
	local nstring,w = string.gsub(name,"Drogen/","")
	return refreshStringManuel(nstring)
	--return "hallo"
end

function loadItemDataFromServer_func(itemdata)
	itemData = itemdata
end
addEvent("loadItemDataFromServer",true)
addEventHandler("loadItemDataFromServer",lp,loadItemDataFromServer_func)

function getPlaceMouseOver()
	local mx,my =  getCursorPosition()
	for i=0,slots-1,1 do
		if(btn_inventar[aktuel][i]) then
			local x,y = guiGetPosition(btn_inventar[aktuel][i],true)
			local bx,by = guiGetSize(btn_inventar[aktuel][i],true)
			bx,by = bx +x , by +y
			if(mx > x and mx < bx and my > y and my < by) then
				return btn_inventar[aktuel][i]
			end
		end
	end
	return false
end

local function onItemMouseOver()
	local src = false
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true) then
		return 0
	end

	if(showInfoBlip == true) then
		return false
	end
	if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][tonumber(guiGetText(source))]) then
		setItemRGB(tonumber(guiGetText(source)),255,255,0)
	end

	InfoBlipTimer = setTimer(showInfoBlipFunc,500,1,source)
end

local function onItemMouseLeave()
	local src = false
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end
	if(src ~= true ) then
		return false
	end
	if(( ( lockItemUseState[aktuel] and lockItemUseState[aktuel][tonumber(guiGetText(source))] ) )) then

	else
		setItemRGB(tonumber(guiGetText(source)), 110,110,110 )
	end

	if(showInfoBlip) then
		showInfoBlip = false
		InventarBlipAlpha = 0
		removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
	end
	killTimer(InfoBlipTimer)
end

local function onCloseClick(button)
	if(button == "left") then
		destroyInventar()
	end
end

function MoveGUI(mx,my)
	x,y = mx - mouseDistX, my - mouseDistY
	slots = tonumber(getElementData(lp,"Inventar_c")[aktuel.."Platz"])
	local line,oline,platz
	for i=0,slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then
			platz = 0
		end
		local id
		if(	getElementData(lp,"Item_"..aktuel.."_c") ) then
			id = getElementData(lp,"Item_"..aktuel.."_c")[i.."_id"]
			if(id) then
				item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			end
		end
		guiSetPosition ( btn_inventar[aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
		sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end
	guiSetPosition ( btn_Items, x+2,y-48, false )
	guiSetPosition ( btn_Objekte ,x+2 + 82,y-48, false )
	guiSetPosition ( btn_Essen , x+2 + 82*2,y-48, false )
	guiSetPosition ( btn_Drogen,  x+2 + 82*3,y-48, false )
	guiSetPosition ( btn_Close , x+bx + 1,y-49, false )
	guiSetPosition ( btn_Move, x+bx + 1,y-49+18, false )
	guiSetPosition ( btn_Reset, x+bx + 1,y-49+36, false )

end

local function onMoveClick(button,mx,my)
	if(button == "left") then
		unbindKey("i","down",destroyInventar)
		mouseDistX,mouseDistY = mx - x, my - y
		addEventHandler("onClientMouseMove",root,MoveGUI)
	end
end

local function onStopMove(button)
	if(button == "left") then
		removeEventHandler("onClientMouseMove",root,MoveGUI)
		bindKey("i","down",destroyInventar)
	end
end

local function onResetClick(button)
	if(button == "left") then
		x,y = fx/2 - bx/2,fy/2 - by/2
		slots = tonumber(getElementData(lp,"Inventar_c")[aktuel.."Platz"])
		local line,oline,platz
		for i=0,slots-1,1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				platz = 0
			end
			local id
			if(	getElementData(lp,"Item_"..aktuel.."_c") ) then
				id = getElementData(lp,"Item_"..aktuel.."_c")[i.."_id"]
				if(id) then
					item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
				end
			end
			guiSetPosition ( btn_inventar[aktuel][i], x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line, false )
			sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
			oline = line
			platz = platz + 1
		end
		guiSetPosition ( btn_Items, x+2,y-48, false )
		guiSetPosition ( btn_Objekte ,x+2 + 82,y-48, false )
		guiSetPosition ( btn_Essen , x+2 + 82*2,y-48, false )
		guiSetPosition ( btn_Drogen,  x+2 + 82*3,y-48, false )
		guiSetPosition ( btn_Close , x+bx + 1,y-49, false )
		guiSetPosition ( btn_Move, x+bx + 1,y-49+18, false )
		guiSetPosition ( btn_Reset, x+bx + 1,y-49+36, false )
	end
end

local function renderInventar()
		if(isMainMenuActive()) then
			destroyInventar()
			return false
		end
		dxDrawImage(x,y-95,50,50,":vrp/files/images/logo.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2.0,y-48,80.0,48.0,tocolor(r["Items"],g["Items"],b["Items"],200),false)
		dxDrawImage(x+20,y-48,48.0,48.0,"files/images/Inventory/items.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82,y-48,80.0,48.0,tocolor(r["Objekte"],g["Objekte"],b["Objekte"],200),false)
		dxDrawImage(x+20 + 82,y-48,48.0,48.0,"files/images/Inventory/items/Objekte.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82*2,y-50,82.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82*2,y-48,80.0,48.0,tocolor(r["Essen"],g["Essen"],b["Essen"],200),false)
		dxDrawImage(x+20 + 82*2,y-48,48.0,48.0,"files/images/Inventory/food.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)

		dxDrawRectangle(x + 82*3,y-50,84.0,50.0,tocolor(r["Rahmen"],g["Rahmen"],b["Rahmen"],255),false)
        dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(0,0,0,255),false)
		dxDrawRectangle(x+2 + 82*3,y-48,80.0,48.0,tocolor(r["Drogen"],g["Drogen"],b["Drogen"],200),false)
		dxDrawImage(x+20 + 82*3,y-48,48.0,48.0,"files/images/Inventory/drogen.png",0.0,0.0,0.0,tocolor(255,255,255,255),false)


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
		for i=0,slots-1,1 do
			line = math.floor(i/7)
			if(line ~= oline) then
				platz = 0
			end
			if(not itemPlatzR[aktuel][i]) then
				if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][i]) then
					setItemRGB(i,110,110,110)
				end
			end
			dxDrawRectangle(x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40,tocolor(itemPlatzR[aktuel][i],itemPlatzG[aktuel][i],itemPlatzB[aktuel][i],200),false)
			local item_table_aktuell = getElementData(lp,"Item_"..aktuel.."_c")
			if item_table_aktuell then
				local id = item_table_aktuell[tostring(i).."_id"]

				if(id) then
					local rx,gx,bx = itemPlatzR[aktuel][i] - 10,itemPlatzG[aktuel][i]- 10,itemPlatzB[aktuel][i]- 10
					local a = 255
					if (rx == 100) then
						rx,gx,bx = 255,255,255
						a = 180
					end
					local item_table = getElementData(lp,"Item_c")
					local itemname = item_table[id]
					if itemname then
						local icon = itemData[itemname]["Icon"]

						if item_table then
							dxDrawImage(item[id]["x"],item[id]["y"],40,40,"files/images/Inventory/items/"..icon,0.0,0.0,0.0,tocolor(rx,gx,bx,255),itemFront[id])
							dxDrawText(tostring(getElementData(lp,"Item_c")[tostring(id).."_Menge"]),item[id]["x"] + 40 - dxGetTextWidth (tostring(getElementData(lp,"Item_c")[tostring(id).."_Menge"] , 0.85, "defauld-bold")),item[id]["y"] + 27.25,40,40,tocolor(rx,gx,bx,a),0.85,"default-bold","left","top",false,false,itemFront[id])
						end
					end
				end
			end
			oline = line
			platz = platz + 1
		end

		if(showInfoBlip == true) then

			showInfo(IBUeber,IBtext,IBx,IBy,Itx,Ity,Iobx,Ioby,Ibx,Iby)
		end


end

local function onClientDragAndDropMove()
	local mx,my = getCursorPosition ()
	local x,y = startMoveButton["x"],startMoveButton["y"]
	local fx,fy = startMoveButton["bx"] + x,startMoveButton["by"] + y
	--if(mx < x or mx >fx or my < y or my > fy) then
		local button = startMoveButton["object"]
		local platz
		if(getElementData(lp,"Item_"..aktuel.."_c") ~= false) then
			platz = getElementData(lp,"Item_"..aktuel.."_c")[guiGetText(button).."_id"]
		else
			platz = nil
		end

		if(showInfoBlip) then
			showInfoBlip = false
			InventarBlipAlpha = 0
			removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
		end
		killTimer(InfoBlipTimer)
		if(getPlaceMouseOver() ~= button) then
			triggerEvent("onClientMouseLeave",button)
		end
		if(platz) then

			local place = guiGetText(button)

			local fullx,fully = guiGetScreenSize()
			mx,my = mx*fullx,my*fully
			if(	getElementData(lp,"Item_"..aktuel.."_c") ) then
				id = getElementData(lp,"Item_"..aktuel.."_c")[place.."_id"]
				if(id) then
					item[tonumber(id)] = { ["x"]= mx,["y"]=my }
				end
			end

			if(isElement(getPlaceMouseOver())) then
				triggerEvent("onClientMouseEnter",getPlaceMouseOver())
				if(isElement(lastOver) and lastOver ~= getPlaceMouseOver()) then
					triggerEvent("onClientMouseLeave",lastOver)
				end
				lastOver = getPlaceMouseOver()
			elseif(isElement(lastOver)) then
				triggerEvent("onClientMouseLeave",lastOver)
				lastOver = nil
			end
		else
			startMoveButton = nil
			removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
		end
	--end
end

function onClickAndDropDown(button)
	local id

	if(getElementData(lp,"Item_"..aktuel.."_c")) then
		id = getElementData(lp,"Item_"..aktuel.."_c")[guiGetText(source).."_id"]
	end

	if button == "left" then
		if(id) then
			local itemname = getElementData(lp,"Item_c")
			local item = itemname[id]
			if item then
				triggerEvent("onPlayerItemUse",lp,getElementData(lp,"Item_c")[id],id,aktuel,tonumber(guiGetText(source)))
			end
		end
		return false
	else

		local src
		for i=0,slots-1,1 do
			if(source == btn_inventar[aktuel][i]) then
				src = true
			end
		end
		if(src ~= true) then
			if(source ~= btn_Move and (source == btn_Items or source == btn_Objekte or source == btn_Essen or source == btn_Drogen or source == btn_Close or source == btn_Reset) ) then
				startMoveButton = { ["object"] = source }
				startMoveButton["x"],startMoveButton["y"] = guiGetPosition ( source, true )
				startMoveButton["bx"],startMoveButton["by"] = guiGetSize ( source, true )
				addEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
				return false
			end
			return false
		end


		if(id) then
			itemFront[id] = true
		end
		startMoveButton = { ["object"] = source }
		startMoveButton["x"],startMoveButton["y"] = guiGetPosition ( source, true )
		startMoveButton["bx"],startMoveButton["by"] = guiGetSize ( source, true )
		addEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
	end
end

function onClickAndDropUp(button)

	local src
	for i=0,slots-1,1 do
		if(source == btn_inventar[aktuel][i]) then
			src = true
		end
	end

	if(startMoveButton) then
		local place = false
		local sbutton = startMoveButton["object"]
		local splace = tonumber(guiGetText(sbutton))
		local item_table = getElementData(lp,"Item_c")

		if(src ~= true) then
			if(source ~= btn_Move and (source == btn_Items or source == btn_Objekte or source == btn_Essen or source == btn_Drogen or source == btn_Close or source == btn_Reset) ) then

				startMoveButton = nil
				lastOver = nil
				removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)
				inventarSetItemToPlace(id,splace)
				--return false
			end
			inventarSetItemToPlace(id,splace)
			--return false
		end

		if getPlaceMouseOver() then
			place = tonumber(guiGetText(getPlaceMouseOver()))
			local nid = getElementData(lp,"Item_"..aktuel.."_c")[place.."_id"]
			if(nid) then
				local oPlace = guiGetText(sbutton)


				local id = getElementData(lp,"Item_"..aktuel.."_c")[splace.."_id"]

				local itemname_moved = item_table[id]
				local itemname_old = item_table[nid]
				if id ~= nid then
					if itemname_moved == itemname_old then
						local itemmenge_moved = tonumber(getElementData(lp,"Item_c")[tostring(id).."_Menge"])
						local itemmenge_old = tonumber(getElementData(lp,"Item_c")[tostring(nid).."_Menge"])
						local gesamt = itemmenge_moved+itemmenge_old
						if itemData[itemname_moved]["Stack_max"] >= gesamt then
							triggerServerEvent("c_stackItems",lp,id,nid,place)
						else
							outputChatBox("Der Stack von Item '"..itemname_moved.."' darf nur "..itemData[itemname_moved]["Stack_max"].." betragen!",255,0,0)
						end
					else
						outputChatBox("Du kannst nur gleiche Items stapeln!",255,0,0)
					end
				end

				inventarSetItemToPlace(id,place)
				inventarSetItemToPlace(nid,splace)

				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)
					setItemRGB(splace,50,200,255)
					lockItemUseState[aktuel] = {[splace]=true}
				end
				triggerServerEvent("changePlaces",lp,aktuel,oPlace,place)
			else
				local id = getElementData(lp,"Item_"..aktuel.."_c")[splace.."_id"]
				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)
					setItemRGB(tonumber(place),50,200,255)
					lockItemUseState[aktuel] = {[tonumber(place)]=true}

				end

				inventarSetItemToPlace(id,place)
				triggerServerEvent("c_setItemPlace",lp,aktuel,splace,tonumber(place))
			end
		else
			local mx,my = getCursorPosition ( )
			mx,my = mx *fx,my*fy

			if(mx >= x and mx <= x+bx and my >= y-50 and my <= y+by) then
				local id = getElementData(lp,"Item_"..aktuel.."_c")[splace.."_id"]
				inventarSetItemToPlace(id,splace)
				if(lockItemUseState[aktuel] and lockItemUseState[aktuel][splace]) then
					setItemsRGBDefault(aktuel)

				--	outputChatBox("To Green")
					--setItemRGB(splace,0,255,0,true)
					--lockItemUseState[aktuel] = {[splace] = true}
				end
			else
				local id = getElementData(lp,"Item_"..aktuel.."_c")[splace.."_id"]
				local itemname = getElementData(lp,"Item_c")
				if tonumber(itemData[(itemname[id])]["Wegwerf"]) == 1 then
					--triggerServerEvent("layItemInWorld_c",lp,lp,aktuel,id)
					triggerServerEvent("wegwerfItem",lp,itemname[id],aktuel,id,splace)
				else
					inventarSetItemToPlace(id,splace)
					outputChatBox("Dieses Item kann nicht weggeworfen werden!",255,0,0)
				end
			end
		end
	end

	startMoveButton = nil
	lastOver = nil
	removeEventHandler("onClientPreRender",getRootElement(),onClientDragAndDropMove)

	local id
	if(getElementData(lp,"Item_"..aktuel.."_c")) then
		id = getElementData(lp,"Item_"..aktuel.."_c")[guiGetText(source).."_id"]
	end
	if(id) then
		itemFront[id] = false
	end
end

local sx,sy = guiGetScreenSize()

function showInventar(teil)
	if(type(teil) == "string" and teil ~= "i") then
		aktuel = teil
	end
	unbindKey("i","down",showInventar)
	bindKey("i","down",destroyInventar)
	showCursor ( true ,false)
	toggleControl ( "fire", false)

	pClose,pMove,pReset = "files/images/Inventory/closeinv.png","files/images/Inventory/moveinv.png","files/images/Inventory/reset.png"
	r,g,b = { ["Items"]=50,["Essen"]=50,["Objekte"]=50,["Drogen"]=50, ["Rahmen"]=255} , { ["Items"]=200,["Essen"]=200,["Objekte"]=200,["Drogen"]=200 ,["Rahmen"]=255} , { ["Items"]=255,["Essen"]=255,["Objekte"]=255,["Drogen"]=255,["Rahmen"]=255 }

	slots = tonumber(getElementData(lp,"Inventar_c")[aktuel.."Platz"])
	lines = math.ceil(slots/7)
	bx,by = 330, 20 - 4 + 45*lines --543,266
	if(not x and not y) then
		x,y = fx/2 - bx/2,fy/2 - by/2
	end
	r[aktuel],g[aktuel],b[aktuel] = 100,130,140
	r["o"..aktuel],g["o"..aktuel],b["o"..aktuel] = 0,255,0
	local line
	local oline
	local platz

	for i=0,slots-1,1 do
		line = math.floor(i/7)
		if(line ~= oline) then
			platz = 0
		end
		btn_inventar[aktuel][i] = guiCreateButton (x+10 + 40 * platz + 5 * platz,y+10 + 40 * line + 5 * line,40,40, i.."", false)
		guiSetAlpha(btn_inventar[aktuel][i],0)
		local id
		if(	getElementData(lp,"Item_"..aktuel.."_c") ) then
			id = getElementData(lp,"Item_"..aktuel.."_c")[i.."_id"]
			if(id) then
				item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
				itemFront[id] = false
			end
		end
		if(not lockItemUseState[aktuel] or not lockItemUseState[aktuel][tonumber(i)]) then
			setItemRGB(i,110,110,110)
		end
		sitem[i]= { ["x"]= x+10 + 40 * platz + 5 * platz,["y"]=y+10 + 40 * line + 5 * line }
		oline = line
		platz = platz + 1
	end

	btn_Items = guiCreateButton (x+2,y-48,80.0,48.0, "", false)
	guiSetAlpha(btn_Items,0)
	btn_Objekte = guiCreateButton ( x+2 + 82,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Objekte,0)
	btn_Essen = guiCreateButton ( x+2 + 82*2,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Essen,0)
	btn_Drogen = guiCreateButton ( x+2 + 82*3,y-48, 80.0,48.0, "", false )
	guiSetAlpha(btn_Drogen,0)
	btn_Close = guiCreateButton ( x+bx + 1,y-49, 18,18, "", false  )
	guiSetAlpha(btn_Close,0)
	btn_Move = guiCreateButton ( x+bx + 1,y-49+18, 18,18, "", false )
	guiSetAlpha(btn_Move,0)
	btn_Reset = guiCreateButton ( x+bx + 1,y-49+36, 18,18, "", false )
	guiSetAlpha(btn_Reset,0)


	addEventHandler("onClientMouseEnter",getRootElement(),onButtonInvEnter)
	addEventHandler("onClientMouseLeave",getRootElement(),onButtonInvLeave)
	addEventHandler("onClientGUIClick",getRootElement(),onInvClick)

	addEventHandler("onClientMouseEnter",getRootElement(),onItemMouseOver)
	addEventHandler("onClientMouseLeave",getRootElement(),onItemMouseLeave)

	addEventHandler("onClientGUIClick",btn_Close,onCloseClick)
	addEventHandler("onClientGUIMouseDown",btn_Move,onMoveClick)
	addEventHandler("onClientGUIMouseUp",btn_Move,onStopMove)
	addEventHandler("onClientGUIClick",btn_Reset,onResetClick)

	addEventHandler("onClientGUIMouseDown",getRootElement(),onClickAndDropDown)
	addEventHandler("onClientGUIMouseUp",getRootElement(),onClickAndDropUp)


	addEventHandler("onClientRender",getRootElement(),renderInventar)
end

function destroyInventar()
	if(not btn_Items) then
		return false
	end
	unbindKey("i","down",destroyInventar)
	bindKey("i","down",showInventar)
	showCursor ( false )

	if not getElementData(getLocalPlayer(),"schutzzone") == true then
		toggleControl ( "fire", true)
	end

	removeEventHandler("onClientRender",getRootElement(),renderInventar)
	removeEventHandler("onClientMouseEnter",getRootElement(),onButtonInvEnter)
	removeEventHandler("onClientMouseLeave",getRootElement(),onButtonInvLeave)
	removeEventHandler("onClientGUIClick",getRootElement(),onInvClick)
	removeEventHandler("onClientMouseEnter",getRootElement(),onItemMouseOver)
	removeEventHandler("onClientMouseLeave",getRootElement(),onItemMouseLeave)
	removeEventHandler("onClientGUIClick", btn_Close,onCloseClick)
	removeEventHandler("onClientGUIMouseDown",btn_Move,onMoveClick)
	removeEventHandler("onClientGUIMouseUp",btn_Move,onStopMove)
	removeEventHandler("onClientMouseMove",root,MoveGUI)
	removeEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
	removeEventHandler("onClientGUIMouseDown",getRootElement(),onClickAndDropDown)
	removeEventHandler("onClientGUIMouseUp",getRootElement(),onClickAndDropUp)

	destroyElement(btn_Items)
	destroyElement(btn_Objekte)
	destroyElement(btn_Essen)
	destroyElement(btn_Drogen)
	destroyElement(btn_Close)
	destroyElement(btn_Move)
	destroyElement(btn_Reset)
	btn_Items = nil
	sitem = {}
	item = {}
	if(isTimer(InfoBlipTimer) and getTimerDetails(InfoBlipTimer)) then
		killTimer(InfoBlipTimer)
	end
	if(callCheck == true) then
		local slots = tonumber(getElementData(lp,"Inventar_c")[oldaktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(btn_inventar[oldaktuel][i])
		end
		callCheck = false
	else
		local slots = tonumber(getElementData(lp,"Inventar_c")[aktuel.."Platz"])
		for i=0,slots-1,1 do
			destroyElement(btn_inventar[aktuel][i])
		end
	end

	showInfoBlip = false
	InventarBlipAlpha = 0

end

addEventHandler("onClientPlayerWasted",lp,destroyInventar)
function onInvClick(button)
	if button == "left" then

		if(source ~= btn_Items and source ~= btn_Objekte and source ~= btn_Essen and source ~= btn_Drogen) then
			return 0
		end
		oldaktuel = aktuel
		if( source == btn_Items and aktuel ~= "Items") then
			aktuel = "Items"
		elseif( source == btn_Objekte and aktuel ~= "Objekte") then
			aktuel = "Objekte"
		elseif( source == btn_Essen and aktuel ~= "Essen") then
			aktuel = "Essen"
		elseif( source == btn_Drogen and aktuel ~= "Drogen") then
			aktuel = "Drogen"
		else
			return 0
		end
		r[oldaktuel],g[oldaktuel],b[oldaktuel] = 110,110,110
		callCheck = true
		destroyInventar()
		showInventar()
	end
end

function onButtonInvEnter()
	if(source ~= btn_Items and source ~= btn_Objekte and source ~= btn_Essen and source ~= btn_Drogen and source ~= btn_Close and source ~= btn_Move and source ~= btn_Reset) then
		return 1
	end

	if( source == btn_Items) then
		if(aktuel == "Items") then
			return 0
		end
		r["oItems"],g["oItems"],b["oItems"] = r["Items"],g["Items"],b["Items"]
		r["Items"],g["Items"],b["Items"] = 100,130,140
	elseif( source == btn_Objekte) then
		if(aktuel == "Objekte") then
			return 0
		end
		r["oObjekte"],g["oObjekte"],b["oObjekte"] = r["Objekte"],g["Objekte"],b["Objekte"]
		r["Objekte"],g["Objekte"],b["Objekte"] = 100,130,140
	elseif( source == btn_Essen) then
		if(aktuel == "Essen") then
			return 0
		end
		r["oEssen"],g["oEssen"],b["oEssen"] = r["Essen"],g["Essen"],b["Essen"]
		r["Essen"],g["Essen"],b["Essen"] = 100,130,140
	elseif( source == btn_Drogen) then
		if(aktuel == "Drogen") then
			return 0
		end
		r["oDrogen"],g["oDrogen"],b["oDrogen"] = r["Drogen"],g["Drogen"],b["Drogen"]
		r["Drogen"],g["Drogen"],b["Drogen"] = 100,130,140
	elseif( source == btn_Close) then
		pClose = "files/images/Inventory/closeinvS.png"
	elseif( source == btn_Move) then
		pMove = "files/images/Inventory/moveinvS.png"
	elseif( source == btn_Reset) then
		pReset = "files/images/Inventory/resetS.png"
	end
end

function onButtonInvLeave()
	if(source ~= btn_Items and source ~= btn_Objekte and source ~= btn_Essen and source ~= btn_Drogen and source ~= btn_Close and source ~= btn_Move and source ~= btn_Reset) then
		return 1
	end
	if( source == btn_Items) then
		if(aktuel == "Items") then
			return 0
		end
		r["Items"],g["Items"],b["Items"] = r["oItems"],g["oItems"],b["oItems"]
	elseif( source == btn_Objekte) then
		if(aktuel == "Objekte") then
			return 0
		end
		r["Objekte"],g["Objekte"],b["Objekte"] = r["oObjekte"],g["oObjekte"],b["oObjekte"]
	elseif( source == btn_Essen) then
		if(aktuel == "Essen") then
			return 0
		end
		r["Essen"],g["Essen"],b["Essen"] = r["oEssen"],g["oEssen"],b["oEssen"]
	elseif( source == btn_Drogen) then
		if(aktuel == "Drogen") then
			return 0
		end
		r["Drogen"],g["Drogen"],b["Drogen"] = r["oDrogen"],g["oDrogen"],b["oDrogen"]
	elseif( source == btn_Close) then
		pClose = "files/images/Inventory/closeinv.png"
	elseif( source == btn_Move) then
		pMove = "files/images/Inventory/moveinv.png"
	elseif( source == btn_Reset) then
		pReset = "files/images/Inventory/reset.png"
	end

end

function inventarSetItemToPlace(id,platz)
	item[tonumber(id)] = {["x"]=sitem[tonumber(platz)]["x"],["y"]=sitem[tonumber(platz)]["y"]}
end

local function afterLogin()
	bindKey(inventarKey,"down",showInventar)
end
addEvent("loadPlayerInventarClient",true)
addEventHandler("loadPlayerInventarClient",lp,afterLogin)

local function setInventarKoordinaten(platz,tasche)
	if(tasche == aktuel) then
		if x then
			local id = getElementData(lp,"Item_"..aktuel.."_c")[platz.."_id"]
			local line = math.floor(platz/7)
			if(platz ~= 0) then
				platz = platz/(platz/7) - 1
			end
			item[id]= { ["x"]= x+10 + 40 * platz + 5 * platz ,["y"]=y+10 + 40 * line + 5 * line }
		end
	end
end
addEvent("setIKoords_c",true)
addEventHandler("setIKoords_c",getRootElement(),setInventarKoordinaten)

function setItemRGB(platz,r,g,b)
	if(r) then
		itemPlatzR[aktuel][platz] = r
	end

	if(g) then
		itemPlatzG[aktuel][platz] = g
	end

	if(b) then
		itemPlatzB[aktuel][platz] = b
	end
end
