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

function GPS:startNavigationTo(position)
	-- Stop old navigation if existing
	if self.m_Active then
		self:stopNavigation()
	end

	self.m_Destination = position
	self.m_Active = true

	-- Ask the server to calculate a route for us
	triggerServerEvent("GPS.calcRoute", localPlayer, "GPS.retrieveRoute", serialiseVector(localPlayer:getPosition()), serialiseVector(position))
end

function GPS:stopNavigation()
	-- Remove route from the radar
	HUDRadar:getSingleton():setGPSRoute(nil)

	-- Remove colshapes
	for k, colshape in pairs(self.m_WaypointCols) do
		destroyElement(colshape)
	end
	self.m_WaypointCols = {}

	-- Kill recalculation timer
	killTimer(self.m_TimerRecalculate)

	self.m_Active = false
end

function GPS:Event_retrieveRoute(nodes)
	if not self.m_Active then
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
						ShortMessage:new(_"Du hast dein Ziel erreicht!")
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
					self.m_NextNode = self.m_Nodes[i + 1]
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
	if (localPlayer:getPosition() - self.m_NextNode):getLength() > 300 then
		self:startNavigationTo(self.m_Destination)
		ShortMessage:new(_"Route wird neu berechnet...")
	end
end
