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
		self:moveOnTrack(JobGravel.Tracks[track], source, 1)
	else
		client:sendError("Internal Error: Track not found!")
	end
end

function JobGravel:moveOnTrack(track, gravel, step)
	if track and track[step] then
		local speed, pos = unpack(track[step])
		gravel:move(speed, pos)
		setTimer(function()
			if track[step+1] then
				self:moveOnTrack(track, gravel, step+1)
			else
				gravel:destroy()
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
	}
}
