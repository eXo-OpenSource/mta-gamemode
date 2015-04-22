AmmuTeam = inherit(Object)

function AmmuTeam:constructor(id,name,rating,kind,members,founder)
	self.m_Id = id
	self.m_Name = name
	self.m_Rating = rating
	self.m_Kind = kind
	self.m_Members = members
	self.m_Founder = founder
	
	print(self.m_Kind,"team created")
end

-- short get-funcs

function AmmuTeam:getKind() return self.m_Kind end 
function AmmuTeam:getRating() return self.m_Rating end
function AmmuTeam:getName() return self.m_Name end
function AmmuTeam:getMembers() return self.m_Members end

--

function AmmuTeam:addMember(player)
	if player:setTeamId(self.m_Kind,self.m_Id) then
		table.insert(self.m_Members,player:getId())
	end
end

function AmmuTeam:setRating(new)
	self.m_Rating = new
end

function AmmuTeam:giveRating(add)
	self.m_Rating = self.m_Rating + add
end

function AmmuTeam:getRating() return self.m_Ratinge end