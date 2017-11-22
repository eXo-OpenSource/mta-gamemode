QuestManager = inherit(Singleton)
QuestManager.Quests = {
	[2] = {
		["Name"] = "Weihnachtsmann-Selfie",
		["Description"] = "Finde den Weihnachtsmann (Er ist in Los Santos) und schieße ein Foto von ihm!",
		["Packages"] = 5,
	},
	[3] = {
		["Name"] = "Weihnachts-Fotograf",
		["Description"] = "Schieße ein Foto mit mindestens 10 Spielern darauf!",
		["Packages"] = 5,
	},
	[16] = {
		["Name"] = "Mützen-Foto",
		["Description"] = "Schieße ein Foto mit mindestens 5 Spielern die eine Weihnachtsmütze auf haben!",
		["Packages"] = 5,
	}
}

function QuestManager:constructor()
	-- Also add it client side if the quest requires a clientside script
	-- The client side quest automatically starts on startQuestForPlayer if the class is setted on clientside Questmanager

	self.m_Quests = {
		[2] = QuestPhotography,
		[3] = QuestPhotography,
		[16] = QuestPhotography
	}
	self.m_CurrentQuest = false

	--DEV:
	self:startQuest(2)

	addRemoteEvents{"questOnPedClick", "questStartClick", "questShortMessageClick"}
	addEventHandler("questOnPedClick", root, bind(self.onPedClick, self))
	addEventHandler("questStartClick", root, bind(self.onStartClick, self))
	addEventHandler("questShortMessageClick", root, bind(self.onShortMessageClick, self))


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
	self.m_CurrentQuest:removePlayer(player)
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

function QuestManager:onShortMessageClick()
	QuestionBox:new(client, client, "Möchtest du den Quest "..self.m_CurrentQuest.m_Name.." abbrechen? Du kannst diesen jederzeit wieder starten.",
	function()
		self:endQuestForPlayer(client)
	end,
	function()
		self:endQuestForPlayer(client)
		self:startQuestForPlayer(client)
	end
)
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
