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
	["coords_per_fire"] = 2
}

addEvent("fireElementKI:onFireRootDestroyed")

function FireRoot:constructor(iX, iY, iW, iH)
	iW = math.min(math.round(iW), 15*FireRoot.Settings["coords_per_fire"])
    iH = math.min(math.round(iH), 15*FireRoot.Settings["coords_per_fire"])
   	self.m_Root = createElement("fire-root")
	self.m_tblFires = {}
	self.m_tblLastFireOfPlayer = {}

	self.m_iX = iX
	self.m_iY = iY
	self.m_iW = iW
	self.m_iH = iH
	self.m_max_i = iW / FireRoot.Settings["coords_per_fire"]
	self.m_max_v = iH / FireRoot.Settings["coords_per_fire"]
	self.m_iStartTime = getTickCount()
	self.m_UpdateBind = bind(self.update, self)
	self.m_uUpdateTimer = setTimer(self.m_UpdateBind, FireRoot.Settings["fire_update_time"], 0, self.m_Root)
	self.m_tblFireElements = {}
	self.m_tblFireSizes = {}
	self.m_tblStatistics = {
		iStartTime = getTickCount(),
		tblFiresByPlayer = {},
		iFiresDecayed = 0,
		iFiresActive = 0,
		iFiresTotal = 0,
	}

    for index = 1, math.sqrt(iW*iH)/FireRoot.Settings["coords_per_fire"]/3 do
        local i, v = math.random(0, iW/FireRoot.Settings["coords_per_fire"]), math.random(0, iH/FireRoot.Settings["coords_per_fire"])
        self:updateFire(i, v, 3)
    end

	addEventHandler("fireElementKI:onFireRootDestroyed", self.m_Root, function(tblStatistics)
        outputDebugString("fire root "..inspect(self.m_Root).." has been extinguished completely. Statistics:")
        iprint(tblStatistics)
    end)

	FireRoot.Map = self

    return self
end

function FireRoot:destructor()
	triggerEvent("fireElementKI:onFireRootDestroyed", self.m_Root, self.m_tblStatistics)
    if isTimer(self.m_uUpdateTimer) then killTimer(self.m_uUpdateTimer) end
    for i, uEle in pairs(self.m_tblFireElements) do
        delete(uEle)
    end
    if isElement(self.m_uRadarArea) then destroyElement(self.m_uRadarArea) end
    destroyElement(self.m_Root)

	if self.m_onFinishHook then
		self.m_onFinishHook[1](unpack(self.m_onFinishHook[2]))
	end

    FireRoot.Map[self] = nil
end

function FireRoot:addOnFinishHook(callback, ...)
	local additionalParameters = {...}
	self.m_onFinishHook = {callback, additionalParameters}
end

