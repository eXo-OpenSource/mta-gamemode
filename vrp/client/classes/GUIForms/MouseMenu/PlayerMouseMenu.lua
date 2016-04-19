-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu class
-- *
-- ****************************************************************************
PlayerMouseMenu = inherit(GUIMouseMenu)

function PlayerMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self:addItem("Name: "..getPlayerName(element)):setTextColor(Color.Red)

	self:addItem(_"Geld geben",
		function()
			if self:getElement() then
				SendMoneyGUI:new(function(amount) triggerServerEvent("playerSendMoney", self:getElement(), amount) end)
			end
		end
	)
	self:addItem(_"Handel starten",
		function()
			if self:getElement() then
				TradeGUI:new(self:getElement())
			end
		end
	)
	self:addItem(_"Schere-Stein-Papier spielen",
		function()
			if self:getElement() then
				triggerServerEvent("rockPaperScissorsQuestion", localPlayer, self:getElement())
			end
		end
	)
	if localPlayer:getFactionId() == 4 and localPlayer:getPublicSync("Faction:Duty") == true then
		self:addItem(_"Medic: heilen",
			function()
				if self:getElement() then
					triggerServerEvent("factionRescueHealPlayerQuestion", localPlayer, self:getElement())
				end
			end
		)
	end
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

	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Admin: Kick",
			function()
				outputChatBox("Not implemented yet")
				--[[if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end]]
			end
		)
	end
end
