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

function Kart:constructor(startFinishMarker, checkpoints, selectedLaps)
	self.m_State = "Flying"
	self.m_HittedCheckpoints = {}

	self.m_StartFinishMarker = startFinishMarker
	self.m_Checkpoints = checkpoints
	self.m_Laps = 1
	self.m_SelectedLaps = selectedLaps

	HUDRace:getSingleton():setSelectedLaps(self.m_SelectedLaps)

	self.m_onStartFinishMarkerHit = bind(Kart.startFinishMarkerHit, self)
	self.m_onCheckpointHit = bind(Kart.checkpointHit, self)

	self.m_GhostRecord = MovementRecorder:new(571)
	self.m_GhostPlayback = MovementRecorder:new(571)
	self.m_GhostPlayback.m_Record =  Kart.record or false


	for _, v in pairs(self.m_Checkpoints) do
		addEventHandler("onClientMarkerHit", v, self.m_onCheckpointHit)
	end

	addEventHandler("onClientMarkerHit", self.m_StartFinishMarker, self.m_onStartFinishMarkerHit)
end

function Kart:destructor()
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

		HUDRace:getSingleton():setStartTick(true)
		HUDRace:getSingleton():setLaps(self.m_Laps)

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
		end
	end
end

addEventHandler("KartReceiveGhostDriver", root,
	function(record)
		Kart.LastRequest = false

		local unparsed = fromJSON(record)
		Kart.record = table.setIndexToInteger(unparsed)

		for _, v in pairs(Kart.record) do
			if type(v) == "table" then
				v.position = Vector3(v.x, v.y, v.z)
				v.rotation = Vector3(v.rx, v.ry, v.rz)
			end
		end
	end
)

addEventHandler("KartRequestGhostDriver", root,
	function(lapTime)
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

			record.duration = lapTime
			triggerLatentServerEvent("sendKartGhost", 100000, false, root, record)
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
		end
	end
)
