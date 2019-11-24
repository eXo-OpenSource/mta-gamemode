# TODO

- [ ] Rewrite all ItemClasses for new Inventory
- [ ] Rework StatisticsLogger:getSingleton():worldItemLog
- [ ] Fix StaticWorldItems
- [ ] Rewrite WorldItem GUI for Admins
- [ ] Implement inventory auto cleanup
- [ ] Reimplement trading
- [ ] Replace all old giveItem & takeItem
- [ ] Look for hardcoded item ids
- [ ] Write testing list
- [ ] Write world items migration
- [ ] Replace property inventory with new inventory
- [ ] Replace weapon depot with new inventory
- [ ] Implement new weapon handling with inventory
- [ ] Create new GUI for trading
- [ ] Fix WorldItems saving (metadata etc. Door, Keypad) and rework Id

- [o] Create new GUI for inventory interaction <- partialy __needs__ better GUI?

- [x] Write inventory migration
- [x] Implement inventory interactions (player inventory -> vehicle inventory)
- [x] Implement inventory storing
- [x] Replace vehicle trunk with new inventory
- [x] Create new GUI for inventory - needs more love
- [x] Rework WorldItem & Item IDs!!
- [x] Rework WorldItems
- [x] Implement inventory change events

## Items

* ItemFurniture = ItemFurniture;
* ItemTransmitter = ItemTransmitter;
* ItemSpeedCam = ItemSpeedCam;
* ItemNails = ItemNails;
* ItemEasteregg = ItemEasteregg;
* ItemPumpkin = ItemPumpkin;
* ItemTaser = ItemTaser;
* ItemSmokeGrenade = ItemSmokeGrenade;
* ItemDefuseKit = ItemDefuseKit;
* ItemFishing = ItemFishing;
* ItemSellContract = ItemSellContract;
* WearableHelmet = WearableHelmet;
* WearableShirt = WearableShirt;
* WearablePortables = WearablePortables;
* WearableClothes = WearableClothes;
* ItemEntrance = ItemEntrance;
* ItemDoor = ItemDoor; - started
* ~~ItemBomb = ItemBomb;~~ - done
* ~~ItemRadio = ItemRadio;~~ - done
* ~~ItemBarricade = ItemBarricade;~~ - done
* ~~ItemDonutBox = ItemDonutBox;~~ - done
* ~~ItemSlam = ItemSlam;~~ - done
* ~~ItemFuelcan = ItemFuelcan;~~ - done
* ~~ItemRepairKit = ItemRepairKit;~~ - done
* ~~ItemFood = ItemFood;~~ - done
* ~~ItemKeyPad = ItemKeyPad;~~ - done
* ~~ItemDrugs = ItemDrugs;~~ - done
* ~~ItemDice = ItemDice;~~ - done
* ~~Plant = Plant;~~ - done
* ~~ItemCan = ItemCan;~~ - done
* ~~ItemIDCard = ItemIDCard;~~ - done
* ~~ItemHealpack = ItemHealpack;~~ - done
* ~~ItemAlcohol = ItemAlcohol;~~ - done
* ~~ItemFirework = ItemFirework;~~ - done
* ~~ItemSkyBeam = ItemSkyBeam;~~ - remove

## Notes

### Sky Beam
Object ID: 2887

### Give yourself every item
`drun for k, v in pairs(ItemManager:getSingleton().m_Items) do me:getInventory():giveItem(v.TechnicalName, 1) end`

#### Inventar-Rework der Extraklasse

# Klassen

## InventoryManager

-   beherbergt alle momentan auf dem Server geladenen Inventare
-   ist für das Laden und Speichern zuständig
-   managed die Transaktionen von Items über Inventare hinweg

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

Spalte Technical Name erstellen (alte Items-Tabelle) und bei Startup beim Script prüfen ob schon die neuen Inventartabellen vorhanden sind (siehe Vehicle Migration auf eine Tabelle) und falls diese noch fehlen die Migration startet. Alle Items die nicht in das neue Inventar passt kann man dann bei einem NPC abholen? Dies müsste man dann natürlich mehrfach zuvor testen.

## Inventory

-   Basisklasse für ein Inventar

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

