QuestManager = inherit(Singleton)
QuestManager.Quests = {
	[1] = {
		["Name"] = "Weihnachts-Bodyguard",
		["Description"] = "Bringe den Weihnachtsmann zum markierten Ort in Montgomery!",
		["Packages"] = 5,
	},
	
	[2] = {
		["Name"] = "Weihnachtsmann-Selfie",
		["Description"] = "Finde den Weihnachtsmann (Er ist in Los Santos) und schieße ein Foto von ihm!",
		["Packages"] = 10,
	},
	[3] = {
		["Name"] = "Weihnachts-Bodyguard",
		["Description"] = "Bringe den Weihnachtsmann zum markierten Ort in Montgomery!",
		["Packages"] = 5,
	},
	[4] = {
		["Name"] = "Päckchen-Transport",
		["Description"] = "Liefere die Päckchen an den angezeigten Ort! Pass gut auf den Anhänger auf!",
		["Packages"] = 5,
	},
	[5] = {
		["Name"] = "Weihnachts-Fotograf",
		["Description"] = "Schieße ein Foto mit mindestens 3 Spielern darauf!",
		["Packages"] = 5,
	},
	[6] = {
		["Name"] = "Weihnachts-Morde",
		["Description"] = "Suche die Einbrecher in den orange markierten Gegenden und bringe sie um!",
		["Packages"] = 5,
	},
	[7] = {
		["Name"] = "Päckchen-Finder",
		["Description"] = "Finde 5 Päckchen und klicke diese an!",
		["Packages"] = 5,
	},
	[8] = {
		["Name"] = "Päckchen-Transport",
		["Description"] = "Liefere die Päckchen an den angezeigten Ort! Pass gut auf den Anhänger auf!",
		["Packages"] = 5,
	},
	[9] = {
		["Name"] = "Glücksrad-Master",
		["Description"] = "Spiele 3 mal am Glücksrad! Die Quest muss währenddessen von dir gestartet sein!",
		["Packages"] = 5,
	},
	[10] = {
		["Name"] = "Feierabend",
		["Description"] = "Heute gibt es nichts zu erledigen! Hier deine Belohnung!",
		["Packages"] = 5,
	},
	[11] = {
		["Name"] = "Päckchen-Transport",
		["Description"] = "Liefere die Päckchen an den angezeigten Ort! Pass gut auf den Anhänger auf!",
		["Packages"] = 5,
	},
	[12] = {
		["Name"] = "Riesenradfahrer",
		["Description"] = "Fahre zwei Runden mit dem Riesenrad (die Gondel muss wieder an den Treppen anhalten)!",
		["Packages"] = 5,
	},
	[13] = {
		["Name"] = "Weihnachts-Morde",
		["Description"] = "Suche die Einbrecher in den orange markierten Gegenden und bringe sie um!",
		["Packages"] = 5,
	},
	[14] = {
		["Name"] = "Mützen-Foto",
		["Description"] = "Schieße ein Foto mit mindestens 3 Spielern die eine Weihnachtsmütze auf haben!",
		["Packages"] = 5,
	},
	[15] = {
		["Name"] = "Weihnachts-Bodyguard",
		["Description"] = "Bringe den Weihnachtsmann zum markierten Ort in Los Santos!",
		["Packages"] = 5,
	},
	[16] = {
		["Name"] = "Päckchen-Transport",
		["Description"] = "Liefere die Päckchen an den angezeigten Ort! Pass gut auf den Anhänger auf!",
		["Packages"] = 5,
	},
	[17] = {
		["Name"] = "Vorfreude",
		["Description"] = "Heute gibt es nichts zu erledigen! Hier deine Belohnung!",
		["Packages"] = 5,
	},
	[18] = {
		["Name"] = "Glücksrad-Master",
		["Description"] = "Spiele 3 mal am Glücksrad! Die Quest muss während dessen von dir gestartet sein!",
		["Packages"] = 5,
	},
	[19] = {
		["Name"] = "Päckchen-Finder",
		["Description"] = "Finde 5 Päckchen und klicke diese an!",
		["Packages"] = 5,
	},
	[20] = {
		["Name"] = "Administriver Fotograf",
		["Description"] = "Schieße ein Foto mit mindestens 1 Teammitgliedern!",
		["Packages"] = 5,
	},
	[21] = {
		["Name"] = "Riesenradfahrer",
		["Description"] = "Fahre zwei Runden mit dem Riesenrad (die Gondel muss wieder an den Treppen anhalten)!",
		["Packages"] = 5,
	},
	[22] = {
		["Name"] = "Weihnachts-Morde",
		["Description"] = "Suche die Einbrecher in den orange markierten Gegenden und bringe sie um!",
		["Packages"] = 5,
	},
	[23] = {
		["Name"] = "Glücksrad-Master",
		["Description"] = "Spiele 3 mal am Glücksrad! Die Quest muss während dessen von dir gestartet sein!",
		["Packages"] = 5,
	},
	[24] = {
		["Name"] = "Familientag",
		["Description"] = "Wir wollen dich heute nicht weiter aufhalten! Hier deine Belonung!",
		["Packages"] = 5,
	},
}

