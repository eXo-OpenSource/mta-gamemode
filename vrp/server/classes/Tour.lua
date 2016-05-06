-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Tour.lua
-- *  PURPOSE:     eXo Tour Class (server)
-- *
-- ****************************************************************************

Tour = inherit(Singleton)

function Tour:constructor()
	addRemoteEvents{"tourStart", "tourSuccess"}
	addEventHandler("tourStart", root, bind(self.start, self))
	addEventHandler("tourSuccess", root, bind(self.successStep, self))
	self.m_showStep = bind(self.showStep, self)
	self.m_TourPlayerData = {}
end

function Tour:start()
	local row = sql:queryFetchSingle("SELECT Tour FROM ??_character WHERE Id = ?;", sql:getPrefix(), client:getId())
	local tbl = (row.Tour ~= nil and row.Tour) or toJSON({})
	self.m_TourPlayerData[client]  = fromJSON(tbl)
	Player.getQuitHook():register(bind(self.save, self))

	self:showStep(client, 1)
end

function Tour:save(player)
	sql:queryExec("UPDATE ??_character SET Tour = ? WHERE Id = ?;", sql:getPrefix(), toJSON(self.m_TourPlayerData[player]), player:getId())
end

function Tour:stop()
	client:sendInfo(_("Du hast die Server-Tour erfolgreich beendet!", client))
	client:triggerEvent("tourStop")
	self:save(client)
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
		if not self.m_TourPlayerData[client][tostring(id)] then
			self.m_TourPlayerData[client][tostring(id)] = true
			client:giveMoney(Tour.Data[id].Money, "Tour")
		else
			client:sendShortMessage(_("Du hast bereits die Belohnung für diesen Schritt erhalten!", client))
		end
		setTimer(self.m_showStep, 5000, 1, client, id+1)
	end
end

