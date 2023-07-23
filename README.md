# vRoleplay: Gamemode
## Installation
1. Git herunterladen: https://git-scm.com/download/win (bei der Installation TortoisePlink als SSH-Client auswählen
2. Wahlweise kann _zusätzlich_ eine grafische Git-Oberfläche installiert werden.
   Empfohlen sei an dieser Stelle TortoiseGit (https://tortoisegit.org/) und
   GitKraken (https://www.gitkraken.com/), __nicht__ jedoch _GitHub for Windows_, da
   dieses die Komplexität von Git zu sehr verbirgt und leicht zu Fehlern führt.
3. SSH-Agent installieren: https://the.earth.li/~sgtatham/putty/latest/x86/pageant.exe
4. Git klonen:

    ```
    git clone git@github.com:eXo-OpenSource/mta-gamemode.git
    ```
5. In den Ressourcenordner gehen und dann folgendes ausführen:

    Unter Windows:
    ```
    mklink /J [vrp] "pfadZumGitKlon"
    ```

    Unter Linux oder macOS:
    ```
    ln -s 'pfadZumGitKlon' '[vrp]'
    ```
    Dies erzeugt einen symbolischene Verknüpfung zum eigentlichen Ressourcenordner.
6. Config-Vorlage `config.ini.example` unter `vrp/server/config/` nach `config.ini` kopieren.

## Datenbank
`tables.sql` unter `vrp/` in einen MariaDB Server importieren.
