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

Merged Commits verhindern:
> git pull --rebase

Weitere Dokumentation:
https://git-scm.com/book/de/v1