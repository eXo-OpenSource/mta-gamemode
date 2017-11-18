-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarStatistics.lua
-- *  PURPOSE:     Gangwar-Statistics Client Class
-- *
-- ****************************************************************************

local w,h = guiGetScreenSize()
local width,height = w*0.4, h*0.1
local bx, by = w*0.5 - (width/2), h*0.3 - (height/2)
local MVPCOUNT = 3
local MARGIN_MVP = math.floor(height / MVPCOUNT)
GangwarStatistics = inherit( Singleton )
addRemoteEvents{"GangwarStatistics:clientGetMVP"}
function GangwarStatistics:constructor() 
	addEventHandler("GangwarStatistics:clientGetMVP", localPlayer, bind( self.Event_GetMVP, self))
end

function GangwarStatistics:Event_GetMVP( t )
	self.m_MVP = t
	if self.m_DrawingMVP then 
		removeEventHandler("onClientRender",root, self.m_RenderFunc)
	end
	self.m_RenderFunc = bind( self.renderMVP, self)
	addEventHandler("onClientRender", root, self.m_RenderFunc)
	self.m_DrawStartTick = getTickCount()
	self.m_EndTick = getTickCount() + 2000
	self.dxFontHeight = dxGetFontHeight( 2, "default")
end

function GangwarStatistics:renderMVP() 
	local now = getTickCount()
	local elap = now - self.m_DrawStartTick 
	local dur = self.m_EndTick - self.m_DrawStartTick 
	local prog = elap / dur 
	local alpha,alpha2, moveBy = interpolateBetween( 0,0,-height,255,200,by,prog,"Linear")
	local alpha3 = interpolateBetween( 0,0,0,160,0,0,prog,"Linear")
	if self.m_MVP then 
		dxDrawImage(bx, moveBy, width,height, "files/images/Gangwar/tile.png",0,0,0,tocolor(0,200,200,alpha2))
		dxDrawBoxShape(bx, moveBy, width,height, tocolor(0,0,0,alpha),2)
		dxDrawImage(bx+width*0.85, moveBy-height*0.2, width*0.15,height*0.37, "files/images/Gangwar/trophy.png")
		dxDrawShadowText("Beste Spieler:", bx+width*0.05, moveBy-self.dxFontHeight, width, self.dxFontHeight, 1,1,tocolor(150,150,150,alpha),tocolor(0,0,0,alpha),2,"default","left","top")
		for i = 1, MVPCOUNT do 
			if self.m_MVP[i] then 
				if i == 1 then
					dxDrawBoxText(i..". "..self.m_MVP[i][1].name.." - "..self.m_MVP[i][2],bx, moveBy + MARGIN_MVP*(i-1), width, MARGIN_MVP, tocolor(200, 200, 0, alpha),2.2, "default-bold", "center","center")
				else 
					dxDrawBoxText(i..". "..self.m_MVP[i][1].name.." - "..self.m_MVP[i][2],bx, moveBy + MARGIN_MVP*(i-1), width, MARGIN_MVP, tocolor(200, 200, 200, alpha3),2-(i*0.2), "default-bold", "center","center")
				end
			else 
				dxDrawBoxText(i.." -/- ", bx, moveBy + MARGIN_MVP*(i-1),width, MARGIN_MVP, tocolor(200,200,200, alpha3),2.2-(i*0.2), "default-bold", "center","center")
			end
		end
	end
	if now - self.m_DrawStartTick >= 15000 then 
		self.m_DrawingMVP = false
		removeEventHandler("onClientRender", root, self.m_RenderFunc)
	end
end

function dxDrawBoxText( text , x, y , w , h , ... ) 
	dxDrawText( text , x , y , x + w , y + h , ... ) 
end

function dxDrawBoxShape( x, y, w, h , ...) 
	dxDrawLine( x, y, x+w,y,...) 
	dxDrawLine( x, y+h , x +w , y+h,...)
	
	dxDrawLine( x , y ,x , y+h , ... )
	dxDrawLine( x+w , y ,x+w , y+h , ...)
end

function dxDrawShadowText( text , x, y , w , h , shadowOffSetX , shadowOffSetY , tCol , sCol , ... ) 
	dxDrawText( text , x + shadowOffSetX , y + shadowOffSetY , x + w , y + h , sCol, ... ) 
	dxDrawText( text , x - shadowOffSetX , y - shadowOffSetY  , x + w , y + h , sCol, ... ) 
	dxDrawText( text , x , y , x + w , y + h , tCol , ... ) 
end