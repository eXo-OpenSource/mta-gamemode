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
	self.m_RenderTarget = dxCreateRenderTarget(260, 120, true)
	self.m_IsModifying = false

	self.m_Style = core:get("HUD", "NametagStyle", NametagStyle.Default)

	self.m_Draw = bind(self.draw, self)
	self.m_ReciveBuffs = bind(self.reciveBuffs,self)


	addEventHandler("reciveNametagBuffs",root,self.m_ReciveBuffs)
	addEventHandler("onClientRender", root, self.m_Draw, true, "high+999")

end

function Nametag:destructor()
	removeEventHandler("reciveNametagBuffs",root,self.m_ReciveBuffs)
	removeEventHandler("onClientRender", root, self.m_Draw, true, "high+999")
end

function Nametag:setStyle(style)
	self.m_Style = style
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

function Nametag:getColorFromHP(hp)
	if hp <= 0 then
		return 0, 0, 0
	else
		hp = math.abs ( hp - 0.01 )
		return ( 100 - hp ) * 2.55 / 2, ( hp * 2.55 ), 0
	end
end


function Nametag:drawDefault(player)
	local pname = player:getName()
	local size = calcDxFontSize(pname, 260, "default-bold", 2)
	local r, g, b = self:getColorFromHP(player:getHealth())
	dxDrawText(getPlayerName(player), 12, 57, 260, 60, tocolor ( 0, 0, 0, 255 ), size,"default-bold", "center")
	dxDrawText(getPlayerName(player), 10, 55, 260, 60, tocolor (r, g, b, 255), size, "default-bold", "center")

	self:drawIcons(player, "center", 90, true)
end

function Nametag:drawVRP(player)
	local pname = player:getName()
	local size = calcDxFontSize(pname, 260, "default-bold", 2)

	dxDrawText(getPlayerName(player), 10, 5, 260, 60, AdminColor[player:getPublicSync("Rank") or 0], size,"default-bold")

	dxDrawRectangle(10, 40, 260*getElementHealth(player)/100, 15, tocolor(0,125,0,255))
	dxDrawRectangle(10, 40, 260*getPedArmor(player)/100, 15, Color.LightBlue)

	self:drawIcons(player, "left", 90)
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

			if self.m_Style == NametagStyle.Default then
				self:drawDefault(player)
			elseif self.m_Style == NametagStyle.vRoleplay then
				self:drawVRP(player)
			end



			dxSetRenderTarget()

			local distance = getDistanceBetweenPoints3D(px,py,pz,lx,ly,lz)

			local scale = 0.4 + ( 15 - distance ) * 0.02
			if scale < 0 then scale = 0.3 end
			dxDrawImage(x-260*scale/2,y-60, 260*scale, 120*scale, self.m_RenderTarget)

			end

		end
	end
end

function Nametag:drawIcons(player, align, startY, armor)
	if isChatBoxInputActive() then
		setElementData(localPlayer, "writing", true)
	else
		setElementData(localPlayer, "writing", false)
	end

	local icons = {}

	if armor and player:getArmor() > 0 then
		icons[#icons+1] = "armor.png"
	end
	if getElementData(player,"writing") == true then
		icons[#icons+1] = "chat.png"
	end
	if (player:getPublicSync("Rank") or 0) > 0 then
		icons[#icons+1] = "admin.png"
	end
	if player:getWanteds() > 0 then
		icons[#icons+1] = "w"..player:getWanteds()..".png"
	end
	if player:getFaction() then
		icons[#icons+1] = player:getFaction():getShortName()..".png"
	end

	local startX = 10
	if align == "center" then
		startX = 130-#icons*17
	end

	for index, icon in pairs(icons) do
		dxDrawImage(startX+(index-1)*34, startY, 32, 32, "files/images/Nametag/"..icon)
	end

end
