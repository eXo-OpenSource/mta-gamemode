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