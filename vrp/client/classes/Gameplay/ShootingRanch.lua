ShootingRanch = inherit(Singleton)

addRemoteEvents{"startClientShootingRanch"}

function ShootingRanch:constructor()
	self.m_Time = 120
	self.m_DrawBind = bind(self.drawTime, self)
	self.m_WeaponFireBind = bind(self.onWeaponFire, self)
	addEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_WeaponFireBind)
	addEventHandler("onClientRender", root, self.m_DrawBind)
end

function ShootingRanch:destructor()
	removeEventHandler("onClientRender", root, self.m_DrawBind)
	removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_WeaponFireBind)
end

function ShootingRanch:onWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if getElementData(localPlayer, "isInShootingRange")==true then
		if(isElement(hitElement))then
			if(getElementData(hitElement, "target") == true)then
				if(getElementData(hitElement, "hitAble")==true)then
					triggerServerEvent("ShootingRanch:onTargetHit", localPlayer, hitElement)
				end
			end
		end
	end
end

function ShootingRanch:drawTime()
	if getElementData(localPlayer, "isInShootingRange") == false then
		delete(self)
		return
	end

	local firstmuni = getElementData(localPlayer,"firstmuni")

	if not getElementData(localPlayer, "hits") then setElementData(localPlayer, "hits",0) end
	local hits = getElementData(localPlayer, "hits")
	if hits==0 then starttime = 0 return end
	local times = getRealTime()
	if starttime==0 and hits==1 then
		starttime = times.timestamp
	end
	local totalammo2 = getPedTotalAmmo(localPlayer)
	local acc = math.floor(hits*100/(firstmuni-totalammo2))

	local time = times.timestamp-starttime
	local drawTime = "Treffer: "..hits.."\nAccuracy: "..acc.."%\nZeit: "..time..""

	if time >= self.m_Time then
		triggerServerEvent("ShootingRanch:Finish", localPlayer, time, acc)
	end
	dxDrawText(drawTime, screenWidth-330, screenHeight/2, screenWidth-330, screenHeight/2, tocolor(255,255,255,255),2,"pricedown")
end

addEventHandler("startClientShootingRanch", root, function()
	ShootingRanch:new()
end)
