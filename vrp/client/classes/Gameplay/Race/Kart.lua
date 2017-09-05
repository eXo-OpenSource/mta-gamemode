-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Kart = inherit(Singleton)
addRemoteEvents{"KartStart", "KartStop", "KartRequestGhostDriver", "KartReceiveGhostDriver"}

Kart.record = false

function Kart:constructor(startFinishMarker, checkpoints, selectedLaps, respawnEnabled, mapId)
	self.m_State = "Flying"
	self.m_HittedCheckpoints = {}

	self.m_StartFinishMarker = startFinishMarker
	self.m_Checkpoints = checkpoints
	self.m_Laps = 1
	self.m_SelectedLaps = selectedLaps
	self.m_RespawnEnabled = respawnEnabled

	HUDKart:getSingleton():setSelectedLaps(self.m_SelectedLaps)
	HUDKart:getSingleton().m_ShowRespawnLabel = respawnEnabled

	self.m_onStartFinishMarkerHit = bind(Kart.startFinishMarkerHit, self)
	self.m_onCheckpointHit = bind(Kart.checkpointHit, self)
	self.m_Respawn = bind(Kart.respawnToLastCheckpoint, self)

	self.m_GhostRecord = MovementRecorder:new(571)
	self.m_GhostPlayback = MovementRecorder:new(571)
	self.m_GhostPlayback.m_Record =  Kart.record or false

	if self.m_RespawnEnabled then
		bindKey("x", "down", self.m_Respawn)
	end

	for _, v in pairs(self.m_Checkpoints) do
		addEventHandler("onClientMarkerHit", v, self.m_onCheckpointHit)
	end

	Kart.MapId = mapId
	addEventHandler("onClientMarkerHit", self.m_StartFinishMarker, self.m_onStartFinishMarkerHit)
end

function Kart:destructor()
	if self.m_RespawnEnabled then
		unbindKey("x", "down", self.m_Respawn)
	end

	for _, v in pairs(self.m_Checkpoints) do
		removeEventHandler("onClientMarkerHit", v, self.m_onCheckpointHit)
	end

	removeEventHandler("onClientMarkerHit", self.m_StartFinishMarker, self.m_onStartFinishMarkerHit)

	self.m_StartFinishMarker = {}
	self.m_Checkpoints = {}
	delete(self.m_GhostRecord)
	delete(self.m_GhostPlayback)
	Kart.record = false
end

function Kart:startFinishMarkerHit(hitPlayer, matchingDimension)
	if not matchingDimension then return end
	if hitPlayer ~= localPlayer then return end

	if self.m_State == "Flying" then
		if #self.m_HittedCheckpoints == #self.m_Checkpoints then
			self.m_State = "Running"
		end
	elseif self.m_State == "Running" then
		if #self.m_HittedCheckpoints == #self.m_Checkpoints then
			self.m_Laps = self.m_Laps + 1
		end
	end

	if self.m_State == "Running" then
		self.m_StartTick = getTickCount()
		self.m_HittedCheckpoints = {}

		HUDKart:getSingleton():setStartTick(true)
		HUDKart:getSingleton():setLaps(self.m_Laps)

		self.m_GhostRecord:stopRecording()
		self.m_LastGhost = self.m_GhostRecord.m_Record
		self.m_GhostRecord:startRecording()

		if Kart.record then
			self.m_GhostPlayback:startPlayback()
		end
	end
end

function Kart:checkpointHit(hitPlayer, matchingDimension)
	if not matchingDimension then return end
	if hitPlayer ~= localPlayer then return end

	for _, v in pairs(self.m_Checkpoints) do
		if v == source then
			for _, v2 in pairs(self.m_HittedCheckpoints) do
				if v == v2 then
					return
				end
			end

			table.insert(self.m_HittedCheckpoints, v)
			self.m_LastCheckpoint = {position = localPlayer.vehicle.position, rotation = localPlayer.vehicle.rotation}
		end
	end
end

function Kart:respawnToLastCheckpoint()
	if self.m_RespawnEnabled and self.m_LastCheckpoint then
		localPlayer.vehicle:setPosition(self.m_LastCheckpoint.position)
		localPlayer.vehicle:setRotation(self.m_LastCheckpoint.rotation)
		localPlayer.vehicle:setVelocity(0, 0, 0)
		localPlayer.vehicle:setTurnVelocity(0, 0, 0)
	end
end

function Kart.receiveGhostDriver(record)
	Kart.LastRequest = false

	local unparsed = fromJSON(record)
	if not unparsed then WarningBox:new("Für diesen Spieler ist kein Geist verfügbar!") return false end
	Kart.record = table.setIndexToInteger(unparsed)

	for _, v in pairs(Kart.record) do
		if type(v) == "table" then
			v.position = Vector3(v.x, v.y, v.z)
			v.rotation = Vector3(v.rx, v.ry, v.rz)
		end
	end

	InfoBox:new("Geist übernommen!")
end

function Kart.uploadGhostDriver()
	if not Kart.requestedRecord then return end

	local options = {
		["postData"] =  ("secret=%s&playerId=%d&mapId=%d&data=%s"):format("8H041OAyGYk8wEpIa1Fv", localPlayer:getPrivateSync("Id"), Kart.MapId, toJSON(Kart.requestedRecord))
	}

	fetchRemote("https://exo-reallife.de/ingame/kart/addGhost.php", options,
		function(responseData, responseInfo)
			Kart.requestedRecord = false
			--outputConsole(inspect({data = responseData, info = responseInfo}))
		end
	)
end

addEventHandler("KartRequestGhostDriver", root,
	function()
		local record = Kart:getSingleton().m_LastGhost

		if record then
			for _, v in pairs(record) do
				if type(v) == "table" then
					v.x, v.y, v.z = v.position.x, v.position.y, v.position.z
					v.rx, v.ry, v.rz = math.floor(v.rotation.x), math.floor(v.rotation.y), math.floor(v.rotation.z)
					v.position = nil
					v.rotation = nil
				end
			end

			record.duration = getTickCount() - Kart:getSingleton().m_StartTick
			Kart.requestedRecord = record
		end
	end
)

addEventHandler("KartStart", root,
	function(...)
		Kart:new(...)
	end
)

addEventHandler("KartStop", root,
	function()
		if Kart:isInstantiated() then
			delete(Kart:getSingleton())
			Kart.uploadGhostDriver()
		end
	end
)
