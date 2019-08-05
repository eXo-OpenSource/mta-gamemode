-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorHelpGUI.lua
-- *  PURPOSE:     Map Editor Help GUI class
-- *
-- ****************************************************************************

MapEditorHelpGUI = inherit(GUIForm)
inherit(Singleton, MapEditorHelpGUI)

function MapEditorHelpGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 15)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Anleitung zum Map Editor", true, true, self)
	self.m_Scrollable = GUIGridScrollableArea:new(1, 1, 19, 14, 19, 40, true, false, self.m_Window)
    self.m_Scrollable:updateGrid()
	
	GUIGridLabel:new(1, 1, 19, 1, "Einleitung", self.m_Scrollable):setHeader()
	GUIGridLabel:new(1, 2, 19, 9, [[Der Map Editor ist ein Werkzeug zum Bearbeiten der Map in Echtzeit. Durch ihn ist es möglich Objekte der Standard Map zu entfernen und neue Objekte nach belieben hinzuzufügen. Objekte die durch das Script hinzugefügt wurden (Fraktionsbasen, kleinere Verschönerungen etc.) können durch den Map Editor nicht beeinflusst werden.

Die Intention hinter der Programmierung des Map Editors ist die Möglichkeit, Events wie z.B. Baustellen, Unfälle, Straßensperren und weiter Erweiterungen von Aktionen etc. auf der Karte in Echtzeit ermöglichen zu können und dem Administrations Team eine gewisse Freiheit über den Aufbau der Map zu lassen.

Da das Verändern der Map, egal ob während der Laufzeit oder nicht, immer einen enormen Einfluss auf das Spielgeschehen hat, ist der Map Editor stets mit Vorsicht und Bedacht zu nutzen. 
Denke lieber zweimal nach oder spreche mit anderen Teammitgliedern bevor du etwas herrichtest, was möglicherweise einen unvorhergesehenen Eingriff ins Spiel verursacht.]], self.m_Scrollable)
    

    GUIGridLabel:new(1, 12, 19, 1, "Mit dem Mappen beginnen", self.m_Scrollable):setHeader()
	GUIGridLabel:new(1, 13, 19, 2, "Während der gesamten Zeit in der du mappst wirst du im unteren Bereich des Bildschirms ein Fenster mit drei weiteren Schaltflächen vorfinden:", self.m_Scrollable)
    
    GUIGridLabel:new(1, 15, 1, 1, FontAwesomeSymbols.Plus, self.m_Scrollable):setFont(FontAwesome(30))
	GUIGridLabel:new(2, 15, 18, 1, "Ein Pluszeichen zum Erstellen eines neuen Objektes", self.m_Scrollable):setHeader("sub")
	GUIGridLabel:new(1, 16, 19, 2, [[    Ein Fenster öffnet sich nun wo du Objekte durch Namen oder durch Kategorien filtern kannst. 
    Anschließend kannst du mit deiner Maus das Objekt platzieren.]], self.m_Scrollable)

    GUIGridLabel:new(1, 18, 1, 1, FontAwesomeSymbols.Erase, self.m_Scrollable):setFont(FontAwesome(30))
	GUIGridLabel:new(2, 18, 18, 1, "Ein Radiergummi zum entfernen von Objekten der Standard Map", self.m_Scrollable):setHeader("sub")
	GUIGridLabel:new(1, 19, 19, 3, [[    Deine Maus zeigt nun Objekte der Standard Map an, die entfernt werden können. Mit einem doppelten 
    Linksklick auf das Objekt wird das Objekt zur besseren Erkennung rot eingefärbt und eine Markierung
    auf der Karte erscheint. Bei einigen Objekten ist es leider nicht möglich, diese Scriptseitig zu erkennen.
    Diese Objekte können leider nicht durch den Map Editor entfernt werden.]], self.m_Scrollable)

    GUIGridLabel:new(1, 22, 1, 1, FontAwesomeSymbols.Edit, self.m_Scrollable):setFont(FontAwesome(30))
	GUIGridLabel:new(2, 22, 18, 1, "Ein Bearbeiten Symbol zum Auswählen der Map und zum anlegen neuer Maps", self.m_Scrollable):setHeader("sub")
	GUIGridLabel:new(1, 23, 19, 7, [[    Die Liste auf der linken Seite zeigt die erstellten Maps und ihren aktuellen Status an. 
    Die Liste auf der rechten Seite zeigt die Objekte, die der Map zugeordnet sind an. Solltest Du ein Objekt 
    aufgrund fehlender Kollision nicht anklicken können, kannst du das Objekt hier suchen, auswählen und 
    bearbeiten. Auch hier wird das Objekt durch ein Koordinatenkreuz, einen Begrenzungsrahmen und einer 
    Markierung auf der Karte gekennzeichnet. Entfernte Standard Objekte können hier ebenfalls 
    wiederhergestellt werden. Auch hier werden wiederherstellbare Objekte durch Einfärbung und 
    Kartenmarkierung gekennzeichnet.
    Es ist höherrangigen Teammitgliedern weiterhin möglich, eine Map zu deaktivieren und die dazugehören 
    Objekte verschwinden zu lassen und in dieser Map entfernte Standard Objekte bis zum erneuten 
    aktivieren der Map wiederherzustellen.]], self.m_Scrollable)

	
	GUIGridLabel:new(1, 31, 19, 1, "Weiteres", self.m_Scrollable):setHeader()
	GUIGridLabel:new(1, 32, 19, 2, [[Durch einen Doppelklick auf ein neuplatziertes Objekt öffnet sich ein Fenster zur genaueren Bearbeitung des Objektes. 
Mit einem Rechtsklick auf das entsprechende Objekt lässt sich dies erneut mit der Maus platzieren.]], self.m_Scrollable)

	
	GUIGridLabel:new(1, 35, 19, 1, "Aufrufen des Map Editors", self.m_Scrollable):setHeader()
	GUIGridLabel:new(1, 36, 19, 4, [[Der Map Editor kann grundsätzlich nur von Administratoren oder höherrangigen Teammitgliedern aufgerufen werden. Diesen steht es aber Frei, weitere Teammitglieder zum Mappen einzuladen. Dies ist möglich in dem im Verwaltungs Fenster die Schaltfläche "Bearbeiten" aufgerufen wird. Es öffnet sich nun ein Einladungs Fenster. 
Mit der Schaltfläche "Derzeit bearbeitende Spieler" ist es einem höherrangigen Teammitglied möglich, den Map Editor von anderen Teammitgliedern zu schließen.]], self.m_Scrollable)
end

function MapEditorHelpGUI:destructor()
	GUIForm.destructor(self)
end