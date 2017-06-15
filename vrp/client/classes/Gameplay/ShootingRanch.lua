ShootingRanch = inherit(GUIForm)
inherit(Singleton, ShootingRanch)

addRemoteEvents{"startClientShootingRanch", "stopClientShootingRanch", "showShootingRanchResult"}

function ShootingRanch:constructor()
	GUIForm.constructor(self, screenWidth-220, screenHeight/2-100/2, 180, 200, false)

	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0,0,0,150), self)

	GUILabel:new(0, 0, self.m_Width, 30, _"Schießstand", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_Hits = GUILabel:new(5, 30, self.m_Width-10, 25, _"Bitte schieße auf die Ziele!", self)
	self.m_TimeLabel = GUILabel:new(5, 60, self.m_Width-10, 25, "", self)
	self.m_Accuracy = GUILabel:new(5, 90, self.m_Width-10, 25, "", self)
	self.m_Time = 0
	self.m_Timer = setTimer(bind(self.updateLabels, self), 500, 0)
	self.m_WeaponFireBind = bind(self.onWeaponFire, self)
	addEventHandler("onClientPlayerWeaponFire", root, self.m_WeaponFireBind)
end

function ShootingRanch:destructor()
	removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_WeaponFireBind)
	if self.m_Timer then killTimer(self.m_Timer) end
	if self.m_TimeIncrease then killTimer(self.m_TimeIncrease) end
	GUIForm.destructor(self)
end

function ShootingRanch:updateLabels()
	if getElementData(localPlayer, "ShootingRanch:Data") then
		if not self.m_TimeIncrease then
			setElementData(localPlayer, "ShootingRanch:ClientStartTime", getRealTime().timestamp)
			 self.m_TimeIncrease = setTimer(function()
			 	self.m_Time = self.m_Time + 1
			 end, 1000, 0)
		end

		local data = getElementData(localPlayer, "ShootingRanch:Data")
		local acc =  data["Hits"]*100/(data["StartMuni"] - localPlayer:getTotalAmmo())

		self.m_Hits:setText(_("Treffer: %d/%d", data["Hits"], data["TargetHits"]))
		self.m_TimeLabel:setText(_("Zeit: %d/%d", self.m_Time, data["Time"]))
		self.m_Accuracy:setText(_("Genauigkeit: %d/%d", acc, data["TargetAccuracy"]))
		if self.m_Time > data["Time"] then
			triggerServerEvent("ShootingRanch:onTimeUp", localPlayer)
		end
	end
end

function ShootingRanch:onWeaponFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if source == localPlayer then
		if(isElement(hitElement))then
			if(getElementData(hitElement, "target") == true)then
				if(getElementData(hitElement, "hitAble")==true)then
					triggerServerEvent("ShootingRanch:onTargetHit", localPlayer, hitElement)
				end
			end
		end
	end
end


addEventHandler("startClientShootingRanch", root,
	function()
		ShootingRanch:new()
	end
)

addEventHandler("stopClientShootingRanch", root,
	function()
		delete(ShootingRanch:getSingleton())
	end
)

ShootingRanchResult = inherit(GUIForm)
inherit(Singleton, ShootingRanchResult)

function ShootingRanchResult:constructor(data, success, totalAmmo)
	GUIForm.constructor(self, screenWidth/2-400/2, screenHeight/2/2-220/2, 400, 220, false)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schießstand Ergebnis", true, true, self)

	self.m_Hits = GUILabel:new(10, 40, self.m_Width-20, 25, "", self)
	self.m_Time = GUILabel:new(10, 70, self.m_Width-20, 25, "", self)
	self.m_Accuracy = GUILabel:new(10, 100, self.m_Width-20, 25, "", self)

	local startTime = getElementData(localPlayer, "ShootingRanch:ClientStartTime") or data["StartTime"]
	local time = getRealTime().timestamp - startTime
	local acc =  data["Hits"]*100/(data["StartMuni"] - totalAmmo)

	self.m_Hits:setText(_("Treffer: %d von benötigten %d", data["Hits"], data["TargetHits"]))
	self.m_Time:setText(_("Benötigte Zeit: %d/%d", time > 60 and 60 or time, data["Time"]))
	self.m_Accuracy:setText(_("Genauigkeit: %d Prozent von benötigten %d Prozent", acc, data["TargetAccuracy"]))
	if success == true then
		GUILabel:new(10, 150, self.m_Width-20, 35, _"Gratuliere! Du hast bestanden!", self):setColor(Color.Green)
	else
		GUILabel:new(10, 150, self.m_Width-20, 35, _"Du hast nicht bestanden!", self):setColor(Color.Red)
	end
end

addEventHandler("showShootingRanchResult", root,
	function(...)
		ShootingRanchResult:new(...)
	end
)
