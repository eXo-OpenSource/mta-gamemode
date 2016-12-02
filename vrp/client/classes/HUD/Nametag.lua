Nametag = inherit(Singleton)

addEvent("reciveNametagBuffs", true)

Nametag.BUFF_IMG = {
	["default"] = "files/images/Nametag/default.png"
}

local sizePerRankIcon = 150/5
local maxDistance = 30

function isCursorOverArea ( x,y,w,h )
	if isCursorShowing () then
		local cursorPos = {getCursorPosition()}
		local mx, my = cursorPos[1]*screenWidth,cursorPos[2]*screenHeight
		if mx >= x and mx <= x+w and my >= y and my <= y+h then
			return true
		end
	end
	return false
end

function Nametag:constructor()

	self.m_Players = {}
	self.m_PlayerBuffs = {}
	self.m_RenderTarget = dxCreateRenderTarget(200, 120, true)
	self.m_IsModifying = false

	self.m_Draw = bind(self.draw,self)
	self.m_ReciveBuffs = bind(self.reciveBuffs,self)

	addEventHandler("onClientRender", root, self.m_Draw, true, "high+999")
	addEventHandler("reciveNametagBuffs",root,self.m_ReciveBuffs)

end

function Nametag:reciveBuffs(buffs)
	self.m_PlayerBuffs = buffs

	for key, value in pairs(self.m_PlayerBuffs) do
		if not self.m_Players[getPlayerFromName(key)] then
			self.m_Players[getPlayerFromName(key)] = true
		end
	end
end

function Nametag:onUnknownSpotted(player)
	self.m_Players[player] = true
	self.m_PlayerBuffs[getPlayerName(player)] = {}
	triggerServerEvent("requestNametagBuffs",localPlayer)
end

function Nametag:draw()

	for _, player in ipairs(getElementsByType("player",true)) do
		if not self.m_Players[player] then
			self:onUnknownSpotted(player)
		end
		if player ~= localPlayer or self.m_IsModifying then
			setPlayerNametagShowing(player,false)
			local px,py,pz = getPedBonePosition(player, 2)
			pz = pz + 1
			local x,y = getScreenFromWorldPosition(px,py,pz)
			local lx,ly,lz = getElementPosition(localPlayer)
			if x and y and isLineOfSightClear(lx,ly,lz,px,py,pz,true,false,false,true,false,true,true) and ( getDistanceBetweenPoints3D(lx,ly,lz,px,py,pz) < maxDistance or getPedTarget(localPlayer) == player) then
			--local name = getPlayerName(player):gsub("#%d%d%d%d","")
			dxSetRenderTarget(self.m_RenderTarget,true)

			dxDrawText(getPlayerName(player), 10, 5, 145, 60,AdminColor[player:getPublicSync("Rank") or 0],2,"default-bold")

			self:drawIcons(player)



			dxDrawRectangle(10, 40, 250*getElementHealth(player)/100, 15, tocolor(0,125,0,255))
			dxDrawRectangle(10, 40, 250*getPedArmor(player)/100, 15, Color.LightBlue)

			dxSetRenderTarget()

			local distance = getDistanceBetweenPoints3D(px,py,pz,lx,ly,lz)

			local scale = 0.4 + ( 15 - distance ) * 0.02
			if scale < 0 then scale = 0.3 end
			dxDrawImage(x-240*scale/2,y-60, 240*scale, 120*scale, self.m_RenderTarget)

			end

		end
	end
end

function Nametag:drawIcons(player)
	if isChatBoxInputActive() then
		setElementData(localPlayer, "writing", true)
	else
		setElementData(localPlayer, "writing", false)
	end

	iconI = 0
	if getElementData(player,"writing") == true then
		dxDrawImage(10+iconI*34, 60, 32, 32, "files/images/Nametag/chat.png")
		iconI = iconI+1
	end
	if (player:getPublicSync("Rank") or 0) > 0 then
		dxDrawImage(10+iconI*34, 60, 32, 32, "files/images/Nametag/admin.png")
		iconI = iconI+1
	end
	if player:getWanteds() > 0 then
		dxDrawImage(10+iconI*34, 60, 32, 32, "files/images/Nametag/w"..player:getWanteds()..".png")
		iconI = iconI+1
	end
	if player:getFaction() then
		dxDrawImage(10+iconI*34, 60, 32, 32, "files/images/Nametag/"..player:getFaction():getShortName()..".png")
		iconI = iconI+1
	end

end
