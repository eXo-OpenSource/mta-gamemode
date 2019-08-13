-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/GPS.lua
-- *  PURPOSE:     GPS class
-- *
-- ****************************************************************************
GPS = inherit(Singleton)
addRemoteEvents({ "GPS.retrieveRoute", "navigationStart", "navigationStop" })

function GPS:constructor()
	self.m_Active = false
	self.m_Nodes = nil
	self.m_WaypointCols = {}

	addEventHandler("navigationStart", root, function(x, y, z) self:startNavigationTo(Vector3(x, y, z)) end)
	addEventHandler("navigationStop", root, bind(self.stopNavigation, self))
	addEventHandler("GPS.retrieveRoute", root, bind(self.Event_retrieveRoute, self))
end

function GPS:startNavigationTo(position, isRecalculate, soundDisabled)
	-- Stop old navigation if existing
	if self.m_Active then
		self:stopNavigation()
	end

	-- Disable navigation for the circle radar
	if HUDRadar:getSingleton():getDesignSet() == RadarDesign.Default then
		ShortMessage:new(_"Das GPS wird vom runden Radar nicht unterstützt! Bitte wechsle das Design", _"Navigation")
		self:stopNavigation()
		return
	end

	-- Cancel navigation in interiors
	if localPlayer:getInterior() ~= 0 then
		self:stopNavigation()
		return
	end

	self.m_Destination = position
	self.m_Active = true

	-- Show message if it's not a recalculation
	if not soundDisabled then
		if not isRecalculate then
			ShortMessage:new(_"Route wird berechnet...", _"Navigation")
			self:playAnnouncement(INGAME_WEB_PATH .. "/ingame/sounds/RouteWirdBerechnet.mp3")
		else
			ShortMessage:new(_"Route wird neu berechnet...", _"Navigation")
			self:playAnnouncement(INGAME_WEB_PATH .. "/ingame/sounds/RouteWirdNeuBerechnet.mp3")
		end
	end

	-- Ask the server to calculate a route for us
	triggerServerEvent("GPS.calcRoute", localPlayer, "GPS.retrieveRoute", serialiseVector(localPlayer:getPosition()), serialiseVector(position))
end

function GPS:stopNavigation()
	if not self.m_Active then
		return
	end

	-- Remove route from the radar
	HUDRadar:getSingleton():setGPSRoute(nil)

	-- Remove colshapes
	for k, colshape in pairs(self.m_WaypointCols) do
		destroyElement(colshape)
	end
	self.m_WaypointCols = {}

	-- Kill recalculation timer
	if isTimer(self.m_TimerRecalculate) then killTimer(self.m_TimerRecalculate) end

	self.m_Active = false
end

function GPS:Event_retrieveRoute(nodes)
	if not self.m_Active then
		return
	end

	-- Remove colshapes (Probably a workaround)
	for k, colshape in pairs(self.m_WaypointCols) do
		destroyElement(colshape)
	end
	self.m_WaypointCols = {}

	-- Kill recalculation timer (Probably a workaround)
	if isTimer(self.m_TimerRecalculate) then killTimer(self.m_TimerRecalculate) end

	if #nodes == 0 then
		ShortMessage:new(_"Es wurde keine Route gefunden!", _"Navigation")
		return
	end

	 -- Unserialise vectors
	self.m_Nodes = table.map(nodes, normaliseVector)

	-- Inform the radar about the gps route
	HUDRadar:getSingleton():setGPSRoute(self.m_Nodes)

	-- Start timer that recalculates the route if required
	self.m_TimerRecalculate = setTimer(bind(self.Timer_Recalculate, self), 5000, 0)

	-- Set next checkpoint to the first
	self.m_NextNode = self.m_Nodes[1]

	-- Create colshapes to keep track of the nodes
	for i, node in ipairs(self.m_Nodes) do
		self.m_WaypointCols[i] = createColCircle(node.x, node.y, 7)

		addEventHandler("onClientColShapeHit", self.m_WaypointCols[i],
			function(hitElement, matchingDimension)
				if hitElement == localPlayer and matchingDimension then
					-- Stop route if this is the last checkpoint
					if #self.m_Nodes == 1 then
						self:stopNavigation()
						ShortMessage:new(_"Du hast dein Ziel erreicht!", "Navigation")
						self:playAnnouncement(INGAME_WEB_PATH .. "/ingame/sounds/SieHabenIhrZielErreicht.mp3")
						return
					end

					-- Remove all node to this index cumulatively
					for j = 1, i do
						-- Check if it's there to prevent us from destroying
						-- the same colshape twice
						if self.m_WaypointCols[j] then
							destroyElement(self.m_WaypointCols[j])
							self.m_WaypointCols[j] = nil

							table.remove(self.m_Nodes, 1)
						end
					end

					-- Redraw route
					HUDRadar:getSingleton():setGPSRoute(self.m_Nodes)

					-- Store next checkpoint
					self.m_NextNode = self.m_Nodes[1]

					-- Process waypoint (e.g. sounds)
					self:processWaypoint(3)
				end
			end
		)
	end
end

function GPS:Timer_Recalculate()
	-- It might not be there if we're close to the destination
	if not self.m_NextNode then
		return
	end

	-- Restart navigation if our distance to the next checkpoint is greater than 300
	if (localPlayer:getPosition() - self.m_NextNode):getLength() > 150 then
		self:startNavigationTo(self.m_Destination, true)
	end
end

function GPS:processWaypoint(nodeIndex)
	local previous = self.m_Nodes[nodeIndex - 1]
	local current = self.m_Nodes[nodeIndex]
	local next = self.m_Nodes[nodeIndex + 1]

	if not previous or not current or not next then
		return
	end

	-- Make two vectors
	local vecA = current - previous
	local vecB = next - current

	-- Calculate angle between both vectors
	local angle = math.deg(math.getAngle(vecA, vecB))
	local cross = vecA:cross(vecB)

	if angle > 45 and angle < 135 then
		-- The up-component is either down or up
		if cross.z < 0 then
			self:playAnnouncement(INGAME_WEB_PATH .. "/ingame/sounds/BitteBiegenSieRechtsAb.mp3")
		else
			self:playAnnouncement(INGAME_WEB_PATH .. "/ingame/sounds/BitteBiegenSieLinksAb.mp3")
		end
	end
end

function GPS:playAnnouncement(url)
	if not core:get("Sounds", "Navi", true) then
		return
	end
	local radio = RadioGUI:getSingleton()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
		radio:setVolume(self.m_OldVolume)
	end

	-- Play announcement sound
	self.m_Sound = playSound(url)

	-- Turn down radio volume meanwhile
	self.m_OldVolume = radio:getVolume()
	radio:setVolume(0.1)

	-- Turn up again
	addEventHandler("onClientSoundStopped", self.m_Sound,
		function()
			radio:setVolume(self.m_OldVolume)
		end
	)
end

