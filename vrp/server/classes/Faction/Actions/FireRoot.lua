-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factions/Actions/FireRoot.lua
-- *  PURPOSE:     Fire class
-- *
-- ****************************************************************************
FireRoot = inherit(Object)
FireRoot.Map = {}
FireRoot.Settings = {
	["fire_update_time"] = 5000,
	["coords_per_fire"] = 3,
	["distance_to_player"] = 100, --distance from fire center to player inside he will be counted as active
}


function FireRoot:constructor(iX, iY, iW, iH)
	iW = math.round(iW)
    iH = math.round(iH)
   	self.m_Root = createElement("fire-root")

	self.m_X = iX
	self.m_Y = iY 
	self.m_Width = iW
	self.m_Height = iH
	self.m_CenterPoint = Vector3(iX + iW/2, iY + iH/2)
	self.m_Max_I = iW / FireRoot.Settings["coords_per_fire"]
	self.m_Max_V = iH / FireRoot.Settings["coords_per_fire"]
	self.m_Max_Fires = math.min(64, math.round((self.m_Max_I * self.m_Max_V) * 0.5)) -- increase fire amount and fire size until there is this specific amount of fires loaded
	self.m_UpdateBind = bind(self.update, self)
	self.m_UpdateTimer = setTimer(self.m_UpdateBind, FireRoot.Settings["fire_update_time"], 0, self.m_Root)
	self.m_FireMap = {}
	self.m_FireSizeMap = {}
	self.m_Statistics = {
		startTime = getTickCount(),
		firesByPlayer = {}, -- this saves the count of fire deletions
		pointsByPlayer = {}, -- this saves the score specified by the amount of work per player
		firesDecayed = 0,
		firesActive = 0,
		firesTotal = 0,
	}

	if DEBUG then
		self.m_DebugArea = RadarArea:new(iX, iY, iW, -iH, {200, 0, 0, 100})
	end

	self:updateFire(math.floor(self.m_Max_I/2), math.floor(self.m_Max_V/2), 3)
    for index = 1, math.min(math.sqrt(iW*iH) / FireRoot.Settings["coords_per_fire"] / 3 , self.m_Max_Fires) do
        local i, v = math.random(0, iW/FireRoot.Settings["coords_per_fire"]), math.random(0, iH/FireRoot.Settings["coords_per_fire"])
        self:updateFire(i, v, 3)
    end



	FireRoot.Map[self] = self.m_Root

    return self
end

function FireRoot:setBaseZ(z)
	self.m_BaseZ = z
	self.m_CenterPoint.z = z
end

function FireRoot:destructor()
    if isTimer(self.m_UpdateTimer) then killTimer(self.m_UpdateTimer) end
    for i, uEle in pairs(self.m_FireMap) do
        delete(uEle)
    end
	if self.m_DebugArea then 
		self.m_DebugArea:delete()
	end
    destroyElement(self.m_Root)

	if self.m_OnFinishHook then
		self.m_OnFinishHook(self.m_Statistics)
	end

    FireRoot.Map[self] = nil
end

function FireRoot:setOnUpdateHook(callback, ...)
	self.m_OnUpdateHook = callback
end

function FireRoot:setOnFinishHook(callback)
	self.m_OnFinishHook = callback
end

