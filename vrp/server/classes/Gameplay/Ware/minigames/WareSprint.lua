-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareSprint.lua
-- *  PURPOSE:     WareSprint class
-- *
-- ****************************************************************************
WareSprint = inherit(Object)
WareSprint.modeDesc = "Sprinte! (Leertaste)"
WareSprint.timeScale = 1

WareSprint.ObjectPos = {
	{Vector3(13.18, 26.47, 500.00), Vector3(0, 0, 230.00)},
	{Vector3(15.32, 28.54, 500.00), Vector3(0, 0, 200.00)},
	{Vector3(17.95, 28.94, 500.00), Vector3(0, 0, 190.00)},
	{Vector3(20.68, 28.69, 500.00), Vector3(0, 0, 170.00)},
	{Vector3(22.96, 27.73, 500.00), Vector3(0, 0, 150.00)},
	{Vector3(24.58, 26.28, 500.00), Vector3(0, 0, 130.00)},
	{Vector3(25.88, 24.05, 500.00), Vector3(0, 0, 110.00)},
	{Vector3(26.05, 21.22, 500.00), Vector3(0, 0, 80.00)},
	{Vector3(24.98, 18.20, 500.00), Vector3(0, 0, 60.00)},
	{Vector3(23.06, 15.91, 500.00), Vector3(0, 0, 30.00)},
	{Vector3(20.26, 15.27, 500.00), Vector3(0, 0, 0.00)},
	{Vector3(17.42, 15.80, 500.00), Vector3(0, 0, 340.00)},
	{Vector3(12.17, 24.51, 500.00), Vector3(0, 0, 250.00)},
	{Vector3(11.84, 22.00, 500.00), Vector3(0, 0, 270.00)},
	{Vector3(12.14, 19.40, 500.00), Vector3(0, 0, 290.00)},
	{Vector3(14.22, 17.03, 500.00), Vector3(0, 0, 320.00)},
}

addRemoteEvents{"Ware:clientSprintFinished"}

function WareSprint:constructor(super)
	self.m_Super = super
	self.m_Treadmills = {}
	local i = 1
	local pos, rot
	for key, p in ipairs(self.m_Super.m_Players) do
		pos = WareSprint.ObjectPos[i][1]
		rot = WareSprint.ObjectPos[i][2]
		self.m_Treadmills[p] = createObject(2627, pos.x, pos.y, pos.z+1, rot)
		self.m_Treadmills[p]:setDimension(self.m_Super.m_Dimension)
		p:setPosition(pos.x, pos.y, pos.z+2)
		p:setRotation(0, 0, rot.z, nil, true)
		p:setFrozen(true)
		i = i+1
		p:triggerEvent("setWareSprintListenerOn")

	end
	self.onSprintFinished = bind(self.Event_onSprintFinished, self)
	addEventHandler("Ware:clientSprintFinished", root, self.onSprintFinished)

end

function WareSprint:Event_onSprintFinished()
	if client.bInWare then
		if client.bInWare == self.m_Super then
			self.m_Super:addPlayerToWinners(client)
		end
	end
end

function WareSprint:destructor()
	for index, obj in pairs(self.m_Treadmills) do
		obj:destroy()
	end

	for key, p in ipairs(self.m_Super.m_Players) do
		p:setFrozen(false)
		p:triggerEvent("setWareSprintListenerOff")
	end
	removeEventHandler("Ware:clientSprintFinished", root, self.onSprintFinished)
end
