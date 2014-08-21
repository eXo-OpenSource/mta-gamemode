-- // Server

JobFarmer = inherit(Job)

local VEHICLE_SPAWN = {-1063.92468,-1226.01440,128.41875,90}
local PLANT_DELIVERY = {-1108.28723,-1620.65833,75.36719}
local MONEYPERPLANT = 25 -- Money per plant at the delivery point
local PLANTSONWALTON = 50
local STOREMARKERPOS = {-1073.52661,-1207.41882,128.21875}

function JobFarmer:constructor()
	Job.constructor(self)
	
	self.m_Plants = {}
	
	local x,y,z,rotation = unpack ( VEHICLE_SPAWN )
	
	VehicleSpawner:new(x,y,z, {"Combine Harvester";"Tractor";"Walton"}, rotation, bind(Job.requireVehicle, self))
	
	self.m_JobElements = {}
	self.m_CurrentPlants = {}
	self.m_CurrentPlantsFarm = 0
	
	local x,y,z = unpack(STOREMARKERPOS)
		
	self.m_Storemarker = self:createJobElement ( createMarker (x,y,z,"cylinder",3,0,125,0,125) )
	
	addEventHandler("onMarkerHit",self.m_Storemarker,bind(self.storeHit,self))
	
	
	-- // this the delivery BLIP
	x,y,z = unpack (PLANT_DELIVERY)
	
	self.m_DeliveryMarker = self:createJobElement(createMarker(x,y,z,"cylinder",4))
	self:createJobElement (createBlip(x,y,z))
	
	addEventHandler ("onMarkerHit",self.m_DeliveryMarker,bind(self.deliveryHit,self))
	
	-- //
	
	for key, value in ipairs (JobFarmer.PlantPlaces) do
		x,y,z = unpack(value)

		addEventHandler("onColShapeHit",createColSphere (x,y,z,3),
			function (hitElement)
				
				if getElementType(hitElement) ~= "vehicle" then
					return
				end
				
				local player = getVehicleOccupant(hitElement,0)
				
				if player then
					self:createPlant(player,source,hitElement)
				end
			end
		)
	end
	
end

function JobFarmer:storeHit(hitElement,matchingDimension)
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") then
		if self.m_CurrentPlants[player] ~= 0 then
			outputChatBox("Du hast schon "..PLANTSONWALTON.." Pflanzen auf deinem Walton !",player,255,0,0)
			return
		end
		if self.m_CurrentPlantsFarm >= PLANTSONWALTON then
			self.m_CurrentPlants[player] = PLANTSONWALTON
			self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm - PLANTSONWALTON
			setElementFrozen ( hitElement, true )
			setTimer ( 
				function(element) 
					setElementFrozen(element,false)
				end,3500,1,hitElement
			)
		else
			outputChatBox("Es gibt momentan nicht genug Pflanzen auf der Farm. Momentane Pflanzen : "..self.m_CurrentPlantsFarm,player,255,0,0)
		end
	end	
end

function JobFarmer:createJobElement (element)
	setElementVisibleTo (element,root,false)
	table.insert (self.m_JobElements,element)	
	return element
end

function JobFarmer:start(player)
	self:setJobElementVisibility (player,true)
	self.m_CurrentPlants[player] = 0
end

function JobFarmer:setJobElementVisibility (player,boolean)
	for key, value in ipairs (self.m_JobElements) do
		setElementVisibleTo (value,player,boolean)
	end
end

function JobFarmer:destroyPlants (player)

end

function JobFarmer:stop(player)
	self.m_CurrentPlants[player] = nil
	--self:destroyPlants(player)
	self:setJobElementVisibility(player,false)
	self.m_Plants[player] = nil
end

function JobFarmer:deliveryHit (hitElement,matchingDimension)
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") then
		outputChatBox ("Sie haben die Lieferung abgegeben, Gehalt : $ "..self.m_CurrentPlants[player]*MONEYPERPLANT,player,0,255,0)
		player:giveMoney(self.m_CurrentPlants[player]*MONEYPERPLANT)
		self.m_CurrentPlants[player] = 0
	end
end

