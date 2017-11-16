# Transfer Money

## transferMoney
````
- table/object toObject
- int amount
- string reason
- string category
- string subcategory
`````

valid parameters for toObject
````
- object (Player, Faction, Company, Group)
- {string objectName, int objectId [, bool toBank, bool silent, bool allIfToMuch}
- {object (Player, Faction, Company, Group), bool toBank [, bool silent, bool allIfToMuch]}
````

The transferMoney method is implemented for the faction, company, group and player object. The player object is a little bit different.

The player object has a transferMoney and transferBankMoney.
- transferMoney - allows to transfer money from the players cash
- transferBankMoney - allows you transfer money from the bank

Example:
Transfer cash from me to the cash of the player Stumpy
`me:transferMoney(player("Stumpy"), 1000, "Überweisung", "Category", "Subcategory")`

Transfer cash from me to the bank of the player Stumpy
`me:transferMoney({player("Stumpy"), false, true}, 1000, "Überweisung", "Category", "Subcategory")`

Transfer bank money to the faction bank
`me:transferBankMoney(me:getFaction(), 1000, "Überweisung", "Category", "Subcategory")`

Transfer bank money to an server bank account
`me:transferBankMoney(BankServer.get("test"), 1000, "Überweisung", "Category", "Subcategory")`

# Server Bank Account

`BankAccount BankServer.get(string name)`
This function returns a bank account for the server. If it doesnt exist it will be created.


# Required database update
```
CREATE TABLE `vrpLogs_MoneyNew` (
`Id`  int NOT NULL AUTO_INCREMENT ,
`FromId`  int NULL ,
`FromType`  int NULL ,
`FromBank`  int NULL ,
`ToId`  int NULL ,
`ToType`  int NULL ,
`ToBank`  int NULL ,
`Amount`  bigint NULL ,
`Reason`  varchar(255) NULL ,
`Category`  varchar(32) NULL ,
`Subcategory`  varchar(32) NULL ,
`Date`  datetime NULL ON UPDATE CURRENT_TIMESTAMP ,
PRIMARY KEY (`Id`)
)
;
```

# Stuff that needs testing after the update
    - Admin Kasse (Ein-/Auszahlen)
	- Fahrschule Theorie
	- Fahrschule Prüfung NPC und mit Spieler
	- Mechaniker Reperatur
	- Mechaniker Fahrzeug freikaufen
	- Mechaniker Tanken
	- Taxifahrt
	- Busfahrt (Spieler, Kilometergeld)
	- San News Werbung
	- Unternehmen (Ein-/ Auszahlen)
	- DM Race
	- Streetrace
	- BankRobbery (State & Evil)
	- Evidence Truck
	- Weapon Truck
	- Fraktion Robbery
	- Fraktion (Ein-/ Auszahlen)
	- Rescue Heilung NPC
	- Rescue Heilung Player
	- Tod Geld Pickup (selbst und fremder Spieler aufheben)
	- Rescue Fahrzeugbrand
	- Staatsfraktion Kautionsticket
	- Staatsfraktion Arrest
	- Jail Bail
	- Wanzencheck (Mechanics)
	- Gangwar Payday
	- Gangwar Kill Boni
	- Beggars Geld geben
	- Rescue Feuer
	- Beggar Rob
	- Beggar Trade
	- Beggar Weed Sell
	- Gameplay Boxen
	- Slotmachine Eastern Event
	- Fische verkaufen
	- Shop (Sell/Buy)
	- Fahrzeug tanken (Shop)
	- Roulett
	- Schildkrötenrennen
	- Horse Race
	- Shop Rob (State, Evil, Expire)
	- Shop buy (food, items, clothes, weapons, item drink?)
	- Shop deposit/withdraw
	- Vehicle Shop - Fahrzeug kaufen
	- Slotmachine
	- Vending Machine (Buy, Rob)
	- Group
	- Faction Drug Asservation
	- Group Spray Wall/Gang Area
	- Group Payday (positive and negative)
	- Group HouseRob
	- Group delete
	- Group (Deposit/Withdraw)
	- Group Property (Sell/Buy)
	- Evil Faction Kill Boni
	- Player Trade
	- Player Weapon Trade
	- Player Vehicle Trade
	- Event Halloween
	- House Rob
	- House Deposit/Withdraw
	- House Sell/Buy
	- Speedcam
	- Farmer Job
	- Bank Withdraw/Deposit
	- San News Donation
	- eXo Event-Team Donation
	- Bank Transfer (Offline/Online)
	- State Kill Arrest
	- Player send money (with clickmenu)
	- Server Tour
	- Pay N Spray
	- Toll Station
	- Group Vehicle Sell
	- Vehicle sell to server
	- Job Fork Lift
	- Job Heli Transport
	- Job Logistician
	- Job Lumberjack
	- Job Pizza Delivery
	- Job Road Sweeper
	- Job Trashman
	- Job Treasure Seeker
	- Payday
	- Garage Upgrade
	- Hangar Upgrade
	- Vehicle Respawn
	- Shop Ammunation (mobile)
	- Arrest of player
	- Gas Station (User owend, Faction, Company)
	- Kart
	- Shooting Ranch
	- Deathmatch Arena
	- Weed Truck
	- Weapon Truck
	- ShopBar Stripper
	- Skin Shop
	- Skydive
	- Group creation, rename, type change, tuning activation
	- Harbor Repair
	- Vehicle Tunings