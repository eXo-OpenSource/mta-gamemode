-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Singleton)

function Job:constructor()
	
end

function Job:getId()
	return self.m_Id
end

function Job:setId(Id)
	self.m_Id = Id
end

function Job:requireVehicle(player)
	return player:getJob() == self
end

function Job:sendMessage(message, ...)
	for k, player in ipairs(getElementsByType("player")) do
		if player:getJob() == self then
			player:sendMessage(_("[JOB] ", player).._(message, player, ...), 0, 0, 255)
		end
	end
end

Job.start = pure_virtual
