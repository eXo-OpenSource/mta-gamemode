# vRoleplay: Gamemode/Script

## Installation
https://github.com/Jusonex/vRoleplay_Script klonen

In den Ressourcenordner gehen und dann folgendes ausführen:
``mklink /J [vrp] "pfadZumGitKlon"``

## Datenbank
Zugangsdaten stehen in vrp/server/constants.lua

## Git Crash-Kurs
Hier eine kurze Anleitung zum Git
Ich benutze Git Bash (https://git-scm.com/downloads)

Als erstes die Repository ins gewünschte Verzeichnis clonen:

> git clone https://github.com/Jusonex/vRoleplay_Script.git

Wenn ihr allein auf dem PC arbeitet könnt ihr auch folgendes benutzen:
(Dann wird nicht jedes mal der Benutzer und das Passwort abgefragt)
> git clone https://USERNAME:PASSWORD@github.com/Jusonex/vRoleplay_Script.git

Vor jedem arbeiten am Code am besten die Repository aktualisieren:
> git pull

Wenn ihr Änderungen vorgenommen habt alle Dateien zum Index hinzufügen:
> git add .

Der Commit wird mit folgenden Befehl gemacht:
> git commit -m "[Changelog Text]"

Danach die Repository auf Github übertragen:
> git push

---
**Weitere Befehle:**
Änderungen für Später verstauen:
> git stash

Änderungen zusammenführen (wenn es Konflikte gibt):
> git stash pop

Merge-Commit verhindern:
> git pull --rebase

Weitere Dokumentation:
https://git-scm.com/book/de/v1

## Klassen Crash-Kurs
### Promises
Beispiel:
```lua
-- See JS-Example: https://www.promisejs.org @ Constructing a promise + Transformation / Chaining

local readString = function ()
	return Promise:new(function (fullfill, reject)
		-- Example (here shorten): We're reading a json string from a file
		local err = false -- err is true, when file reading fails
		if err then
			reject("A error")
		else
			-- The string is the json string from a file
			fullfill("[ { \"a_number\": 12, \"date_of_birth\": \"11.05.1998\", \"name\": \"StiviK\", \"a_boolean\": false } ]")
		end
	end)
end
local readJSON = function () -- function which reads json from the file and parses it
	return readString().next(fromJSON)
end

readJSON().done( -- implement handlers for the readJSON function
	function (result) -- function if the progress is successful
		outputDebug(table.compare(result, {["name"] = "StiviK", ["date_of_birth"] = "11.05.1998", ["a_number"] = 12, ["a_boolean"] = false}))
	end,
	function (err) -- err function if file reading fails
		error(err)
	end
)
```
