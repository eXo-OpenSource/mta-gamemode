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
    git clone git@git.heisi.at:eXo/mta-gamemode.git
    ```
5. In den Ressourcenordner gehen und dann folgendes ausführen:

    ```
    mklink /J [vrp] "pfadZumGitKlon"
    ```
    Dies erzeugt einen symbolischene Verknüpfung zum eigentlichen Ressourcenordner.
6. Config-Vorlage `config.json.dist` unter `vrp/server/config/` nach `config.json` kopieren.

## Git-Tipps und -Workflows
### Von der Änderung zum Server
Bevor Änderungen gemacht werden, am besten einmal die Änderungen vom Server holen:
```
git pull
```

Wenn ihr Änderungen vorgenommen habt alle Dateien zum Committen markieren:
```
git add .
```

Vor dem eigentlichen Committen empfiehlt es sich jedoch, die Änderungen noch einmal anzuschauen:
```git diff --staged```
Das `--staged` ist nötig, da die Änderungen durch obiges `git add` schon _gestaged_ wurden.

Nun kann der Commit erstellt werden:
```
git commit -m "[Changelog Text]"
```

Danach alle getätigten Commits zum Server hochladen
```
git push
```

Wenn hier ein Fehler auftaucht und man aufgefordert wird zu pullen, ist folgender Fall eingetreten:
Man hat lokal Commits, die auf auf einem nicht aktuellen Zustand des Repositories basieren (da jemand anderes
in der Zwischenzeit schon Commits gepusht hat).
Ein normales `git pull` würde dazu führen, dass zusätzlich ein Merge-Commit erstellt wird, der den neuen und alten Entwicklungszweig zusammenführt.
Dies ist jedoch in so gut wie keinen Fällen nötig. Stattdessen empfiehlt es sich die entfernten Commits zu rebasen
(das bedeutet: lokale Commits temporär rückgängig machen, die Commits vom Server herunterladen und anwenden und schließlich die lokalen Commits auf
die aktuelle Version des Repos anwenden):
```
git pull --rebase
```

### Neustes Update auf den Produktiv-Server laden
Bevor Änderungen gemacht werden, müssen wir zuerst unseren lokalen master branch auf den aktuellsten stand bringen
```
git pull
```

Nun wechseln wir in den `release/production` branch und updaten diesen branch bei uns lokal
```
git checkout release/production
git pull
```

Jetzt können wir den master mergen und die Updates in den branch "laden"
```
git merge master
```

Und dann pushen wir das ganze zum Server
```
git push
```

Das Update wird dann automatisch um 05:00 Uhr auf den Server geladen!

### Hotfixes auf dem Produktiv-Server machen

1. Hotfix-Branch auf basis von `release/production` erstellen
	```
	git checkout release/production
	git pull
	git checkout -b hotfix/mein-hotfix-name
	```
	Als Konvention hat es sich eingebürgert den Namen danach durch Bindestriche zu trennen.

2. Jetzt können ganz normal Commits gemacht werden. Sollte beim Pushen eine Fehlermeldung erscheinen, kann folgender Pushbefehl verwendet werden:

    ```
    git push origin hotfix/mein-hotfix-name
    ```
3. Ist der Bug behoben, wird zunächst zurück auf den master gewechelt:

    ```
    git checkout master
    ```
4. Nun wird der Hotfix-Branch squash-gemerged. Das bedeutet, dass alle Commits zu einem einzigen zusammengeführt (_gesquasht_) werden.

    ```
   	git merge --squash hotfix/mein-hotfix-name
	```
5. Den schritt 3 & 4 wiederholen wir auch nochmal für den Branch `release/production`

    ```
    git checkout release/production
	git merge --squash hotfix/mein-hotfix-name
    ```

6. Am Ende nur noch pushen und den Hotfix-Branch löschen:

    ```
    git push
    git push origin :hotfix/mein-hotfix-name # Doppelpunkt löscht den Branch auf dem Server
    git branch -d hotfix/mein-hotfix-name # Branch lokal auch löschen (optional)
    ```
7. Um den Hotfix auf den Server zu laden, zu `https://git.heisi.at/eXo/mta-gamemode/environments` navigieren und bei der Spalte `production` auf `Re-deploy` klicken, dadurch wird der hotfix auf den Produktiv-Server geladen und neu gestartet.

### Bugfixes auf dem Dev-Server machen
_Fast-Deploy_ ermöglicht es Änderungen zu machen, die nahezu sofort auf dem Dev-Server verfügbar sind.
Weiterhin können hier problemlos viele Fix-Commits gemacht werden, da am Ende alle Änderungen zu einem einzigen Commit zusammengeführt werden.

1. Bugfix-Branch erstellen:

    ```
    git checkout -b bugfix/mein-bugfix-name
    ```
   Wichtig ist hierbei das `bugfix/` Präfix, welches wichtig ist, damit der Branch auch als Bugfix-Branch erkannt wird.
   Als Konvention hat es sich eingebürgert den Namen danach durch Bindestriche zu trennen.
2. Jetzt können ganz normal Commits gemacht werden. Sollte beim Pushen eine Fehlermeldung erscheinen, kann folgender Pushbefehl verwendet werden:

    ```
    git push origin bugfix/mein-bugfix-name
    ```
3. Ist der Bug behoben, wird zunächst zurück auf den master gewechelt:

    ```
    git checkout master
    ```
4. Nun wird der Bugfix-Branch squash-gemerged. Das bedeutet, dass alle Commits zu einem einzigen zusammengeführt (_gesquasht_) werden.

    ```
   git merge --squash bugfix/mein-bugfix-name
   ```
   Sollen alle Commits erhalten bleiben (z.B. weil nur ein einziger Commit getätigt wurde), kann das `--squash` auch weggelassen werden.
5. Am Ende nur noch pushen und den Bugfix-Branch löschen:

    ```
    git push
    git push origin :bugfix/mein-bugfix-name # Doppelpunkt löscht den Branch auf dem Server
    git branch -d bugfix/mein-bugfix-name # Branch lokal auch löschen (optional)
    ```

### Nützliche Befehle
#### Änderungen für später verstauen
```
git stash
```

#### Oberste Änderungen aus dem Stash-Stapel wieder anwenden
```
git stash pop
```


## Datenbank
Zugangsdaten stehen in `vrp/server/config/config.json.dist`
