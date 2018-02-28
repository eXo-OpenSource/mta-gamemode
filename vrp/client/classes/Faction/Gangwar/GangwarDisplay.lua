-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar HUD
-- *
-- ****************************************************************************

--[[
 This class includes the Box-Display containing the count of alive ally/enemy players and the name of the attacking/defending faction.
 It also displays the damage and kills the localPlayer has inflicted as well as the remaining time for the gangwar. 
	
	_____________________________________
	| FACTON-NAME 	|  FACTON-NAME2 	|
	|  X / X		|		X / X		|
	|_______________|___________________|		
	|  DAMAGE	|	KILLS   | 	TIME	|
	|___________|___________|___________|			
---]]

GangwarDisplay = inherit(Object)
local w,h = guiGetScreenSize()
local width, height = w*0.2,h*0.1
local startX,startY = w- width*1.1, h*0.5-(height/2)
local overViewHeight = h*0.4 / ASPECT_RATIO_MULTIPLIER
local overViewWidth =  screenWidth/2-(screenWidth*0.65/2) / ASPECT_RATIO_MULTIPLIER
local overViewStartHeight = h*0.5-h*0.3+(screenWidth*0.65)*0.06
local overViewHealthWidth = dxGetTextWidth("200", 1, "default-bold")
local overViewScoreboardEnd = overViewWidth+screenWidth*0.65
local gradientTexture = dxCreateTexture( "files/images/Gangwar/gradient.png", "argb", true, "clamp")
local overViewLocationSize = 1
local overViewNameSize = 1
if w < 1280 and h < 850 then 
	overViewLocationSize = 0.4 
	overViewNameSize = 0.4
	if w < 900 then 
		overViewLocationSize = 0 
		overViewNameSize = 0.5
	end
end
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

-- constructor/destructor --
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

function GangwarDisplay:destructor()
	removeEventHandler("onClientRender",root,self.m_BindRender) 
end

-- draw-functions --
function GangwarDisplay:render() 
	self:checkDragDrop()
	self:rend_Display()
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
	if ScoreboardGUI and ScoreboardGUI:getSingleton().m_Showing and core:get("Other", "GangwarTabView", true) then
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

function GangwarDisplay:drawParticipantOverview() 
	local faction
	local factionPlayers1 = {}
	local factionPlayers2 = {}
	local localFaction = localPlayer:getFactionId()
	local localFactionObject = localPlayer:getFaction()
	local enemyFaction, enemyFactionObject
	for key, player in ipairs(getElementsByType("player")) do 	
		if player:getPublicSync("gangwarParticipant") then
			if player:getFactionId() == localFaction then 
				factionPlayers1[#factionPlayers1+1] = player
			else 
				factionPlayers2[#factionPlayers2+1] = player
				if not enemyFaction then 
					enemyFaction = player:getFactionId() 
					enemyFactionObject = player:getFaction()
				end
			end
		end
	end
	if enemyFaction and enemyFactionObject then
		self:drawAttackerOverview( factionPlayers1, factionPlayers2, localFactionObject.m_Color["r"], localFactionObject.m_Color["g"], localFactionObject.m_Color["b"], enemyFactionObject.m_Color["r"], enemyFactionObject.m_Color["g"], enemyFactionObject.m_Color["b"] )
	else 
		self:drawAttackerOverview( factionPlayers1, factionPlayers2, localFactionObject.m_Color["r"], localFactionObject.m_Color["g"], localFactionObject.m_Color["b"])
	end
end

function GangwarDisplay:drawAttackerOverview( playerTable, enemyTable, r, g, b, r2, g2, b2 ) 
	local heightPerElement =  overViewHeight / #playerTable
	if heightPerElement >= h*0.06 then heightPerElement = h*0.06 end
	for i = 0, #playerTable -1, 1 do
		self:drawPlayerOverview(playerTable[i+1], 0, overViewStartHeight+(heightPerElement*i), overViewWidth, heightPerElement, r, g, b) 
	end
	if r2 and g2 and b2 then
		for i = 0, #enemyTable -1, 1 do
			self:drawEnemyOverview(enemyTable[i+1], overViewScoreboardEnd*1+overViewWidth*0.05, overViewStartHeight+(heightPerElement*i), overViewWidth, heightPerElement, r2, g2, b2) 
		end	
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

	dxDrawRectangle(x, y+height*0.05, width- height*0.5, height*0.9, tocolor( 0, 0, 0, 100))
	dxDrawImage(x, y+height*0.05, (width-height*0.5)*healthbar, height*0.45, gradientTexture, 0, 0, 0, tocolor(r*0.6, g*0.6, b*0.6, 200))
	
	dxDrawText("#e8f0ff"..math.ceil(health+armor), x+width*0.01+height*0.3, y+height*0.05, x+width*0.01+height*0.3+overViewHealthWidth, y+height*0.45, tocolor(255, 255, 255, 255),  1, "default-bold", "left", "center", false, false, false, true )
	dxDrawImage(x+width*0.01, y+height*0.125, height*0.25, height*0.25, "files/images/Gangwar/armor.png")
	dxDrawText(getPlayerName(player), x+overViewHealthWidth+height*0.3+width*0.08, y+height*0.05, x+width*0.15, y+height*0.45, tocolor(255, 255, 255, 255), overViewNameSize, "default-bold", "left", "center", false, false, false, true )
	dxDrawText(zoneName, x+width*0.01, y+height*0.55, x+width, y+height, tocolor( 200, 200, 200, 255), overViewLocationSize, "default-bold")
	dxDrawImage(x+width - height*0.8, y+height*0.1, height*0.3, height*0.3, "files/images/Gangwar/"..(moveStateImages[moveState] or "stand_icon")..".png")
	dxDrawImage(x+width-height*0.5, y+height*0.25, height*0.5, height*0.5, "files/images/Weapons/"..(getWeaponNameFromID(weapon) or "Fist")..".png")
end

function GangwarDisplay:drawEnemyOverview( player, x, y, width, height, r, g, b) 
	dxDrawRectangle(x, y+height*0.05, width, height*0.9, tocolor( 0, 0, 0, 100))
	dxDrawImage(x, y+height*0.05, width, height*0.45, gradientTexture, 0, 0, 0, tocolor(r*0.6, g*0.6, b*0.6, 200))
	dxDrawText(getPlayerName(player), x+width*0.05, y+height*0.05, x+width, y+height*0.45, tocolor(255, 255, 255, 255), overViewNameSize, "default-bold", "left", "center", false, false, false, true )
end

-- synchronize functions --
function GangwarDisplay:synchronizeTime( pTime ) 
	self.m_TimeLeft = pTime
end

function GangwarDisplay:tickTime( ) 
	self.m_TimeLeft = self.m_TimeLeft - 1 
end

-- click functions --
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

-- These functions are utilities --
function GangwarDisplay:drawShadowBoxText( text,x,y,w,h, color,... )
	self:dxDrawBoxText(text,x-1,y-1,w,h,tocolor(0,0,0,255),...)
	self:dxDrawBoxText(text,x+1,y+1,w,h,tocolor(0,0,0,255),...)
	self:dxDrawBoxText(text,x,y,w,h,color,...)
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