Tour.Data = {
	[1] = {
		["Title"] = "Herzlich Willkommen",
		["Description"] = "Ich werde dich hier ein wenig durch eXo-Reallife führen. Halte dich an meine Tipps und ein super Start ist dir sicher. Gelegentlich wartet auch eine großzügige Belohnung für eine abgeschlossene Aufgabe auf dich!",
		["Success"] = "Sehr gut! Du hast die erste Haltestelle erreicht! Hier ist das Los Santos Police Department. Hier verrichten unsere Polizisten ihren Job",
		["Position"] = Vector3(1544.79, -1675.15, 13),
		["Money"] = 50
	},
	[2] = {
		["Title"] = "Besuche die Fahrschule",
		["Description"] = "Finde die Fahrschule, diese wird mit einem roten Auto auf der Minimap angezeigt, du kannst die große Karte mit der F11 Taste öffnen oder folge einfach dem Pfeil über deinem Kopf!!",
		["Success"] = "Herzlichen Glückwunsch du hast die Fahrschule gefunden! Du erhälst als Belohnung 200$ \nRufe am gelben i-Punkt einen Fahrlehrer oder starte die autmatische Prüfung!",
		["Position"] = Vector3(1371.26,-1653.54,13.38),
		["Money"] = 200
	},
	[3] = {
		["Title"] = "Winner Winner Chicken Dinner",
		["Description"] = "Besuche das Casino in Los Santos!\n Du findest es am rosafarbenen C-Icon auf der Karte! Folge einfach dem Pfeil über deinem Kopf! Dort gibt es Spiele wie Flappy Birds, Slot Maschinen, Roulette, Black Jack und viele andere!",
		["Success"] = "Super du hast das Casino gefunden! \nSpiele mit der Belohnung eine Runde auf der Slot-Maschine!",
		["Position"] = Vector3(1833.00,-1682.61,13.49),
		["Money"] = 150
	},
	[4] = {
		["Title"] = "Werde Mobil",
		["Description"] = "Kauf dir nun dein erstes Fahrzeug! Immer der Pfeilspitze nach, dort befindet sich der günstige Gebrauchtwagen-Händler!",
		["Success"] = "Du hast ihn gefunden, du kannst dir hier ein Auto kaufen! Hier hast du etwas Geld zum Start! Damit geht sich ein zerdellter Glendale aus! Mal sehen was sich mit ein wenig Tunings aus den Fahrzeugen machen lässt!",
		["Position"] = Vector3(1117.98,-1232.32,16.15),
		["Money"] = 900
	},
	[5] = {
		["Title"] = "Tuning",
		["Description"] = "Der Los Santos Tuningshop ist mit einem roten Schraubenschlüssel markiert, besuche Ihn um dein Fahrzeug zu lackieren oder Tunen. Du kannst auch einfach dem Pfeil über deinem Kopf folgen! Angefangen von Neonröhren bis hin zu Spoilern ist alles vorrätig!",
		["Success"] = "Mal sehen was sich mit ein wenig Tunings aus den Fahrzeugen machen lässt! Fahr in die Garage und tob dich aus!",
		["Position"] = Vector3(1041.98,-1028.30,32.10),
		["Money"] = 900
	},
	[6] = {
		["Title"] = "I'm a Sexy Bitch",
		["Description"] = "Wie läufst du den rum? Es wird Zeit für ein geiles Outfit! Ab in den Skinladen und was vernünftiges zum Anziehen kaufen!\n\n Folge dem Pfeil!",
		["Success"] = "Kauf dir da drinnen mit dem Geld einen schönen Skin. Wer weiß, vielleicht wird das dann doch noch was mit uns beiden.",
		["Position"] = Vector3(2244.78,-1660.79,15.46),
		["Money"] = 500
	},
	[7] = {
		["Title"] = "Fastfood FTW",
		["Description"] = "Hast du schon rechts oben die Hungerleiste gesehen? Du musst immer mal wieder was essen um nicht vom Fleisch zu fallen. Besorgen wir uns doch einen richtig geilen Burger. Der Pfeil zeit dir wo lang!",
		["Success"] = "Du hast den Burger-Shop gefunden, kauf dir entweder am Drive-In einen Burger zum mitnehmen oder iss im Restaurant ein herzhaftes Menü!",
		["Position"] = Vector3(1216.47,-920.08,42.92),
		["Money"] = 500
	},
	[8] = {
		["Title"] = "Pizza Pizza",
		["Description"] = "Es wird nun Zeit das erste Geld zu verdienen, am besten wir fangen mit dem austragen von Pizza an. Folge den Pfeil um zum Job zu kommen!",
		["Success"] = "Du hast die Hauptfiliale von Well Stacked Pizza gefunden. Frag den Chef am besten ob er einen Job für dich hat. Du erreichst Ihn am gelben i Punkt!",
		["Position"] = Vector3(2100.125,-1804.69,13.55),
		["Money"] = 500
	},
	[9] = {
		["Title"] = "Trockener Hals",
		["Description"] = "Überall auf der Karte verteilt findest du Sprunk-Automaten. Ich zeig dir am besten einmal ein Beispiel. Folge den Pfeil!",
		["Success"] = "Genau hier ist ein Automat, du kannst dir eine Dose leckerer Sprunk-Limonade mit einem Klick holen. Du öffnest die Maus mit ALT-GR.\nSollte dies nicht funktionieren tippe /rebind und versuchs nochmal!",
		["Position"] = Vector3(1510.09,-1767.99,13.54),
		["Money"] = 500
	},
	[10] = {
		["Title"] = "Formel 1 war gestern",
		["Description"] = "Du kannst hier auf eXo-Reallife in einem Unternehmen und einer Fraktion zu gleich sein. Eines davon ist die Race N Drift. Sehen wir uns mal die Rennstrecke an. Ab gehts folge dem Pfeil! Dort gibts massenhaft PS, quietschende Räder und geile Boxenluder!",
		["Success"] = "So nur noch die Brücke rüber und schon sind wir da, der eXo Circuit. Zusätzlich zur modernen Rennstrecke findest du hier einen Derby-Bereich eine Dragstrecke und eine Kartstrecke.",
		["Position"] = Vector3(2915.00,-773.27,10.73),
		["Money"] = 500
	},
	[11] = {
		["Title"] = "Fahrzeug verschwunden",
		["Description"] = "Nun zum nächsten Unternehmen, der Mechanic and Tow Company! Hier werden Motorentunings vorgenommen und falsch geparkte Autos abgeschleppt. Folge dem Pfeil.",
		["Success"] = "So gut angekommen? Solltest du einmal dein Auto vermissen, schau hier auf dem Abschlepphof nach. Rufe die Mitarbeiter mit /call 500 an und bitte Sie dieses wieder frei zu machen.",
		["Position"] = Vector3(914.29,-1227.14,16.98),
		["Money"] = 500
	},
	[12] = {
		["Title"] = "Ab in den Süden",
		["Description"] = "Strandparty gefällig? Ich zeige dir wo es bei Events richtig ab geht, ab in den Süden den Pfeil hinter her.",
		["Success"] = "Das ist unsere fette Strandbühne, hier sind gelegentlich DJ´s, Stripperinnen und Bodyguards onduty wenn es wieder heißt 'The Party goes on!'",
		["Position"] = Vector3(306.15,-1813.20,4.39),
		["Money"] = 500
	}
}
