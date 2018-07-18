-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Tour.lua
-- *  PURPOSE:     eXo Tour Class (server)
-- *
-- ****************************************************************************

Tour = inherit(Singleton)
function Tour:constructor()
	addRemoteEvents{"tourStart", "tourStop", "tourSuccess"}
	addEventHandler("tourStart", root, bind(self.start, self))
	addEventHandler("tourStop", root, bind(self.stop, self))
	addEventHandler("tourSuccess", root, bind(self.successStep, self))
	self.m_showStep = bind(self.showStep, self)
	self.m_TourPlayerData = {}
	self.m_BankAccountServer = BankServer.get("gameplay.tour")
	Player.getQuitHook():register(bind(self.save, self))
end

function Tour:start(forceNew)
	local Id = client:getId()
	if not Id then return end
	if self.m_TourPlayerData[Id] then
		self:save(client)
		client:triggerEvent("tourStop")
	end
	local row = sql:queryFetchSingle("SELECT Tour FROM ??_character WHERE Id = ?;", sql:getPrefix(), Id)
	local tbl = (row.Tour ~= nil and row.Tour) or toJSON({})
	self.m_TourPlayerData[Id]  = fromJSON(tbl)
	local step = 1
	if not forceNew == true then
		for id, data in pairs(Tour.Data) do
			if not self.m_TourPlayerData[Id][tostring(id)] == true then
				step = id
			end
		end
	end
	client:sendShortMessage(_("Du kannst die Tour jederzeit im self-Menü (F2) unter Einstellungen beenden!", client), "Servertour")
	self:showStep(client, step)
end

function Tour:save(player)
	if not player then player = source end

	if player and self.m_TourPlayerData and player:getId() and self.m_TourPlayerData[player:getId()] then
		sql:queryExec("UPDATE ??_character SET Tour = ? WHERE Id = ?;", sql:getPrefix(), toJSON(self.m_TourPlayerData[player:getId()]), player:getId())
	end
end

function Tour:stop(player)
	if client and isElement(client) then player = client end
	player:sendInfo(_("Du hast die Server-Tour erfolgreich beendet!", player))
	player:triggerEvent("tourStop")
	self:save(player)
end

function Tour:showStep(player, id)
	if Tour.Data[id] then
		player:triggerEvent("tourShow", id, Tour.Data[id].Title, Tour.Data[id].Description, Tour.Data[id].Success, Tour.Data[id].Position.x, Tour.Data[id].Position.y, Tour.Data[id].Position.z)
	else
		Tour:stop(player)
	end
end

function Tour:successStep(id)
	if Tour.Data[id] then
		if not self.m_TourPlayerData[client:getId()][tostring(id)] then
			self.m_TourPlayerData[client:getId()][tostring(id)] = true
			self.m_BankAccountServer:transferMoney(client, Tour.Data[id].Money, "Tour", "Gameplay", "Tour")
		else
			client:sendShortMessage(_("Du hast bereits die Belohnung für diesen Schritt erhalten!", client))
		end
		setTimer(self.m_showStep, 10000, 1, client, id+1)
	end
end

