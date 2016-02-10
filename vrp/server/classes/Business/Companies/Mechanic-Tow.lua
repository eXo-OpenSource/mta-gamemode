MechanicTow = inherit(Company)

function MechanicTow:constructor()
	outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
	self.m_PlayerJobIds = {}
end

function MechanicTow:destuctor()

end

function MechanicTow:start(player)
	self.m_PlayerJobIds[player] = player:getJob() and player:getJob():getId() or false

	-- Set MechanicJob for the player
	local job = JobManager:getSingleton():getFromId(6)
	if job then
		player:setJob(job)
	end
end

function MechanicTow:stop(player)
	-- Stop MechanicJob for the player
	if self.m_PlayerJobIds[player] then
		local job = JobManager:getSingleton():getFromId(self.m_PlayerJobIds[player])
		if job then
			outputDebug(job:getId())
			self.m_PlayerJobIds[player] = nil
			player:setJob(job)
			return
		end
	end

	player:setJob(nil)
	self.m_PlayerJobIds[player] = nil
end
