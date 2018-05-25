-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Storage/UserGroupSettings.lua
-- * PURPOSE: Group class
-- *
-- ****************************************************************************
UserGroupSettings = inherit(Object)
UserGroupSettings.ms_UpdateTypes = {
    Insert = -1,
    Delete = -2
}

function UserGroupSettings:constructor(groupType, groupId)
    assert(tonumber(groupType), "bad group type (not a number)")
    assert(tonumber(groupId), "bad group id (not a number)")
    self.m_GroupType = tonumber(groupType)
    self.m_GroupId = tonumber(groupId)

    self.m_Settings = {}
    local result = sql:queryFetch("SELECT * FROM ??_user_group_settings WHERE GroupType = ? AND GroupId = ?;", sql:getPrefix(), self.m_GroupType, self.m_GroupId)
    for i, row in pairs(result) do
        if not self.m_Settings[row.Category] then self.m_Settings[row.Category] = {} end
		self.m_Settings[row.Category][row.Key] = {row.Value, row.Id, false, row.Value} -- current value
	end
end

function UserGroupSettings:save()
    for category, settings in pairs(self.m_Settings) do
        for key, data in pairs(settings) do
            local value, id, changed = unpack(data)
            if id == UserGroupSettings.ms_UpdateTypes.Insert then --new setting
                sql:queryExec("INSERT INTO ??_user_group_settings (GroupType, GroupId, Category, `Key`, Value) VALUES (?, ?, ?, ?, ?);", sql:getPrefix(), self.m_GroupType, self.m_GroupId, category, key, value)
            elseif value == nil then -- delete garbage
                sql:queryExec("DELETE FROM ??_user_group_settings WHERE Id = ?;", sql:getPrefix(), id)
            else --update
                if changed then
                    sql:queryExec("UPDATE ??_user_group_settings SET Value = ? WHERE Id = ?;", sql:getPrefix(), tostring(value), id)
                end
            end
        end
    end
end


function UserGroupSettings:setSetting(category, key, value)
    local category, key = tostring(category), tostring(key)
    if self.m_Settings[category] and self.m_Settings[category][key] ~= nil then -- update row
        self.m_Settings[category][key][1] = value
        self.m_Settings[category][key][3] = (self.m_Settings[category][key][4] ~= value)
    else -- create new row
        if not self.m_Settings[category] then self.m_Settings[category] = {} end
        self.m_Settings[category][key] = {value, UserGroupSettings.ms_UpdateTypes.Insert}
    end
end

function UserGroupSettings:getSetting(category, key, default)
    local category, key = tostring(category), tostring(key)
    if not self.m_Settings[category] then return default end
    return self.m_Settings[category][key] and self.m_Settings[category][key][1] or default 
end

function UserGroupSettings:restoreDefaults()
    self.m_Settings = {}
    sql:queryExec("DELETE FROM ??_user_group_settings WHERE GroupType = ? AND GroupId = ?;", sql:getPrefix(), self.m_GroupType, self.m_GroupId)
end