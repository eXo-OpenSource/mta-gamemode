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
		if player ~= localPlayer and (player.getPublicSync and not player:getPublicSync("inSmokeGrenade") and not player:getPublicSync("isInvisible")) then
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/Nametag") end
			setPlayerNametagShowing(player, false)
			local pX, pY, pZ = getElementPosition(player)
			local phX, phY, phZ = getPedBonePosition(player, 8)
			local bDistance = getDistanceBetweenPoints3D(cx,cy,cz, pX, pY, pZ)
			local smokeHit = false
			if bRifleCheck == player then bDistance = 10 end -- fix the distance if the localPlayer aims at the specific player
			if not localPlayer:isLoggedIn() then return false end
			if (bDistance <= maxDistance) or localPlayer:getPrivateSync("isSpecting") then
				local scx,scy = getScreenFromWorldPosition(pX, pY, pZ + 1.2)
				if scx and scy then
					local bLineOfSight = isLineOfSightClear(cx, cy, cz, phX, phY, phZ, true, false, false, true, false, false, false, localPlayer)
					for col, bool in pairs(ItemSmokeGrenade.Map) do
						if col and isElement(col) then
							local point, hit = checkRaySphere(Vector3(cx, cy, cz), (Vector3(phX, phY, phZ) - Vector3(cx, cy, cz)):getNormalized(), col:getPosition(), 3)
							local color = Color.Green
							if hit then
								color = Color.Red
								smokeHit = true
							end
							if DEBUG then
								--dxDrawLine3D(Vector3(cx, cy, cz-0.5), Vector3(phX, phY, phZ), color)
							end
						else
							ItemSmokeGrenade.Map[col] = nil
						end
					end
					if bLineOfSight and not smokeHit or localPlayer:getPrivateSync("isSpecting") then
						local drawName = getPlayerName(player)
						local isAdmin = false
						if player.getPublicSync and player:getPublicSync("supportMode") then
							drawName = ("(%s) %s"):format(RANKSCOREBOARD[player.getPublicSync and player:getPublicSync("Rank") or 3] or "Support", drawName)
							isAdmin = true
						end
						local wanteds = player:getWanteds()
						local size = math.max(0.5, 1 - bDistance/maxDistance)*0.9
						local alpha = localPlayer:getPrivateSync("isSpecting") and 1 or math.min(1, 1 - (bDistance - maxDistance*0.5)/(maxDistance - maxDistance*0.5))
						local r,g,b =  self:getColorFromHP(getElementHealth(player), getPedArmor(player))
						local textWidth = dxGetTextWidth(drawName, 1.5*size, Nametag.font)
						local textWidth2 = dxGetTextWidth(drawName, 2*size, Nametag.font)
						local fontHeight = dxGetFontHeight(1.5*size,Nametag.font)
						local fontHeightName = dxGetFontHeight(2*size,Nametag.font)
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
						dxDrawText(drawName, scx + 1,scy + 1, nil, nil, tocolor(0, 0, 0, 255*alpha), 2*size, Nametag.font, "center", "center")
						if isAdmin then
							dxDrawText(drawName, scx,scy, nil, nil, Color.changeAlpha(Color.Accent, 255*alpha), 2*size, Nametag.font, "center", "center")
						else
							dxDrawText(drawName, scx,scy, nil, nil, tocolor(r, g, b, 255*alpha), 2*size, Nametag.font, "center", "center")
						end
						if core:get("HUD", "DisplayBadge", true) and localPlayer.m_DisplayMode and not localPlayer.vehicle and (localPlayer:getWeapon() == 43 or not isPedAiming(localPlayer)) and player:getData("Badge") and player:getData("Badge") ~= "" and getDistanceBetweenPoints2D(player.position.x, player.position.y, localPlayer.position.x, localPlayer.position.y) < 3 then
							self:drawBadge(player, size*.8, alpha)
						end
						if getElementData(player, "Damage:isTreating") then
							dxDrawText("+", scx, (scy-fontHeight*3)+1, scx+textWidth2, (scy-fontHeight*.25)+1, Color.changeAlpha(Color.Black, alpha*255), 4, "default-bold", "center", "center")
							dxDrawText("+", scx, scy-fontHeight*3, scx+textWidth2, scy-fontHeight*.25, Color.changeAlpha(Color.Red, alpha*255), 4, "default-bold", "center", "center")
						end
					end
				end
			end
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/Nametag") end
end

