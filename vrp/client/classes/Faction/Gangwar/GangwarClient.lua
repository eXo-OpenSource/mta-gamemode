-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar Client Class
-- *
-- ****************************************************************************

GangwarClient = inherit( Singleton )
addRemoteEvents{"Gangwar:show_AttackGUI","Gangwar_shortMessageAttack"}

 
--// CONSTANTS 
GANGWAR_ATTACK_PAUSE = 1 --// UPDATE THIS IF YOU UPDATE THE SERVER CONSTANT
UNIX_TIMESTAMP_24HRS = 86400 
local ANIM_SCALE = 1 
local ANIM_TIME = 2000
local w,h = guiGetScreenSize()
local width ,height = w*0.4,h*0.3

function GangwarClient:constructor( ) 
	self.m_ShowBind = bind( self.show_AttackRequest, self)	
	addEventHandler("Gangwar_shortMessageAttack",localPlayer, bind(GangwarClient.Event_shortMessageAttack,self))
	addEventHandler("Gangwar:show_AttackGUI", root, self.m_ShowBind)
end

function GangwarClient:Event_shortMessageAttack( pArea )
	self.m_LastArea = pArea
	self.m_ShortCallback = function (this)
		if GangwarClient:getSingleton().m_LastArea then
			GangwarClient:show_AttackRequest( GangwarClient:getSingleton().m_LastArea )
			delete(this)
		end
	end
	ShortMessage:new("Dies ist ein Gangwar-Gebiet, klicke hier um anzugreifen!", "Gangwar", Color.DarkLightBlue, 5000, self.m_ShortCallback)
end

function GangwarClient:show_AttackRequest( pArea )
	if not self.m_AttackDisplayShowing then
		self.m_AttackDisplayShowing = true
		self.m_RenderBind = bind( self.render_Window_start , self)
		self.m_ClickBind = bind(self.clickBind,self)
		self.m_StartTick1 = getTickCount() 
		self.m_EndTick1 = self.m_StartTick1 + ANIM_SCALE*ANIM_TIME
		self.m_Area = pArea
		if self.m_RenderBind then
			removeEventHandler("onClientRender",root,self.m_RenderBind)
			addEventHandler("onClientRender",root,self.m_RenderBind)
		end
		if self.m_RenderBind2 then
			removeEventHandler("onClientRender",root,self.m_RenderBind2)
		end
		if self.m_ClickBind then
			removeEventHandler("onClientClick",root,self.m_ClickBind)
			addEventHandler("onClientClick",root,self.m_ClickBind)
		end
	end
end
 
function GangwarClient:hide_AttackRequest( )
	if self.m_RenderBind then
		removeEventHandler("onClientRender",root,self.m_RenderBind)
	end
	if self.m_RenderBind2 then
		removeEventHandler("onClientRender",root,self.m_RenderBind2)
	end
	if self.m_ClickBind then
		removeEventHandler("onClientClick",root,self.m_ClickBind)
	end
	self.m_AttackDisplayShowing = false
end

function GangwarClient:clickBind( b, s)
	if b == "left" then 
		if s == "up" then 
			if self.m_Over == 1 then 
				self:hide_AttackRequest()
				triggerServerEvent("Gangwar:onClientRequestAttack",localPlayer)
			elseif self.m_Over == 2 then 
				self:hide_AttackRequest()
			end
		end
	end
end

function GangwarClient:render_Window_start( ) 
	local now = getTickCount() 
	local elap = now - self.m_StartTick1
	local dur = self.m_EndTick1 - self.m_StartTick1
	local prog = elap / dur 
	local h_x = interpolateBetween( -h*0.5,0,0,h*0.5,0,0,prog,"OutBack")
	dxDrawRectangle(0,h_x-(w*0.05),w,w*0.1,tocolor(0,205,205,100))
	dxDrawImage(w*0.2,(h_x)-(w*0.05),w*0.3,w*0.1,"files/images/gangwar/gangwar.png")
	if prog >= 1 then 
		removeEventHandler("onClientRender",root,self.m_RenderBind)
		self.m_StartTick2 = getTickCount() 
		self.m_EndTick2 = self.m_StartTick2 + ANIM_SCALE*ANIM_TIME
		self.m_RenderBind2 = bind( self.render_Window_options, self)
		addEventHandler("onClientRender",root,self.m_RenderBind2)
	end
end

function GangwarClient:render_Window_options( ) 
	local now = getTickCount() 
	local elap = now - self.m_StartTick2
	local dur = self.m_EndTick2 - self.m_StartTick2 
	local prog = elap / dur 
	local w_x = interpolateBetween( w*0.2,0,0,w*0.5,0,0,prog,"OutBack")
	local alpha = interpolateBetween(0,0,0,255,0,0,prog,"Linear")
	local w_x2 = interpolateBetween( w*0.5,0,0,w*0.65,0,0,prog,"OutBack")
	local w_x3 = interpolateBetween( -w*0.5,0,0,w*0.025,0,0,prog*1.4,"OutBack")
	local color1 = tocolor(255,255,255,alpha)
	local color2 = tocolor(255,255,255,alpha)
	if self:isMouseOver( w_x,(h*0.5)-(w*0.05),w*0.15,w*0.05) then 
		color1 = tocolor(0,204,204,alpha)
		self.m_Over = 1 
	elseif self:isMouseOver( w_x,(h*0.5)-(w*0.05)+(w*0.05),w*0.15,w*0.05) then 
		color2 = tocolor(0,204,204,alpha)
		self.m_Over = 2
	else self.m_Over = nil
	end
	dxDrawRectangle(0,h*0.5-(w*0.05),w,w*0.1,tocolor(0,205,205,100))
	dxDrawImage(w*0.2,(h*0.5)-(w*0.05),w*0.3,w*0.1,"files/images/gangwar/gangwar.png")
	dxDrawImage(w_x,(h*0.5)-(w*0.05),w*0.15,w*0.05,"files/images/gangwar/attack.png",0,0,0,color1)
	dxDrawImage(w_x,(h*0.5)-(w*0.05)+(w*0.05),w*0.15,w*0.05,"files/images/gangwar/close.png",0,0,0,color2)
	dxDrawLine(w*0.5,h*0.5,w_x2,h*0.5)
	
	self:dxDrawBoxText(self.m_Area.m_Name , w_x3, h*0.5-w*0.05, w*0.3 , w*0.05, tocolor(255,255,255,255),1,"pricedown","left","top" )

end

function GangwarClient:isMouseOver( x,y,width,height) 
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


function GangwarClient:dxDrawBoxText( text , x, y , w , h , ... ) 
	dxDrawText( text , x , y , x + w , y + h , ... ) 
end