Tour.Data = {
	[1] = {
		["Title"] = "Herzlich Willkommen",
		["Description"] = "Ich führe dich ein wenig durch eXo-Reallife. Halte dich an meine Tipps und ein super Start ist dir sicher. Gelegentlich wartet auch eine Belohnung für eine Aufgabe auf dich! Folge dem Pfeil über deinem Kopf zur ersten Station!",
		["Success"] = "Sehr gut! Du kannst nun mit der Taste 'B' das Klickmenü öffnen. Wenn du damit auf den NPC vor dir klickst, kannst du dir deinen Personalausweis beantragen.",
		["Position"] = Vector3(1832.01, -1276.67, 119.26),
		["Money"] = 400
	},
	[2] = {
		["Title"] = "Verlasse das Gebäude",
		["Description"] = "Verlasse nun das Gebäude über den Aufzug. (Gelber Marker)",
		["Success"] = "Sehr gut, und gib nicht alles auf einmal aus! Hol dir nun am besten am NPC ein Faggio!",
		["Position"] = Vector3(1788.62, -1293.71, 12.54),
		["Money"] = 50
	},
	[3] = {
		["Title"] = "Usertreff / Spawn",
		["Description"] = "Besuche nun den Usertreff / Spawn. Dazu kannst du dir über dein Handy (Taste U) ein Taxi rufen oder dir am Stand einen Faggio leihen.",
		["Success"] = "Dies ist der Bahnhof, auch bekannt als ein beliebter Treffpunkt unter der Community. Ein Vorteil am Bahnhof ist, dass der Ort nie schläft und somit stets Spaß und Action bietet!",
		["Position"] = Vector3(1480.41, -1749.80, 12.55),
		["Money"] = 50
	},
	[4] = {
		["Title"] = "Fahrschule",
		["Description"] = "Du solltest nun die Fahrschule absolvieren. Folge dem Pfeil!",
		["Success"] = "Zunächst musst du im Gebäude die Theorie Prüfung absolvieren, indem du auf den NPC klickst. Anschließend kannst du hier im gelben Info-Marker einen Fahrlehrer kontaktieren.",
		["Position"] = Vector3(1376.02, -1658.39, 12.38),
		["Money"] = 1500
	},
	[5] = {
		["Title"] = "Fahrbahrer Untersatz",
		["Description"] = "Sobald du deinen Führerschein gemacht hast, solltest du dich um einen Fahrbahren Untersatz kümmern. Folge dem Pfeil zum Billig-Autohändler!",
		["Success"] = "Hier hast du einen kleinen Bonus, kaufe dir davon ein Fahrzeug!",
		["Position"] = Vector3(1116.31, -1220.24, 16.93),
		["Money"] = 2500
	},
	[6] = {
		["Title"] = "Tuning",
		["Description"] = "Dein Fahrzeug ist dir zu langsam oder dir gefällt die Farbe nicht? Kein Problem, im Tuningshop kannst du es aufmotzen.",
		["Success"] = "Fahre einfach in die Garage und gönn dir ein paar Tuningteile!",
		["Position"] = Vector3(1041.85, -1031.00, 31),
		["Money"] = 10000
	},
	[7] = {
		["Title"] = "Fahrzeug verschwunden",
		["Description"] = "Kommen wir nun zum Unternehmen Mechanic & Tow. Fahre zum Abschlepphof!",
		["Success"] = "Hier können abgeschleppte oder explodierte Fahrzeuge freigekauft werden. Schaue dazu rechts im Hof ins Glashaus.",
		["Position"] = Vector3(925.55, -1221.33, 15.98),
		["Money"] = 500
	},
	[8] = {
		["Title"] = "Hier müffelt was",
		["Description"] = "Riechst du das auch? Du solltest dringend deine Kleidung wechseln!",
		["Success"] = "Dies ist der billige Kleidungsshop. Wenn du willst kannst natürlich auch gehobene Kleidung im Westen der Stadt kaufen...",
		["Position"] = Vector3(2245.26, -1662.27, 14.47),
		["Money"] = 100
	},
	[9] = {
		["Title"] = "Pizza Pizza",
		["Description"] = "Es wird nun Zeit das erste Geld zu verdienen, am besten wir fangen mit dem Austragen von Pizza an. Folge den Pfeil um zum Job zu kommen!",
		["Success"] = "Du hast die Hauptfiliale von Well Stacked Pizza gefunden. Frag den Chef am besten ob er einen Job für dich hat. Öffne mit Taste 'B' das Klicksystem und nimm den Job an. Anschließend kannst du im roten Marker ein Fahrzeug zum Austragen spawnen.",
		["Position"] = Vector3(2108.83, -1786.57, 12.56),
		["Money"] = 500
	},
	[10] = {
		["Title"] = "Money, Money, Money",
		["Description"] = "Nachdem du gejobbt hast solltest du dein Geld in die Bank einzahlen. Fahre zum ATM beim PD!",
		["Success"] = "Öffne nun das Klickmenü mit 'B', klicke auf den ATM. In unserem Handy (Taste U) gibt es eine Bank-App um deinen Kontostand zu überprüfen oder Geld zu überweisen!",
		["Position"] = Vector3(1508.89, -1673.20, 13.05),
		["Money"] = 2500
	},
	[11] = {
		["Title"] = "Fishing? Still funny!",
		["Description"] = "Der nächste Punkt auf unserer Liste ist der Angler Lutz. Folge einfach wieder dem Pfeil!",
		["Success"] = "Hier ist der Angelshop, weitere Infos zu unserem Angelsystem erhälst du im Hilfemenü (F1)",
		["Position"] = Vector3(393.06, -1897.12, 7.3),
		["Money"] = 50
	},
	[12] = {
		["Title"] = "eXo Boxing Association",
		["Description"] = "Unser nächster Zwischenstopp führt uns zur Boxhalle!",
		["Success"] = "In der Boxhalle kannst du gegen andere Spieler boxen. Ihr könnt optional einen Geldbetrag setzen und euch so mit gekonnten hieben etwas dazu verdienen.",
		["Position"] = Vector3(2228.73, -1722.71, 12.7),
		["Money"] = 50
	},
	[13] = {
		["Title"] = "Alkohol ist auch eine Lösung",
		["Description"] = "Puh viel geschafft. Machen wir nun einen Abstecher in eine Bar!",
		["Success"] = "Es gibt zahlreiche Bars in Los Santos. Besitzer der Bar können Stripperinnen engagieren und Musik verwalten.",
		["Position"] = Vector3(1830.46, -1683.94, 12.7),
		["Money"] = 200
	},
	[14] = {
		["Title"] = "Pferderennen",
		["Description"] = "So, nun ab zum Pferderennen. Du findest dies im Norden von Los Santos.",
		["Success"] = "Hier kannst du am täglichen Pferderennen teilnehmen. Gehe einfach ins Wettlokal und setze auf ein Pferd deiner Wahl!",
		["Position"] = Vector3(1632.55, -1167.53, 23.2),
		["Money"] = 100
	},
	[15] = {
		["Title"] = "Casino",
		["Description"] = "Der nächste Punkt ist fast nebenan. Hier ist unser Casino, du findest da drin einige nette Spiele!",
		["Success"] = "Es gibt auf eXo-Reallife einige Multiplayer-Minigames. Klicke auf einen Spieler um diese zu starten.",
		["Position"] = Vector3(1463.51, -1169.74, 23.3),
		["Money"] = 250
	},
	[16] = {
		["Title"] = "Formel 1 - Naja fast",
		["Description"] = "Der letzte Punkt unserer Tour führt zu einem richtigen Highlight. Der eXo-Reallife Kartbahn!",
		["Success"] = "Hier kannst du Rennen gegen die Uhr fahren und neue Toptimes aufstellen. Das wars mit der Tour, weiter Hilfe findest du unter F1, /report oder im Forum!",
		["Position"] = Vector3(1295.52, 149.98, 19),
		["Money"] = 500
	}
}
