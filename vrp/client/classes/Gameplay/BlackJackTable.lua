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
	self.m_OnDestroyBind = bind(self.Event_onElementDestroy, self)

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
		addEventHandler("onClientElementDestroy", obj, self.m_OnDestroyBind)
		self:checkIfStreamed(obj)
		self:applyTexture(obj)
	end
end

function BlackJackTable:Event_onReceiveTables(tbl)
	for obj, k in pairs(tbl) do 
		if isValidElement(obj, "object") then
			self.m_Table[obj] = true
			addEventHandler("onClientElementStreamedIn", obj, self.m_OnStreamBind)
			addEventHandler("onClientElementStreamedOut", obj, self.m_OnStreamOutBind)
			addEventHandler("onClientElementDestroy", obj, self.m_OnDestroyBind)
			self:checkIfStreamed(obj)
			self:applyTexture(obj)
		end
	end
end

function BlackJackTable:applyTexture(object)
	local ped = object:getData("BlackJackTable:ped") 
	if ped and isValidElement(ped, "ped") then
		object.m_Ped = FileTextureReplacer:new(ped, "BlackJack/sbmyst.jpg", "sbmyst", {}, true, true)
		local cone = ped:getData("BlackJackPed:cone")
		if cone and isValidElement(cone, "object") then
			object.m_Cone = FileTextureReplacer:new(cone, "BlackJack/redwhite_stripe.jpg", "redwhite_stripe", {}, true, true)
		end
	end
end

function BlackJackTable:removeTexture(object)
	if object.m_Ped then 
		object.m_ped:delete()
	end
	if object.m_Cone then 
		object.m_Cone:delete()
	end
end


function BlackJackTable:Event_onElementDestroy() 
	self.m_Table[source] = nil
	self.m_Streamed[source] = nil
	self:removeTexture(source)
end


function BlackJackTable:onRender() 
	for obj, k in pairs(self.m_Streamed) do 
		if isValidElement(obj, "object") then
			local ped = obj:getData("BlackJackTable:ped") and isValidElement(obj:getData("BlackJackTable:ped"), "ped") and obj:getData("BlackJackTable:ped")
			local x, y, z = getPedBonePosition(ped, 8)
			local lx, ly = getElementPosition(localPlayer)
			local dist = getDistanceBetweenPoints2D(x, y, lx, ly)
			if dist < 1 then dist = 1 end
			local distModifier = (0.7+ .3*(1/dist))
			
			local th = dxGetFontHeight(1.4, "sans") * distModifier
			if dist < 10 then
				local sx, sy = getScreenFromWorldPosition(x, y, z+.4)
				if isElementOnScreen(obj) and sx and sy then
					if obj:getData("BlackJack:TableBet") then 
						local text = ("Einsatz: $%s"):format(convertNumber(obj:getData("BlackJack:TableBet")))
						local tw = dxGetTextWidth(text, 1.4, "sans") * distModifier

						dxDrawBoxShape(sx-tw*0.55, sy-th*0.05, tw*1.1, th*1.1)
						dxDrawBoxShape((sx-tw*0.55)+1, (sy-th*0.05)+1, tw*1.1, th*1.1, Color.Black)
						dxDrawText(text, (sx-tw*0.5)+1, sy+1, sx+tw*0.5, sy, Color.Black, 1.4 * distModifier, "sans")
						dxDrawText(text, sx-tw*0.5, sy, sx+tw*0.5, sy, Color.White, 1.4 * distModifier, "sans")

						dxDrawText("Rechtsklick zum Zuschauen", (sx-tw*0.5)+1, (sy+th*1.1)+1, sx+tw*0.5, sy+th*1.1, Color.Black, 0.9 * distModifier, "sans", "center")
						dxDrawText("Rechtsklick zum Zuschauen", sx-tw*0.5, sy+th*1.1, sx+tw*0.5, sy+th*1.1, Color.White, 0.9 * distModifier, "sans", "center")
					else 
						local tw = dxGetTextWidth("Tisch frei", 1.4, "sans") * distModifier
						dxDrawBoxShape((sx-tw*0.55)+1, (sy-th*0.05)+1, tw*1.1, th*1.1, Color.Black)
						dxDrawBoxShape(sx-tw*0.55, sy-th*0.05, tw*1.1, th*1.1)
							dxDrawText(("Tisch frei"), (sx-tw*0.5)+1, sy+1, sx+tw*0.5, sy, Color.Black, 1.4 *distModifier, "sans")
						dxDrawText(("Tisch frei"), sx-tw*0.5, sy, sx+tw*0.5, sy, Color.White, 1.4 * distModifier, "sans")
					end
				end
			end
		end
	end	
end

function BlackJackTable:checkIfStreamed(obj) 
	self.m_Streamed[obj] = isElementStreamedIn(obj)
end
