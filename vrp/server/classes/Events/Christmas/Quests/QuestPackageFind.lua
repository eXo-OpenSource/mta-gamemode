QuestPackageFind = inherit(Quest)
QuestPackageFind.Target = 5

function QuestPackageFind:constructor(id)
	Quest.constructor(self, id)
	self.m_Objects = {}

	nextframe(function()
		self:reload()
	end)

end

function QuestPackageFind:destructor(id)
	Quest.destructor(self)
	killTimer(self.m_Timer)
	for id, object in pairs(self.m_Objects) do
		if isElement(object) then
			object:destroy()
			self.m_Objects[id] = nil
		else
			self.m_Objects[id] = nil
		end
	end
end

function QuestPackageFind:addPlayer(player)
	Quest.addPlayer(self, player)
	player.packagesFound = 0

end

function QuestPackageFind:removePlayer(player)
	Quest.removePlayer(self, player)
	player.packagesFound = nil
end


function QuestPackageFind:reload()
	for id, object in pairs(self.m_Objects) do
		if isElement(object) then
			object:destroy()
			self.m_Objects[id] = nil
		else
			self.m_Objects[id] = nil
		end
	end
	self.m_Objects = {}

   	local result = sql:queryFetch("SELECT * FROM ??_word_objects WHERE Typ = 'Osterei';", sql:getPrefix())
	for i, row in pairs(result) do
		if chance(10) then
			self:addObject(row.Id, Vector3(row.PosX, row.PosY, row.PosZ))
		end
	end

	triggerClientEvent(root, "questPackagesFindRefreshPackages", root, false)

	local time = math.random(15, 100)*60*1000
	self.m_Timer = setTimer(bind(self.reload, self), time, 1)
end

function QuestPackageFind:addObject(Id, pos)
	pos.z = pos.z+0.5
	self.m_Objects[Id] = createObject(3878, pos)
	self.m_Objects[Id]:setAlpha(0)
	self.m_Objects[Id].Id = Id
    self.m_Objects[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Objects[Id], bind(self.onPackageClick, self))
	return self.m_Objects[Id]
end

function QuestPackageFind:onPackageClick(button, state, player)
	if button == "left" and state == "down" then
		if table.find(self:getPlayers(), player) then
			self.m_Objects[source.Id] = nil
			source:destroy()
			player.packagesFound = player.packagesFound + 1
			player:sendInfo(_("Du hast %d/%d Päckchen gefunden!", player, player.packagesFound, QuestPackageFind.Target))
			if player.packagesFound >= QuestPackageFind.Target then
				self:success(player)
			end
		else
			player:sendError("Dafür musst du erst den Quest annehmen!")
		end
	end
end