function FireRoot:update()
	local start = getTickCount()
	local tblFiresToUpdate = {}
	for sPos, iSize in spairs(self.m_FireSizeMap, function(t,a,b) return t[b] < t[a] end) do
		local i,v = tonumber(split(sPos, ",")[1]), tonumber(split(sPos, ",")[2])
		local tblSurroundingFires = {
			[(i+1)..","..(v+1)] = (self:getFireSize(i+1, v+1)   or 0), --tr
			[(i)..","..(v+1)]   = (self:getFireSize(i,   v+1)   or 0), --t
			[(i-1)..","..(v+1)] = (self:getFireSize(i-1, v+1)   or 0), --tl
			[(i+1)..","..(v-1)] = (self:getFireSize(i+1, v-1)   or 0), --br
			[(i)..","..(v-1)]   = (self:getFireSize(i,   v-1)   or 0), --b
			[(i-1)..","..(v-1)] = (self:getFireSize(i-1, v-1)   or 0), --bl
			[(i+1)..","..(v)]   = (self:getFireSize(i+1, v)     or 0), --r
			[(i-1)..","..(v)]   = (self:getFireSize(i-1, v)     or 0), --l
		}

		if iSize == 3 then
			if not self:isFireDecaying() then --spawn new fires around size 3 fires
				local iSizeSum = 0
				for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
					if iSurroundSize == 0 and math.random(1, 3) == 1 and not self:isFireLimitReached() then -- spawn new fires
						local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2])
						if not tblFiresToUpdate[ii] then tblFiresToUpdate[ii] = {} end
						tblFiresToUpdate[ii][vv] = 1
					else
						iSizeSum = iSizeSum + iSurroundSize
					end
				end
				if iSizeSum > 8 then -- let the big fire decay if there is every spot taken
					if math.random(1,3) == 1 or self:isFireLimitReached() then
						if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
						tblFiresToUpdate[i][v] = 0
					else
						if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
						tblFiresToUpdate[i][v] = 2
					end
				end
			elseif math.random(1, 20) == 1 then  -- let the fire decay
				if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
				tblFiresToUpdate[i][v] = 2
			end
		elseif iSize == 2 then
			if not self:isFireDecaying() then
				local iSizeSum = 0
				for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
					if iSurroundSize == 0 and math.random(1, 100) == 1 and not self:isFireLimitReached() then -- spawn new fires
						local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2])
						if not tblFiresToUpdate[ii] then tblFiresToUpdate[ii] = {} end
						tblFiresToUpdate[ii][vv] = 1
					else
						iSizeSum = iSizeSum + iSurroundSize
					end
				end
				if iSizeSum > 8 then -- let the big fire decay if there is every spot surrounding it taken
					if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
					tblFiresToUpdate[i][v] = 1
				elseif iSizeSum > 6 and math.random(1, 2) == 1 and not self:isFireLimitReached() then -- increase the size if there are more size 2 fires in its surrounding
					if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
					tblFiresToUpdate[i][v] = 3
				end
			elseif math.random(1, 20) == 1 then  -- let the fire decay
				if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
				tblFiresToUpdate[i][v] = 1
			end
		elseif iSize == 1 then
			if not self:isFireDecaying() then
				for sSurroundPos, iSurroundSize in spairs(tblSurroundingFires, function(t,a,b) return t[b] > t[a] end) do -- merge two small fires into one medium fire
					if iSurroundSize == 1 and math.random(1, 2) == 1 and not self:isFireLimitReached() then
						local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2])
						if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
						tblFiresToUpdate[i][v] = 2
						if not tblFiresToUpdate[ii] then tblFiresToUpdate[ii] = {} end
						tblFiresToUpdate[ii][vv] = 0
					end
				end
			elseif math.random(1, 20) == 1 then  -- let the fire decay
				if not tblFiresToUpdate[i] then tblFiresToUpdate[i] = {} end
				tblFiresToUpdate[i][v] = 0
			end
		end
	end
	local deletes = 0
	for i,v in pairs(tblFiresToUpdate) do
		for ii,vv in pairs(v) do
			self:updateFire(i, ii, vv)
			if vv == 0 then deletes = deletes + 1 end
		end
	end
	if self.m_Statistics.firesActive == 0 then
		delete(self)
	end

	self.m_Statistics.activeRescuePlayers = self:countUsersAtSight(true)
	if self:isFireLimitReached() and not self:isFireDecaying() and math.random(1, 10) == 1 and self:getTimeSinceStart() < self:getTimeEstimate()/2  then -- let the fire decay if the fire limit is reached anyways
		--PlayerManager:getSingleton():breakingNews("Das Feuer bildet sich langsam wieder zurück")
		self:letFireDecay()
	end
	if self.m_OnUpdateHook then
		self.m_OnUpdateHook(self.m_Statistics)
	end
	self:triggerStatistics()
	outputDebug("updated fire", getTickCount()-start.."ms")
end

function FireRoot:isFireLimitReached()
	return self.m_Max_Fires < self.m_Statistics.firesActive
end

function FireRoot:getMaxFireCount()
	return self.m_Max_Fires 
end

function FireRoot:letFireDecay()
	self.m_FireDecayMode = true
end

function FireRoot:isFireDecaying()
	return self.m_FireDecayMode
end

function FireRoot:dump()
	local tab = {}
	for i, v in  pairs(self.m_FireSizeMap) do
		print(i, v)
	end
end

