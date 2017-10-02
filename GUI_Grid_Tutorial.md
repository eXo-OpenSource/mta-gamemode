# krasses GUI Gridsystem Tutorial / Cheatsheet
#### by MasterM
Die GUIGrid*-Klassen sollen das Erstellen von Fenstern vereinfachen und das Design auf dem Server universell halten. 


## Klassenübersicht
* `GUIGridButton` - einfacher Button mit blauem Strich
* `GUIGridIconButton` - blauer Button mit Höhe / Breite 1 und FontAwesome-Font standardmäßig
* `GUIGridChanger` - Auswahlbox mit Pfeilen nach links / rechts
* `GUIGridCheckbox` - Checkbox mit optionalem Infotext
* `GUIGridEdit` - Editbox
* `GUIGridGridList` - scrollbare Liste, die mit Items gefüllt werden kann
* `GUIGridImage` - Bild
* `GUIGridLabel` - einfacher Text
* `GUIGridLinkLabel` - anklickbarer Text
* `GUIGridMiniMap` - Karte (ähnlich des Radars, aber ohne Rotation)
* `GUIGridProgressBar` - Ladebalken mit optionalem Infotext
* `GUIGridRadioButton` - Checkbox mit Einfach-Auswahl
* `GUIGridRectangle` - Rechteck zur Deko (dafür sollte aber DxRectangle verwendet werden)
* `GUIGridSlider` - Schieberegler
* `GUIGridSwitch`  - AN / AUS Schieberegler (Breite 3)
* `GUIGridScrollableArea` - scrollbares Element (ähnlich GridList, aber für eigene Elemente)
* `GUIGridWebView`- Webbrowser
* `GUIGridMemo` - mehrzeilige Editbox

## Grid-Basics
Das Gridsystem besteht aus einem Raster aus 30*30px großen Quadraten mit 10px Außenabstand. Eine Einheit in den Grid-Klassen entspricht einem "Grid-Quadrat", der Abstand wird automatisch berechnet. Beispiel:
``` Lua
    GUIGridButton:new(1, 1, 4, 1, "Button 1") -- Button 2 ist unter Button 1,
    GUIGridButton:new(1, 2, 4, 1, "Button 2") -- hat aber 10px Abstand
```
### Grid-Anpassungen, maximale Größen
Das Grid erkennt nicht automatisch, in welchem Kontext (also unter welchem GUI-Parent) es sich befindet. Stattdessen gibt es folgene Funktionen:
* ` GUIWindow.updateGrid(boolean withTabs)` - statische Methode für ein neues Fenster (GUIWindow zeichnet den Header innerhalb des Elements, wodurch das komplette Grid oben "Platz lassen" muss). Dabei bezeichnet `withTabs`, ob Platz für einen Tab-Host gelassen werden soll (weiteres dazu im Abschnitt "Fenster mit Tabs")
* `GUIScrollableArea:updateGrid()` - Methode, die aufgerufen werden muss bevor man Childs in die jeweilige Scrollarea einfügen will (da ansonsten innerhalb der Area ein weiteres Mal der Außenabstand berechnet wird)
* `GUITabPanel:updateGrid()` - wichtig bei einem Fenster mit Tabs, um das Grid auf diese auszurichten (da das Tab-Menü nicht mit in den Tabs eingerechnet wird ist die Position `0,0` in den Tabs tatsächlich unter dem Menü)

Um die Größe eines neuen Fensters zu bestimmen muss man einen leichten Umweg gehen, der im Abschnitt "neues Fenster" erklärt wird. Wichtig hierbei ist zu wissen, dass Elemente niemals größer als 16 (bzw 17) x 12 Grid-Einheiten sein sollten, was in etwa 640 x 480px entspricht (minimalste MTA-Auflösung). 

### Hilfestellungen, damit man sich die Positionen vorstellen kann
Sobald man das Grid-System verstanden hat kann man auch ohne Editor einfach neue Fenster schreiben. Dazu eignet sich folgender Merksatz: Die Position eines Elements ist gleich der Position + Dimension der Nachbarn. Beispiel: 
``` Lua
                           -- x, y, w, h
self.m_B1 = GUIGridButton:new(1, 1, 5, 1, ...) -- oben links, 5 Einheiten breit und 1 Einheit hoch
-- nun wollen wir einen Button rechts neben B1 erstellen:
self.m_B2 = GUIGridButton:new(6, 1, 5, 1, ...) -- x2 = x1 + w1
-- und einen Button unter B2 
self.m_B3 = GUIGridButton:new(6, 2, 5, 1, ...) -- y3 = y2 + h2
```

