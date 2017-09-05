-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BindManager.lua
-- *  PURPOSE:     Responsible for managing binds
-- *
-- ****************************************************************************
BindManager = inherit(Singleton)

function BindManager:constructor()
    self.m_Binds = {}
	self.m_BindsPerOwner = {}
	self:loadBinds()

	addRemoteEvents{"bindTrigger", "bindRequestPerOwner"}
    addEventHandler("bindTrigger", root, bind(self.Event_OnBindTrigger, self))
    addEventHandler("bindRequestPerOwner", root, bind(self.Event_requestBindsPerOwner, self))
end

function BindManager:Event_OnBindTrigger(name, parameters)

    if name == "say" then
        PlayerManager:getSingleton():playerChat(parameters, 0, client)
    else
        executeCommandHandler(name, client, parameters)
     end
end

function BindManager:loadBinds()
	local result = sql:queryFetch("SELECT * FROM ??_binds", sql:getPrefix())
    local i = 0
	for k, row in ipairs(result) do
		self.m_Binds[row.Id] = {
			["Func"] = row.Func,
			["Message"] = row.Message
		}
		if not self.m_BindsPerOwner[row.OwnerType] then self.m_BindsPerOwner[row.OwnerType] = {} end
		if not self.m_BindsPerOwner[row.OwnerType][row.Owner] then self.m_BindsPerOwner[row.OwnerType][row.Owner] = {} end
		self.m_BindsPerOwner[row.OwnerType][row.Owner][row.Id] = self.m_Binds[row.Id]
	end
	outputDebugString(i.." Server-Binds geladen!")
end

function BindManager:Event_requestBindsPerOwner(ownerType, ownerId)
	client:triggerEvent("bindReceive", self.m_BindsPerOwner[ownerType][ownerId])
end
