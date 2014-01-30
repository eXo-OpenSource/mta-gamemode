-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GroupManager = inherit(Singleton)
GroupManager.Map = {}

function GroupManager:constructor()
	local result = sql:queryFetch("SELECT Id, Name FROM ??_groups", sql:getPrefix())
	for k, row in ipairs(result) do
		local group = Group:new(row.Id, row.Name, row.Money)
		GroupManager.Map[row.Id] = group
	end
end

function GroupManager:destructor()
	for k, v in pairs(GroupManager.Map) do
		delete(v)
	end
end

function GroupManager:getFromId(Id)
	return GroupManager.Map[Id]
end

function GroupManager:addRef(ref)
	GroupManager.Map[ref:getId()] = ref
end

function GroupManager:removeRef(ref)
	GroupManager.Map[ref:getId()] = nil
end
