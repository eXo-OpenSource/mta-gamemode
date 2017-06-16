-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangAreaManager.lua
-- *  PURPOSE:     Gangarea manager class
-- *
-- ****************************************************************************
GangAreaManager = inherit(Singleton)
local RESOURCES_DISTRIBUTE_INTERVAL = 15*60*1000

function GangAreaManager:constructor()
	self.m_Map = {}
	local st, count = getTickCount(), 0
	for i, info in ipairs(GangAreaData) do
		self.m_Map[i] = GangArea:new(i, info.areaPosition, info.width, info.height, info.resources or DEFAULT_GANGAREA_RESOURCES)
		count = count + 1
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s gang-areas in %sms"):format(count, getTickCount()-st)) end

	addRemoteEvents{"gangAreaTagSprayed"}
	addEventHandler("gangAreaTagSprayed", root, bind(self.Event_gangAreaTagSprayed, self))

	addEventHandler("onPlayerQuit", root,
		function()
			for k, area in pairs(self.m_Map) do
				area:removeTurfingPlayer(source)
			end
		end
	)

	-- Start the timer that produces and distributes the resources
	setTimer(bind(self.distributeResources, self), RESOURCES_DISTRIBUTE_INTERVAL, 0)
end

function GangAreaManager:destructor()
	for k, gangArea in pairs(self.m_Map) do
		delete(gangArea)
	end
end

function GangAreaManager:distributeResources()
	for k, gangArea in pairs(self.m_Map) do
		gangArea:distributeResources()
	end
end

function GangAreaManager:freeAreas(group)
	for k, area in pairs(self.m_Map) do
		if area:getOwnerGroup() == group then
			area:setOwner(nil)
		end
	end
end

function GangAreaManager:Event_gangAreaTagSprayed(Id)
	local gangArea = self.m_Map[Id]
	if gangArea then
		local clientGroup = client:getGroup()
		local ownerGroup = gangArea:getOwnerGroup()
		if not clientGroup then
			return
		end

		if clientGroup ~= ownerGroup then
			if not gangArea:isTurfingInProgress() then
				--[[if #clientGroup:getOnlinePlayers() < 3 then -- Todo: Add this as soon as it is finished
					client:sendError(_("Es müssen mindestens 3 Mitglieder deiner Gang online sein, um dieses Gebiet zu erobern", client))
					return
				end]]

				--[[if ownerGroup and #ownerGroup:getOnlinePlayers() < 2 then -- Todo: Change this back to 3
					client:sendError(_("Es müssen mindestens 3 Mitglieder der gegnerischen Gang online sein!", client))
					return
				end]]

				if not gangArea:canBeTurfed() then
					client:sendError(_("Dieses Gebiet kann derzeit nicht erobert werden. Versuche es in ein paar Stunden wieder!", client))
					return
				end

				if gangArea:startTurfing(clientGroup) then
					client:sendInfo(_("Der Gangwar wurde gestartet! Halte nun bis zur Neutralisierung im Gebiet durch!", client))
				else
					client:sendError(_("Fehler beim Starten des Gangwars. Bitte kontaktiere einen Admin", client))
				end
			else
				-- Change turfing direction back to attacking
				gangArea:setTurfingDirection(true)
			end
		else
			-- Change turfing direction to defending
			gangArea:setTurfingDirection(false)
		end
	end
end

--[[

Anforderungen:
- Turfing starten durch Spray (funktioniert nur, wenn andere Gang online ist) [DONE]
- nach vollständigem Übersprühen wird Timer (5-8min) gestartet [DONE]
- wenn Angreifer nicht vertrieben wird --> Besitzer wechseln [DONE]
- wird Angreifer vertrieben --> Gebiet erfolgreich verteidigt --> Timer stoppen [DONE]
- nach Start kann verteidigende Gang wieder übersprühen --> Progress geht in andere Richtung bis erfolgreich verteidigt [DONE]
- wenn Verteidiger in die Flucht geschlagen wird --> wieder andersherum bis voll [DONE]

]]
