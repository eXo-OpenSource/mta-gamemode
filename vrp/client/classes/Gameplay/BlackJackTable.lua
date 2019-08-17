-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/BlackJackTable.lua
-- *  PURPOSE:     BlackJackTable-Class which is only used for drawing/info above tables
-- *
-- ****************************************************************************

BlackJackTable = inherit(Singleton) 


addRemoteEvents{"BlackJack:sendTableObjects", "BlackJack:sendTableObject"}

function BlackJackTable:constructor() 
	self.m_OnStreamBind = bind(self.Event_onElementStreamIn, self)
	self.m_OnStreamOutBind = bind(self.Event_onElementStreamOut, self)
	
	self.m_Streamed = {}
	self.m_Table = {}

	addEventHandler("BlackJack:sendTableObjects", root, bind(self.Event_onReceiveTables, self))
	addEventHandler("BlackJack:sendTableObject", root, bind(self.Event_onTableCreated, self))

	addEventHandler("onClientRender", root, bind(self.onRender, self))

	triggerServerEvent("BlackJackManager:requestTables", localPlayer)
end

function BlackJackTable:Event_onElementStreamIn() 
	self.m_Streamed[source] = true
end

function BlackJackTable:Event_onElementStreamOut() 
	self.m_Streamed[source] = nil
end

function BlackJackTable:Event_onTableCreated(obj)
	if not self.m_Table[obj] then 
		self.m_Table[obj] = true
		addEventHandler("onClientElementStreamedIn", obj, self.m_OnStreamBind)
		addEventHandler("onClientElementStreamedOut", obj, self.m_OnStreamOutBind)
		self:checkIfStreamed(obj)
	end
end

function BlackJackTable:Event_onReceiveTables(tbl)
	for obj, k in pairs(tbl) do 
		if isValidElement(obj, "object") then
			self.m_Table[obj] = true
			addEventHandler("onClientElementStreamedIn", obj, self.m_OnStreamBind)
			addEventHandler("onClientElementStreamedOut", obj, self.m_OnStreamOutBind)
			self:checkIfStreamed(obj)
		end
	end
end


function BlackJackTable:onRender() 
	for table, k in pairs(self.m_Streamed) do 
		local ped = table:getData("BlackJackTable:ped") and isValidElement(table:getData("BlackJackTable:ped"), "ped") and table:getData("BlackJackTable:ped")
		local x, y, z = getPedBonePosition(ped, 8)
		local lx, ly = getElementPosition(localPlayer)
		local th = dxGetFontHeight(1.4, "sans")
		if getDistanceBetweenPoints2D(x, y, lx, ly) < 10 then
			local sx, sy = getScreenFromWorldPosition(x, y, z+.4)
			if isElementOnScreen(table) and sx and sy then
				if table:getData("BlackJack:TableBet") then 
					local text = ("Einsatz: $%s"):format(convertNumber(table:getData("BlackJack:TableBet")))
					local tw = dxGetTextWidth(text, 1.4, "sans")
					
					dxDrawBoxShape(sx-tw*0.55, sy-th*0.05, tw*1.1, th*1.1)
					dxDrawBoxShape((sx-tw*0.55)+1, (sy-th*0.05)+1, tw*1.1, th*1.1, Color.Black)
					dxDrawText(text, (sx-tw*0.5)+1, sy+1, sx+tw*0.5, sy, Color.Black, 1.4, "sans")
					dxDrawText(text, sx-tw*0.5, sy, sx+tw*0.5, sy, Color.White, 1.4, "sans")
					
					dxDrawText("Rechtsklick zum Zuschauen", (sx-tw*0.5)+1, (sy+th*1.1)+1, sx+tw*0.5, sy+th*1.1, Color.Black, 0.9, "sans", "center")
					dxDrawText("Rechtsklick zum Zuschauen", sx-tw*0.5, sy+th*1.1, sx+tw*0.5, sy+th*1.1, Color.White, 0.9, "sans", "center")
				else 
					local tw = dxGetTextWidth("Tisch frei", 1.4, "sans")
					dxDrawBoxShape((sx-tw*0.55)+1, (sy-th*0.05)+1, tw*1.1, th*1.1, Color.Black)
					dxDrawBoxShape(sx-tw*0.55, sy-th*0.05, tw*1.1, th*1.1)
					dxDrawText(("Tisch frei"), (sx-tw*0.5)+1, sy+1, sx+tw*0.5, sy, Color.Black, 1.4, "sans")
					dxDrawText(("Tisch frei"), sx-tw*0.5, sy, sx+tw*0.5, sy, Color.White, 1.4, "sans")
				end
			end
		end
	end
end

function BlackJackTable:checkIfStreamed(obj) 
	self.m_Streamed[obj] = isElementStreamedIn(obj)
end
