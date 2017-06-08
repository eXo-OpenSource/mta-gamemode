-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu/MouseMenuCompany.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
PlayerMouseMenuCompany = inherit(GUIMouseMenu)

function PlayerMouseMenuCompany:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	if element:getFaction() then
		local faction = element:getFaction()
		local color = faction:getColor()
		self:addItem(("Name: %s (%s)"):format(element:getName(), faction:getShortName())):setTextColor(rgb(color.r, color.g, color.b))
	else
		self:addItem(("Name: %s"):format(element:getName())):setTextColor(Color.Red)
	end
	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	if localPlayer:getCompanyId() == 1 and localPlayer:getPublicSync("Company:Duty") == true then
		if not element:getPublicSync("inDrivingLession") then
			self:addItem(_"Fahrschule: Prüfung starten",
				function()
					if self:getElement() then
						DrivingSchoolChooseLicenseGUI:new(self:getElement())
					end
				end
			)
		else
			self:addItem(_"Fahrschule: Prüfung abbrechen",
				function()
					if self:getElement() then
						triggerServerEvent("drivingSchoolEndLession", localPlayer, self:getElement(), false)
					end
				end
			)
			self:addItem(_"Fahrschule: Schein geben",
				function()
					if self:getElement() then
						triggerServerEvent("drivingSchoolEndLession", localPlayer, self:getElement(), true)
					end
				end
			)
		end
	elseif localPlayer:getCompanyId() == 3 and localPlayer:getPublicSync("Company:Duty") == true then
		if not element:getPublicSync("inInterview") then
			self:addItem(_"San News: Interview starten",
				function()
					if self:getElement() then
						triggerServerEvent("sanNewsStartInterview", localPlayer, self:getElement())
					end
				end
			)
		else
			self:addItem(_"San News: Interview beenden",
				function()
					if self:getElement() then
						triggerServerEvent("sanNewsStopInterview", localPlayer, self:getElement())
					end
				end
			)
		end
	end

	self:adjustWidth()
end
