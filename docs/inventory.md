#### Inventar-Rework der Extraklasse

# Klassen

## InventoryManager
- beherbergt alle momentan auf dem Server geladenen Inventare
- ist für das Laden und Speichern zuständig
- managed die Transaktionen von Items über Inventare hinweg

```Lua
function InventoryManager:createInventory()
    return new()
end

function InventoryManager:deleteInventory()
    unload()
    delete()
end

function InventoryManager:loadInventory(int Uid)
    return load()
end

function InventoryManager:unloadInventory(int Uid)
    save()
    unload()
end

function InventoryManager:isItemGivable(int Uid, int itemId, int amount)
    checkIfCategoryAllowed()
    checkIfSpace()
end

function InventoryManager:isItemRemovable(int Uid, int itemId, int amount)
    checkIfCategoryAllowed()
    checkIfSpace()
end

function InventoryManager:removeItem()
    if self:isItemRemovable() then
        remove()
        return true
    end
    return false
end

function InventoryManager:giveItem()
    if self:isItemGivable() then
        give()
        return true
    end
    return false
end

function InventoryManager:transactItem(int givingInventoryUId, int recievingInventoryUid, int itemId, int amount, [string value])
    if self:isItemRemovable() and self:isItemGivable() then
        self:removeItem()
        self:giveItem()
        return true
    else 
        return self:isItemRemovable(), self:isItemGivable()
    end
end
```

### Methoden, um die alten Inventare zu migrieren
TODO

## Inventory
- Basisklasse für ein Inventar
```Lua
function Inventory:constructor(int Uid, int inventoryType, int ownerId)

function Inventory:hasPlayerAccessTo(ele player)
    -- Typbasierte Checks, bspw.:
    --  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
    --  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
    --  Haus: ist der Spieler Mieter / Besitzer des Hauses
end
```

## ItemManager
- lädt Itemdaten aus der Datenbank und wird verwendet, um statische Infos über Items zu erhalten (Kategorie, Gewicht etc.)

## Item
- Jedes Objekt dieser Klasse repräsentiert einen Itemstack aus der Datenbank
- jedes Item hat eine eigene, vom Script generierte UID, damit in einem Item mehrere Stacks gleicher Items gespeichert werden können (bspw. )
```Lua
function Item:constructor(int Uid, string name, int amount, [string value])
```

## ItemCategoryManager
- Hilfsklasse, die die Itemkategorien aus der DB lädt

# Generelle Struktur der Objekte

```Lua
InventoryManager.Map = { -- beinhaltet alle Inventare
    [InventarUid1] = { -- beinhaltet alle Kategorien 
    --(diese Tabelle wird zum client gesendet, wenn er das Inventar öffnet)
        ["Kategoriename1"] = { -- beinhaltet die Kategorien aller Items
            [ItemUid1] = {string name1, int anzahl, string value},
            [ItemUid2] = {string name1, int anzahl, string anderervalue},
            [ItemUid3] = {string name2, int anzahl}, -- kein value
            ...
        },
        ["Kategoriename2"] = {
            ...
        }
    },
    [InventarUid2] = {
        ...
    }
    ...
}
```




# Datenbanktabellen

TODO by MegaThorx

# Inventartypen
- Spieler
- Fahrzeug (Kofferraum)
- Fraktionslager (auch für Weltobjekte -> Kegel etc.)
- Unternehmenslager (Kegel und Objekte für Sannews etc)
- Gruppenimmo-Lager

# Weiteres
- nur zwei UIs clientseitig:
    - __InventoryViewUI__
    - ein einzelnes Inventar wo man Items ansehen kann
    - Kategorieauswahl links als Gridlist
    - zusätzlich dazu kann man (wenn erlaubt) auch mit den Items interagieren
    - bspw. das ganz normale Inventar (Taste `I`)
    - __InventoryTransactGUI__
    - zwei Inventare nebeneinander, jeweils darüber ein Text für den Namen
    - Kategorieauswahl in der Mitte zwischen den Inventaren
    - umlagern von Items zwischen Inventaren möglich, aber keine Interaktion
    - bspw. Kofferraum