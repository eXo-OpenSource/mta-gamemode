# vRoleplay

<p align="center">
    <img src="./images/exo-vrp.png" />
</p>

<p align="center">
vRoleplay ist ein in Lua geschriebener Reallife/Roleplay Gamemode für <a href="https://multitheftauto.com/">Multi Theft Auto: San Andreas</a>.
</p>

### Features:
- Fraktionen
    - Staatsfraktionen (Police Department, FBI, Army)
        - Waffen- und Geldtrucks
        - Bewahren der Ordnung auf den Straßen
        - Verfolgung von Straftätern
    - Rescue Team
        - Feuerbekämpfung
        - Rettung verletzter Spieler
    - Verschiedene Gangs und Mafien
        - Gangwars
        - Bankräube
        - Waffen- und Drogentrucks
        - Airdrops
    
- Unternehmen
    - Fahrschule
        - Führerscheine an Spieler verteilen
    - San News
        - Mitteilen von Neuigkeiten an die Spieler
    - Mech and Tow
        - Abschleppen von falschparkenden und liegengebliebenen Autos
    - Public Transport
        - Beförderung von Spielern und Autohändler mit Neuwagen beliefern

- Private Firmen/Gangs
    - Verkauf/Verleih von Fahrzeugen
    - Überfallen von Geschäften

- Aktivitäten
    - Angeln
    - Casino
    - Fahrzeugtuning
    - Jobs
    - Kanalisation mit geheimen Casino und Waffenhändler
    - Kino
    - Minigames
    - Saisonale Events (Ostern, Halloween, Weihnachten, Silvester)

- Achievements

- Häuser/Wohnungen/Garagen

- Inventar

- Selbstbehandlung von Wunden

- Spendensystem

- Umfangreiches UI inklusive Handy mit verschiedenen Apps

- Serververwaltung
    - Umfangreiche Administrations Funktionen
    - Integrierter Map Editor
    - Modding Kontrolle
    - Integration mit Woltlab Forum und Control Panel

- Und viel mehr!

## Installation

### Docker (empfohlen)
1. Docker installieren

2. `docker-compose.yml` aus dem Repository herunterladen und bei Bedarf anpassen

3. Befehl zum Starten der Container ausführen: 
    ```
    docker compose up -d
    ```

### Manuell
1. vRoleplay herunterladen

2. MariaDB Server herunterladen und eine Datenbank für vRoleplay erstellen
    
2. In den Ressourcenordner gehen und dann folgendes ausführen:

    Unter Windows:
    ```
    mklink /J [vrp] "Pfad zum vRoleplay Ordner (nicht vrp)"
    ```

    Unter Linux oder macOS:
    ```
    ln -s 'Pfad zum vRoleplay Ordner (nicht vrp)' '[vrp]'
    ```
    Dies erzeugt einen symbolischene Verknüpfung zum eigentlichen Ressourcenordner

3. Config-Vorlage `config.ini.example` unter `vrp/server/config/` nach `config.ini` kopieren und ausfüllen

### Admin Rechte
Nach dem erstellen eines Accounts in der Datenbank in der Tabelle `vrp_account` bei dem erstellen Account in die Spalte `Rank` __9__ (Projektleiter) eintragen.