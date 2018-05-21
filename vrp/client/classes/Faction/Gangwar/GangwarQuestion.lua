-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     GangwarQuestion class
-- *
-- ****************************************************************************

GangwarQuestion = inherit( Object )
addRemoteEvents{"GangwarQuestion:new"}

local w,h = guiGetScreenSize()
local PseudoObj
local already_selected --// just in case
local AFK_TIME = 1000*60*3
function GangwarQuestion:constructor( )
	already_selected = false	
	self.m_Start = getTickCount()
	self.m_EndTick = self.m_Start + 2000
	self.m_bindRender = bind(self.render,self)
	self.m_bindClick = bind(self.onClick,self)
	self.m_bindAFKFunc = bind( self.onAFKTimer, self)
	self.m_AFKTimer = setTimer( self.m_bindAFKFunc, AFK_TIME, 1)
	addEventHandler("onClientRender",root,self.m_bindRender)
	addEventHandler("onClientClick",root,self.m_bindClick)
end


function GangwarQuestion:onClick( b, s )
	if b == "left" then 
		if s == "up" then 
			if self.m_Option then 
				if not self.m_SureCheck then 
					self.m_SureCheck = self.m_Option 
					self.m_DrawSure = true
					return 
				end
				if self.m_SureCheck == self.m_Option then 
					if self.m_Option == 2 then 
						triggerServerEvent("GangwarQuestion:disqualify",localPlayer)
						PseudoObj:delete()
					else 
						PseudoObj:delete() 
					end
					already_selected = true
					PseudoObj:delete()
					if isTimer(self.m_AFKTimer) then 
						killTimer(self.m_AFKTimer)
					end
				else self.m_SureCheck = nil
				end
			end
		end
	end
end

function GangwarQuestion:render() 
	local now = getTickCount()
	local elap = now - self.m_Start  
	local dur = self.m_EndTick - self.m_Start 
	local prog = elap / dur 
	local w_x = interpolateBetween(w,0,0,w*0.8,0,0,prog,"OutBack")
	dxDrawImage(w_x,h*0.55,w*0.2,h*0.05,"files/images/gangwar/teilnehmen.png")
	dxDrawRectangle(w_x,h*0.6,w*0.2,h*0.1,tocolor(0,0,0,150))
	self:dxDrawBoxShape( w_x,h*0.6,w*0.2,h*0.1 ,tocolor(0,104,104,255)) 
	
	dxDrawRectangle(w_x+w*0.04,h*0.61,w*0.04,h*0.035,tocolor(0,104,104,180))
	self:dxDrawBoxShape( w_x+w*0.04,h*0.61,w*0.04,h*0.035 ) 
	self:dxDrawBoxShape( w_x+w*0.02,h*0.61,w*0.02,h*0.035 ) 
	self:dxDrawBoxText( "Ja",w_x+w*0.04,h*0.61,w*0.04,h*0.035,tocolor(0,180,40,255),1,"default-bold","center","center"  ) 

	
	dxDrawRectangle(w_x+w*0.04,h*0.655,w*0.04,h*0.035,tocolor(0,104,104,180))
	self:dxDrawBoxShape(w_x+w*0.04,h*0.655,w*0.04,h*0.035 ) 
	self:dxDrawBoxShape( w_x+w*0.02,h*0.655,w*0.02,h*0.035 ) 	
	self:dxDrawBoxText( "Nein",w_x+w*0.04,h*0.655,w*0.04,h*0.035,tocolor(180,0,0,255),1,"default-bold","center","center"  ) 
	
	if self:isMouseOver(w_x+w*0.02,h*0.61,w*0.06,h*0.035 ) then 
		dxDrawImage(w_x+w*0.02,h*0.61,w*0.02,h*0.035,"files/images/gangwar/tick.png")
		self.m_Option = 1 
	elseif self:isMouseOver(w_x+w*0.02,h*0.655,w*0.06,h*0.035 ) then 
		dxDrawImage(w_x+w*0.02,h*0.655,w*0.02,h*0.035,"files/images/gangwar/cross.png")
		self.m_Option = 2
	else 
		self.m_Option = nil
	end
	
	if self.m_DrawSure then 
		self:dxDrawBoxText( "Bitte zum bestätigen noch einmal klicken!",(w_x+w*0.11)-1,(h*0.63)-1,w*0.08,h*0.03,tocolor(0,0,0,255),1,"default-bold","center","center",true,true  ) 
		self:dxDrawBoxText( "Bitte zum bestätigen noch einmal klicken!",(w_x+w*0.11)+1,(h*0.63)+1,w*0.08,h*0.03,tocolor(0,0,0,255),1,"default-bold","center","center" ,true,true ) 
		self:dxDrawBoxText( "Bitte zum bestätigen noch einmal klicken!",w_x+w*0.11,h*0.63,w*0.08,h*0.03,tocolor(0,204,204,255),1,"default-bold","center","center" ,true,true ) 
	end
end


function GangwarQuestion:onAFKTimer()
	if PseudoObj then 
		if not already_selected then 
			triggerServerEvent("GangwarQuestion:disqualify", localPlayer, true)
			destroyQuestionBox()
		end
	end
end



function GangwarQuestion:destructor() 
	removeEventHandler("onClientRender",root,self.m_bindRender)
	removeEventHandler("onClientClick",root,self.m_bindClick)
end

function GangwarQuestion:dxDrawBoxShape( x, y, w, h , ...) 
	dxDrawLine( x, y, x+w,y,...) 
	dxDrawLine( x, y+h , x +w , y+h,...)
	
	dxDrawLine( x , y ,x , y+h , ... )
	dxDrawLine( x+w , y ,x+w , y+h , ...)
end

function GangwarQuestion:isMouseOver( x,y,width,height) 
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

addEventHandler("GangwarQuestion:new",localPlayer,function() 
	if PseudoObj then 
		PseudoObj:delete()
		PseudoObj = nil
	end
	PseudoObj = GangwarQuestion:new()
end)

function destroyQuestionBox() 
	if PseudoObj then 
		PseudoObj:delete()
		PseudoObj = nil
	end
end

function GangwarQuestion:dxDrawBoxText( text , x, y , w , h , ... ) 
	dxDrawText( text , x , y , x + w , y + h , ... ) 
end
