In diesem Dokument wird versucht, einen einheitlichen Scriptstil zu beschreiben.
Dieses Dokument sollte derzeit als Vorschlag gesehen werden, in dem ich versuche, den durchschnittlichen Scriptstil der MTA-Community zu beschrieben.

### Leerzeichen zwischen Funktionsklammern
Zwischen, sowie vor und nach Funktionklammern werden __keine__ Leerzeichen gesetzt.

#### Beispiel
```lua
function eineFunktion(parameter1, parameter2, parameter3)
  print("Hallo Welt!")
end

eineFunktion(1, 2, 3)
```

### Klammern und Leerzeichen bei if-, for-, while-, repeat-until-Blöcken
Klammern werden, wenn sie nicht notwendig sind um den Vorrang zu verändern, nicht geschrieben. Leerzeichen werden außerdem, wie bei Funktionen weggelassen.

#### Beispiel
```lua
local myFirstVar = 1
local mySecondVar = 2
local myThirdVar = 3

-- Klammern sind nicht notwendig --> weglassen
if myFirstVar == 1 then
  print("Hi")
end

-- Klammern sind zur korrekten Auswertung der Bedingung notwendig --> Klammern setzen
if (myFirstVar == 1 or mySecondVar == 1337) and myThirdVar == 42 then
  print("Hallo!")
end
```

### Leerzeichen nach Kommata
Nach Kommata werden grundsätzlich Leerzeichen gesetzt.

#### Beispiel
```lua
function myFunc(a, b, c, d, e, f)
end
myFunc(1, 2, 3, 4, 5, 6)

local myTable = {1, 2, 3, 4, 5, 6}
```

### Tabs vs Leerzeichen
Zur Einrückungen werden __Tabs__ verwendet.

### Ungarische Notation
Da Lua dynamisch typisiert ist, macht eine vollständige Umsetzung der ungarischen Notation keinen Sinn.
Eine eingeschränkte Variante mag jedoch sinnvoll sein für:
* Membervariablen (Präfix: `m_`)
* Klassenvariablen (Präfix: `ms_`)
Zusätzlich wird für Klassen- sowieso Membernamen die *UpperCamelCase-* und für Methoden-, Funktions- sowie lokalen Variablen die *lowerCamelCase-*Notation verwendet.

#### Beispiel
```lua
-- UpperCamelCase für Klassennamen (d.h. Beginn neuer "Wörter" groß)
MyClass = inherit(Object)
MyClass.ms_ClassVariable = 1 -- Klassenvariablen (Präfix: ms_)

function MyClass:constructor(thisPlayer)
  -- UpperCamelCase auch für Membervariablen
  -- lowerCamelCase für lokale Variablen (d.h. erster Buchstabe klein, ansonsten wie UpperCamelCase)
  self.m_ThisPlayer = thisPlayer -- ungarische Notation (m_ bei Membervariablen)
end

-- lowerCamelCase für Methodennamen
function MyClass:thisIsAMethod()
  print("Hallo!")
end
```

### Semikola
Semikola werden an Zeilenenden weggelassen.

### Anführungszeichen
Es werden Double Quotes (`" "`) verwendet.

### Anonyme Funktionen
Anonyme Funktionen werden mit einem Zeilenumbruch eingeleitet.

```lua
addEventHandler("onClientRender", root,
  function()
    dxDrawRectangle(0, 0, 100, 100, tocolor(100, 100, 100))
  end
)
```

### Header
Folgender Header sollte einheitlich verwendet werden. 
Autor und Datum sind irrelevant, da man dies sowieso übersichtlich in Github sieht.

```lua
-- ****************************************************************************
-- *
-- *  PROJECT:     [ProjectName]
-- *  FILE:        [FilePath]
-- *  PURPOSE:     [Description]
-- *
-- ****************************************************************************
```
