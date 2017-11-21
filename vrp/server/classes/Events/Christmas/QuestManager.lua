QuestManager = inherit(Singleton)
QuestManager.Quests = {
	[2] = {
		["Name"] = "Weihnachts-Fotograf",
		["Description"] = "Schieße ein Foto mit mindestens 10 Spielern darauf!",
		["Packages"] = 5,
	}
}

function QuestManager:constructor()
	self.m_Quests = {
		[2] = QuestPhotography
	}
	self.m_CurrentQuest = false

	--DEV:
	self:startQuest(2)

	addRemoteEvents{"questOnPedClick", "questStartClick"}
	addEventHandler("questOnPedClick", root, bind(self.onPedClick, self))
	addEventHandler("questStartClick", root, bind(self.onStartClick, self))


end

function QuestManager:startQuest(questId)
	if not self.m_Quests[questId] then return end
	if self.m_CurrentQuest then self:stopQuest() end

	self.m_CurrentQuest = self.m_Quests[questId]:new(questId)
end

function QuestManager:startQuestForPlayer(player)
	if not self.m_CurrentQuest then
		return false
	end
	if table.find(self.m_CurrentQuest:getPlayers(), player) then
		player:sendError("Du hast den Quest bereits gestartet!")
		return
	end

	if self.m_CurrentQuest:isQuestDone(player) then
		player:sendError("Du hast den Quest bereits abgeschlossen!")
		return
	end

	self.m_CurrentQuest:addPlayer(player)
end

function QuestManager:endQuestForPlayer(player)
	self.m_CurrentQuest:removePlayer(removePlayer)
end


function QuestManager:onStartClick()
	if not self.m_CurrentQuest then
		client:sendError("Aktuell läuft kein Quest!")
		return false
	end
	self:startQuestForPlayer(client)
end

function QuestManager:onPedClick()
	if not self.m_CurrentQuest then
		client:sendError("Aktuell läuft kein Quest!")
		return false
	end
	self.m_CurrentQuest:onClick(client)
end

function QuestManager:stopQuest()
	delete(self.m_CurrentQuest)
	self.m_CurrentQuest = false
end


--[[
Quest System:

1.) Löse das Rätsel
2.) Fotografiere den Weihnachtsmann (Steht irgendwo auf der Map)
3.) Mache ein Foto mit mindestens 10 Spielern auf dem Bild
4.) Zeichne einen schönen Weihnachtsmann (Wird von Admins bestätigt)
5.) Bringe den Weihnachtsmann an einem Punkt
6.) Bringe das Päckchen an einen Abgabeort
7.) Finde 5 Päckchen (werden nur an diesem Tag verteilt)
8.) Töte 3 Weihnachtsmänner  (Spawnen an NPC-Positionen)
9.) Schaffe den Parcour (gemapt)
10.) Zeichne einen Schneemann (Wird von Admins bestätigt)
11.) Finde das Päckchen mithilfe des Radars (Radar aus Schatzsucher Job) mehrere zufällige Positionen die nach jedem Fund wechseln
12.) Fotografiere den Weihnachtsmann (Steht irgendwo auf der Map)
13.) Bringe ein Geschenkspapier zum Weihnachtsmann
14.) Spiele 5x am Glücksrad
15.) Schaffe den Parcour (gemapt)
16.) Mache ein Foto mit mindestens 5 Spielern mit Mütze auf dem Bild
17.) Bringe den Weihnachtsmann an einem Punkt
18.) Bringe das Päckchen an einen Abgabeort
19.) Töte 3 Weihnachtsmänner (Spawnen an NPC-Positionen)
20.) Spiele 5x am Glücksrad
21.) Bringe das Päckchen an einen Abgabeort
22.) Bekomme eine Alkoholvergiftung vom Glühwein
23.) Finde das Päckchen mithilfe des Radars (Radar aus Schatzsucher Job) mehrere zufällige Positionen die nach jedem Fund wechseln
24.) Heute keine Aufgabe, verbringe den Tag mit deiner Familie - Gratis Päckchen!


]]
