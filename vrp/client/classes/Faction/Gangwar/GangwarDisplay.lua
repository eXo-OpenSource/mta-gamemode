-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar HUD
-- *
-- ****************************************************************************

GangwarDisplay = inherit(Object)

local w,h = guiGetScreenSize()
local width, height = w*0.2,h*0.1
local startX,startY = w- width*1.1, h*0.5-(height/2)
local overViewHeight = h*0.4
local overViewWidth = w*0.15
local moveStateImages = 
{
	["stand"] = "stand_icon", 
	["walk"] = "run_icon", 
	["jog"] = "run_icon", 
	["sprint"] = "run_icon",
	["crouch"] = "stand_icon", 
	["crawl"] = "run_icon", 
	["jump"] = "run_icon", 
	["fall"] = "run_icon", 
	["climb"] = "run_icon", 
	["powerwalk"] = "run_icon", 
}
function GangwarDisplay:constructor( fac1, fac2, pAttackClient, pInitTime, pPos ) 
	self.m_Faction1 = fac1
	self.m_Faction2 = fac2 
	self.m_AttackClient = pAttackClient 
	self.m_TimeLeft = pInitTime
	self.m_BindRender = bind( self.render,self)
	self.m_FlagPosition = pPos
	addEventHandler("onClientRender",root,self.m_BindRender)
	self.m_BindClick = bind(self.click,self)
	addEventHandler("onClientClick",root,self.m_BindClick)
	self.m_BindFuncTime = bind( GangwarDisplay.tickTime, self )
	setTimer( self.m_BindFuncTime, 1000, pInitTime )
end

function GangwarDisplay:render() 
	self:checkDragDrop()
	self:rend_Display()
end

function GangwarDisplay:synchronizeTime( pTime ) 
	self.m_TimeLeft = pTime
end

function GangwarDisplay:checkDragDrop() 
	if self.m_Drag then 
		local cx, cy = getCursorPosition()
		cx = cx*w;
		cy = cy*h;
		if not self.offsetX and not self.offsetY then 
			self.offsetX = cx - startX
			self.offsetY = cy - startY
		end
		startX = cx - self.offsetX
		startY = cy - self.offsetY
	end
end

function GangwarDisplay:click( b, s)
	if b == "left" then 
		local b_Over = self:isMouseOver( startX,startY,width,height) 
		if b_Over then 
			if s == "down" then 
				self.m_Drag = true
			else 
				self.m_Drag = false
				self.offsetX = nil
				self.offsetY = nil
			end
		else 
			self.m_Drag = false
			self.offsetX = nil
			self.offsetY = nil
		end
	end
end

function GangwarDisplay:tickTime( ) 
	self.m_TimeLeft = self.m_TimeLeft - 1 
end


