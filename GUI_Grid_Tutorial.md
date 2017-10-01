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

## Styleguide
Damit Fenster einheitlich aussehen sollten sie folgende Richtlinien einhalten:
- nur ganze Grid-Einheiten
## neues Fenster erstellen 
``` Lua
    --TODO
```




###### 1337