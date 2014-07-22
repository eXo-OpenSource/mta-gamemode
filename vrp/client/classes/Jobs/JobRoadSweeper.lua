-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobRoadSweeper.lua
-- *  PURPOSE:     Road sweeper job class
-- *
-- ****************************************************************************
JobRoadSweeper = inherit(Job)

function JobRoadSweeper:constructor()
	Job.constructor(self, 199, -1448, 12.1, "Roadsweeper.png", "files/images/Jobs/HeaderRoadSweeper.png", _"Straßenkehrer", _([[
		Als Straßenkehrer ist es deine Aufgabe Los Santos von Dreck zu befreien. 
		Hierzu steht dir ein Straßenkehrfahrzeug zur Verfügung.
		
		Geld pro gesammelten Müllhaufen: 3$
		Erfahrungspunkte pro gesammelten Müllhaufen: 3XP
	]]))
	
	self.m_Rubbish = {}
end

function JobRoadSweeper:start()
	local func = bind(self.Rubbish_Hit, self)

	for k, v in pairs(JobRoadSweeper.Rubbish) do
		local model, x, y, z, rot = unpack(v)
		local object = createObject(model, x, y, z, 0, 0, rot)
		local colShape = createColSphere(x, y, z, 5)
		setElementParent(object, colShape)
		addEventHandler("onClientColShapeHit", colShape, func)
		
		table.insert(self.m_Rubbish, colShape)
	end
end

function JobRoadSweeper:stop()
	for k, v in pairs(self.m_Rubbish) do
		if v and isElement(v) then
			destroyElement(v)
		end
	end
	self.m_Rubbish = {}
end

function JobRoadSweeper:Rubbish_Hit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension and not self.m_Busy then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or getElementModel(vehicle) ~= 574 then -- Sweeper
			localPlayer:sendMessage(_"Hierzu musst du einen Roadsweeper fahren!", 255, 0, 0)
			return
		end
		
		destroyElement(source)
		triggerServerEvent("sweeperGarbageCollect", root)
		
		setElementFrozen(vehicle, true)
		self.m_Busy = true
		setTimer(function() setElementFrozen(vehicle, false) self.m_Busy = nil end, 500, 1)
	end
end


JobRoadSweeper.Rubbish = {
	{2670, 248.7, -1448.90002, 12.7, 38},
	{2672, 240.7, -1417.90002, 12.8, 22},
	{2675, 322.79999, -1378.69995, 13.3, 308},
	{926, 326.79999, -1340.40002, 13.8, 0},
	{928, 327.29999, -1339.90002, 13.8, 0},
	{2670, 327.70001, -1341.30005, 13.6, 0},
	{2676, 341.60001, -1333.40002, 13.6, 338},
	{2672, 373.60001, -1353.80005, 13.9, 14},
	{2674, 391.89999, -1369, 13.8, 0},
	{2671, 394.89999, -1368.09998, 13.8, 274},
	{2676, 398.79999, -1338.09998, 13.9, 72},
	{2677, 455.70001, -1328.80005, 14.6, 0},
	{2673, 480.29999, -1315, 14.8, 0},
	{2671, 484.29999, -1318.59998, 14.8, 0},
	{2672, 472.10001, -1283.19995, 14.8, 0},
	{2676, 476.29999, -1282.09998, 14.7, 64},
	{910, 433.60001, -1291.90002, 15.4, 68},
	{926, 434.39999, -1290.80005, 14.4, 0},
	{928, 434.60001, -1291.40002, 14.4, 0},
	{926, 435, -1290.90002, 14.4, 332},
	{2670, 434.10001, -1293.19995, 14.2, 0},
	{2677, 434.29999, -1293, 14.4, 0},
	{2674, 448.39999, -1295.30005, 14.3, 0},
	{2671, 450.5, -1295.09998, 14.3, 0},
	{2676, 499.29999, -1296.5, 15, 80},
	{2674, 580.09998, -1216.30005, 16.9, 0},
	{2671, 595.09998, -1247, 17.3, 0},
	{2672, 621.90002, -1279.40002, 15.9, 0},
	{2676, 595.70001, -1313.30005, 12.6, 0},
	{2670, 594.09998, -1313.30005, 12.6, 0},
	{2671, 523.90002, -1346.69995, 14.8, 0},
	{2676, 511.89999, -1330.40002, 15.2, 0},
	{3035, 564.79999, -1355.80005, 14.8, 10},
	{2674, 563.59998, -1356.80005, 14.1, 0},
	{2673, 571.09998, -1359.5, 14, 0},
	{2670, 566.20001, -1356.69995, 14.1, 0},
	{2676, 527, -1367.19995, 15.2, 354},
	{2673, 530.40002, -1388.19995, 15.2, 0},
	{2670, 588.5, -1384.59998, 12.8, 0},
	{2672, 583.79999, -1417.69995, 13.3, 352},
	{2675, 512.09998, -1403.90002, 15.2, 0},
	{2670, 547.79999, -1498.59998, 13.6, 0},
	{2673, 547.40002, -1499.69995, 13.6, 0},
	{2676, 606.20001, -1351.30005, 13, 0},
	{2677, 609.09998, -1347.19995, 13.1, 0},
	{2670, 646.5, -1343, 12.6, 0},
	{2672, 646.5, -1342.69995, 12.8, 0},
	{2675, 618.90002, -1334, 12.7, 0},
	{2676, 653.29999, -1328.30005, 12.7, 0},
	{2674, 676, -1328.69995, 12.7, 0},
	{2672, 688.5, -1310.59998, 13, 284},
	{2670, 690.70001, -1312, 12.8, 0},
	{2671, 661.5, -1279.09998, 12.5, 0},
	{2675, 673.5, -1278.80005, 12.7, 0},
	{2673, 666.09998, -1222.5, 15, 0},
	{2674, 666.59998, -1221.59998, 14.9, 0},
	{2672, 659, -1217.69995, 16.1, 0},
	{2670, 697.29999, -1180.69995, 14.7, 0},
	{2675, 696.40002, -1181.69995, 14.6, 0},
	{2672, 719.29999, -1134.59998, 16.7, 0},
	{2673, 719.90002, -1134.09998, 16.6, 0},
	{2676, 734.5, -1094.80005, 20, 278},
	{2672, 707.90002, -1088.09998, 19.6, 346},
	{2670, 752, -1080.19995, 22.5, 0},
	{2676, 766, -1012.20001, 23.2, 338},
	{2677, 762.70001, -1011.29999, 23.4, 334},
	{2671, 767.70001, -1035.69995, 23.1, 0},
	{2674, 783.09998, -1066.19995, 23.8, 0},
	{2674, 805.70001, -1060.40002, 23.9, 0},
	{2670, 804, -1060.5, 24, 0},
}
