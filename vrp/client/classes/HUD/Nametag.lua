-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/Nametag.lua
-- *  PURPOSE:     Nametag class
-- *
-- ****************************************************************************

Nametag = inherit(Singleton)
Nametag.font = "default-bold"
Nametag.fontSize = 2
addEvent("reciveNametagBuffs", true)
local maxDistance = 50

function Nametag:constructor()
	self.m_Stream = {}
	self.m_Style = core:get("HUD", "NametagStyle", NametagStyle.Default)
	self.m_Draw = bind(self.draw, self)

	addEventHandler("onClientRender", root, self.m_Draw, true, "high")
	setPedTargetingMarkerEnabled(false)
end

function Nametag:destructor()
	removeEventHandler("onClientRender", root, self.m_Draw)
	setPedTargetingMarkerEnabled(true)
end

function Nametag:draw()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("3D/Nametag") end
	local cx,cy,cz = getCameraMatrix()
	local bRifleCheck = self:_weaponCheck()
	local lpX, lpY, lpZ = getElementPosition(localPlayer)
	for _, player in pairs(getElementsByType("player", root, true)) do
		if player ~= localPlayer then
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/Nametag") end
			setPlayerNametagShowing(player, false)
			local pX, pY, pZ = getElementPosition(player)
			local phX, phY, phZ = player:getBonePosition(8)
			local bDistance = getDistanceBetweenPoints3D(cx,cy,cz, pX, pY, pZ)
			if bRifleCheck == player then bDistance = 10 end -- fix the distance if the localPlayer aims at the specific player
			if not localPlayer:isLoggedIn() then return false end
			if (bDistance <= maxDistance) or localPlayer:getPrivateSync("isSpecting") then
				local scx,scy = getScreenFromWorldPosition(pX, pY, pZ + 1.2)
				if scx and scy then
					local bLineOfSight = isLineOfSightClear(cx, cy, cz, phX, phY, phZ, true, false, false, true, false, false, false, localPlayer)
					if bLineOfSight or localPlayer:getPrivateSync("isSpecting") then
						local drawName = getPlayerName(player)
						local wanteds = player:getWanteds()
						local size = math.max(0.5, 1 - bDistance/maxDistance)*0.9
						local alpha = localPlayer:getPrivateSync("isSpecting") and 1 or math.min(1, 1 - (bDistance - maxDistance*0.5)/(maxDistance - maxDistance*0.5))
						local r,g,b =  self:getColorFromHP(getElementHealth(player), getPedArmor(player))
						local textWidth = dxGetTextWidth(drawName, 1.5*size, Nametag.font)
						local fontHeight = dxGetFontHeight(1.5*size,Nametag.font)

						if self:drawIcons(player, scx, scy, fontHeight, alpha) then
							scy = scy - fontHeight
						end
						if wanteds > 0 then
							dxDrawImage(scx - textWidth/2 - fontHeight*2, scy - fontHeight*1.1, fontHeight*2.2, fontHeight*2.2, "files/images/Nametag/wanted.png", 0, 0, 0, tocolor(200, 150, 0, 255*alpha))
							dxDrawText(wanteds, scx - textWidth/2 - fontHeight*2, scy - fontHeight*1.1, ( scx - textWidth/2 - fontHeight*2 )+ fontHeight*2.2, (scy - fontHeight*1.1)+ fontHeight*2.4, tocolor(0, 0, 0, 255*alpha), 1.5*size, Nametag.font, "center", "center")
							--dxDrawText(wanteds, scx - textWidth/2 - fontHeight, scy, nil, nil, tocolor(255, 255, 255, 255*alpha), 1.5*size, Nametag.font, "center", "center")
							scx = scx + fontHeight
						end
						if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/Nametag", true) end
						dxDrawText(player:getName(), scx + 1,scy + 1, nil, nil, tocolor(0, 0, 0, 255*alpha), 2*size, Nametag.font, "center", "center")
						dxDrawText(player:getName(), scx,scy, nil, nil, tocolor(r, g, b, 255*alpha), 2*size, Nametag.font, "center", "center")
					end
				end
			end
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/Nametag") end
end

function Nametag:_weaponCheck ( player )
	if isPedAiming ( localPlayer ) and (getPedWeaponSlot ( localPlayer ) == 6 or getPedWeaponSlot ( localPlayer ) == 5)  then
		local x1, y1, z1 = getPedTargetStart ( localPlayer )
		local x2, y2, z2 = getPedTargetEnd ( localPlayer )
		local boolean, x, y, z, hit = processLineOfSight ( x1, y1, z1, x2, y2, z2)
		if boolean then
			if isElement ( hit ) then
				if isElementStreamedIn(hit) then
					if getElementType ( hit ) == "player" then
						return hit
					end
				end
			end
		end
	end
	return false
end

function Nametag:drawIcons(player, center_x , center_y, height, alpha)
	if isChatBoxInputActive() then
		setElementData(localPlayer, "writing", true)
	else
		setElementData(localPlayer, "writing", false)
	end

	local icons = {}
	if getElementData(player,"writing") == true then
		icons[#icons+1] = "chat.png"
	end
	if player:getFaction() then
		icons[#icons+1] = player:getFaction():getShortName()..".png"
	end
	if player:getCompany() then 
		icons[#icons+1] = (player:getCompany().m_Id == CompanyStaticId.MECHANIC and "MT" or player:getCompany():getShortName())..".png"
	end
	local bHasBigGun = false
	if not getElementData(player, "CanWeaponBeConcealed") then
		for i = 3,7 do
			bHasBigGun = getPedWeapon(player,i)
			if bHasBigGun ~= 0 then
				bHasBigGun = true
				break;
			else
				bHasBigGun = false
			end
		end
	end
	if bHasBigGun then
		icons[#icons+1] = "gun.png"
	end
	if getElementData(player, "isBuckeled") and getPedOccupiedVehicle(player) then
		icons[#icons+1] = "seatbelt.png"
	end
	for index, icon in pairs(icons) do
		index = index - 1
		dxDrawImage(center_x - (#icons * height*1.1)/2 + index * height*1.1, center_y, height, height, "files/images/Nametag/"..icon,0,0,0,tocolor(255,255,255,255*alpha))
	end
	return #icons > 0
end

function Nametag:getColorFromHP(hp, armor)
	armor = armor*2
	if armor >= 255 then armor = 255 end
	if hp <= 0 then
		return 0, 0, 0
	else
		return math.min(255, (( 100 - hp ) * 2.55 / 2) + armor), math.min(255, (( hp * 2.55 )) + armor), armor
	end
end

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

function isPedAiming ( thePedToCheck )
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
				return true
			end
		end
	end
	return false
end
