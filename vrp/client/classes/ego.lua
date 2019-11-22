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
		ego.Active = false
	end)
end

function ego:destructor()
	removeEventHandler("onClientPreRender", root, self.m_FreeCamFrameBind)
	removeEventHandler("onClientRender", root, self.m_FreeCamFrameBind)
	removeEventHandler("onClientCursorMove", root, self.m_FreeCamMouseBind)
	setCameraTarget(localPlayer)
end

function ego:freeCamFrame()
	if not ego.Active then return end
    local camPosX, camPosY, camPosZ = getPedBonePosition(localPlayer, 8)

	local angleZ = math.sin(self.m_RotY)
    local angleY = math.cos(self.m_RotY) * math.cos(self.m_RotX)
    local angleX = math.cos(self.m_RotY) * math.sin(self.m_RotX)

	local camTargetX = camPosX + ( angleX ) * 100
    local camTargetY = camPosY + angleY * 100
    local camTargetZ = camPosZ + angleZ * 100

    setCameraMatrix(camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ)
end

function ego:freeCamMouse(_, _, aX, aY)
	if not ego.Active then return end
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
	if WeaponManager:getSingleton():isAimingRocketLauncher() then 
		ego.Active = false
	end
end


function ego.toggle()
	if ego.Active then
		delete(ego:getSingleton())
		ego.Active = false
	else
		if not localPlayer:getPublicSync("gangwarParticipant") then
			ego:new()
		end
	end
end
addCommandHandler("ego", ego.toggle)


function ego.enterVehicle(player)
	if player ~= localPlayer then return end
	if ego.Active then
		delete(ego:getSingleton())
	end
end
addEventHandler("onClientVehicleStartEnter", root, ego.enterVehicle)

function ego.exitVehicle(player)
	if player ~= localPlayer then return end
	if ego.Active then
		ego:new()
	end
end
addEventHandler("onClientVehicleExit", root, ego.exitVehicle)
