lockItemUseState = {}

local function makeStringToLines(string,xpos,breite,schrift,scale)
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

function getInfoClip(string,xpos,ypos,breite,hoehe,schrift,scale)
	local bx
	while(dxGetFontHeight(scale,schrift) * makeStringToLines(string,xpos,breite,schrift,scale) >= hoehe - ypos) do
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
function showInfo(name,info,x,y,tx,ty,obx,oby,bx,by)
		if not bx then bx = 0 end
				if not by then by = 0 end

		if(InventarBlipAlpha < 250) then
			InventarBlipAlpha = InventarBlipAlpha + 10
		else
			InventarBlipAlpha = 255
		end
		dxDrawImage(x,y,bx + 13 - tx,by + 31 - ty,"files/images/Inventory/infoblubf.png",0.0,0.0,0.0,tocolor(255,255,255,InventarBlipAlpha),true)
		dxDrawText(name,x,y+3,bx ,y + 20,tocolor(0,0,0,InventarBlipAlpha),ueberSize,"default-bold","center","top",false,true,true)
        dxDrawText(info,tx,ty,bx,by,tocolor(0,0,0,InventarBlipAlpha),textSize,"default-bold","left","top",false,true,true)

end
function showInfo2()
	showInfo(IBUeber,IBtext,1035,448,Itx,Ity,Iobx,Ioby,Ibx,Iby)
end
InventarBlipAlpha = 0

local function onItemClick(itemname,itemid,tasche,platz)
	if(not lockItemUseState[tasche] or not lockItemUseState[tasche][platz]) then
		local verbraucht = itemData[itemname]["Verbraucht"]
		if verbraucht == 1 then delete = true
	elseif verbraucht == 2 then delete = false
	elseif verbraucht == 0 then delete = false
		end
			triggerServerEvent("onPlayerItemUseServer",getLocalPlayer(),itemid,tasche,itemname,platz,delete)
	end

end
addEvent("onPlayerItemUse",false)
addEventHandler("onPlayerItemUse",getRootElement(),onItemClick)

function setItemsRGBDefault(tasche,setFalse)
	local max = getElementData(getLocalPlayer(),"Inventar_c")[tasche.."Platz"]
	for i=0,max,1 do
		setItemRGB(i,110,110,110)
	end

	if(not setFalse) then
		if(lockItemUseState[tasche]) then
			lockItemUseState[tasche] = nil
		end
	end
end

function moveInfoWindow(x,y)
	setInventarBlipPos(x+5,y+8)
end

function showInfoBlipFunc(button)
	if(showInfoBlip == true) then
		return false
	end

	if(getElementData(getLocalPlayer(),"Item_"..aktuel.."_c") == false) then
		showInfoBlip = "close"
		return false
	end
	local id = getElementData(getLocalPlayer(),"Item_"..aktuel.."_c")[guiGetText(button).."_id"]
	if(id == nil) then
		showInfoBlip = "close"
		return 0
	end

	local itemtable = getElementData(getLocalPlayer(),"Item_c")
	if itemtable then
		if id then
			local name = itemtable[tonumber(id)]
			if name then
				local text = itemData[name]["Info"]
				aname, atext = getRealItemName(name),text


				local fx,fy = guiGetScreenSize()
				local mx,my = getCursorPosition ()
				setInventarBlipData(aname,text,mx * fx + 5,my *fy + 8)

				showInfoBlip = true

				addEventHandler("onClientMouseMove",getRootElement(),moveInfoWindow)
			end
		end
	end
end

function setInventarBlipData(uber,text,x,y)
	IBUeber = getRealItemName(uber)
	IBtext = text
	if not IBtext then IBtext = "kein Text" end
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
end

function setInventarBlipPos(x,y)
	IBUeber = aname
	IBtext =  atext
	if not IBtext then IBtext = "kein Text" end
	IBx,IBy = x,y
	ueberSize = 1.1
	textSize = 0.8
	Itx,Ity = IBx + 8,IBy + 20
	Iobx,Ioby = Itx + 137,Ity --1255,523
	Ibx,Iby = getInfoClip(IBtext,Itx,Ity,Iobx,Ioby ,"default-bold",textSize)
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

function getMouseState()
	return mouseState
end

local function onClick(button,state)
	mouseState = state
end
addEventHandler("onClientClick",getRootElement(),onClick)

a = "ä"
o = "ö"
u = "ü"
s = "ß"
A = "Ä"
O = "Ö"
U = "Ü"

function refreshString(string)
	local nstring,w = string.gsub(string,"Ü","Ue")
	local nstring,w = string.gsub(nstring,"Ö","Oe")
	local nstring,w = string.gsub(nstring,"Ä","Ae")
	local nstring,w = string.gsub(nstring,"ü","ue")
	local nstring,w = string.gsub(nstring,"ö","oe")
	local nstring,w = string.gsub(nstring,"ä","ae")
	local nstring,w = string.gsub(nstring,"ß","sz")
	return nstring
end


function refreshStringManuel(string)
	local nstring,w = string.gsub(string,"Ue",""..U.."")
	local nstring,w = string.gsub(nstring,"Oe",""..O.."")
	local nstring,w = string.gsub(nstring,"Ae",""..A.."")
	local nstring,w = string.gsub(nstring,"ue",""..u.."")
	local nstring,w = string.gsub(nstring,"oe",""..o.."")
	local nstring,w = string.gsub(nstring,"ae",""..a.."")
	local nstring,w = string.gsub(nstring,"*sz",""..s.."")
	return nstring
end
