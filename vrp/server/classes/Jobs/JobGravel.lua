-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     Gravel Job
-- *
-- ****************************************************************************
JobGravel = inherit(Job)

MAX_STONES_IN_STOCK = 250
MAX_STONES_MINED = 100

LOAN_MINING = 25 -- Per Stone
LOAN_DOZER = 55 -- Per Stone
LOAN_DUMPER = 75 -- Per Stone

function JobGravel:constructor()
	Job.constructor(self)

	self.m_GravelStock = 0
	self.m_GravelMined = 0

	self.m_Jobber = {}
	self.m_Gravel = {}

	self.m_DumpLoadMarker = {
		createMarker(544.3, 919.9, -44, "cylinder", 6, 250, 130, 0, 100),
		createMarker(594.7, 926.3, -43, "cylinder", 6, 250, 130, 0, 100)
	}
	for index, marker in pairs(self.m_DumpLoadMarker) do
		marker.Track = JobGravel.Tracks["Dumper"..index]
		addEventHandler("onMarkerHit", marker, bind(self.onDumperLoadMarkerHit, self))
	end

	self.m_DozerSpawner = VehicleSpawner:new(719.35, 871.02, -28.4, {"Dozer"}, 170, bind(Job.requireVehicle, self))
	self.m_DozerSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_DozerSpawner:disable()

	self.m_DumperSpawner = VehicleSpawner:new(565.96, 886.05, -44.5, {"Dumper"}, 0, bind(Job.requireVehicle, self))
	self.m_DumperSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_DumperSpawner:disable()

	self.m_DumperDeliverTimer = {}
	self.m_DumperDeliverStones = {}
	self.m_DozerDropTimer = {}
	self.m_DozerDropStones = {}

	self.m_Col = createColSphere(592.54, 868.73, -42.497, 300)
	addEventHandler("onColShapeLeave", self.m_Col , bind(self.onGravelJobLeave, self))

	self.m_TimedPulse = TimedPulse:new(60000)
	self.m_TimedPulse:registerHandler(bind(self.destroyUnusedGravel, self))

	addRemoteEvents{"onGravelMine", "gravelOnCollectingContainerHit", "gravelDumperDeliver", "gravelOnDozerHit", "gravelTogglePickaxe"}
	addEventHandler("onGravelMine", root, bind(self.Event_onGravelMine, self))
	addEventHandler("gravelOnCollectingContainerHit", root, bind(self.Event_onCollectingContainerHit, self))
	addEventHandler("gravelDumperDeliver", root, bind(self.Event_onDumperDeliver, self))
	addEventHandler("gravelOnDozerHit", root, bind(self.Event_onDozerHit, self))
	addEventHandler("gravelTogglePickaxe", root, bind(self.Event_togglePickaxe, self))

end

function JobGravel:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_GRAVEL) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_GRAVEL), 255, 0, 0)
		return false
	end
	return true
end

function JobGravel:start(player)
	table.insert(self.m_Jobber, player)
	self.m_DozerSpawner:toggleForPlayer(player, true)
	self.m_DumperSpawner:toggleForPlayer(player, true)
	player.m_LastJobAction = getRealTime().timestamp
	setTimer(function()
		player:triggerEvent("gravelUpdateData", self.m_GravelStock, self.m_GravelMined)
	end, 1000, 1)
end

function JobGravel:stop(player)
	table.remove(self.m_Jobber, table.find(self.m_Jobber, player))
	self.m_DozerSpawner:toggleForPlayer(player, false)
	self.m_DumperSpawner:toggleForPlayer(player, false)
	if player.pickaxe and isElement(player.pickaxe) then player.pickaxe:destroy() end
	self:destroyDumperGravel(player)
end

