-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ArmsDealer.lua
-- *  PURPOSE:     Arms Dealer class
-- *
-- ****************************************************************************
ArmsDealer = inherit(Singleton)

ArmsDealer.Data = 
{
    ["Waffen"] = AmmuNationInfo,
    ["Spezial"] = 
    {
        ["Gasmaske"] = {50, 50000},
        ["Gasgranate"] = {6, 50000},
        ["Rauchgranate"] = {3, 100000},
        ["Scharfschützengewehr"] = {5, 60000}
    },
    ["Explosiv"] = 
    {
        ["RPG-7"] = {5, 300000},
        ["Granate"] = {10, 80000},
    }
}
addRemoteEvents{"requestArmsDealerInfo"}
function ArmsDealer:constructor()
    addEventHandler("requestArmsDealerInfo", root, bind(self.sendInfo, self))
end

function ArmsDealer:sendInfo()
    if client.getFaction and client:getFaction() and client:getFaction():isEvilFaction() then
        local faction = client:getFaction()
        local depot = faction.m_Depot
        client:triggerEvent("updateArmsDealerInfo", ArmsDealer.Data, faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable(id) )
    end
end

function ArmsDealer:destructor()

end