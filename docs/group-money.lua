restoredAmount = 0
groupIds = {}

calculateMoneyOfGroup = function(id, cb)
    sqlLogs:queryFetch(function(result)
        if #result > 0 then
            cb(result[1]["Money"])
        end
        cb(false)
    end, "SELECT ((SELECT SUM(Amount) FROM vrpLogs_MoneyNew WHERE ToId = ? AND ToType = 8) - (SELECT SUM(Amount) FROM vrpLogs_MoneyNew WHERE FromId = ? AND FromType = 8)) AS Money", id, id)
end

restoreGroupMoney = function(id)
    if GroupManager:getSingleton().Map[id] then
        local grp = GroupManager:getSingleton().Map[id]
        calculateMoneyOfGroup(id, function(sMoney)
            if sMoney then
                local curMoney = grp.m_BankAccount:getMoney()
                local diff = sMoney - curMoney
                if diff ~= 0 then
                    restoredAmount = restoredAmount + diff
                    grp.m_BankAccount.m_Money = sMoney
                    grp.m_BankAccount:save()
                    grp:sendShortMessage(diff.."$ wiederhergestellt!")
                    outputDebugString("Restored "..diff.."$ for group with id " .. id)
                end
            end
        end)
    end
end

restoreAll = function()
    local first = table.remove(groupIds, 1)
    if first then
        restoreGroupMoney(first)
        setTimer(restoreAll, 250, 1)
    else
        outputDebugString("fix done")
    end
end

getListOfGroupIds = function()
    for k, v in pairs(GroupManager:getSingleton().Map) do
        table.insert(groupIds, v.m_Id)
    end
end
