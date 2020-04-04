-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupHouseRob.lua
-- *  PURPOSE:     Group HouseRob class
-- *
-- ****************************************************************************
local findItems =
{
	"TV-Reciever",
	"Handy",
	"Armbanduhr",
	"Kreditkarte",
	"Radio",
	"Schmuckkette",
	"Goldring",
	"Tablet",
	"Laptop",
	"MP3-Player",
	"Digitalkamera",
	"Elektrokabel",
}

local sellerPeds =
{
   {{2344.76, -1233.29, 22.50, 74}, "Piotr Scherbakov", {2348.10, -1233.54, 22.62,240},44, "Du siehst mir aus wie jemand der etwas loswerden will!"},
   {{2759.16, -1177.98, 69.40, 74}, "Jorvan Krajewski", {2762.65, -1178.32, 69.52,262}, 73, "Komme hierhin, zeig Sache ich mach Preis!"},
   {{2046.80, -1987.59, 13.80}, "Machiavelli Johnson", {2046.59, -1991.5, 13.5}, 143, "Komm mal ran, du willst doch sicherlich n' bisschen Geld oder?"},
   {{1730.60, -2148.86, 13.55,109}, "Carlos Peralta", {1734.09, -2147.95, 13.68,280}, 114, "Ese, zeig deine Sachen oder verschwinde."},
}

GroupHouseRob = inherit( Singleton )
GroupHouseRob.COOLDOWN_TIME = 1000*60*15
addRemoteEvents{"GroupRob:SellRobItems"}
function GroupHouseRob:constructor()
	self.m_GroupsRobCooldown = {}
	self.m_HousesRobbed = {}
	self.m_SellerPeds = {}
	self.m_OnSellerClick = bind(self.Event_onClickPed, self)
	self.m_OnColShapeHit = bind(self.Event_onColHit, self)
	self.m_BankServerAccount = BankServer.get("action.house_rob")
	addEventHandler("GroupRob:SellRobItems", root, bind(self.Event_OnSellAccept, self))
	local pedPos, pedName, vehPos, skin, ped, sellvehicle, greetText
	for i = 1,#sellerPeds do
		pedPos = sellerPeds[i][1]
		pedName = sellerPeds[i][2]
		vehPos = sellerPeds[i][3]
		skin = sellerPeds[i][4]
		ped = createPed(skin, pedPos[1],pedPos[2],pedPos[3],pedPos[4])
		sellvehicle = createVehicle(482,vehPos[1],vehPos[2],vehPos[3],0,0,vehPos[4])
		greetText = sellerPeds[i][5]
		setVehicleDoorOpenRatio(sellvehicle, 4,1)
		setVehicleDoorOpenRatio(sellvehicle, 5,1)
		setVehicleDoorOpenRatio(sellvehicle, 1,1)
		setElementCollisionsEnabled ( sellvehicle, false)
		setVehicleColor(sellvehicle, 100,100, 100,100,100,100)
		setElementFrozen(sellvehicle,true)
		setVehicleLocked(sellvehicle, true)
		setVehicleDamageProof(sellvehicle,true)
		ped:setData("Ped:Name", pedName)
		ped:setData("Ped:greetText", greetText)
		setElementData(ped, "Ped:fakeNameTag", pedName)
		setElementData(ped,"NPC:Immortal_serverside",true)
		setElementFrozen(ped,true)
		setPedAnimation(ped, "dealer", "dealer_idle",200, true, false, false)
		ped.m_ColShape = createColSphere ( pedPos[1],pedPos[2],pedPos[3], 10)
		setElementData(ped.m_ColShape, "colPed", ped)
		ped.m_LastOutPut = -10000 --// nur alle 10sekunden eine begrüßung vom ped
		addEventHandler("onColShapeHit", ped.m_ColShape, self.m_OnColShapeHit)
		self.m_SellerPeds[i] = ped
		addEventHandler("onElementClicked", ped, self.m_OnSellerClick)
	end
end

function GroupHouseRob:Event_OnSellAccept()
	if client then
		if client.m_ClickPed then
			if getDistanceBetweenPoints3D(client.m_ClickPed:getPosition(), client:getPosition()) > 10 then
				client:sendError("Du bist zu weit entfernt!")
				return
			end
			local inv = client:getInventory()
			if inv then
				local amount = inv:getItemAmount("Diebesgut")
				local randomPrice = math.random( 500,1000)
				local pay = amount * randomPrice
				inv:removeAllItem("Diebesgut")
				self.m_BankServerAccount:transferMoney(client, pay, "Verkauf von Diebesware", "Group", "HouseRob")
				client:meChat(true, "streckt seine Hand aus und nimmt einen Umschlag mit Scheinen entgegen!")
				client:sendPedChatMessage(client.m_ClickPed:getData("Ped:Name"), "Gutes Geschäft. Komm wieder wenn du mehr hast!")
			end
		end
	end
end

function GroupHouseRob:Event_onColHit( hE, matchDim )
	if getElementType(hE) == "player" then
		if matchDim then
			local ped = getElementData(source, "colPed")
			if ped then
				if ped.m_LastOutPut + 10000 <= getTickCount() then
					ped.m_LastOutPut = getTickCount()
					hE:sendPedChatMessage( ped:getData("Ped:Name"),ped:getData("Ped:greetText", greetText))
				end
			end
		end
	end
end


function GroupHouseRob:Event_onClickPed(  m, s, player)
	if m == "left" then
		if s == "up" then
			local inv = player:getInventory()
			if inv then
				local thiefItems = inv:getItemAmount("Diebesgut")
				if thiefItems > 0 then
					player:meChat(true, "nickt mit dem Kopf.")
					player.m_ClickPed = source
					player:sendPedChatMessage( source:getData("Ped:Name"), "Lass mich mal sehen!")
					player:triggerEvent("showHouseRobSellGUI")
				else
					player:meChat(true, "schüttelt den Kopf.")
					player:sendPedChatMessage( source:getData("Ped:Name"), "Hmm... Komm wieder wenn du etwas hast!")
				end
			end
		end
	end
end

function GroupHouseRob:startNewRob( house, player )
	if player then
		local group = player:getGroup()
		if group then
			if group:getType() == "Gang" then
				if FactionState:getSingleton():countPlayers() < HOUSEROB_MIN_MEMBERS then
					player:sendError(_("Es müssen mindestens %d Staatsfraktionisten online sein!", player, HOUSEROB_MIN_MEMBERS))
					return false
				end
				if player:getFaction() and player:getFaction():isStateFaction() then
					player:sendError(_("Als Staatsfraktionist kannst du keine Häuser ausrauben!", player))
					return false
				end

				if not self.m_HousesRobbed[house] then
					local tick = getTickCount()
					if not self.m_GroupsRobCooldown[group] then
						self.m_GroupsRobCooldown[group]  = 0 - GroupHouseRob.COOLDOWN_TIME
					end
					if self.m_GroupsRobCooldown[group] + GroupHouseRob.COOLDOWN_TIME <= tick then
						self.m_GroupsRobCooldown[group]  = tick
						self.m_HousesRobbed[house] = true
						return true
					else
						player:sendError(_("Ihr könnt noch nicht wieder ein Haus ausrauben!", player))
					end
				else
					player:sendError(_("Dieses Haus wurde bereits ausgeraubt!", player))
				end
			end
		end
	end
	return false
end



function GroupHouseRob:getRandomItem()
	return findItems[math.random(1,#findItems)]
end

function GroupHouseRob:destructor()

end

