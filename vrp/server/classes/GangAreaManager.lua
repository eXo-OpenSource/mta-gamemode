-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangAreaManager.lua
-- *  PURPOSE:     Gangarea manager class
-- *
-- ****************************************************************************
GangAreaManager = inherit(Singleton)

function GangAreaManager:constructor()
	self.m_Map = {}
	
	outputServerLog("Loading gangareas...")
	for i, info in ipairs(GangAreaData) do
		self.m_Map[i] = GangArea:new(i, info.areaPosition, info.width, info.height)
	end
	
	addRemoteEvents{"gangAreaTurfStart"}
	addEventHandler("gangAreaTurfStart", root, bind(self.Event_gangAreaTurfStart, self))
end

function GangAreaManager:Event_gangAreaTurfStart(Id)
	local gangArea = self.m_Map[Id]
	if gangArea then
		local clientGroup = client:getGroup()
		local ownerGroup = gangArea:getOwnerGroup()
		if not clientGroup or clientGroup == ownerGroup then
			return
		end
		
		--[[if #clientGroup:getOnlinePlayers() < 3 then
			client:sendError(_("Es müssen mindestens 3 Mitglieder deiner Gang online sein, um dieses Gebiet zu erobern", client))
			return
		end]]
		
		if ownerGroup and #ownerGroup:getOnlinePlayers() < 3 then
			client:sendError(_("Es müssen mindestens 3 Mitglieder der gegnerischen Gang online sein!", client))
			return
		end
		
		if gangArea:startTurfing(clientGroup) then
			client:sendInfo(_("Der Gangwar wurde gestartet! Halte nun bis zur Neutralisierung im Gebiet durch!", client))
		else
			client:sendError(_("Fehler beim Starten des Gangwars. Bitte kontaktiere einen Admin", client))
		end
	end
end

--[[

Anforderungen:
- Turfing starten durch Spray (funktioniert nur, wenn andere Gang online ist) [DONE]
- nach vollständigem Übersprühen wird Timer (5-8min) gestartet [DONE]
- wenn Angreifer nicht vertrieben wird --> Besitzer wechseln [DONE]
- wird Angreifer vertrieben --> Gebiet erfolgreich verteidigt --> Timer stoppen [DONE]
- nach Start kann verteidigende Gang wieder übersprühen --> Progress geht in andere Richtung bis erfolgreich verteidigt
- wenn Verteidiger in die Flucht geschlagen wird --> wieder andersherum bis voll

]]