-   lädt Itemdaten aus der Datenbank und wird verwendet, um statische Infos über Items zu erhalten (Kategorie, Gewicht etc.)

## Item

-   Jedes Objekt dieser Klasse repräsentiert einen Itemstack aus der Datenbank
-   jedes Item hat eine eigene, vom Script generierte UID, damit in einem Item mehrere Stacks gleicher Items gespeichert werden können (bspw. )

```Lua
function Item:constructor(int Uid, string name, int amount, [string value])
```

## ItemCategoryManager

-   Hilfsklasse, die die Itemkategorien aus der DB lädt

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

Items dürfen bei einer Transaction nicht ihre ID ändern! (Nachverfolgbarkeit)

TODO by MegaThorx

## vrp_item_categories

-   Id int PK
-   Name varchar(128) NOT NULL

## vrp_items

-   Id int PK
-   TechincalName varchar(128) NOT NULL
-   CategoryId int NOT NULL FK
-   Class varchar(128) NOT NULL
-   Name varchar(128) NOT NULL
-   Description text NOT NULL DEFAULT ''
-   Consumable bool NOT NULL DEFAULT 0
-   Icon varchar(128) NOT NULL
-   Size int NOT NULL
-   ModelId int NOT NULL DEFAULT 0
-   MaxDurability int NOT NULL DEFAULT 0
-   Tradeable bool NOT NULL DEFAULT 0
-   Expireable bool NOT NULL DEFAULT 0
-   IsUnique bool NOT NULL DEFAULT 0
-   Throwable bool NOT NULL DEFAULT 0
-   Breakable bool NOT NULL DEFAULT 0

## vrp_inventory

-   Id int PK
-   ElementId int NOT NULL
-   ElementType int NOT NULL (1 - player, 2 - faction, 3 - company, 4 - vehicle, 5 - house, 6 - TBD)
-   Size int NOT NULL
-   AllowedCategories text NOT NULL (json array with types)
-   Deleted datetime NULL

## vrp_inventory_items

-   Id varchar(36) PK
-   InventoryId int NOT NULL FK
-   ItemId int NOT NULL FK
-   Slot int NOT NULL
-   Amount int NOT NULL DEFAULT 0
-   Durability int NOT NULL DEFAULT 0
-   Metadata text NULL

```sql
CREATE TABLE `vrp_item_categories`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `TechnicalName` varchar(128) NOT NULL,
  `Name` varchar(128) NOT NULL,
  PRIMARY KEY (`Id`)
);

CREATE TABLE `vrp_items`  (
  `Id` int(0) NOT NULL AUTO_INCREMENT,
  `TechnicalName` varchar(128) NOT NULL,
  `CategoryId` int(0) NOT NULL,
  `Class` varchar(128) NOT NULL,
  `Name` varchar(128) NOT NULL,
  `Description` text NOT NULL DEFAULT '',
  `Icon` varchar(128) NOT NULL,
  `Size` int(0) NOT NULL,
  `ModelId` int(0) NOT NULL DEFAULT 0,
  `MaxDurability` int(0) NOT NULL DEFAULT 0,
  `DurabilityDestroy` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Destroys item on zero durability',
  `Consumable` tinyint(1) NOT NULL DEFAULT 0,
  `Tradeable` tinyint(1) NOT NULL DEFAULT 0,
  `Expireable` tinyint(1) NOT NULL DEFAULT 0,
  `IsUnique` tinyint(1) NOT NULL DEFAULT 0,
  `IsStackable` tinyint(1) NOT NULL DEFAULT 0,
  `Throwable` tinyint(1) NOT NULL DEFAULT 0,
  `Breakable` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`CategoryId`) REFERENCES `vrp_item_categories` (`Id`)
);

CREATE TABLE `vrp_inventory_types`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `TechnicalName` varchar(128) NOT NULL,
  `Name` varchar(128) NOT NULL,
  `Permissions` text NOT NULL,
  PRIMARY KEY (`Id`)
);

CREATE TABLE `vrp_inventory_type_categories`  (
  `TypeId` int NOT NULL,
  `CategoryId` int NOT NULL,
  PRIMARY KEY (`TypeId`, `CategoryId`),
  FOREIGN KEY (`TypeId`) REFERENCES `vrp_inventory_types` (`Id`),
  FOREIGN KEY (`CategoryId`) REFERENCES `vrp_item_categories` (`Id`)
);

CREATE TABLE `vrp_inventories`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `ElementId` int NOT NULL,
  `ElementType` int NOT NULL,
  `Size` int NOT NULL,
  `TypeId` int NOT NULL,
  `Deleted` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`TypeId`) REFERENCES `vrp_inventory_types` (`Id`)
);

CREATE TABLE `vrp_inventory_items`  (
  `Id` varchar(36) NOT NULL AUTO_INCREMENT,
  `InventoryId` int(0) NOT NULL,
  `ItemId` int(0) NOT NULL,
  `Slot` int(0) NOT NULL,
  `Amount` int(0) NOT NULL,
  `Durability` int(0) NOT NULL,
  `Metadata` text NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  FOREIGN KEY (`InventoryId`) REFERENCES `vrp_inventories` (`Id`) ON DELETE CASCADE,
  FOREIGN KEY (`ItemId`) REFERENCES `vrp_items` (`Id`)
);

INSERT INTO vrp_item_categories VALUES (1, 'food', 'Essen'), (2, 'weapons', 'Waffen');
INSERT INTO vrp_inventory_types VALUES (1, 'player_inventory', 'Spielerinventar', ''), (2, 'weaponbox', 'Waffenbox', '[["faction": [1, 2, 3]]]');
INSERT INTO vrp_inventory_type_categories VALUES (1, 1), (1, 2), (2, 2);
INSERT INTO vrp_items VALUES (1, 'burger', 1, 'Burger', 'Burgershot Burger', 'myAwesomeBurger.png', 1, 0, 0, 1, 1, 1, 0);
INSERT INTO vrp_inventories VALUES (1, 4123, 1, 32, 1), (2, 2, 1, 32, 2);
INSERT INTO vrp_inventory_items VALUES (1, 1, 1, 1, 1, 0, '');
```