## der Editor
### neues Fenster
Zum einfachen Designen kann der Ingame-Code Editor verwendet werden. Diesen kann man ganz einfach mit `dcrun CodeEditorGUI:getSingleton()`aufrufen. Danach gibt man in der Editbox `Klassenname` den Name der neuen Klasse ein. Mit einem Klick auf "neue Klasse" wird eine Basisstruktur eingefügt. Diese sieht wie folgt aus: 

``` Lua
TestClass = inherit(GUIForm)
inherit(Singleton, TestClass)

function TestClass:constructor()
	GUIWindow.updateGrid()			
	self.m_Width = grid("x", 16) --Außenabstand bekommt man mit x und y	
	self.m_Height = grid("y", 12) --statt wie sonst üblich w und h

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)
	
end

function TestClass:destructor()
	GUIForm.destructor(self)
end

```

### bestehendes Fenster laden
Um ein Fenster nachträglich zu bearbeiten reicht es in den meisten Fällen, den Code komplett in den Editor zu kopieren und in der Editbox ("Klassenname") den Name der Klasse zu aktualisieren. Wichtig ist, dass der Editor nur eine Klasse zur selben Zeit managen kann und es somit sinnvoll ist, evtl. weitere Klassen in der gleichen Datei temporär zu deaktivieren (auskommentieren oder löschen)


## Verwendung der Elemente
Damit Fenster einheitlich aussehen sollten sie folgende Richtlinien einhalten bzw. GUI-Elemente wie folgt benutzt werden:


### Allgemein
- nur ganze Grid-Einheiten also Positions- und Größenangabe verwenden
- Designänderungen (z.B. andere Font-Größe) sind nur auf Ebene der Elemente erwünscht. Lösungen für ein einzelnes Fenster schränken die Wiederverwertbarkeit des Codes extrem ein und sehen nicht toll aus
- wenn Inhalt nicht in ein Fenster passt, dann sind Tabs und / oder ScrollAreas zu verwenden, "Hacks" sind nicht zielführend (und würden ggf. gegen die oberen Punkte verstoßen)

### Fenster
Das oberste Parent (was an GUIForm anknüpft) muss ein `GUIWindow` sein um die klassische Fenster-Funktionalität zu erhalten (z.B. verschieben, in Vordergrund heben). Dies trifft ebenfalls zu wenn man den "Close"-Button ausblendet etc. Ein GUIWindow muss sein! Außerdem müssen sich Windows immer komplett schließen lassen, was entweder durch den Close-Button oder manuell durch `GUIClass:getSingleton():close()` geschehen muss. Andernfalls kommt der Renderer und der Manager, der Binds in GUIForms verbietet, durcheinander.

#### Fenster ohne Tabs
```Lua
GUIWindow.updateGrid()			
self.m_Width = grid("x", 16) 
self.m_Height = grid("y", 12) 

GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)

self.m_Btn = GUIGridButton:new(1, 1, 5, 1, "cooler Button", self.m_Window) -- parent ist das Window und nicht self! 
```

#### Fenster mit Tabs
```Lua
GUIWindow.updateGrid(true) -- hier muss true stehen, damit die tabs mit einbrechnet werden bzw. das Grid weiter nach unten verschoben wird			
self.m_Width = grid("x", 16) 
self.m_Height = grid("y", 12) 

GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Window title", true, true, self)
self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Tab 1", "Tab 2"}) -- fügt Tabs hinzu und gibt ihnen eine füllende Breite
self.m_TabPanel:updateGrid() -- updated das Grid, weil die nächsten Elemente als parent einen tab haben, der keinen Header besitzt (und somit auch keinen oberen Abstand)

self.m_Btn = GUIGridButton:new(1, 1, 5, 1, "cooler Button", self.m_Tabs[1]) --parent am "ersten" Tab
```

### Buttons
Buttons sind elementar für so ziemlich jedes Fenster. Standardmäßig haben sie einen blauen Strich an der Oberseite, der sich beim Hover mit einer Animation weiß färbt. Buttons haben die Höhe 1 - nur wenn der Text eines Buttons zu groß ist, sollte man einen 2 Grid-Einheiten hohen Button verwenden. 

