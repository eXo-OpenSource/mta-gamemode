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

function GangwarDisplay:constructor( fac1, fac2, pAttackClient) 
	self.m_Faction1 = fac1
	self.m_Faction2 = fac2 
	self.m_AttackClient = pAttackClient 
	
	self.m_BindRender = bind( self.render,self)
	addEventHandler("onClientRender",root,self.m_BindRender)
	self.m_BindClick = bind(self.click,self)
	addEventHandler("onClientClick",root,self.m_BindClick)
end

function GangwarDisplay:render() 
	self:checkDragDrop()
	self:rend_Display()
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

	
	dxDrawRectangle( startX , startY+height*0.5 , bottom_width , height*0.495, tocolor(0,204,204,100)  )
	self:dxDrawBoxShape(startX , startY+height*0.5 , bottom_width , height*0.495,tocolor(0,0,0,150))
	self:drawShadowBoxText( self.m_AttackClient.m_GangwarDamage,startX , startY+height*0.5 , bottom_width , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	
	dxDrawRectangle( startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495, tocolor(0,204,204,100)  )
	self:dxDrawBoxShape(startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495,tocolor(0,0,0,150))
	self:drawShadowBoxText( self.m_AttackClient.m_GangwarKill,startX+(bottom_width+width*0.005) , startY + height*0.5, bottom_width , height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	
	dxDrawRectangle( startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495, tocolor(0,204,204,100)  )
	self:dxDrawBoxShape(startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495,tocolor(0,0,0,150))
	self:drawShadowBoxText( "0",startX+(bottom_width*2 + width*0.01) , startY+height*0.5, bottom_width, height*0.495, tocolor(255,255,255,255),1,"default-bold","center","center" )
	
	self:dxDrawBoxShape(startX,startY,width,height,tocolor(0,0,0,150))
	
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