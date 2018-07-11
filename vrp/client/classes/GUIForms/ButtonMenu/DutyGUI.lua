DutyGUI = inherit(GUIButtonMenu)
inherit(Singleton, DutyGUI)
addRemoteEvents{"showDutyGUI"}

function DutyGUI:constructor(isFaction, id, isOnDuty)
	GUIButtonMenu.constructor(self, "Duty-Menü")
	
	if isFaction then
		local fac = FactionManager.Map[id]
		if fac then
			self:loadFactionItems(fac, isOnDuty)
		end
	else -- company
		local cmp = CompanyManager.Map[id]
		if cmp then
			self:loadCompanyItems(cmp, isOnDuty)
		end
	end
end

function DutyGUI:loadFactionItems(fac, isOnDuty)
    self.m_Window:setTitleBarText(fac:getShortName().."-Basis")
    
    if isOnDuty then
        if fac:isStateFaction() then
            self:addItem(_"Dienst beenden", Color.Red, bind(self.itemEvent, self, "factionStateToggleDuty")):setBarEnabled(false)
            self:addItem(_"Kleidung wechseln", Color.Accent, bind(self.itemEvent, self, "factionRequestSkinSelection"))
            self:addItem(_"Ausrüsten", Color.Accent, bind(self.itemEvent, self, "factionStateRearm"))
            self:addItem(_"Waffen einlagern", Color.Accent, bind(self.itemEvent, self, "factionStateStorageWeapons"))
        elseif fac:isEvilFaction() then
            self:addItem(_"Dienst beenden", Color.Red, bind(self.itemEvent, self, "factionEvilToggleDuty")):setBarEnabled(false)
            self:addItem(_"Kleidung wechseln", Color.Accent, bind(self.itemEvent, self, "factionRequestSkinSelection"))
            self:addItem(_"Ausrüsten", Color.Accent, bind(self.itemEvent, self, "factionEvilRearm"))
            self:addItem(_"Waffen einlagern", Color.Accent, bind(self.itemEvent, self, "factionEvilStorageWeapons"))
        else
            self:addItem(_"Dienst beenden", Color.Red, bind(self.itemEvent, self, "factionRescueToggleDuty")):setBarEnabled(false)
            self:addItem(_"Kleidung wechseln", Color.Accent, bind(self.itemEvent, self, "factionRequestSkinSelection"))
        end
    else
        if fac:isStateFaction() then
            self:addItem(_"In Dienst gehen", Color.Green, bind(self.itemEvent, self, "factionStateToggleDuty", false, core:get("Cache", "LastFactionSkin"))):setBarEnabled(false)
        elseif fac:isEvilFaction() then
            self:addItem(_"In Dienst gehen", Color.Green, bind(self.itemEvent, self, "factionEvilToggleDuty", core:get("Cache", "LastFactionSkin"))):setBarEnabled(false)
        else -- Rescue Team 4ever alone
            self:addItem(_"In Sanitäter-Dienst gehen", Color.Green, bind(self.itemEvent, self, "factionRescueToggleDuty", "medic", false, core:get("Cache", "LastFactionSkin")))
            self:addItem(_"In Feuerwehr-Dienst gehen", Color.Green, bind(self.itemEvent, self, "factionRescueToggleDuty", "fire", false, core:get("Cache", "LastFactionSkin")))
        end
    end
end

function DutyGUI:loadCompanyItems(cmp, isOnDuty)
    self.m_Window:setTitleBarText(cmp:getShortName().." HQ")
    
    if isOnDuty then
        self:addItem(_"Dienst beenden", Color.Red, bind(self.itemEvent, self, "companyToggleDuty"))
                :setBarEnabled(false)
        self:addItem(_"Kleidung wechseln", Color.Accent, bind(self.itemEvent, self, "companyRequestSkinSelection"))
    else
        self:addItem(_"In den Dienst gehen", Color.Green, bind(self.itemEvent, self, "companyToggleDuty", false, core:get("Cache", "LastCompanySkin")))
                :setBarEnabled(false)
    end
end

function DutyGUI:itemEvent(eventName, arg1, arg2)
    if type(arg1) ~= "table" then -- prevent triggering whole class instances 
        outputDebug(type(arg1), arg1)
        triggerServerEvent(eventName, localPlayer, arg1, arg2)
    else
        triggerServerEvent(eventName, localPlayer)
    end
end

function DutyGUI:destructor()
	GUIForm.destructor(self)
end


function DutyGUI.open(isFaction, id, isOnDuty)
	if DutyGUI:isInstantiated() then
		delete(DutyGUI:getSingleton())
	end
	DutyGUI:new(isFaction, id, isOnDuty)
end
addEventHandler("showDutyGUI", root, DutyGUI.open)