function JobGravel:onGravelJobLeave(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getJob() == self then
			if hitElement.vehicle and hitElement.vehicle.jobPlayer then
				hitElement:sendError(_("Du hast das Jobgebiet unerlaubt mit einem Fahrzeug verlassen!", hitElement))
				hitElement.vehicle:destroy()
				JobManager:getSingleton():stopJobForPlayer(hitElement)
			end
		end
	end
end

function JobGravel:destroyUnusedGravel()
	for index, gravel in pairs(self.m_Gravel) do
		if gravel and isElement(gravel) then
			if gravel.mined then
				if gravel.LastHit and getRealTime().timestamp - gravel.LastHit > 60*10 then
					gravel:destroy()
					table.remove(self.m_Gravel, index)
					self:updateGravelAmount("mined", false)
				end
			elseif gravel.dumper then
				if gravel.LoadTime and getRealTime().timestamp - gravel.LoadTime > 60*10 then
					gravel:destroy()
					table.remove(self.m_Gravel, index)
				end
			end
		end
	end
end

--General

function JobGravel:updateGravelAmount(type, increase)
	local amount = increase and 1 or -1
	if type == "stock" then
		self.m_GravelStock = self.m_GravelStock + amount
	elseif type == "mined" then
		self.m_GravelMined = self.m_GravelMined + amount
	end
	for index, player in pairs(self.m_Jobber) do
		player:triggerEvent("gravelUpdateData", self.m_GravelStock, self.m_GravelMined)
	end
end

function JobGravel:onVehicleSpawn(player,vehicleModel,vehicle)
	self:registerJobVehicle(player, vehicle, true, false)
	if vehicleModel == 486 then
		player:triggerEvent("gravelOnDozerSpawn", vehicle)
	end
end

function JobGravel:moveOnTrack(track, gravel, step, callback)
	if track and track[step] then
		local speed, pos = unpack(track[step])
		gravel:move(speed, pos)
		setTimer(function()
			if track[step+1] then
				self:moveOnTrack(track, gravel, step+1, callback)
			else
				if callback then
					callback(gravel)
				end
			end
		end, speed, 1)
	end
end

--Step 1 Mine

function JobGravel:Event_onGravelMine(rockDestroyed, times)
	if self.m_GravelMined < MAX_STONES_MINED then
		client:setAnimation("sword", "sword_4", 2200, true, true, false, false)

		local pos = client.matrix:transformPosition(Vector3(-1.5, 0, 0))
		local gravel = createObject(2936, pos)
		gravel.mined = true
		gravel.LastHit = getRealTime().timestamp
		client:triggerEvent("gravelDisableCollission", gravel)
		gravel:setScale(0)
		nextframe(
			function()
				setTimer(
				function()
					gravel:setVelocity(-0.12, 0.12, 0.12)
					gravel:setScale(gravel:getScale() + 0.05)
				end, 50, 20)
			end
		)
		if rockDestroyed then
			local duration = getRealTime().timestamp - client.m_LastJobAction
			client.m_LastJobAction = getRealTime().timestamp
			StatisticsLogger:getSingleton():addJobLog(client, "jobGravel.mining", duration, times*LOAN_MINING)
			client:addBankMoney(times*LOAN_MINING, "Kiesgruben-Job")
		end
		if chance(6) then
			client:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
		end

		self:updateGravelAmount("mined", true)
		table.insert(self.m_Gravel, gravel)
	else
		client:sendError(_("Es können keine weiteren Steine abgebaut werden, bitte mit Dozern die Steine in die Behälter schieben.", client))
	end
end

function JobGravel:Event_togglePickaxe(state)
	if state then
		if not client.pickaxe and not isElement(client.pickaxe) then
			client.pickaxe = createObject(1858, 708.87, 836.69, -29.74)
			exports.bone_attach:attachElementToBone(client.pickaxe, client, 12, 0, 0, 0, 90, -90, 0)
		end
	else
		if client.pickaxe and isElement(client.pickaxe) then client.pickaxe:destroy() end
		client.pickaxe = nil
	end
end

--Step 2 Dozer Part

function JobGravel:Event_onCollectingContainerHit(track)
	local client = client --to use in-line timer
	local source = source --to use in-line timer
	if JobGravel.Tracks[track] then
		if self.m_GravelStock < MAX_STONES_IN_STOCK then
			if source.delivered then
				return
			end
			self:updateGravelAmount("mined", false)
			source.delivered = true
			if source.vehicle and isElement(source.vehicle) then
				if source.vehicle:getOccupant() then
					if not self.m_DozerDropStones[client] then self.m_DozerDropStones[client] = 0 end
					self.m_DozerDropStones[client] = self.m_DozerDropStones[client] + 1

					if not self.m_DozerDropTimer[client] then
						self.m_DozerDropTimer[client] = setTimer(function()
							local loan = LOAN_DOZER * (self.m_DozerDropStones[client] or 0)
							local duration = getRealTime().timestamp - client.m_LastJobAction
							client.m_LastJobAction = getRealTime().timestamp
							StatisticsLogger:getSingleton():addJobLog(client, "jobGravel.dozer", duration, loan)
							source.vehicle:getOccupant():addBankMoney(loan, ("Kiesgruben-Job (%d Steine)"):format(self.m_DozerDropStones[client]))
							self.m_DozerDropStones[client] = nil
							self.m_DozerDropTimer[client] = nil
						end, 1500, 1)
					end
				end
			end
			if chance(6) then
				client:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
			end
			self:moveOnTrack(JobGravel.Tracks[track], source, 1, function(gravel)
				self:updateGravelAmount("stock", true)
				if gravel and isElement(gravel) then gravel:destroy() end
			end)
		else
			client:sendError(_("Das Lager ist voll! Bitte erst mit einem Dumper die Waren nach oben befördern!", client))
			source:destroy()
		end
	else
		client:sendError("Internal Error: Track not found!")
	end
end

function JobGravel:Event_onDozerHit(vehicle)
	source.vehicle = vehicle
	source.LastHit = getRealTime().timestamp
end


--Step 3 Transport / Dumper Part

function JobGravel:destroyDumperGravel(player)
	for index, gravel in pairs(self.m_Gravel) do
		if gravel and isElement(gravel) then
			if gravel.dumper and gravel.player and gravel.player == player then
				gravel:destroy()
				table.remove(self.m_Gravel, index)
			end
		else
			table.remove(self.m_Gravel, index)
		end
	end
end

function JobGravel:onDumperLoadMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getJob() == self then
			if hitElement.vehicle and hitElement.vehicle:getModel() == 406 then
				if source.isBusy then
					hitElement:sendWarning(_("Der vordere Ladevorgang wurde noch nicht beendet! Bitte warten!", hitElement))
					return
				end
				if not hitElement.vehicle.gravelLoaded and not hitElement.gravelLoaded then
					if self.m_GravelStock >= 1 then
						hitElement:sendInfo(_("Bitte stelle die Dumper-Ladefläche direkt unter das Förderband!", hitElement))
						hitElement.vehicle.gravelLoaded = true
						hitElement.gravelLoaded = true
						source.isBusy = true
						local speed, pos = unpack(source.Track[1])
						local gravel
						setTimer(function(pos, track, player)
							if self.m_GravelStock >= 1 then
								gravel = createObject(2936, pos)
								table.insert(self.m_Gravel, gravel)
								gravel.dumper = true
								gravel.player = player
								self:updateGravelAmount("stock", false)
								self:moveOnTrack(track, gravel, 1, function(gravel)
									gravel.LoadTime = getRealTime().timestamp
									setElementVelocity(gravel, 0, 0, -0.1)
								end
								)
							else
								player:sendError(_("Das Lager ist leer! Es können keine weiteren Steine aufgeladen werden", player))
								if sourceTimer and isTimer(sourceTimer) then killTimer(sourceTimer) end
							end
						end, 1500, 10, pos, source.Track, hitElement)

						setTimer(function(marker)
							marker.isBusy = false
						end, 1500*10, 1, source)
					else
						hitElement:sendError(_("Das Lager ist leer! Bitte bau neues Material ab!", hitElement))
					end
				else
					hitElement:sendError(_("Du hast diesen Dumper bereits beladen, oder deine alte Ladung nicht abgegeben!", hitElement))
				end
			else
				hitElement:sendError(_("Du sitzt in keinem Dumper!", hitElement))
			end
		else
			hitElement:sendError(_("Du musst im Kiesgruben-Job tätig sein!", hitElement))
		end
	end
end

function JobGravel:Event_onDumperDeliver()
	if source.player and source.player == client then
		if not self.m_DumperDeliverStones[client] then self.m_DumperDeliverStones[client] = 0 end
		self.m_DumperDeliverStones[client]= self.m_DumperDeliverStones[client] + 1
		client.vehicle.gravelLoaded = false
		client.gravelLoaded = false
		source:destroy()
		if not self.m_DumperDeliverTimer[client] then
			self.m_DumperDeliverTimer[client] = setTimer(bind(self.giveDumperDeliverLoan, self), 1500, 1, client)
		end
	end
end

function JobGravel:giveDumperDeliverLoan(player)
	local amount = self.m_DumperDeliverStones[player] or 0
	local loan = amount*LOAN_DUMPER
	local duration = getRealTime().timestamp - player.m_LastJobAction
	player.m_LastJobAction = getRealTime().timestamp
	StatisticsLogger:getSingleton():addJobLog(player, "jobGravel.dumper", duration, loan)
	player:addBankMoney(loan, ("Kiesgruben-Job (%d Steine)"):format(amount))
	self:destroyDumperGravel(player)
	self.m_DumperDeliverTimer[player] = nil
	self.m_DumperDeliverStones[player] =  nil
	player:givePoints(math.floor(math.floor(amount/2)*JOB_EXTRA_POINT_FACTOR))
end

JobGravel.Tracks = {
	["Track1"] = {
		[1] = {50, Vector3(676.10, 827.4, -41.2)},
		[2] = {6000, Vector3(641.00, 843.80, -34.4)},
		[3] = {1000, Vector3(640.90, 843.90, -37)},
		[4] = {6000, Vector3(627.5, 881.1, -30.4)},
		[5] = {1000, Vector3(627.5, 882.10, -31.9)},
		[6] = {3000, Vector3(619.50, 886.80, -30.3)},
		[7] = {2000, Vector3(619.20, 886.70, -34.4)}
	},
	["Track2"] = {
		[1] = {50, Vector3(686.90, 847.5, -41.10)},
		[2] = {6000, Vector3(654.20, 866.70, -34.6)},
		[3] = {1000, Vector3(653.80, 866.90, -37)},
		[4] = {6000, Vector3(619.50, 886.80, -30.3)},
		[5] = {2000, Vector3(619.20, 886.70, -34.4)}
	},
	["Dumper1"] = {
		[1] = {50, Vector3(618.5, 894.4, -41.3)},
		[2] = {6000, Vector3(584.5, 914, -34.5)},
		[3] = {2000, Vector3(583.8, 914.1, -37.3)},
		[4] = {6000, Vector3(545.1, 919.8, -30.5)},
		[5] = {2000, Vector3(544.5, 920, -33.1)},

	},
	["Dumper2"] = {
		[1] = {50, Vector3(620.2, 896.4, -41.3)},
		[2] = {6000, Vector3(594.7, 926.6, -34.4)},
		[3] = {2000, Vector3(594.6, 927.0, -37.1)}
	}
}