function FireRoot:updateFire(i, v, iNewSize, bDontDestroyElement)
	if (i >= 0 and i <= self.m_Max_I) and (v >= 0 and v <= self.m_Max_V) then
		local currentFire = self.m_FireMap[i..","..v]
		if iNewSize ~= self.m_FireSizeMap[i..","..v] then
			if iNewSize == 0 then -- fire will be deleted
				if currentFire then
					if not bDontDestroyElement then delete(currentFire) end
					currentFire = nil
					self.m_FireSizeMap[i..","..v] = nil
					self.m_FireMap[i..","..v] = nil
				end
			else -- new fire or fire changes size
				if not currentFire then
					local iX = self.m_X + i*FireRoot.Settings["coords_per_fire"] + math.random(-10, 10)/10
					local iY = self.m_Y + v*FireRoot.Settings["coords_per_fire"] + math.random(-10, 10)/10
					local fire = Fire:new(iX, iY, self.m_BaseZ or 4, iNewSize, false, self, i, v)
					self.m_Statistics.firesActive = self.m_Statistics.firesActive + 1
					self.m_Statistics.firesTotal = self.m_Statistics.firesTotal + 1
					
					fire:addExtinguishCallback(function(uDestroyer, iSize)
						if isElement(uDestroyer) then
							--outputDebugString(inspect(uDestroyer).." has destroyed fire "..inspect(source))
							if not self.m_Statistics.firesByPlayer[uDestroyer] then
								self.m_Statistics.firesByPlayer[uDestroyer] = 0
							end
							self.m_Statistics.firesByPlayer[uDestroyer] = self.m_Statistics.firesByPlayer[uDestroyer] + 1
						else
							self.m_Statistics.firesDecayed = self.m_Statistics.firesDecayed + 1
						end
						self.m_Statistics.firesActive = self.m_Statistics.firesActive - 1
						self.m_FireSizeMap[i..","..v] = nil
						self.m_FireMap[i..","..v] = nil
					end)
					
					fire:addSizeDecreaseCallback(function(player, size)
						if isElement(player) then
							local timeEstimateForFinish =  self:getTimeEstimate() -- estimated time to extinguish the fire (in ms)
							local p = math.random(1, size)
							if self:isFireDecaying() or self:getTimeSinceStart() > timeEstimateForFinish/2 then p = p/2 end -- give less points if fire is already decaying
							if self:getTimeSinceStart() > timeEstimateForFinish then p = 0 end
							if not self.m_Statistics.pointsByPlayer[player] then
								self.m_Statistics.pointsByPlayer[player] = 0
							end
							self.m_Statistics.pointsByPlayer[player] = self.m_Statistics.pointsByPlayer[player] + math.round(p)
						end
					end)

					if self.m_FireMap[i..","..v] then outputDebugString("fail!") end
					self.m_FireMap[i..","..v] = fire
				else
					currentFire:setFireSize(iNewSize)
				end
				self.m_FireSizeMap[i..","..v] = iNewSize
			end
		end
	end
end

function FireRoot:getFireSize(i, v)
	if (i >= 0 and i <= self.m_Max_I) and (v >= 0 and v <= self.m_Max_V) then
		return self.m_FireSizeMap[i..","..v] or 0
	end
end

function FireRoot:getTimeEstimate() -- in ms
	return math.sqrt(self.m_Width*self.m_Height)/4 * 60 * 1000 + (5 * 60 * 1000) -- add size dependent time to 5 minutes
end

function FireRoot:getTimeSinceStart() -- in ms
	return (getTickCount() - self.m_Statistics.startTime)
end

function FireRoot:triggerStatistics()
	triggerClientEvent(FactionRescue:getSingleton():getOnlinePlayers(true, true), "refreshFireStatistics", resourceRoot, self.m_Statistics, self:getTimeSinceStart(), self:getTimeEstimate(), self.m_Width, self.m_Height)
end

function FireRoot:countUsersAtSight(rescueOnly)
	local activeRescue, activeState = 0, 0

	for i, v in pairs(FactionRescue:getSingleton():getOnlinePlayers(true, true)) do
		if getDistanceBetweenPoints3D(v.position, self.m_CenterPoint) <= FireRoot.Settings.distance_to_player then
			activeRescue = activeRescue + 1
		end
	end
	if not rescueOnly then
		for i, v in pairs(FactionState:getSingleton():getOnlinePlayers(true, true)) do
			if getDistanceBetweenPoints3D(v.position, self.m_CenterPoint) <= FireRoot.Settings.distance_to_player then
				activeState = activeState + 1
			end
		end
	end

	return activeRescue, activeState
end

function FireRoot:getFireSpreadSize()
	local size = self.m_Statistics.firesActive * (FireRoot.Settings.coords_per_fire/2)^2
	local lastCheckedSize = self.m_LastSizeChecked or size
	self.m_LastSizeChecked = size
	return size, lastCheckedSize
end