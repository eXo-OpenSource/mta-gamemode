-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskMove.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskMove = inherit(Task)

function TaskMove:constructor(actor, actorSyncer, targetPosition)
	self.m_Actor = actor
	self.m_TargetPosition = targetPosition
	self:setSyncer(actorSyncer)
end

function TaskMove:destructor()

end

function TaskMove:getId()
    return Tasks.TASK_MOVE
end

function TaskMove:hasClientScript()
    return true
end

function TaskMove:getClientParameter()
    return {self.m_Syncer, serialiseVector(self.m_TargetPosition)}
end

function TaskMove:setSyncer(syncer)
	self.m_Syncer = syncer

	addEventHandler("onPlayerWasted", self.m_Syncer,
		function()
			self:findNewSyncer()
		end
	)
	addEventHandler("onPlayerQuit", self.m_Syncer,
		function()
			self:findNewSyncer()
		end
	)
end

function TaskMove:findNewSyncer()
	local MAX_DIST = 100
	local nearest = {ele = false, dist = math.huge}
	for i, v in pairs(getElementsByType("player")) do
		local dist = (v:getPosition() - self.m_Actor:getPosition()).length
		if (dist < nearest.dist) and dist <= MAX_DIST then
			nearest = {ele = v, dist = dist}
		end
	end

	if nearest.ele then
		self:setSyncer(nearest.ele)
	else
		outputDebug("no good syncer foud! destroying..")
		self.m_Actor:destroy()
	end
end

function TaskMove:isSyncer(player)
	return self.m_Syncer == player
end


addEvent("someEVENT", true)
addEventHandler("someEVENT", root,
    function()
        if not instanceof(source, Actor) then
            return
        end
    end
)
