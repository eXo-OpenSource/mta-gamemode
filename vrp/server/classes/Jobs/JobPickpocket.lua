-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPickpocket.lua
-- *  PURPOSE:     Pickpocket job (evil)
-- *
-- ****************************************************************************
JobPickpocket = inherit(Job)

function JobPickpocket:constructor()
	Job.constructor(self)
	self.m_Blips = {}
	
	VehicleSpawner:new(1982.4, -1784.4, 12.8, {"BMX"}, 270, bind(Job.requireVehicle, self))
	
	local func = bind(self.Vending_Hit, self)
	for k, v in ipairs(JobPickpocket.Vending) do
		local model, x, y, z, rot = unpack(v)
		local object = createObject(model, x, y, z, 0, 0, rot)
		local colshape = createColSphere(x, y, z, 2)
		addEventHandler("onColShapeHit", colshape, func)
		
		local blip = createBlip(x, y, z, 32)
		setElementVisibleTo(blip, root, false)
		table.insert(self.m_Blips, blip)
	end
end

function JobPickpocket:start(player)
	for k, blip in ipairs(self.m_Blips) do
		setElementVisibleTo(blip, player, true)
	end
end

function JobPickpocket:stop(player)
	for k, blip in ipairs(self.m_Blips) do
		setElementVisibleTo(blip, player, false)
	end
end

function JobPickpocket:Vending_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if hitElement:getJob() ~= self then
			return
		end
	
		if source.isBusy then
			hitElement:sendMessage(_("Dieser Automat kann zurzeit nicht ausgeraubt werden!", hitElement), 255, 0, 0)
			return
		end
	
		-- Play animation
		setPedAnimation(hitElement, "BOMBER", "BOM_Plant", -1, false, true, false, false)
		
		-- Give wage
		hitElement:giveMoney(math.random(10, 100))
		hitElement:giveXP(0.1)
		hitElement:takeKarma(0.01)
		
		-- Give wanted level
		if hitElement:getWantedLevel() < 1 then
			hitElement:giveWantedLevel(1)
		end
		
		-- Set vending machine busy for 2min
		source.isBusy = true
		setTimer(function(c) c.isBusy = nil end, 120000, 1, source)
	end
end

JobPickpocket.Vending = {
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
}
