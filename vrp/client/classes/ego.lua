-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ego.lua
-- *  PURPOSE:     Ego View class
-- *
-- ****************************************************************************
ego = inherit(Singleton)
ego.Active = false
ego.Pi = math.pi

function ego:constructor()
	local pos = localPlayer:getPosition()

	self.m_RotX, self.m_RotY = 0, 0
	self.m_CamVehRot = 0
	self.m_Rot = 0

	self.m_CurVehRot = 0
	self.m_OldVehRot = 0

	self.m_MouseSensitivity = 0.1

	self.m_Delay = 0

	setCameraMatrix(pos)

	self.m_FreeCamFrameBind = bind(self.freeCamFrame, self)
	self.m_FreeCamMouseBind =bind(self.freeCamMouse, self)

	ego.Active = true

	addEventHandler("onClientPreRender", root, self.m_FreeCamFrameBind)
	addEventHandler("onClientRender", root, self.m_FreeCamFrameBind)
	addEventHandler("onClientCursorMove", root, self.m_FreeCamMouseBind)
	addEventHandler("onClientPlayerWasted", localPlayer, function()
		delete(self)
	end)
end

function ego:destructor()
	removeEventHandler("onClientPreRender", root, self.m_FreeCamFrameBind)
	removeEventHandler("onClientRender", root, self.m_FreeCamFrameBind)
	removeEventHandler("onClientCursorMove", root, self.m_FreeCamMouseBind)
	setCameraTarget(localPlayer)
	ego.Active = false
end

function ego:freeCamFrame()
    local camPosX, camPosY, camPosZ = getPedBonePosition(localPlayer, 8)

	local angleZ = math.sin(self.m_RotY)
    local angleY = math.cos(self.m_RotY) * math.cos(self.m_RotX)
    local angleX = math.cos(self.m_RotY) * math.sin(self.m_RotX)

	local camTargetX = camPosX + ( angleX ) * 100
    local camTargetY = camPosY + angleY * 100
    local camTargetZ = camPosZ + angleZ * 100

	if localPlayer.vehicle then
		local rot = localPlayer.vehicle:getRotation()
		self.m_CurVehRot = rot.z
		local changedRotation = self.m_OldVehRot - self.m_CurVehRot

		self.m_OldVehRot = self.m_CurVehRot

		if not self.m_TotalRot then
			self.m_TotalRot = self.m_CurVehRot
		end

		self.m_TotalRot = changedRotation * 2 + self.m_TotalRot

		self.m_RotX = ( ( self.m_RotX * 360 / ego.Pi ) + self.m_TotalRot ) / 360 * ego.Pi
		if self.m_RotX > ego.Pi then
			self.m_RotX = self.m_RotX - 2 * ego.Pi
		elseif self.m_RotX < - ego.Pi then
			self.m_RotX = self.m_RotX + 2 * ego.Pi
		end

		camTargetX = camPosX + ( math.cos(self.m_RotY) * math.sin(self.m_RotX) ) * 100
		camTargetY = camPosY + ( math.cos(self.m_RotY) * math.cos(self.m_RotX) ) * 100
	end

    setCameraMatrix(camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ)
end

function ego:freeCamMouse(_, _, aX, aY)
	if isCursorShowing() then
		self.m_Delay = 5
		return
	elseif self.m_Delay > 0 then
		self.m_Delay = self.m_Delay - 1
		return
	end

    aX = aX - screenWidth / 2
    aY = aY - screenHeight / 2

    self.m_RotX = self.m_RotX + aX * self.m_MouseSensitivity * 0.01745
    self.m_RotY = self.m_RotY - aY * self.m_MouseSensitivity * 0.01745

	if self.m_RotX > ego.Pi then
		self.m_RotX = self.m_RotX - 2 * ego.Pi
	elseif self.m_RotX < -ego.Pi then
		self.m_RotX = self.m_RotX + 2 * ego.Pi
	end

	if self.m_RotY > ego.Pi then
		self.m_RotY = self.m_RotY - 2 * ego.Pi
	elseif self.m_RotX < -ego.Pi then
		self.m_RotY = self.m_RotY + 2 * ego.Pi
	end

    if self.m_RotY < -ego.Pi / 2.05 then
       self.m_RotY = -ego.Pi / 2.05
    elseif self.m_RotY > ego.Pi / 2.05 then
        self.m_RotY = ego.Pi / 2.05
    end
end


function ego.toggle()
	if ego.Active then
		delete(ego:getSingleton())
	else
		ego:new()
	end
end

addCommandHandler("ego", ego.toggle)
