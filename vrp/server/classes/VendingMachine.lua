VendingMachine = inherit(Object)
VendingMachine.Map = {}

function VendingMachine:constructor(model, x, y, z, rotation)
	self.m_LastRobTime = 0
	
	local object = createObject(model, x, y, z, 0, 0, rotation)
	VendingMachine.Map[object] = self
end

function VendingMachine.initializeAll()
	addEvent("vendingRob", true)
	addEventHandler("vendingRob", root, VendingMachine.Event_vendingRob)
	
	-- Create machines
	for k, data in ipairs(VendingMachine.MachineData) do
		local model, x, y, z, rotation = unpack(data)
		VendingMachine:new(model, x, y, z, rotation)
	end
end

function VendingMachine.Event_vendingRob()
	local vendingMachine = VendingMachine.Map[source]
	if not vendingMachine then return end
	
	if getTickCount() - vendingMachine.m_LastRobTime < 5*60*1000 then
		client:sendMessage(_("Dieser Automat kann zurzeit nicht ausgeraubt werden!", client), 255, 0, 0)
		return
	end
	
	-- Play animation
	setPedAnimation(client, "BOMBER", "BOM_Plant", -1, false, true, false, false)
	
	-- Give wage
	client:giveMoney(math.random(10, 100))
	client:giveXP(0.1)
	client:takeKarma(0.05)
	
	-- Update rob time
	vendingMachine.m_LastRobTime = getTickCount()
end

VendingMachine.MachineData = { -- Note: If you add more models to the list, you'll have to add a model id to the clickhandler
	{1775, 1937, -1864.59961, 13.7, 179.995},
	{1776, 1748, -1863.59998, 13.7, 180},
	{1775, 1749.30005, -1863.5, 13.7, 180},
	{1776, 1465.69995, -1749.90002, 15.5, 180},
	{1209, 1464.39941, -1750, 14.4, 179.995},
	{1775, 1496, -1582.5, 13.6, 0},
	{1776, 1303.5, -1367.90002, 13.7, 0},
	{1209, 1035.5, -1339.5, 12.7, 180},
	{1775, 928.29999, -1336.69995, 13.6, 178},
	{1775, 469.10001, -1284.80005, 15.5, 38},
	{1776, 1938.30005, -1864.69995, 13.7, 180},
	{1776, 1569.80005, -1898.09998, 13.7, 180},
	{1209, 1304.69995, -1367.80005, 12.5, 0},
	-- Todo: add more
}