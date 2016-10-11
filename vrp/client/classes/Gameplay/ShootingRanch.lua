ShootingRanch = inherit(GUIForm)
inherit(Singleton, ShootingRanch)

addRemoteEvents{"startClientShootingRanch", "stopClientShootingRanch"}

function ShootingRanch:constructor()
	GUIForm.constructor(self, screenWidth-220, screenHeight/2-100/2, 180, 200, false)

	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0,0,0,150), self)

	GUILabel:new(0, 0, self.m_Width, 30, _"Schießstand", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_Hits = GUILabel:new(5, 30, self.m_Width-10, 25, _"Bitte schieße auf die Ziele!", self)
	self.m_Time = GUILabel:new(5, 60, self.m_Width-10, 25, "", self)
	self.m_Accuracy = GUILabel:new(5, 90, self.m_Width-10, 25, "", self)

	self.m_Timer = setTimer(bind(self.updateLabels, self), 500, 0)

	self.m_WeaponFireBind = bind(self.onWeaponFire, self)
	addEventHandler("onClientPlayerWeaponFire", root, self.m_WeaponFireBind)
end

function ShootingRanch:destructor()
	removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_WeaponFireBind)

	GUIForm.destructor(self)
end

function ShootingRanch:updateLabels()
	if getElementData(localPlayer, "ShootingRanch:Data") then
		local data = getElementData(localPlayer, "ShootingRanch:Data")
		local time = getRealTime().timestamp - data["StartTime"]
		local acc =  data["Hits"]*100/(data["StartMuni"] - localPlayer:getTotalAmmo())

		self.m_Hits:setText(_("Treffer: %d/%d", data["Hits"], data["TargetHits"]))
		self.m_Time:setText(_("Zeit: %d/%d", time, data["Time"]))
		self.m_Accuracy:setText(_("Genauigkeit: %d/%d", acc, data["TargetAccuracy"]))
	end
end

function ShootingRanch:onWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if(isElement(hitElement))then
		if(getElementData(hitElement, "target") == true)then
			if(getElementData(hitElement, "hitAble")==true)then
				triggerServerEvent("ShootingRanch:onTargetHit", localPlayer, hitElement)
			end
		end
	end
end


addEventHandler("startClientShootingRanch", root, function()
	ShootingRanch:new()
end)

addEventHandler("stopClientShootingRanch", root, function()
	delete(ShootingRanch:getSingleton())
end)
