-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PublicTransportTaxiGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
PublicTransportTaxiGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showPublicTransportTaxiGUI"}

function PublicTransportTaxiGUI:constructor(driver, player)
	GUIButtonMenu.constructor(self, "eXo Public Transport")
	if driver then
		self:addItem(_"Taxometer aktivieren",Color.Green ,
			function()
				triggerServerEvent("publicTransportStartTaxi", localPlayer, player, true)
				self:delete()
			end
		)
		self:addItem(_("%s gratis transportieren", player.name),Color.Green ,
			function()
				triggerServerEvent("publicTransportStartTaxi", localPlayer, player)
				self:delete()
			end
		)
	else
		self:addItem(_"Ziel auf Karte markieren",Color.Green ,
			function()
				if MapGUI:isInstantiated() then
					delete(MapGUI:getSingleton())
				else
					MapGUI:getSingleton(
						function(posX, posY, posZ)
							triggerServerEvent("publicTransportSetTargetMap", localPlayer, posX, posY)
						end
					)
				end
				self:delete()
			end
		)
		self:addItem(_"Ziel dem Fahrer mitteilen",Color.Green ,
			function()
				triggerServerEvent("publicTransportSetTargetTell", localPlayer)
				self:delete()
			end
		)
	end
end

addEventHandler("showPublicTransportTaxiGUI", root,
	function(...)
		PublicTransportTaxiGUI:new(...)
	end
)
