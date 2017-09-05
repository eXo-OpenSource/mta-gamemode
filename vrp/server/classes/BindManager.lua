-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BindManager.lua
-- *  PURPOSE:     Responsible for managing binds
-- *
-- ****************************************************************************
BindManager = inherit(Singleton)

function BindManager:constructor()
    self:loadBinds()

	addRemoteEvents{"bindTrigger"}
    addEventHandler("bindTrigger", root, bind(self.Event_OnBindTrigger, self))
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
    for k, row in ipairs(result) do

	end
end
