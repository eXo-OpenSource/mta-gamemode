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