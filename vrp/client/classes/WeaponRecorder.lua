WeaponRecorder = inherit(Singleton)
WeaponRecorder.MAX_PER_PLAYER = 50
WeaponRecorder.MAX_DISPLAY_TIME = 30 * 1000

function WeaponRecorder:constructor(target)
	self.m_Data = {}
	self.m_Target = target or root

	self.m_OnFire = bind(self.record, self)
	self.m_Draw = bind(self.draw, self)
	addEventHandler("onClientRender", root, self.m_Draw)
	addEventHandler("onClientPlayerWeaponFire", self.m_Target, self.m_OnFire)
end

function WeaponRecorder:destructor()
	removeEventHandler("onClientPlayerWeaponFire", self.m_Target, self.m_OnFire)
	removeEventHandler("onClientRender", root, self.m_Draw)
end

function WeaponRecorder:draw()
	for player, data in pairs(self.m_Data) do
		if isElementStreamedIn(player) then
			for i, weaponData in pairs(data.data) do
				if (getTickCount() - weaponData[3]) > WeaponRecorder.MAX_DISPLAY_TIME then
					data.data[i] = nil
				else
					dxDrawLine3D(weaponData[1], weaponData[2], data.color, 1.5, false)
				end
			end
		else
			self.m_Data[player] = nil
		end
	end
end

function WeaponRecorder:record(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)
	if isElementStreamedIn(source) then
		if not self.m_Data[source] then
			self.m_Data[source] = {
				color = tocolor(math.random(255), math.random(255), math.random(255), 150),
				data = {}
			}
		end

		if #self.m_Data[source].data > WeaponRecorder.MAX_PER_PLAYER then
			self.m_Data[source].data[#self.m_Data[source].data] = nil
		end
		table.insert(self.m_Data[source].data, 1, {Vector3(getPedWeaponMuzzlePosition(source)), Vector3(hitX, hitY, hitZ), getTickCount()})
	else
		if self.m_Data[source] then
			self.m_Data[source] = nil
		end
	end
end

addEvent("startWeaponRecorder", true)
addEventHandler("startWeaponRecorder", root,
	function(target)
		WeaponRecorder:new(target)
	end
)

addEvent("stopWeaponRecorder", true)
addEventHandler("stopWeaponRecorder", root,
	function()
		delete(WeaponRecorder:getSingleton())
	end
)