function QuestManager:constructor()
	-- Also add it client side if the quest requires a clientside script
	-- The client side quest automatically starts on startQuestForPlayer if the class is setted on clientside Questmanager
	self.m_Quests = {
		[1] = QuestNPCTransport,
		[2] = QuestPhotography,
		[3] = QuestNPCTransport,
		[4] = QuestPackageTransport,
		[5] = QuestPhotography,
		[6] = QuestSantaKill,
		[7] = QuestPackageFind,
		[8] = QuestPackageTransport,
		[9] = QuestFortuneWheel,
		[10] = QuestNoQuest,
		[11] = QuestPackageTransport,
		[12] = QuestFerrisRide,
		[13] = QuestSantaKill,
		[14] = QuestPhotography,
		[15] = QuestNPCTransport,
		[16] = QuestPackageTransport,
		[17] = QuestNoQuest,
		[18] = QuestFortuneWheel,
		[19] = QuestPackageFind,
		[20] = QuestPhotography,
		[21] = QuestFerrisRide,
		[22] = QuestSantaKill,
		[23] = QuestFortuneWheel,
		[24] = QuestNoQuest,
	}
	self.m_CurrentQuest = false


	addRemoteEvents{"questOnPedClick", "questStartClick", "questShortMessageClick"}
	addEventHandler("questOnPedClick", root, bind(self.onPedClick, self))
	addEventHandler("questStartClick", root, bind(self.onStartClick, self))
	addEventHandler("questShortMessageClick", root, bind(self.onShortMessageClick, self))

	PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))
	PlayerManager:getSingleton():getWastedHook():register(bind(self.onPlayerQuit, self))
	PlayerManager:getSingleton():getAFKHook():register(bind(self.onPlayerQuit, self))

	if DEBUG then
		addCommandHandler("quest", function(player, cmd, id)
			local id = tonumber(id)
			if (id and id >= 1 and id <= 24) then
				self:startQuest(id)
				player:sendInfo(_("Quest %s gestartet", player, id))
			else
				player:sendError(_("Bitte eine valide Quest-Nummer (1-24) angeben!", player))
			end
		end)
	else
		self:getTodayQuest()
	end
	GlobalTimer:getSingleton():registerEvent(bind(self.getTodayQuest, self), "Christmas-Quests", nil, 00, 5)

end

function QuestManager:startQuest(questId)
	if not self.m_Quests[questId] then return end
	if self.m_CurrentQuest then self:stopQuest() end

	self.m_CurrentQuest = self.m_Quests[questId]:new(questId)
end

function QuestManager:getTodayQuest()
	local day = getRealTime().monthday
	local month = getRealTime().month+1

	if month ~= 12 then	return end
	if not self.m_Quests[day] then return end

	self:startQuest(day)
end

function QuestManager:startQuestForPlayer(player)
	if not self.m_CurrentQuest then
		return false
	end
	if table.find(self.m_CurrentQuest:getPlayers(), player) then
		player:sendError("Du hast die Quest bereits gestartet!")
		return
	end

	if self.m_CurrentQuest:isQuestDone(player) then
		player:sendError("Du hast die Quest bereits abgeschlossen!")
		return
	end

	self.m_CurrentQuest:addPlayer(player)
end

function QuestManager:endQuestForPlayer(player)
	self.m_CurrentQuest:removePlayer(player)
end


function QuestManager:onStartClick()
	if not self.m_CurrentQuest then
		client:sendError("Aktuell läuft keine Quest!")
		return false
	end
	self:startQuestForPlayer(client)
end

function QuestManager:onPedClick()
	if not self.m_CurrentQuest then
		client:sendError("Aktuell läuft keine Quest!")
		return false
	end
	self.m_CurrentQuest:onClick(client)
end

function QuestManager:stopQuest()
	for index, player in pairs(self.m_CurrentQuest:getPlayers()) do
		if player and isElement(player) then
			self:endQuestForPlayer(player)
		end
	end

	delete(self.m_CurrentQuest)
	self.m_CurrentQuest = false
end

function QuestManager:onShortMessageClick()
	QuestionBox:new(client, "Möchtest du die Quest "..self.m_CurrentQuest.m_Name.." abbrechen? Du kannst diesen jederzeit wieder starten.",
	function()
		self:endQuestForPlayer(client)
	end,
	function()
		self:endQuestForPlayer(client)
		self:startQuestForPlayer(client)
	end
)
end

function QuestManager:onPlayerQuit(player)
	if self.m_CurrentQuest then
		if table.find(self.m_CurrentQuest:getPlayers(), player) then
			self:endQuestForPlayer(player)
		end
	end
end

--[[
Quest System:

1.) Bringe den Weihnachtsmann an einem Punkt
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