function JobFarmer:createPlant (hitElement,createColShape,vehicle )
	
	if hitElement:getJob() ~= self then
		return
	end
	
	local x,y,z = getElementPosition(hitElement)
	
	local vehicleID = getElementModel(vehicle)
	
	if self.m_Plants[createColShape] and vehicleID == getVehicleModelFromName("Combine Harvester") and self.m_Plants[createColShape].isFarmAble then
		destroyElement (self.m_Plants[createColShape])
		self.m_Plants[createColShape] = nil
		hitElement:giveMoney(math.random(5,8))
		self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm + 1
	else
		if vehicleID == getVehicleModelFromName("Tractor") and not self.m_Plants[createColShape] then
			self.m_Plants[createColShape] = createObject(818,x,y,z-1.5)
			local object = self.m_Plants[createColShape]
			object.isFarmAble = false
			setTimer ( function (o) o.isFarmAble = true end, 1000*30, 1, object )
			setElementVisibleTo (object,hitElement,true)
			hitElement:giveMoney(math.random(2,4))
		end
	end
	
end

JobFarmer.PlantPlaces = {
{-1091.53515625,-1217.5478515625,129}                   ;
{-1091.9296875,-1209.041015625,129}                     ;
{-1092.2373046875,-1200.587890625,129}                  ;
{-1092.548828125,-1188.966796875,129}                   ;
{-1092.685546875,-1179.4755859375,129}                  ;
{-1099.962890625,-1175.54296875,129}                    ;
{-1109.3916015625,-1174.9443359375,129}                 ;
{-1119.951171875,-1174.275390625,129}                   ;
{-1132.4521484375,-1173.482421875,129}                  ;
{-1143.1494140625,-1173.09765625,129}                   ;
{-1153.6982421875,-1173.212890625,129}                  ;
{-1163.201171875,-1173.599609375,129}                   ;
{-1171.91796875,-1173.953125,129}                       ;
{-1181.4912109375,-1174.3427734375,129}                 ;
{-1192.890625,-1174.8056640625,129}                     ;
{-1202.4921875,-1175.1953125,129}                       ;
{-1210.1015625,-1175.5048828125,129}                    ;
{-1213.5,-1184.2890625,129}                             ;
{-1213.248046875,-1195.2890625,129}                     ;
{-1213.029296875,-1204.84375,129}                       ;
{-1212.9130859375,-1213.5537109375,129}                 ;
{-1203.3203125,-1217.578125,129}                        ;
{-1192.8447265625,-1217.5224609375,129}                 ;
{-1182.3349609375,-1217.4677734375,129}                 ;
{-1172.5986328125,-1217.4169921875,129}                 ;
{-1161.77734375,-1217.3603515625,129}                   ;
{-1154.08984375,-1217.3203125,129}                      ;
{-1145.0625,-1217.2724609375,129}                       ;
{-1136.59765625,-1217.228515625,129}                    ;
{-1127.6083984375,-1217.181640625,129}                  ;
{-1121.0234375,-1219.53125,129}                         ;
{-1119.716796875,-1228.5185546875,129}                  ;
{-1119.126953125,-1237.1552734375,129}                  ;
{-1118.7724609375,-1247.6689453125,129}                 ;
{-1112.8193359375,-1251.9462890625,129}                 ;
{-1104.1162109375,-1251.8017578125,129}                 ;
{-1096.369140625,-1252.0166015625,129}                  ;
{-1091.11328125,-1246.2412109375,129}                   ;
{-1091.7685546875,-1236.7509765625,129}                 ;
{-1091.947265625,-1225.2021484375,129}                  ;
{-1175.2666015625,-1160.759765625,129}              ;
{-1168.83984375,-1162.35546875,129}                 ;
{-1162.369140625,-1164.2919921875,129}              ;
{-1154.7548828125,-1164.001953125,129}              ;
{-1148.08984375,-1163.767578125,129}                ;
{-1141.3935546875,-1163.826171875,129}              ;
{-1132.826171875,-1164.4091796875,129}              ;
{-1125.2763671875,-1165.0595703125,129}             ;
{-1117.5673828125,-1165.259765625,129}              ;
{-1110.8759765625,-1165.4638671875,129}             ;
{-1105.212890625,-1165.734375,129}                  ;
{-1098.580078125,-1166.5634765625,129}              ;
{-1092.2119140625,-1168.09765625,129}               ;
{-1091.1953125,-1161.8251953125,129}                ;
{-1091.33203125,-1156.0908203125,129}               ;
{-1097.7578125,-1154.1318359375,129}                ;
{-1105.4521484375,-1153.513671875,129}              ;
{-1113.0078125,-1153.1630859375,129}                ;
{-1119.8505859375,-1152.96875,129}                  ;
{-1127.4462890625,-1152.751953125,129}              ;
{-1135.14453125,-1152.5234375,129}                  ;
{-1143.59375,-1152.265625,129}                      ;
{-1153.2822265625,-1152.3896484375,129}             ;
{-1160.9619140625,-1152.6337890625,129}             ;
{-1170.5283203125,-1152.7041015625,129}             ;
{-1178.0908203125,-1152.48828125,129}               ;
{-1185.8232421875,-1152.30859375,129}               ;
{-1191.552734375,-1152.302734375,129}               ;
{-1199.068359375,-1152.294921875,129}               ;
{-1194.4404296875,-1155.765625,129}                 ;
{-1187.6904296875,-1156.1748046875,129}             ;
{-1181.0625,-1156.525390625,129}                    ;
{-1174.4384765625,-1156.9091796875,129}             ;
{-1166.46875,-1159.423828125,129}                   ;
{-1158.6025390625,-1159.841796875,129}              ;
{-1151.896484375,-1159.46875,129}                   ;
{-1145.189453125,-1159.3828125,129}                 ;
{-1138.3857421875,-1159.5078125,129}                ;
{-1132.6611328125,-1159.810546875,129}              ;
{-1125.66796875,-1156.337890625,129}                ;
{-1122.8876953125,-1160.724609375,129}              ;
{-1118.408203125,-1158.2177734375,129}              ;
{-1113.9443359375,-1160.48046875,129}               ;
{-1110.2060546875,-1159.3818359375,129}             ;
{-1105.8017578125,-1160.55078125,129}               ;
{-1101.1484375,-1159.6015625,129}                   ;
{-1097.1376953125,-1163.7353515625,129}             ;
{-1090.8583984375,-1252.345703125,129}              ;
{-1094.7705078125,-1256.6640625,129}                ;
{-1100.9326171875,-1257.90234375,129}               ;
{-1107.603515625,-1257.8828125,129}                 ;
{-1114.380859375,-1257.7548828125,129}              ;
{-1119.427734375,-1260.7763671875,129}              ;
{-1119.5146484375,-1268.45703125,129}               ;
{-1119.7578125,-1276.0693359375,129}                ;
{-1120.0810546875,-1282.740234375,129}              ;
{-1115.6640625,-1286.8388671875,129}                ;
{-1106.853515625,-1287.4970703125,129}              ;
{-1098.369140625,-1287.57421875,129}                ;
{-1090.6943359375,-1287.64453125,129}               ;
{-1082.880859375,-1287.7158203125,129}              ;
{-1076.10546875,-1287.77734375,129}                 ;
{-1070.435546875,-1287.8291015625,129}              ;
{-1067.2392578125,-1282.9287109375,129}             ;
{-1067.330078125,-1274.0751953125,129}              ;
{-1067.15625,-1267.466796875,129}                   ;
{-1067.2685546875,-1260.8447265625,129}             ;
{-1074.4111328125,-1258.4580078125,129}             ;
{-1083.2451171875,-1258.064453125,129}              ;
{-1089.2919921875,-1257.7958984375,129}             ;
{-1092.103515625,-1261.0869140625,129}              ;
{-1097.8203125,-1261.9150390625,129}                ;
{-1105.5400390625,-1262.15625,129}                  ;
{-1111.2412109375,-1262.65234375,129}               ;
{-1114.775390625,-1266.2724609375,129}              ;
{-1114.92578125,-1272.76171875,129}                 ;
{-1115.65234375,-1278.505859375,129}                ;
{-1112.2783203125,-1282.2353515625,129}             ;
{-1105.7861328125,-1283.43359375,129}               ;
{-1100.0576171875,-1283.408203125,129}              ;
{-1093.30859375,-1283.2138671875,129}               ;
{-1085.75,-1283.5263671875,129}                     ;
{-1079.9541015625,-1283.7666015625,129}             ;
{-1075.208984375,-1283.9638671875,129}              ;
{-1071.4931640625,-1281.146484375,129}              ;
{-1071.3994140625,-1273.7470703125,129}             ;
{-1071.541015625,-1268.01953125,129}                ;
{-1072.2587890625,-1262.435546875,129}              ;
{-1079.2451171875,-1262.6806640625,129}             ;
{-1086.75390625,-1263.5556640625,129}               ;
{-1093.232421875,-1264.9892578125,129}              ;
{-1100.421875,-1265.892578125,129}                  ;
{-1106.083984375,-1266.6865234375,129}              ;
{-1110.3642578125,-1270.3076171875,129}             ;
{-1109.9423828125,-1277.23828125,129}               ;
{-1102.7529296875,-1278.9755859375,129}             ;
{-1094.0888671875,-1278.833984375,129}              ;
{-1086.3740234375,-1279.109375,129}                 ;
{-1079.80078125,-1279.34375,129}                    ;
{-1075.6142578125,-1276.7216796875,129}             ;
{-1076.1552734375,-1271.3720703125,129}             ;
{-1081.43359375,-1267.7119140625,129}               ;
{-1091.0439453125,-1268.8671875,129}                ;
{-1097.80078125,-1269.681640625,129}                ;
{-1104.3486328125,-1271.419921875,129}              ;
{-1099.314453125,-1275.0439453125,129}              ;
{-1091.7890625,-1273.9541015625,129}                ;
{-1084.1171875,-1273.7294921875,129}				;
{-1170.388671875,-1168.6799316406,129}			;
{-1161.1798095703,-1168.8403320313,129}         ;
{-1153.4324951172,-1168.2869873047,129}         ;
{-1095.7319335938,-1158.5280761719,129}         ;
{-1092.5587158203,-1173.4725341797,129}         ;
{-1096.6031494141,-1171.7113037109,129}         ;
{-1103.6186523438,-1171.33203125,129}           ;
{-1108.5255126953,-1170.2155761719,129}         ;
{-1113.5556640625,-1170.6118164063,129}         ;
{-1119.3522949219,-1169.3685302734,129}         ;
{-1125.0902099609,-1170.1372070313,129}         ;
{-1130.9063720703,-1168.7459716797,129}         ;
{-1128.9885253906,-1160.9217529297,129}         ;
{-1136.9356689453,-1169.0183105469,129}         ;
{-1137.7528076172,-1173.208984375,129}          ;
{-1144.0672607422,-1168.1735839844,129}         ;
{-1149.8791503906,-1169.7485351563,129}         ;
{-1177.9362792969,-1165.0126953125,129}         ;
{-1183.146484375,-1160.8579101563,129}          ;
{-1184.8272705078,-1164.1547851563,129}         ;
{-1191.0843505859,-1164.6491699219,129}         ;
{-1191.9296875,-1159.9249267578,129}            ;
{-1197.7590332031,-1165.0651855469,129}         ;
{-1198.2282714844,-1160.2337646484,129}         ;
{-1204.0181884766,-1154.6032714844,129}         ;
{-1204.7261962891,-1164.2313232422,129}         ;
{-1204.3670654297,-1160.5632324219,129}         ;
{-1212.7000732422,-1170.5747070313,129}         ;
{-1211.1311035156,-1165.1450195313,129}         ;
{-1211.0399169922,-1159.9123535156,129}         ;
{-1211.2393798828,-1155.4840087891,129}         ;
{-1206.1099853516,-1211.2213134766,129}         ;
{-1207.5617675781,-1205.6867675781,129}         ;
{-1208.4400634766,-1200.3371582031,129}         ;
{-1208.85546875,-1196.1219482422,129}           ;
{-1209.6007080078,-1190.9293212891,129}         ;
{-1208.1632080078,-1185.2181396484,129}         ;
{-1207.5588378906,-1180.1882324219,129}         ;
{-1197.5318603516,-1211.0906982422,129}         ;
{-1196.3804931641,-1206.2041015625,129}         ;
{-1196.6206054688,-1201.7717285156,129}         ;
{-1197.7725830078,-1197.5458984375,129}         ;
{-1197.6236572266,-1192.9916992188,129}         ;
{-1196.8494873047,-1187.8139648438,129}         ;
{-1196.3930664063,-1183.2153320313,129}         ;
{-1196.619140625,-1179.2518310547,129}          ;
{-1186.5384521484,-1209.7738037109,129}         ;
{-1187.8621826172,-1205.2188720703,129}         ;
{-1188.4865722656,-1200.2276611328,129}         ;
{-1187.3715820313,-1195.4521484375,129}         ;
{-1187.2297363281,-1190.5460205078,129}         ;
{-1186.2088623047,-1185.060546875,129}          ;
{-1185.8229980469,-1179.2535400391,129}         ;
{-1178.2814941406,-1210.5369873047,129}         ;
{-1177.6892089844,-1205.0635986328,129}         ;
{-1177.0615234375,-1199.9573974609,129}         ;
{-1175.7651367188,-1194.1401367188,129}         ;
{-1175.6511230469,-1189.1741943359,129}         ;
{-1175.8736572266,-1184.3450927734,129}         ;
{-1176.1726074219,-1179.4304199219,129}         ;
{-1166.8803710938,-1179.2492675781,129}         ;
{-1167.8868408203,-1184.5213623047,129}         ;
{-1168.8430175781,-1190.3649902344,129}         ;
{-1168.9906005859,-1195.5201416016,129}         ;
{-1170.2357177734,-1200.5751953125,129}         ;
{-1170.4592285156,-1205.1740722656,129}         ;
{-1169.5703125,-1211.0118408203,129}            ;
{-1161.4364013672,-1210.2473144531,129}         ;
{-1161.9517822266,-1205.8271484375,129}         ;
{-1161.6529541016,-1200.6000976563,129}         ;
{-1161.2482910156,-1195.1752929688,129}         ;
{-1160.4967041016,-1188.9165039063,129}         ;
{-1160.0509033203,-1183.5816650391,129}         ;
{-1159.8372802734,-1177.9401855469,129}         ;
{-1153.9426269531,-1178.8193359375,129}         ;
{-1153.630859375,-1184.6009521484,129}          ;
{-1154.1131591797,-1190.9006347656,129}         ;
{-1154.6488037109,-1196.8830566406,129}         ;
{-1155.5346679688,-1201.7149658203,129}         ;
{-1156.2648925781,-1207.3273925781,129}         ;
{-1155.9013671875,-1212.5247802734,129}         ;
{-1150.1306152344,-1211.0823974609,129}         ;
{-1149.5709228516,-1205.0266113281,129}         ;
{-1148.6630859375,-1199.689453125,129}          ;
{-1146.5646972656,-1193.7081298828,129}         ;
{-1145.0524902344,-1187.8447265625,129}         ;
{-1144.7391357422,-1182.7602539063,129}         ;
{-1146.1794433594,-1177.9088134766,129}         ;
{-1136.103515625,-1178.2553710938,129}          ;
{-1136.9294433594,-1184.3220214844,129}         ;
{-1138.8028564453,-1189.9575195313,129}         ;
{-1140.4772949219,-1196.3286132813,129}         ;
{-1142.1784667969,-1202.2900390625,129}         ;
{-1143.6495361328,-1207.2301025391,129}         ;
{-1144.0134277344,-1211.7866210938,129}         ;
{-1136.9737548828,-1210.8466796875,129}         ;
{-1136.7702636719,-1204.9826660156,129}         ;
{-1135.4010009766,-1199.9722900391,129}         ;
{-1134.8836669922,-1195.2236328125,129}         ;
{-1134.3500976563,-1190.5936279297,129}         ;
{-1133.0360107422,-1186.6625976563,129}         ;
{-1132.7825927734,-1181.6042480469,129}         ;
{-1132.1489257813,-1177.5760498047,129}         ;
{-1127.4031982422,-1174.6070556641,129}         ;
{-1126.1843261719,-1179.3786621094,129}         ;
{-1126.6678466797,-1184.6108398438,129}         ;
{-1127.4890136719,-1189.8576660156,129}         ;
{-1128.4510498047,-1195.0274658203,129}         ;
{-1129.6656494141,-1210.4820556641,129}         ;
{-1128.8020019531,-1204.5494384766,129}         ;
{-1129.0791015625,-1200.1153564453,129}         ;
{-1109.5864257813,-1180.9805908203,129}         ;
{-1102.9884033203,-1180.8896484375,129}         ;
{-1098.5015869141,-1180.1821289063,129}         ;
{-1115.6752929688,-1179.6834716797,129}         ;
{-1121.4580078125,-1179.3875732422,129}         ;
{-1120.4801025391,-1184.6845703125,129}         ;
{-1114.6229248047,-1186.3344726563,129}         ;
{-1109.4488525391,-1186.4056396484,129}         ;
{-1104.0197753906,-1187.0640869141,129}         ;
{-1098.5021972656,-1186.8288574219,129}         ;
{-1092.8742675781,-1186.8468017578,129}         ;
{-1091.8103027344,-1194.2640380859,129}         ;
{-1098.0300292969,-1193.5257568359,129}         ;
{-1103.0693359375,-1192.7698974609,129}         ;
{-1108.3673095703,-1192.6324462891,129}         ;
{-1113.7258300781,-1191.5911865234,129}         ;
{-1121.0815429688,-1191.8792724609,129}         ;
{-1122.3405761719,-1212.4860839844,129}         ;
{-1122.4068603516,-1208.3449707031,129}         ;
{-1121.5908203125,-1202.7634277344,129}         ;
{-1121.5511474609,-1199.4018554688,129}         ;
{-1097.6446533203,-1199.4595947266,129}         ;
{-1101.5625,-1198.7882080078,129}               ;
{-1106.6448974609,-1199.1668701172,129}         ;
{-1110.2762451172,-1199.0861816406,129}         ;
{-1115.7349853516,-1198.8502197266,129}         ;
{-1097.7138671875,-1206.5256347656,129}         ;
{-1102.8560791016,-1205.9442138672,129}         ;
{-1108.3536376953,-1206.4737548828,129}         ;
{-1113.388671875,-1207.2315673828,129}          ;
{-1117.7534179688,-1207.1257324219,129}         ;
{-1099.4431152344,-1243.4631347656,129}         ;
{-1105.5887451172,-1245.1971435547,129}         ;
{-1112.2987060547,-1245.8178710938,129}         ;
{-1099.1501464844,-1236.9710693359,129}         ;
{-1105.4128417969,-1238.4877929688,129}         ;
{-1112.3391113281,-1240.6496582031,129}         ;
{-1112.1795654297,-1233.8898925781,129}         ;
{-1105.1959228516,-1230.7604980469,129}         ;
{-1099.7576904297,-1231.3012695313,129}         ;
{-1098.6973876953,-1225.2855224609,129}         ;
{-1104.4128417969,-1225.9971923828,129}         ;
{-1109.7847900391,-1226.8077392578,129}         ;
{-1115.16015625,-1224.0908203125,129}           ;
{-1115.2143554688,-1218.0808105469,129}         ;
{-1115.9113769531,-1212.6807861328,129}         ;
{-1109.8040771484,-1212.4045410156,129}         ;
{-1110.0782470703,-1217.9445800781,129}         ;
{-1108.6896972656,-1222.0270996094,129}         ;
{-1098.1519775391,-1219.9647216797,129}         ;
{-1103.9846191406,-1220.6480712891,129}         ;
{-1104.85546875,-1216.408203125,129}            ;
{-1097.4360351563,-1216.1026611328,129}         ;
{-1099.6385498047,-1212.2254638672,129}         ;
{-1105.4639892578,-1212.1599121094,129}         ;
}