```sql
DROP TABLE vrp_inventory_items;
DROP TABLE vrp_inventories;
DROP TABLE vrp_inventory_type_categories;
DROP TABLE vrp_inventory_types;
DROP TABLE vrp_items;
DROP TABLE vrp_item_categories;
```

# Inventartypen

-   Spieler
-   Fahrzeug (Kofferraum)
-   Fraktionslager (auch für Weltobjekte -> Kegel etc.)
-   Unternehmenslager (Kegel und Objekte für Sannews etc)
-   Gruppenimmo-Lager

# Weiteres

-   Für die Worlditems ein eigenes Inventar?
-   Wie wir die Waffen am besten abbilden?
-   nur zwei UIs clientseitig:
    -   **InventoryViewUI**
    -   ein einzelnes Inventar wo man Items ansehen kann
    -   Kategorieauswahl links als Gridlist
    -   zusätzlich dazu kann man (wenn erlaubt) auch mit den Items interagieren
    -   bspw. das ganz normale Inventar (Taste `I`)
    -   **InventoryTransactGUI**
    -   zwei Inventare nebeneinander, jeweils darüber ein Text für den Namen
    -   Kategorieauswahl in der Mitte zwischen den Inventaren
    -   umlagern von Items zwischen Inventaren möglich, aber keine Interaktion
    -   bspw. Kofferraum



# Testing list
* All WorldItems (KeyPads, ...)

# World Items rework

```sql
CREATE TABLE `vrp_world_items`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Item` varchar(128) NOT NULL,
  `Model` int NOT NULL,
  `ElementId` int NOT NULL,
  `ElementType` int NOT NULL COMMENT '1 = Player, 2 = Faction, 3 = Company, 4 = Group',
  `PlacedBy` int NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `RotX` float NOT NULL,
  `RotY` float NOT NULL,
  `RotZ` float NOT NULL,
  `Interior` int NOT NULL,
  `Dimension` int NOT NULL,
  `Value` text NOT NULL DEFAULT '',
  `Metadata` text NULL DEFAULT NULL,
  `Breakable` tinyint(1) NOT NULL DEFAULT 0,
  `Locked` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL,
  `UpdatedAt` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`)
);

INSERT INTO vrp_world_items SELECT * FROM vrp_WorldItems;
```
