-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
MovementRecorder = inherit(Object)

function MovementRecorder:constructor(vehicleModel)
	self.m_VehicleDummy = createVehicle(vehicleModel, 1337, 1337, 1337)
	self.m_VehicleDummy:setPlateText("eXo")
	self.m_VehicleDummy:setFrozen(true)
	self.m_VehicleDummy:setCollisionsEnabled(false)
	self.m_VehicleDummy:setAlpha(150)
	setVehicleOverrideLights(self.m_VehicleDummy, 2)

	self.m_DummyPed = createPed(0, 1337, 1337, 1337)
	self.m_DummyPed:setCollisionsEnabled(false)
	self.m_DummyPed:setAlpha(150)
	self.m_DummyPed:warpIntoVehicle(self.m_VehicleDummy)

	self.m_Record = {}
	self.m_Recording = false
	self.m_RenderPlayback = false
	self.m_PlayRecordFrame = 1

	self.m_fnRenderRecord = bind(MovementRecorder.renderRecord, self)
	self.m_fnRenderPlayback = bind(MovementRecorder.renderPlayback, self)
end

function MovementRecorder:destructor()
	if isElement(self.m_VehicleDummy) then self.m_VehicleDummy:destroy() end
	if isElement(self.m_DummyPed) then self.m_DummyPed:destroy() end

	removeEventHandler("onClientRender", root, self.m_fnRenderRecord)
	removeEventHandler("onClientRender", root, self.m_fnRenderPlayback)
end

function MovementRecorder:startRecording()
	if self.m_Recording then return end
	if not localPlayer.vehicle then return end

	self.m_Record = {}
	self.m_Vehicle = localPlayer.vehicle
	self.m_RecordStartTick = getTickCount()
	self.m_Recording = true

	addEventHandler("onClientRender", root, self.m_fnRenderRecord)
end

function MovementRecorder:stopRecording()
	if not self.m_Recording then return end
	self.m_Recording = false
	removeEventHandler("onClientRender", root, self.m_fnRenderRecord)

	self.m_Record.duration = getTickCount() - self.m_RecordStartTick
end

function MovementRecorder:isRecording()
	return self.m_Recording
end

function MovementRecorder:startPlayback()
	if not self.m_VehicleDummy then return end
	if self.m_RenderPlayback then self:stopPlayback() end

	--if self.m_PlayRecordFrame >= #self.m_Record then
		self.m_PlayRecordFrame = 1
	--end

	self.m_RenderPlayback = true
	self.m_PlaybackStartTick = getTickCount()
	self.m_PlaybackStartFrame = self.m_PlayRecordFrame or 1
	self.m_PlaybackDuration = self.m_Record.duration - self.m_Record[self.m_PlaybackStartFrame].elapsedTime

	addEventHandler("onClientRender", root, self.m_fnRenderPlayback)
end

function MovementRecorder:stopPlayback()
	self.m_RenderPlayback = false
	removeEventHandler("onClientRender", root, self.m_fnRenderPlayback)
end

function MovementRecorder:isPlaybackRendered()
	return m_RenderPlayback
end

function MovementRecorder:renderRecord()
	if not localPlayer.vehicle then
		return self:stopRecording()
	end

	-- Fetching datas
	local model = self.m_Vehicle.model
	local position = self.m_Vehicle.position
	local rotation = self.m_Vehicle.rotation
	local elapsedTime = getTickCount()-self.m_RecordStartTick

	table.insert(self.m_Record, {model = model, position = position, rotation = rotation, elapsedTime = elapsedTime})
end

function MovementRecorder:renderPlayback()
	if not self.m_VehicleDummy then return end

	local playbackProgress = (getTickCount() - self.m_PlaybackStartTick) / self.m_PlaybackDuration
	self.m_PlayRecordFrame = math.floor(interpolateBetween(self.m_PlaybackStartFrame, 0, 0, #self.m_Record, 0, 0, playbackProgress, "Linear")+0.5)

	self:updateFrame()

	if playbackProgress >= 1 then
		self:stopPlayback()
	end
end

function MovementRecorder:updateFrame()
	local frame = self.m_Record[self.m_PlayRecordFrame]
	if not frame then return end

	self.m_VehicleDummy:setPosition(frame.position)
	self.m_VehicleDummy:setRotation(frame.rotation)
end
