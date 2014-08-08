-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/JailBreak.lua
-- *  PURPOSE:     Jailbreak class
-- *
-- ****************************************************************************
JailBreak = inherit(Singleton)

function JailBreak:constructor()
	self.m_MainGate = getElementByID("jail_maingate")
	self.m_IntGateRight = getElementByID("jail_intgate_right")
	self.m_IntGateLeft = getElementByID("jail_intgate_left")
	self.m_CellGates = {} -- Todo
end

function JailBreak:toggleMainGate(state)
	self.m_MainGateState = state
	
	if state then
		moveObject(self.m_MainGate, 1000, 76.7, -234.5, 0.6)
	else
		moveObject(self.m_MainGate, 1000, 69.5, -234.5, 0.6)
	end
end

function JailBreak:toggleInteriorGate(state)
	self.m_InteriorGateState = state
	
	if state then
		moveObject(self.m_IntGateLeft, 1000, 99.6, -262.7, 7.5)
		moveObject(self.m_IntGateRight, 1000, 95, -262.8, 7.5)
	else
		moveObject(self.m_IntGateLeft, 1000, 98.1, -262.7, 7.5)
		moveObject(self.m_IntGateRight, 1000, 96.4, -262.76, 7.5)
	end
end

function JailBreak:getRandomQuestion()
	return unpack(JailBreak.Questions[Randomizer:get(1, #JailBreak.Questions)])
end

JailBreak.Questions = {
	{"Berechne den elektrischen Widerstand R aus U = 34V, I = 500mA!", "68Ω", "17Ω", "34mΩ", "68MΩ"},
	{"Nenne den Satz des Pythagoras! (c: Hypotenuse)", "c² = a² + b²", "a² = b² + c²", "c² = a² - b²", "b² = c² + b²"},
	{"Was gibt die Kategorie eines Ethernetkabels an (Beispiel: Cat. 7)", "Die höchstmögliche Frequenz", "Die höchstmögliche Bandbreite", "Den Biegeradius", "Den Steckertyp"},
	{"Wie viele nutzbare IP Adressen sind im Subnetz der IP 192.168.1.16 und Netzmaske 255.255.255.240?", "14", "16", "240", "1"},
	{"Gegeben ist ein SFUTP Kabel. Wofür steht das U?", "Keine Adernschirmung", "Keine Gesamtschirmung", "Folienschirmung um die Adernschirmung", "Gesamtschirmung übernimmt ein Geflecht"},
	{"Welches Protokoll befindet sich auf dem Application Layer des TCP/IP Models?", "FTP", "IP", "ICMP", "ARP"},
	{"Was trifft auf TCP zu?", "TCP ist ein verbindungsorientiertes Protokoll", "TCP ist ein verbindungsloses Protokoll", "Die PDU von TCP wird Datagramm genannt", "TCP prüft nicht auf fehlende Segmente"},
	{"Welcher Algorithmus liegt dem Routingprotokoll OSPF zugrunde?", "Shortest Path First", "Satz des Pythagoras", "Advanced Encryption Standard", "Routing Information Protocol"},
	{"Welche der folgenden Programmiersprachen ist keine Programmiersprache?", "HTML", "C++", "C#", "Java"},
	{"Welche Beziehung sollte in der objektorientierten Programmierung zwischen Klasse und Basisklasse vorliegen?", "Ist-ein Beziehung", "Hat-ein Beziehung", "Ehe", "War-ein Beziehung"},
	{"Welchen Zweck hat das IRC-Protokoll?", "Chat", "Routing", "Dateiübertragungen", "Media-Streaming"},
}
