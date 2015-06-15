AmmuTeam = inherit(Object)

function AmmuTeam:constructor(id,name,rating,kind,members,founder)
	self.m_Id = id
	self.m_Name = name
	self.m_Rating = rating
	self.m_Arena = false
	self.m_Kind = kind
	self.m_Members = members
	self.m_Founder = founder
	self.m_Request = false
	self.m_QueueActive = false
end

-- short get-funcs

function AmmuTeam:getId() return self.m_Id end
function AmmuTeam:getKind() return self.m_Kind end
function AmmuTeam:getRating() return self.m_Rating end
function AmmuTeam:getName() return self.m_Name end
function AmmuTeam:getMembers() return self.m_Members end
function AmmuTeam:getStatus() return self.m_Request end
function AmmuTeam:getQueueStatus() return self.m_QueueActive end
function AmmuTeam:getArena() return self.m_Arena end

--

function AmmuTeam:setRequestStatus (status) self.m_Request = status end
function AmmuTeam:setQueueStatus (status) self.m_QueueActive = status end
function AmmuTeam:setArena(arena) self.m_Arena = arena end

function AmmuTeam:addMember(player)
	if player:setTeamId(self.m_Kind,self.m_Id) then
		table.insert(self.m_Members,player:getId())
	end
end

function AmmuTeam:countMembers()
	local count = 0
	for key, value in ipairs(self.m_Members) do
		if isElement(Player.getFromId(value)) then
			count = count + 1
		end
	end
	return count, count == AmmuLadder.Settings[self:getKind()].MAX_PER_TEAM
end

function AmmuTeam:setRating(new)
	self.m_Rating = new
end

function AmmuTeam:giveRating(add)
	self.m_Rating = self.m_Rating + add
end
