-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player/GroupProperty.lua
-- *  PURPOSE:     GroupProperty
-- *
-- ****************************************************************************
GroupProperty = inherit( Singleton )
local w,h = guiGetScreenSize()
local width = w*0.18
local height = h*0.12
local sx = 0
local sy = h*0.5-height/2
local fontHeight = dxGetFontHeight(1,"default-bold")
addRemoteEvents{"showGroupEntrance", "hideGroupEntrance","createGroupBlip","destroyGroupBlip","addPickupToGroupStream","groupEntryMessage"}
function GroupProperty:constructor( )
	self.m_BlipProperties = {}
	self.m_BlipProperties2 = {}
	self.m_MarkerProperties = {}
	self.m_StreamCheckPickups = {}
	addEventHandler("createGroupBlip", localPlayer, bind( GroupProperty.createBlips, self) )
	addEventHandler("destroyGroupBlip", localPlayer, bind( GroupProperty.destroyBlips, self) )
	addEventHandler("showGroupEntrance", localPlayer, bind( GroupProperty.showWindow, self) )
	addEventHandler("hideGroupEntrance", localPlayer, bind( GroupProperty.hideWindow, self) )
	addEventHandler("addPickupToGroupStream", localPlayer, bind( GroupProperty.addPickupToStream, self) )
	addEventHandler("groupEntryMessage",localPlayer,bind(GroupProperty.showEntryMessage,self))
	self.m_Render = bind( GroupProperty.render, self)
end

function GroupProperty:addPickupToStream( pickup, id )
	self.m_StreamCheckPickups[pickup] = id
	addEventHandler("onClientElementStreamIn",pickup,bind(GroupProperty.requestImmoPanel,self))
	addEventHandler("onClientElementStreamOut",pickup,bind(GroupProperty.requestImmoPanelClose,self))
	if isElementStreamedIn( pickup ) then
		self:requestImmoPanel( pickup )
	end
end

function GroupProperty:requestImmoPanel( pickup )
	if not source then source = pickup end
	if self.m_StreamCheckPickups[source] then
		localPlayer:setData("insideGroupInterior",true) -- setData not syncing
		triggerServerEvent("requestImmoPanel",localPlayer,self.m_StreamCheckPickups[source])
	end
end

function GroupProperty:requestImmoPanelClose( )
	localPlayer:setData("insideGroupInterior",false, true)
	GroupPropertyGUI.disable()
end

function GroupProperty:showWindow( tInfo, tPickup, tName )
	self.m_Table = tInfo
	self.m_Name = tName
	self.m_Pickup = tPickup
	removeEventHandler("onClientRender", root, self.m_Render)
	addEventHandler("onClientRender", root, self.m_Render)
end

function GroupProperty:hideWindow( )
	removeEventHandler("onClientRender", root, self.m_Render)
end

function GroupProperty:render()
	if self.m_Table and self.m_Name then
		local mx,my = getElementPosition( localPlayer )
		local px, py = getElementPosition( self.m_Pickup )
		local dist = getDistanceBetweenPoints2D( mx, my, px, py)
		if dist <= 5 then
			dxDrawRectangle( sx, sy, width, height,tocolor(0,0,0,150))
			local bCol1 = self:isMouseOver( sx+width*0.1,sy+height*0.1, width*0.35, height*0.8)
			local bCol2 = self:isMouseOver( sx+width*0.5,sy+height*0.1, width*0.35, height*0.8)
			local color1 = tocolor(50, 50,50,255)
			local color2 = tocolor( 50,50,50,255)
			if bCol1 then
				color1 = tocolor(200, 200, 200, 255)
			end
			if bCol2 then
				color2 = tocolor(200, 200, 200, 255 )
			end
			dxDrawRectangle( sx, sy-fontHeight, width, fontHeight,tocolor(50,50,50,150))
			dxDrawText(string.upper(self.m_Table.m_Name.." - "..self.m_Name),sx, sy-fontHeight,width,height, tocolor(200,200,200,255),1,"default-bold","center")
			dxDrawImage( sx+width*0.1,sy+height*0.1, width*0.35, height*0.8, "files/images/Other/Enter.png", 0, 0, 0, color1)
			dxDrawImage( sx+width*0.5,sy+height*0.1, width*0.35, height*0.8, "files/images/Other/Close.png", 0, 0, 0, color2)

			if getKeyState("mouse1") then
				if bCol1 then
					removeEventHandler("onClientRender", root, self.m_Render)
					triggerServerEvent("GroupPropertyClientInput", localPlayer)
				elseif bCol2 then
					removeEventHandler("onClientRender", root, self.m_Render)
				end
			end
		else
			removeEventHandler("onClientRender", root, self.m_Render)
		end
	end
end

function GroupProperty:isMouseOver( startX, startY, wi, he)
	local bIsMouse = isCursorShowing()
	if bIsMouse then
		local cx, cy = getCursorPosition()
		if cx and cy then
			cx = cx * w
			cy = cy * h
			if ( cx >= startX and cx <= startX + wi) then
				if ( cy >= startY and cy <= startY + he) then
					return true
				end
			end
		end
	end
	return false
end

function GroupProperty:createBlips( x, y, z, id, groupType)
	self.m_BlipProperties[id] =  Blip:new("House.png", x, y, 500, groupType == "Firma" and {50, 200, 255} or {178, 35, 33})
	self.m_BlipProperties[id]:setDisplayText(groupType == "Firma" and "Firmensitz" or "Gangversteck")
	self.m_BlipProperties[id]:setZ(z)
end

function GroupProperty:destroyBlips( id )
	if self.m_BlipProperties[id] then
		delete(self.m_BlipProperties[id])
	end

end

function GroupProperty:showEntryMessage( text )
	if not self.m_MessageDisplayed then
		self.m_Message = GUILabel:new( 0,0,w*0.9,h*0.9, text, nil):setAlignX("right"):setAlignY("bottom"):setFont(RageFont(h*0.1))
		Animation.FadeAlpha:new(self.m_Message, 1000, 0, 255)
		setTimer(bind( GroupPropertyGUI.destroyMessage,self),2500,1)
		self.m_MessageDisplayed = true
	end
end
