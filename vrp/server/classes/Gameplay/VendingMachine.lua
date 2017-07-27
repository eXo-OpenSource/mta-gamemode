-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/VendingMachine.lua
-- *  PURPOSE:     Vending Machine class
-- *
-- ****************************************************************************
VendingMachine = inherit(Object)
VendingMachine.Map = {}

function VendingMachine:constructor(model, x, y, z, rotation)
	self.m_LastRobTime = 0

	local object = createObject(model, x, y, z, 0, 0, rotation)
	VendingMachine.Map[object] = self
end

function VendingMachine.initializeAll()
	addEvent("vendingRob", true)
	addEvent("vendingBuySnack", true)
	addEventHandler("vendingRob", root, VendingMachine.Event_vendingRob)
	addEventHandler("vendingBuySnack", root, VendingMachine.Event_vendingBuySnack)

	-- Create machines
	for k, data in ipairs(VendingMachine.MachineData) do
		local model, x, y, z, rotation = unpack(data)
		VendingMachine:new(model, x, y, z, rotation)
	end
end

function VendingMachine.Event_vendingRob()
	local vendingMachine
	if VendingMachine.Map[source] then
		vendingMachine = VendingMachine.Map[source]
	else
		local pos = source:getPosition()
		local rot = source:getRotation()
		vendingMachine = VendingMachine:new(source:getModel(), pos.x, pos.y, pos.z, rot.z)
		source:destroy()
	end

	if not vendingMachine then return end
	if not client.vehicle then
		if getTickCount() - vendingMachine.m_LastRobTime < 5*60*1000 then
			client:sendMessage(_("Dieser Automat kann zurzeit nicht ausgeraubt werden!", client), 255, 0, 0)
			return
		end

		-- Play animation
		client:setAnimation("BOMBER", "BOM_Plant", -1, false, true, false, false)

		-- Give wage
		client:giveWanteds(2)
		client:sendMessage("Verbrechen begangen: Automaten-Raub, 2 Wanteds", 255, 255, 0)
		client:giveMoney(math.random(10, 100), "Automaten-Raub")
		client:giveKarma(-1)

		-- give Achievement
		client:giveAchievement(19)

		-- Update rob time
		vendingMachine.m_LastRobTime = getTickCount()
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end

function VendingMachine.Event_vendingBuySnack()
	if not client.vehicle then
		if client:getMoney() >= 20 then
			client:setAnimation("VENDING", "vend_eat1_P", -1, false, true, false, false)
			client:setHealth(client:getHealth() + 10)
			StatisticsLogger:getSingleton():addHealLog(client, 10, "VendingMachine")
			client:takeMoney(20, "Automat")
		else
			client:sendError(_("Du hast nicht genügend Geld!", client))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end

VendingMachine.MachineData = { -- Note: If you add more models to the list, you'll have to add a model id to the clickhandler
	{1775, 1937, -1864.59961, 13.7, 179.995},
	{1776, 1748, -1863.59998, 13.7, 180},
	{1775, 1749.30005, -1863.5, 13.7, 180},
	{1775, 1496, -1582.5, 13.6, 0},
	{1775, 1473.1, -1777.2, 13.6, 180},
	{1776, 1303.5, -1367.90002, 13.7, 0},
	{1209, 1035.5, -1339.5, 12.7, 180},
	{1775, 928.29999, -1336.69995, 13.6, 178},
	{1775, 469.10001, -1284.80005, 15.5, 38},
	{1776, 1938.30005, -1864.69995, 13.7, 180},
	{1776, 1569.80005, -1898.09998, 13.7, 180},
	{1209, 1304.69995, -1367.80005, 12.5, 0},
	-- Todo: add more
}
