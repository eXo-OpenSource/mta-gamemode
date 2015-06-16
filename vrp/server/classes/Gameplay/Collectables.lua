-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Collectables.lua
-- *  PURPOSE:     Collectables server-side class
-- *
-- ****************************************************************************
Collectables = inherit(Singleton)

addEvent("requestCollectables", true)
addEvent("checkCollectableHit", true)

function Collectables:constructor()
	addEventHandler("requestCollectables", root, bind(self.sendCollectables,self))
	addEventHandler("checkCollectableHit", root, bind(self.checkCollectable,self))
end

function Collectables:checkCollectable(collectableID)
	if not client then return end
	local x,y,z = getElementPosition(client)
	local px,py,pz = unpack(Collectables.POSITIONS[collectableID])
	if getDistanceBetweenPoints3D (x,y,z,px,py,pz) >= 10 then
		print(("WARNING: %s is maybe cheatin' @ collectables"):format(getPlayerName(client)))
	else
		local collectables = client:getCollectables() or {}
		collectables[collectableID] = "1"
		client:setCollectables(collectables)

		client:sendShortMessage(_("Du hast ein vRP-Logo gefunden!\nDafür erhälst du %s vRP-Points!", client, 500))
		client:givePoints(500)
	end
end

function Collectables:sendCollectables()
	if not client then return end

	triggerClientEvent(client,"reciveCollectables",client,Collectables.POSITIONS,client:getCollectables() or {})
end

Collectables.POSITIONS = {
	{2012.4,-1199.7,19.3},
	{2789.8,-1096.8,30},
	{2898.3999,-1878,1.9},
	{2790.2,-2417.5,12.9},
	{2060.7,-2371.8999,15.4},
	{1474.6,-2286.8,41.7},
	{1117.7,-2037,78},
	{31.5,-241.39999,8.7},
	{-688.09998,938.79999,12.9},
	{1911.6,1746.8,18.2},
	{2457.8,-953.09998,79.3},
	{154.5,-1962.6,3},
	{380.29999,-1886.4,1.2},
	{-1095.6,-673,31.6},
	{-2062.7,306.70001,41.2},
	{-2193,853.29999,69},
	{-1504.3,1373.2,3},
	{-2396.5,1554.6,31.1},
	{-2658.3999,1528.2,54.9},
	{-2752.1001,-252,6.4},
	{-2261.3999,2569.2,6},
	{-2091.7,2313.8999,25.2},
	{-869.79999,2308.7,160.8},
	{290.20001,2439.8999,16},
	{1693.8,2222.2,19.6},
}