function Nametag:drawBadge(player, size, alpha)
	dxSetBlendMode ( "modulate_add" )
	local relRot = findRotation(getCamera().position.x, getCamera().position.y, player.position.x, player.position.y)
	local white = tocolor(255, 255, 255, 255*alpha)
	local grey= tocolor(255, 255, 255, 255*alpha)
	relRot = (relRot - (player.rotation.z)) % 360
	if relRot >= 110 and relRot <= 220 then
		--local textRot = (relRot - 180)*.3
		textRot = 0
		local cx, cy, cz = getCameraMatrix()
		local x, y, z = getPedBonePosition(player, 22)
		local bLineOfSight = isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, false, false, false, localPlayer)
		if not bLineOfSight then return end
		local x2, y2 = x, y

		if x and y then
			local sx, sy = getScreenFromWorldPosition(x2, y2, z)
			local sx2, sy2 = getScreenFromWorldPosition(x, y, z-0.15)

			if sx and sy and sx2 and sy2 then
				local leftShift = screenWidth*(0.05*size)
				sx = sx  - leftShift
				local textWidth = dxGetTextWidth(player:getData("Badge"), size, "sans" or Nametag.font)
				local textWidthLower = dxGetTextWidth(player:getData("BadgeTitle") or "LSPD", size, "sans" or Nametag.font)
				local diffAdjust = (textWidthLower - textWidth*1)-screenWidth*0.02
				if diffAdjust < 0 then
					diffAdjust = 0
				end

				local fontHeight = dxGetFontHeight(size, "sans" or Nametag.font)

				dxDrawRectangle(sx-diffAdjust -  textWidth*.1,  sy - fontHeight*.1, textWidth*1.2 , fontHeight*1.2, tocolor(0,0,0,220*alpha))
				dxDrawRectangle(sx - diffAdjust - textWidth*.1,   (sy  + fontHeight * 1.2), textWidthLower+textWidth*.2 , fontHeight, tocolor(0,0,0,220*alpha))

				dxDrawText(player:getData("Badge"), sx-diffAdjust, sy - fontHeight*.1, sx+textWidth, nil, white, size, "sans" or Nametag.font, "left", "top", false, false, false, false, false, textRot)

				dxDrawLine((sx-diffAdjust*1.2)-textWidth*.1, (sy + fontHeight*1.1) + 1, sx + textWidth, sy + fontHeight * 1.1,  tocolor(0, 0, 0, 255*alpha), 1)
				dxDrawLine((sx-diffAdjust*1.2)-textWidth*.1, sy + fontHeight*1.1, sx + textWidth, sy + fontHeight * 1.1,  grey)

				dxDrawLine(((sx-diffAdjust*1.2)-1) - textWidth*.1, (sy+1-fontHeight*.1) + 1, ((sx-diffAdjust*1.2) -1)-textWidth*.1, (sy  + fontHeight * 1.2 + fontHeight) + 1, tocolor(0, 0, 0, 255*alpha), 1)
				dxDrawLine(((sx-diffAdjust*1.2)-1) - textWidth*.1, sy+1-fontHeight*.1, ((sx-diffAdjust*1.2) -1)-textWidth*.1, sy  + fontHeight * 1.2 + fontHeight, grey)

				dxDrawLine(sx+textWidth,(sy + fontHeight*1.1)+1, sx + textWidth*1.5, sy2+1, tocolor(0, 0, 0, 255*alpha), 1)
				dxDrawLine(sx+textWidth,sy + fontHeight*1.1, sx + textWidth*1.5, sy2, grey)


				dxDrawText(player:getData("BadgeTitle") or "LSPD", sx - diffAdjust , (sy  + fontHeight * 1.2), sx+textWidthLower, nil, white, size,"sans" or  Nametag.font, "left", "top", false, false, false, false, false, textRot)

				dxDrawImage((sx + textWidth*1.5) - screenWidth*0.005,  sy2- (screenWidth*0.005), screenWidth*0.01, screenWidth*0.01, player:getData("BadgeImage") or "files/images/Nametag/SASF.png", 0, 0, 0, white)
			end
		end
	end
	dxSetBlendMode ( "blend" )
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
	if player:getPublicSync("gangwarParticipant") then
		icons[#icons+1] = "GangwarIcon.png"
	end
	for index, icon in pairs(icons) do
		index = index - 1
		dxDrawImage(center_x - (#icons * height*1.1)/2 + index * height*1.1, center_y, height, height, "files/images/Nametag/"..icon,0,0,0,tocolor(255,255,255,255*alpha))
	end
	if player:getPublicSync("LastHealTime") then
		local time = player:getPublicSync("LastHealTime")
		local diff = os.time() - Time.serverToLocal(time)

		if diff <= 60 * 5 then
			local r, g, b = interpolateBetween(0, 255, 0, 255, 0, 0, diff / (60 * 5), "Linear")
			local min = math.floor(diff / 60)
			local index = #icons
			local x, y = center_x - (#icons * height*1.1)/2 + index * height*1.1, center_y
			dxDrawImage(x, y, height, height, "files/images/Nametag/bandage.png",0,0,0,tocolor(r,g,b,255*alpha))
			icons[#icons+1] = "bandage.png"
		end
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
