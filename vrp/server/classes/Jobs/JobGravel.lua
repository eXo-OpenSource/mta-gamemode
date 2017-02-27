-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobGravel.lua
-- *  PURPOSE:     Gravel Job
-- *
-- ****************************************************************************
JobGravel = inherit(Job)

function JobGravel:constructor()
	Job.constructor(self)

	self.m_Jobber = {}
	self.m_Gravel = {}

	self.m_DumpLoadMarker = {
		createMarker(544.3, 919.9, -43, "cylinder", 6, 250, 130, 0, 100),
		createMarker(594.7, 926.3, -43, "cylinder", 6, 250, 130, 0, 100)
	}
	for index, marker in pairs(self.m_DumpLoadMarker) do
		marker.Track = JobGravel.Tracks["Dumper"..index]
		addEventHandler("onMarkerHit", marker, bind(self.onDumperLoadMarkerHit, self))
	end

	addRemoteEvents{"onGravelMine", "gravelStartTrack"}
	addEventHandler("onGravelMine", root, bind(self.Event_onGravelMine, self))
	addEventHandler("gravelStartTrack", root, bind(self.Event_startTrack, self))
end

function JobGravel:start(player)
	player:setPosition(708.87, 836.69, -29.74)
	table.insert(self.m_Jobber, player)
end

function JobGravel:Event_onGravelMine()
	local item = createObject(2936 ,713.96, 837.82, -30.23)
	table.insert(self.m_Gravel, item)
end

function JobGravel:Event_startTrack(track)
	if JobGravel.Tracks[track] then
		self:moveOnTrack(JobGravel.Tracks[track], source, 1, function(gravel) gravel:destroy() end)
	else
		client:sendError("Internal Error: Track not found!")
	end
end

function JobGravel:onDumperLoadMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getJob() == self then
			if hitElement.vehicle and hitElement.vehicle:getModel() == 406 then
				hitElement:sendInfo(_("Bitte stelle die Dumper-Ladefläche direkt unter das Förderband!", hitElement))
				local speed, pos = unpack(source.Track[1])
				local gravel
				setTimer(function(pos, track)
					gravel = createObject(2936, pos)
					table.insert(self.m_Gravel, gravel)

					self:moveOnTrack(track, gravel, 1, function(gravel) local pos = gravel:getPosition() gravel:setPosition(pos.x, pos.y, pos.z-0.01) end)
				end, 1500, 8, pos, source.Track)
			else
				hitElement:sendError(_("Du sitzt in keinem Dumper!", hitElement))
			end
		else
			hitElement:sendError(_("Du musst ihm Kiesgruben Job tätig sein!", hitElement))
		end
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

JobGravel.Tracks = {
	["Track1"] = {
		[1] = {2000, Vector3(676.10, 827.4, -41.2)},
		[2] = {6000, Vector3(641.00, 843.80, -34.4)},
		[3] = {1000, Vector3(640.90, 843.90, -37)},
		[4] = {6000, Vector3(627.5, 881.1, -30.4)},
		[5] = {1000, Vector3(627.5, 882.10, -31.9)},
		[6] = {3000, Vector3(619.50, 886.80, -30.3)},
		[7] = {2000, Vector3(619.20, 886.70, -34.4)}
	},
	["Track2"] = {
		[1] = {2000, Vector3(686.90, 847.5, -41.10)},
		[2] = {6000, Vector3(654.20, 866.70, -34.6)},
		[3] = {1000, Vector3(653.80, 866.90, -37)},
		[4] = {6000, Vector3(619.50, 886.80, -30.3)},
		[5] = {2000, Vector3(619.20, 886.70, -34.4)}
	},
	["Dumper1"] = {
		[1] = {2000, Vector3(618.5, 894.4, -41.3)},
		[2] = {6000, Vector3(584.5, 914, -34.5)},
		[3] = {2000, Vector3(583.8, 914.1, -37.3)},
		[4] = {6000, Vector3(545.1, 919.8, -30.5)},
		[5] = {2000, Vector3(544.5, 920, -33.1)},

	},
	["Dumper2"] = {
		[1] = {2000, Vector3(620.2, 896.4, -41.3)},
		[2] = {6000, Vector3(594.7, 926.6, -34.4)},
		[3] = {2000, Vector3(594.6, 927.0, -37.1)}
	}
}
