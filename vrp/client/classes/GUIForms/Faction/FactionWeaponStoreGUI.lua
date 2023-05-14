-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWeaponStoreGUI.lua
-- *  PURPOSE:     Faction Weapon Store GUI class
-- *
-- ****************************************************************************
FactionWeaponStoreGUI = inherit(GUIForm)
inherit(Singleton, FactionWeaponStoreGUI)

addRemoteEvents{"showPlayerWeapons"}
function FactionWeaponStoreGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 13) 
	self.m_Height = grid("y", 11) 

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, localPlayer.position)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffen einlagern", true, true, self)

    self.m_Marked = {}
	
	self.m_StoreWeaponButton = GUIGridButton:new(1, 10, 6, 1, "Einlagern", self.m_Window)
    self.m_StoreWeaponButton.onLeftClick = bind(self.onWeaponStore, self)
	self.m_StoreAllWeaponButton = GUIGridButton:new(7, 10, 6, 1, "Alle Einlagern", self.m_Window)
    self.m_StoreAllWeaponButton.onLeftClick = bind(self.onAllWeaponStore, self)

    triggerServerEvent("requestPlayerWeapons", localPlayer)
    addEventHandler("showPlayerWeapons", localPlayer, bind(self.updateList, self))
end

function FactionWeaponStoreGUI:updateList(weapons)
    if self.m_WeaponStoreGrid then delete(self.m_WeaponStoreGrid) end

	self.m_WeaponStoreGrid = GUIGridGridList:new(1,1, 12, 9, self.m_Window)
    self.m_WeaponStoreGrid:addColumn(_"✘", 0.1)
    self.m_WeaponStoreGrid:addColumn(_"Waffe", 0.6)
    self.m_WeaponStoreGrid:addColumn(_"Munition", 0.3)
    for wpn, ammo in pairs(weapons) do
        if wpn ~= 23 then
            local item = self.m_WeaponStoreGrid:addItem("", WEAPON_NAMES[wpn], ammo)
            item.weaponId = wpn
            item.onLeftDoubleClick = function() self:onSelectItem(item) end
        end
    end
end

function FactionWeaponStoreGUI:onSelectItem(item)
    if self.m_Marked[item.weaponId] then
        item:setColumnText(1, "")
        self.m_Marked[item.weaponId] = nil
    else 
        item:setColumnText(1, "✘")
        self.m_Marked[item.weaponId] = true
    end
end

function FactionWeaponStoreGUI:onWeaponStore()
    if table.size(self.m_Marked) == 0 then return end
    
    triggerServerEvent("factionStorageSelectedWeapons", localPlayer, self.m_Marked)
    triggerServerEvent("requestPlayerWeapons", localPlayer)
end

function FactionWeaponStoreGUI:onAllWeaponStore()
    if #getPedWeapons(localPlayer) == 0 then return end

    if localPlayer:getFaction():isStateFaction() then
        triggerServerEvent("factionStateStorageWeapons", localPlayer)
    elseif localPlayer:getFaction():isEvilFaction() then
        triggerServerEvent("factionEvilStorageWeapons", localPlayer)
    end
    triggerServerEvent("requestPlayerWeapons", localPlayer)
end

