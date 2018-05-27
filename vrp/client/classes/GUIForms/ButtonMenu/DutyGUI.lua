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
	self.m_Window:setTitleBarText(fac:getShortName().." Duty-Menü")
	self:addItem(_"Dienst beenden", Color.Green):setBarEnabled(false)
end

function DutyGUI:loadCompanyItems(cmp, isOnDuty)
    self.m_Window:setTitleBarText(cmp:getShortName().." Duty-Menü")
    
    if isOnDuty then
        self:addItem(_"Dienst beenden", Color.Red,
            function()
                triggerServerEvent("companyToggleDuty", localPlayer)
            end
        ):setBarEnabled(false)
        self:addItem(_"Kleidung wechseln", Color.Accent, 
            function()
                triggerServerEvent("companyRequestSkinSelection", localPlayer)
            end
        )
    else
        self:addItem(_"In den Dienst gehen",Color.Green ,
            function()
                triggerServerEvent("companyToggleDuty", localPlayer)
            end
        ):setBarEnabled(false)
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