#### Farben
Um die Intention des Buttons hervorzuheben, kann man den Balken einfärben:
``` Lua
self.m_Btn = GUIGridButton:new(1, 1, 5, 1, "cooler Button", self.m_Window) 

self.m_Btn:setBackgroundColor(Color.Red) -- rot = negativ
self.m_Btn:setBackgroundColor(Color.Green) -- grün = positiv
self.m_Btn:setBackgroundColor(Color.Orange) -- orange = Warnung / Achtung (praktisch für Aktionen, bei denen keine weitere Rückfrage bzw. Bestätigung kommt, z.B. Respawnen von Fahrzeugen)
```
Damit die Hervorhebung auch Wirkung hat, sollte man jede Farbe nicht mehr als eimal pro Fenster verwenden (bzw. pro Tab bei einem Tab-Fenster).

#### Primärer Button
Zusätzlich zu den Farben kann ein Button primär werden (sprich die Balkenfarbe wird zur Vollfarbe). Dies ist besonders sinnvoll, wenn man ein Fenster mit vielen Buttons hat und einen hervorheben will, den der Spieler nach aller Erwartung nach drücken sollte (z.B. den "Akzeptieren" Button bei einer Frage). 
``` Lua
self.m_Btn = GUIGridButton:new(1, 1, 5, 1, "cooler Button", self.m_Window) 

self.m_Btn:setBarEnabled(false) -- Balken deaktivieren, nun hat man einen komplett blauen Button
self.m_Btn:setBackgroundColor(Color.Red/Green/Orange) -- optional: Intention als Vollfarbe setzen
```
Ähnlich der Farben ist mehr als ein primärer Button pro Ansicht nicht zielführend und sollte vermieden werden.

#### Icon-Button
Anklickbare Icons lassen sich am besten durch die `GUIGridIconButton`-Klasse realisieren (z.B. der Close-Button). Diese sind im Style eines primären Buttons, können aber wegen ihrer Größe auch mehrfach pro Ansicht vorkommen und schließen einen primären Button nicht aus. Sie haben eine unveränderbare Größe von 1 x 1 Grid-Einheiten.
``` Lua
GUIGridIconButton:new(1, 1, FontAwesomeSymbols.Refresh, self.m_Window) -- Button mit "neu laden" - Icon

--[[andere sinnvolle Icons:
Left, Right - Pfeil nach links/rechts, siehe GUIChanger
Save - speichern-Symbol
SoundOff, SoundOn - Lautstärke-Symbol
http://fontawesome.io/cheatsheet/ - alle anderen ^^
]]
```
Als Text kann direkt das FontAwesome-Icon angegeben werden, zusätzlich kann der Button wie jeder andere nach den gleichen Richtlinien eingefärbt werden.



### Typografie / Labels
Die `GUIGridLabel`-Klasse hat einige Methoden zur Vereinfachung um Texte in ein Fenster zu schreiben. Wichtig ist, dass man zwischen 3 verschiedenen Textgrößen unterscheiden muss: `header`, `subheader` und `normal`.
``` Lua
self.m_Label = GUIGridLabel:new(1, 1, 5, 1, "Text") -- normal
self.m_Label = GUIGridLabel:new(1, 2, 5, 1, "Text"):setHeader() -- header
self.m_Label = GUIGridLabel:new(1, 3, 5, 1, "Text"):setHeader("sub") -- subheader
```
Damit Text nicht über die Bounding Box geht ist folgendes wichtig:
- es darf nur einen Header pro Ansicht geben
- Subheader werden anstelle von mehreren Headern verwendet
- mehr als eine Zeile Text muss immer in mehr als 1 Grid-Höhe sein

### Bilder
Bilder werden mit `GUIGridImage` eingefügt. 
``` Lua
GUIGridImage:new(1, 1, 9, 2, "files/images/LogoNoFont.png", self.m_Window)
```
Aufgrund den fixen Positionen des Grids kann es passieren, dass Bilder gezerrt werden. Dazu gibt es die Methode `fitBySize(origW, origH)`.
``` Lua
GUIGridImage:new(1, 1, 9, 2, "files/images/LogoNoFont.png", self.m_Window):fitBySize(285, 123)
```
Die beiden Zahlen spiegeln die originale Bildgröße wider und werden intern benutzt um das Seitenverhältnis zu ermitteln. Mit diesem wird das Bild innerhalb des angegebenen Grids (also in dem Beispiel `9, 2`) zentriert.

###### 1337