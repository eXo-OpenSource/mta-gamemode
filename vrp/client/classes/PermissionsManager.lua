-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/PermissionsManager.lua
-- *  PURPOSE:     PermissionsManager class
-- *
-- ****************************************************************************

PermissionsManager = inherit(Singleton)

addRemoteEvents{"recievePermissions"}
function PermissionsManager:constructor()
	self.m_Types = {["faction"] = 1, ["company"] = 2, ["group"] = 3}
	self.m_LeaderRank = {["faction"] = 6, ["company"] = 5, ["group"] = 6}

    triggerServerEvent("syncPermissions", localPlayer, localPlayer, "all")

    addEventHandler("recievePermissions", localPlayer, bind(self.Event_recievePermissions, self))
end

function PermissionsManager:Event_recievePermissions(perms)
    if table.size(perms) == 0 then return end
    for type, data in pairs(perms) do
        localPlayer.m_RankPermissions[type] = {} 
        localPlayer.m_PlayerPermissions[type] = {}
        localPlayer.m_PlayerActionPermissions[type] = {}
        localPlayer.m_PlayerWeaponPermissions[type] = {}

        localPlayer.m_RankPermissions[type]["permission"] = data["permission"]
        localPlayer.m_PlayerPermissions[type] = data["playerPermission"]

        if type == "faction" then
            localPlayer.m_RankPermissions[type]["action"] = data["action"]
            localPlayer.m_RankPermissions[type]["weapon"] = data["weapon"]
            localPlayer.m_PlayerActionPermissions[type] = data["playerAction"]
            localPlayer.m_PlayerWeaponPermissions[type] = data["playerWeapon"]
        end
    end
end

function PermissionsManager:hasPlayerPermissionsTo(type, permission)
    local rank = self:getRank(type)

    if rank then
        if localPlayer.m_PlayerPermissions[type][permission] == true then
            return true
        elseif localPlayer.m_PlayerPermissions[type][permission] == false then
            return false
        elseif localPlayer.m_RankPermissions[type]["permission"][tostring(rank)][permission] == true then
            return true
        end
    end

    return false
end

function PermissionsManager:isPlayerAllowedToStart(type, action)
    local rank = self:getRank(type)

    if rank then
        if self:hasPlayerPermissionsTo(type, "changePermissions") then
            return true 
        elseif localPlayer.m_PlayerActionPermissions[type][action] == true then
            return true
        elseif localPlayer.m_PlayerActionPermissions[type][action] == false then
            return false
        elseif localPlayer.m_RankPermissions[type]["action"][tostring(rank)][permission] == true then
            return true
        end
    end

    return false
end

function PermissionsManager:getPermissions(permissionsType, type)
	local temp = {}
    local id = self:getId(type)

    for permission, info in pairs(permissionsType == "permission" and PERMISSIONS_INFO or ACTION_PERMISSIONS_INFO) do
        if info[1][1] == 0 or (info[1][1] == self.m_Types[type] and table.find(info[1][2], id)) then
            if info[2][type] then
                temp[permission] = permissionsType == "permission" and PERMISSION_NAMES[permission] or ACTION_PERMISSION_NAMES[permission]
            end
        end
    end

	return temp 
end

function PermissionsManager:getId(type)
    local id = false
    if type == "faction" then
        id = localPlayer:getFactionId()
    elseif type == "company" then
        id = localPlayer:getCompanyId()
    elseif type == "group" then
        id = localPlayer:getGroupId()
    end
    return id
end

function PermissionsManager:getRank(type)
    local rank = false
    if type == "faction" then
        rank = localPlayer:getPublicSync("FactionRank")
    elseif type == "company" then
        rank = localPlayer:getPublicSync("CompanyRank")
    elseif type == "group" then
        rank = localPlayer:getPublicSync("GroupRank")
        
    end
    return rank
end