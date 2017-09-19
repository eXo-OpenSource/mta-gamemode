-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/WareClient.lua
-- *  PURPOSE:     WareClient
-- *
-- ****************************************************************************

WareClient = inherit(Singleton)
local w,h = guiGetScreenSize()
local showDesc = false
local showBest = false
addRemoteEvents{"onClientWareRoundStart","onClientWareRoundEnd","onClientWareJoin","onClientWareLeave", "onClientWareChangeGameSpeed","onClientWareSuceed"}
function WareClient:constructor()
	addEventHandler("onClientWareJoin", localPlayer,bind(self.OnJoinWare,self))
	addEventHandler("onClientWareLeave", localPlayer,bind(self.OnLeaveWare,self))
	addEventHandler("onClientWareRoundStart", localPlayer,bind(self.Event_RoundStart,self))
	addEventHandler("onClientWareRoundEnd", localPlayer,bind(self.Event_RoundEnd,self))
	addEventHandler("onClientWareChangeGameSpeed", localPlayer,bind(self.Event_GameSpeedChange,self))
	addEventHandler("onClientWareSuceed", localPlayer,bind(self.Event_OnSuceed,self))
	
	self.m_RendBind = bind(self.Event_OnRender,self)
	addEventHandler("onClientRender", root, self.m_RendBind)
	self.m_Font = FontMario256(h*0.05)
	self.m_FontSmall = FontMario256(h*0.03)
	self.m_StartTick = getTickCount()
	self.m_EndTick = self.m_StartTick+1000
	
	self.m_WareJump = WareJump:new()
	self.m_WareDuck = WareDuck:new()
	self.m_WareKeepMove = WareKeepMove:new()
	self.m_WareDontMove = WareDontMove:new()
	self.m_WareDisplay = WareHUD:new()
end

function WareClient:destructor()

end

function WareClient:Event_OnSuceed()
	playSound("files/audio/Ware/done.mp3")
end

function WareClient:OnJoinWare( gamespeed ) 
	self.m_Gamespeed = gamespeed or 1
end

function WareClient:OnLeaveWare() 
end

function WareClient:Event_RoundStart( desc, duration )
	self.m_TextWidth = dxGetTextWidth(desc,1,self.m_Font or "default-bold")
	self.m_ShowDesc = desc
	showDesc = true
	showBest = false
	self.m_TopList = false
	self.m_WareDisplay:displayRoundTime( duration )
end

function WareClient:Event_RoundEnd( bestList)
	showDesc = false
	self.m_ShowDesc = false
	self.m_TopList = bestList
	showBest = true
	self.m_RoundSound = playSound("files/audio/Ware/kahoot.ogg")
	setSoundSpeed(self.m_RoundSound, self.m_Gamespeed)
	self.m_WareDisplay:stopRoundTime( )
end

function WareClient:Event_GameSpeedChange( gamespeed )
	self.m_Gamespeed = gamespeed
	if gamespeed == 2 then 
		setGameSpeed(1.2)
	elseif gamespeed == 3 then 
		setGameSpeed(1.5)
	elseif gamespeed == 1 then
		setGameSpeed(1)
	end
end



function WareClient:RenderBestList(rot)
	if self.m_TopList and showBest then 
		for i = 1,4 do 
			if i < 3 then
				if self.m_TopList[i] then
					dxDrawText("#"..i.." "..getPlayerName(self.m_TopList[i][1])..": "..self.m_TopList[i][2],w*0.7,h*0.2+(i*(h*0.05))+1,w,h,tocolor(0,0,0,255),1,self.m_FontSmall or "default-bold","left","top",false,false,false,false,false,rot)
					dxDrawText("#"..i.." "..getPlayerName(self.m_TopList[i][1])..": "..self.m_TopList[i][2],w*0.7,h*0.2+(i*(h*0.05)),w,h,tocolor(188, 88, 0,255),1,self.m_FontSmall or "default-bold","left","top",false,false,false,false,false,rot)
				end
			elseif i == 3 and #self.m_TopList > 2 then 
				dxDrawText("...",w*0.7,h*0.2,w,h,tocolor(0,0,0,255),1,self.m_FontSmall or "default-bold")
				dxDrawText("...",w*0.7,h*0.2,w,h,tocolor(188, 88, 0,255),1,self.m_FontSmall or "default-bold")	
			elseif i == 4 and #self.m_TopList > 2 then
				for i2 = 1,#self.m_TopList do 
					if self.m_TopList[i2] then 
						if self.m_TopList[i2][1] == localPlayer then 
							dxDrawText("#"..i2.." "..getPlayerName(self.m_TopList[i2][1])..": "..self.m_TopList[i2][2],w*0.7,h*0.2+(i*(h*0.05))+1,w,h,tocolor(0,0,0,255), 1, self.m_FontSmall or "default-bold","left","top",false,false,false,false,false,rot)
							dxDrawText("#"..i2.." "..getPlayerName(self.m_TopList[i2][1])..": "..self.m_TopList[i2][2],w*0.7,h*0.2+(i*(h*0.05)),w,h,tocolor(188, 88, 0,255), 1, self.m_FontSmall or "default-bold","left","top",false,false,false,false,false,rot)
						end
					end
				end
			end
		end
	end
end

function WareClient:Event_OnRender() 
	local now = getTickCount() 
	local elap = now - self.m_StartTick
	local dur = self.m_EndTick - self.m_StartTick
	local prog = elap/dur
	local rot = interpolateBetween(-6,0,0,6,0,0,prog,"CosineCurve")
	if self.m_ShowDesc and showDesc then 
		dxDrawText(self.m_ShowDesc,w*0.5-(self.m_TextWidth*0.5),h*0.3+1,w*0.5+(self.m_TextWidth*0.5),h,tocolor(0, 0, 0, 255),1,self.m_Font or "default-bold","center","center",false,false,false,false,false,rot)
		dxDrawText(self.m_ShowDesc,w*0.5-(self.m_TextWidth*0.5),h*0.3,w*0.5+(self.m_TextWidth*0.5),h,tocolor(7, 91, 140, 255),1,self.m_Font or "default-bold","center","center",false,false,false,false,false,rot)
	end
	self:RenderBestList(rot)
end

function WareClient:destructor()
end