function GangwarDisplay:rend_Display( )
	local bottom_width = (width - ( width*0.01)) / 3

	local r,g,b = self.m_Faction1.m_Color["r"],self.m_Faction1.m_Color["g"],self.m_Faction1.m_Color["b"]
	dxDrawImage( startX , startY , width*0.495 , height*0.495,"files/images/gangwar/tile.png",0,0,0,tocolor(r,g,b,200) )
	self:dxDrawBoxShape(startX , startY , width*0.495 , height*0.495,tocolor(0,0,0,255))
	self:drawShadowBoxText( self.m_Faction1.m_Name,startX , startY+height*0.05 , width*0.495 , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","top" )
	
	local tParticipants = self.m_AttackClient:getFactionParticipants( self.m_Faction1 )
	local tFacMembers =  self.m_AttackClient:getFactionsMembers(self.m_Faction1 )
	self:drawShadowBoxText(#tParticipants.."/"..#tFacMembers,startX , startY -height*0.1, width*0.495 , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","bottom" )
	
	r,g,b = self.m_Faction2.m_Color["r"],self.m_Faction2.m_Color["g"],self.m_Faction2.m_Color["b"]
	dxDrawImage( startX+width*0.5 , startY , width*0.495 , height*0.495, "files/images/gangwar/tile.png",0,0,0,tocolor(r,g,b,200)  )
	self:dxDrawBoxShape(startX+width*0.5 , startY , width*0.495 , height*0.495,tocolor(0,0,0,255))
	self:drawShadowBoxText( self.m_Faction2.m_Name,startX+width*0.5 , startY +height*0.05, width*0.495 , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","top" )
	
	tParticipants = self.m_AttackClient:getFactionParticipants( self.m_Faction2 )
	tFacMembers =  self.m_AttackClient:getFactionsMembers(self.m_Faction2 )
	self:drawShadowBoxText(#tParticipants.."/"..#tFacMembers,startX+width*0.5 , startY -height*0.1, width*0.495 , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","bottom" )

	
	dxDrawImage( startX , startY+height*0.5 , bottom_width , height*0.495,"files/images/gangwar/tile.png",0,0,0, tocolor(0,204,204,180)  )
	self:dxDrawBoxShape(startX , startY+height*0.5 , bottom_width , height*0.495,tocolor(0,0,0,150))
	dxDrawImage( startX+ bottom_width*0.075 , startY+height*0.5+(height*0.495)*0.3 , bottom_width*0.2, bottom_width*0.2, "files/images/gangwar/gw_damage.png" )
	self:drawShadowBoxText( self.m_AttackClient.m_GangwarDamage,startX , startY+height*0.5 , bottom_width , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	
	dxDrawImage( startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495, "files/images/gangwar/tile.png",0,0,0,tocolor(0,204,204,180)  )
	self:dxDrawBoxShape(startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495,tocolor(0,0,0,150))
	dxDrawImage( startX+(bottom_width + width*0.01)+ bottom_width*0.075 , startY+height*0.5+(height*0.495)*0.3 , bottom_width*0.2, bottom_width*0.2, "files/images/gangwar/gw_kill.png" )
	self:drawShadowBoxText( self.m_AttackClient.m_GangwarKill,startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	
	dxDrawImage( startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495, "files/images/gangwar/tile.png",0,0,0,tocolor(0,204,204,180)  )
	self:dxDrawBoxShape(startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495,tocolor(0,0,0,150))
	self:drawShadowBoxText( self:formatTick( self.m_TimeLeft ) ,startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	dxDrawImage( startX+(bottom_width*2 + width*0.01)+ bottom_width*0.075 , startY+height*0.5+(height*0.495)*0.3 , bottom_width*0.2, bottom_width*0.2, "files/images/gangwar/gw_time.png" )
	self:dxDrawBoxShape(startX,startY,width,height,tocolor(0,0,0,150))
	
	self:rend_Flag() 
	if ScoreboardGUI and ScoreboardGUI:getSingleton().m_Showing then
		self:drawParticipantOverview()
	end
end

function GangwarDisplay:rend_Flag() 
	if self.m_FlagPosition then 
		local x, y = self.m_FlagPosition[1], self.m_FlagPosition[2], self.m_FlagPosition[3]
		local px, py = getElementPosition( localPlayer )
		local distance = math.floor( getDistanceBetweenPoints2D( x, y, px ,py) )
		if distance > 15 then 
			distance = "#ee0000"..distance
		else 
			distance = "#00ee00"..distance
		end
		dxDrawText( distance.."#ffffff/15 m",startX, startY - height*0.2, width, height*0.2, tocolor( 255, 255, 255, 255), 1,"default-bold","left","top", false, false, false, true)
	end
end

function GangwarDisplay:drawShadowBoxText( text,x,y,w,h, color,... )
	self:dxDrawBoxText(text,x-1,y-1,w,h,tocolor(0,0,0,255),...)
	self:dxDrawBoxText(text,x+1,y+1,w,h,tocolor(0,0,0,255),...)
	self:dxDrawBoxText(text,x,y,w,h,color,...)
end

function GangwarDisplay:destructor()
	removeEventHandler("onClientRender",root,self.m_BindRender) 
end

function GangwarDisplay:draw_DisplayBox( x , y , w , h ,color)
	dxDrawRectangle(x , y , w , h ,tocolor(0,0,0,100))
	--self:dxDrawBoxShape( x , y , w , h ) 
end

function GangwarDisplay:dxDrawBoxShape( x, y, w, h , ...) 
	dxDrawLine( x, y, x+w,y,...) 
	dxDrawLine( x, y+h , x +w , y+h,...)
	
	dxDrawLine( x , y ,x , y+h , ... )
	dxDrawLine( x+w , y ,x+w , y+h , ...)
end


function GangwarDisplay:isMouseOver( x,y,width,height) 
	if isCursorShowing() then 
		local cx,cy = getCursorPosition()
		cx = cx*w
		cy = cy*h
		if cx >= x and cx <= x+width then 
			if cy >= y and cy <= y+height then 
				return true
			end
		end
	end
	return false
end

function GangwarDisplay:dxDrawBoxText( text , x, y , w , h , ... ) 
	dxDrawText( text , x , y , x + w , y + h , ... ) 
end

function GangwarDisplay:formatTick( tick ) 	
	if tick then
		 return string.format("%.2d:%.2d", tick/60%60, tick%60)
	end
end

function GangwarDisplay:drawParticipantOverview() 
	local faction
	local factionPlayers1 = {}
	local factionPlayers2 = {}
	local localFaction = localPlayer:getFactionId()
	for key, player in ipairs(getElementsByType("player")) do 
		if player:getPublicSync("gangwarParticipant") then
			if player:getFactionId() == localFaction then 
				factionPlayers1[#factionPlayers1+1] = player
			end
		end
	end
	self:drawAttackerOverview( factionPlayers1, self.m_Faction1.m_Color["r"], self.m_Faction1.m_Color["g"], self.m_Faction1.m_Color["b"] ) 
end

function GangwarDisplay:drawAttackerOverview( playerTable, r, g, b ) 
	local heightPerElement =  overViewHeight / #playerTable
	if heightPerElement >= h*0.1 then heightPerElement = h*0.1 end
	local sy = h*0.2
	for i = 0, #playerTable -1 do 
		self:drawPlayerOverview(playerTable[i+1], 0, sy+(heightPerElement*i), overViewWidth, heightPerElement, r, g, b) 
	end
end

function GangwarDisplay:drawPlayerOverview( player, x, y, width, height, r, g, b) 
	local health = getElementHealth( player ) 
	local armor = getPedArmor( player ) 
	local weapon = getPedWeapon(player)
	local healthbar = (health+armor) / 200
	local px,py,pz = getElementPosition(player) 
	local zoneName = getZoneName(px, py, pz)
	local moveState = getPedMoveState(player)
	dxDrawRectangle(x, y+height*0.05, width, height*0.9, tocolor( 0, 0, 0, 100))
	dxDrawRectangle(x, y+height*0.05, width*healthbar, height*0.45, tocolor(r, g, b, 50))
	dxDrawText("#EEEEEE"..math.ceil(health+armor).." #FFFFFF"..getPlayerName(player), x+width*0.01, y+height*0.05, x+width, y+height*0.45, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top", false, false, false, true )
	dxDrawText(zoneName, x+width*0.01, y+height*0.55, x+width, y+height, tocolor( 200, 200, 200, 255), 1, "default-bold")
	dxDrawImage( x+width - height*0.3, y+height*0.1, height*0.3, height*0.3, "files/images/Gangwar/"..(moveStateImages[moveState] or "stand_icon")..".png")
	dxDrawImage(x+width, y+height*0.25, height*0.5, height*0.5, "files/images/Weapons/"..(getWeaponNameFromID(weapon) or "Fist")..".png")
end