function FireRoot:update()
        for sPos, iSize in spairs(self.m_tblFireSizes, function(t,a,b) return t[b] < t[a] end) do
            local i,v = tonumber(split(sPos, ",")[1]), tonumber(split(sPos, ",")[2])
            local tblSurroundingFires = {
                [(i+1)..","..(v+1)] = (self:getFireSize(i+1, v+1)   or 0), --tr
                [(i)..","..(v+1)]   = (self:getFireSize(i, i,   v+1)   or 0), --t
                [(i-1)..","..(v+1)] = (self:getFireSize(i, i-1, v+1)   or 0), --tl
                [(i+1)..","..(v-1)] = (self:getFireSize(i, i+1, v-1)   or 0), --br
                [(i)..","..(v-1)]   = (self:getFireSize(i, i,   v-1)   or 0), --b
                [(i-1)..","..(v-1)] = (self:getFireSize(i, i-1, v-1)   or 0), --bl
                [(i+1)..","..(v)]   = (self:getFireSize(i, i+1, v)     or 0), --r
                [(i-1)..","..(v)]   = (self:getFireSize(i, i-1, v)     or 0), --l
            }

            if iSize == 3 then --spawn new fires around size 3 fires
                local iSizeSum = 0
                for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
                    if iSurroundSize == 0 and math.random(1, 3) == 1 then -- spawn new fires
                        local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2])
                        self:updateFire(ii, vv, 1)
                    else
                        iSizeSum = iSizeSum + iSurroundSize
                    end
                end
                if iSizeSum > 8 then -- let the big fire decay if there is every spot taken
                    if math.random(1,3) == 1 then
                        self:updateFire(i, v, 0)
                    else
                        self:updateFire(i, v, 2)
                    end
                end
            elseif iSize == 2 then
                local iSizeSum = 0
                for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
                    iSizeSum = iSizeSum + iSurroundSize
                end
                if iSizeSum > 8 then -- let the big fire decay if there is every spot surrounding it taken
                    self:updateFire(i, v, 1)
                elseif iSizeSum > 6 and math.random(1, 2) == 1 then -- increase the size if there are more size 2 fires in its surrounding
                    self:updateFire(i, v, 3)
                end
            elseif iSize == 1 then
                for sSurroundPos, iSurroundSize in spairs(tblSurroundingFires, function(t,a,b) return t[b] > t[a] end) do -- merge two small fires into one medium fire
                    if iSurroundSize == 1 and math.random(1, 2) == 1 then
                        local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2])
                        self:updateFire(i, v, 2)
                        self:updateFire(ii, vv, 0)
                    end
                end
            end
        end
        if self.m_tblStatistics.iFiresActive == 0 then
            delete(self)
        end
end

function FireRoot:updateFire(i, v, iNewSize, bDontDestroyElement)
	if (i >= 0 and i <= self.m_max_i) and (v >= 0 and v <= self.m_max_v) then
		local currentFire = self.m_tblFireElements[i..","..v]
		if iNewSize ~= self.m_tblFireSizes[i..","..v] then
			if iNewSize == 0 then -- fire will be deleted
				if currentFire then
					if not bDontDestroyElement then delete(currentFire) end
					currentFire = nil
					self.m_tblFireSizes[i..","..v] = nil
				end
			else -- new fire or fire changes size
				if not currentFire then
					local iX = self.m_iX + i*FireRoot.Settings["coords_per_fire"] + math.random(-0.7, 0.7)
					local iY = self.m_iY + v*FireRoot.Settings["coords_per_fire"] + math.random(-0.7, 0.7)
					local uFe = Fire:new(iX, iY, 4, iNewSize, false, self, i, v)
					self.m_tblStatistics.iFiresActive = self.m_tblStatistics.iFiresActive + 1
					self.m_tblStatistics.iFiresTotal = self.m_tblStatistics.iFiresTotal + 1

					addEventHandler("fireElements:onFireExtinguish", uFe.m_Ped, function(uDestroyer)
						if isElement(uDestroyer) then
							--outputDebugString(inspect(uDestroyer).." has destroyed fire "..inspect(source))
							if not self.m_tblStatistics.tblFiresByPlayer[uDestroyer] then
								self.m_tblStatistics.tblFiresByPlayer[uDestroyer] = 0
							end
							self.m_tblStatistics.tblFiresByPlayer[uDestroyer] = self.m_tblStatistics.tblFiresByPlayer[uDestroyer] + 1
						else
							self.m_tblStatistics.iFiresDecayed = self.m_tblStatistics.iFiresDecayed + 1
						end
						self.m_tblStatistics.iFiresActive = self.m_tblStatistics.iFiresActive - 1
					end)
					if self.m_tblFireElements[i..","..v] then outputDebugString("fail!") end
					self.m_tblFireElements[i..","..v] = uFe
				else
					currentFire:setFireSize(iNewSize)
				end
				self.m_tblFireSizes[i..","..v] = iNewSize
			end
		end
	end
end

function FireRoot:getFireSize(i, v)
	if (i >= 0 and i <= self.m_max_i) and (v >= 0 and v <= self.m_max_v) then
		if self.m_tblFireSizes then
			return self.m_tblFireSizes[i..","..v] or 0
		else
			return self.m_tblFireSizes[i..","..v] or 0
		end
	end
end
