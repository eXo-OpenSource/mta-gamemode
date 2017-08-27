
addEvent("fireElementKI:onFireRootDestroyed")
local tblFireRoots = {}
local setting_fire_update_time = 5000 -- time in ms between two fire root updates (new fire spawns)
local setting_coords_per_fire = 2 -- how many coordinates a single fire occupies (experimental!)
local setting_createRadarArea = true -- should there be a radar area indicating the position on the map?


--//
--||  useful functions
--\\

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function spairs(t, order) --http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end


--//
--||  createFireRoot
--||  	parameters:
--||  		iX, iY	= bottom-left position of the fire root
--||  		iW, iH	= width and height of the fire root
--||  	returns: fire root element
--\\

function createFireRoot(iX, iY, iW, iH)
    iW = math.min(math.round(iW), 15*setting_coords_per_fire)
    iH = math.min(math.round(iH), 15*setting_coords_per_fire)
    local uSyncedElement = createElement("fire-root")
    tblFireRoots[uSyncedElement] = {
        iX = iX,
        iY = iY,
        iW = iW,
        iH = iH,
        max_i = iW / setting_coords_per_fire,
        max_v = iH / setting_coords_per_fire,
        iStartTime = getTickCount(),
        uUpdateTimer = setTimer(updateFireRoot, setting_fire_update_time, 0, uSyncedElement),
        tblFireElements = {},
        tblFireSizes = {},
        tblStatistics = {
            iStartTime = getTickCount(),
            tblFiresByPlayer = {},
            iFiresDecayed = 0,
            iFiresActive = 0,
            iFiresTotal = 0,
        },
       
    }
    if setting_createRadarArea then 
        tblFireRoots[uSyncedElement].uRadarArea = createRadarArea(iX, iY, iW, iH)
        setRadarAreaFlashing(tblFireRoots[uSyncedElement].uRadarArea, true)
    end

    for index = 1, math.sqrt(iW*iH)/setting_coords_per_fire/3 do
        local i, v = math.random(0, iW/setting_coords_per_fire), math.random(0, iH/setting_coords_per_fire)
        updateFireInRoot(uSyncedElement, i, v, 3)
    end
    return uSyncedElement
end


--//
--||  updateFireRoot
--||  	parameters:
--||  		uRoot       = the fire root
--||  updates all fires in one root according to spread rules (e.g. large fires spawn small fires)
--\\

function updateFireRoot(uRoot)
    if tblFireRoots[uRoot] then
        for sPos, iSize in spairs(tblFireRoots[uRoot].tblFireSizes, function(t,a,b) return t[b] < t[a] end) do
            local i,v = tonumber(split(sPos, ",")[1]), tonumber(split(sPos, ",")[2])
            local tblSurroundingFires = {
                [(i+1)..","..(v+1)] = (getFireSizeInRoot(uRoot, i+1, v+1)   or 0), --tr
                [(i)..","..(v+1)]   = (getFireSizeInRoot(uRoot, i,   v+1)   or 0), --t
                [(i-1)..","..(v+1)] = (getFireSizeInRoot(uRoot, i-1, v+1)   or 0), --tl
                [(i+1)..","..(v-1)] = (getFireSizeInRoot(uRoot, i+1, v-1)   or 0), --br
                [(i)..","..(v-1)]   = (getFireSizeInRoot(uRoot, i,   v-1)   or 0), --b
                [(i-1)..","..(v-1)] = (getFireSizeInRoot(uRoot, i-1, v-1)   or 0), --bl
                [(i+1)..","..(v)]   = (getFireSizeInRoot(uRoot, i+1, v)     or 0), --r
                [(i-1)..","..(v)]   = (getFireSizeInRoot(uRoot, i-1, v)     or 0), --l
            }
            
            if iSize == 3 then --spawn new fires around size 3 fires
                local iSizeSum = 0
                for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
                    if iSurroundSize == 0 and math.random(1, 3) == 1 then -- spawn new fires
                        local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2]) 
                        updateFireInRoot(uRoot, ii, vv, 1)
                    else
                        iSizeSum = iSizeSum + iSurroundSize
                    end
                end
                if iSizeSum > 8 then -- let the big fire decay if there is every spot taken
                    if math.random(1,3) == 1 then 
                        updateFireInRoot(uRoot, i, v, 0)
                    else
                        updateFireInRoot(uRoot, i, v, 2)
                    end
                end
            elseif iSize == 2 then
                local iSizeSum = 0
                for sSurroundPos, iSurroundSize in pairs(tblSurroundingFires) do
                    iSizeSum = iSizeSum + iSurroundSize
                end
                if iSizeSum > 8 then -- let the big fire decay if there is every spot surrounding it taken
                    updateFireInRoot(uRoot, i, v, 1)
                elseif iSizeSum > 6 and math.random(1, 2) == 1 then -- increase the size if there are more size 2 fires in its surrounding
                    updateFireInRoot(uRoot, i, v, 3)
                end
            elseif iSize == 1 then
                for sSurroundPos, iSurroundSize in spairs(tblSurroundingFires, function(t,a,b) return t[b] > t[a] end) do -- merge two small fires into one medium fire
                    if iSurroundSize == 1 and math.random(1, 2) == 1 then
                        local ii, vv = tonumber(split(sSurroundPos, ",")[1]), tonumber(split(sSurroundPos, ",")[2]) 
                        updateFireInRoot(uRoot, i, v, 2)
                        updateFireInRoot(uRoot, ii, vv, 0)
                    end
                end
            end
        end
        if tblFireRoots[uRoot].tblStatistics.iFiresActive == 0 then
            destroyFireRoot(uRoot)
        end
    end
end


--//
--||  updateFireInRoot
--||  	parameters:
--||  		uRoot       = the fire root
--||  		i,v         = the coordinates inside the fire root grid
--||  		iNewSize    = the new size of the fire (0 = no fire)
--||  		bDontDestroyElement    = used to prevent an infinite loop when this function gets called by destroyFireElement (to set the size to 0)
--||  updates the size of a single fire in the root
--\\

function updateFireInRoot(uRoot, i, v, iNewSize, bDontDestroyElement)
    if tblFireRoots[uRoot] then
        if (i >= 0 and i <= tblFireRoots[uRoot].max_i) and (v >= 0 and v <= tblFireRoots[uRoot].max_v) then
            if iNewSize ~= tblFireRoots[uRoot].tblFireSizes[i..","..v] then
                if iNewSize == 0 then -- fire will be deleted
                    if isElement(tblFireRoots[uRoot].tblFireElements[i..","..v]) then
                        if not bDontDestroyElement then destroyFireElement(tblFireRoots[uRoot].tblFireElements[i..","..v]) end
                        tblFireRoots[uRoot].tblFireElements[i..","..v] = nil
                        tblFireRoots[uRoot].tblFireSizes[i..","..v] = nil
                    end
                else -- new fire or fire changes size
                    if not isElement(tblFireRoots[uRoot].tblFireElements[i..","..v]) then
                        local iX = tblFireRoots[uRoot].iX + i*setting_coords_per_fire + math.random(-0.7, 0.7)
                        local iY = tblFireRoots[uRoot].iY + v*setting_coords_per_fire + math.random(-0.7, 0.7)
                        local uFe = createFireElement(iX, iY, 4, iNewSize, false, uRoot, i, v)
                        tblFireRoots[uRoot].tblStatistics.iFiresActive = tblFireRoots[uRoot].tblStatistics.iFiresActive + 1
                        tblFireRoots[uRoot].tblStatistics.iFiresTotal = tblFireRoots[uRoot].tblStatistics.iFiresTotal + 1
        
                        addEventHandler("fireElements:onFireExtinguish", uFe, function(uDestroyer)
                            if isElement(uDestroyer) then
                                --outputDebugString(inspect(uDestroyer).." has destroyed fire "..inspect(source))
                                if not tblFireRoots[uRoot].tblStatistics.tblFiresByPlayer[uDestroyer] then
                                    tblFireRoots[uRoot].tblStatistics.tblFiresByPlayer[uDestroyer] = 0
                                end
                                tblFireRoots[uRoot].tblStatistics.tblFiresByPlayer[uDestroyer] = tblFireRoots[uRoot].tblStatistics.tblFiresByPlayer[uDestroyer] + 1
                            else
                                tblFireRoots[uRoot].tblStatistics.iFiresDecayed = tblFireRoots[uRoot].tblStatistics.iFiresDecayed + 1
                            end
                            tblFireRoots[uRoot].tblStatistics.iFiresActive = tblFireRoots[uRoot].tblStatistics.iFiresActive - 1
                        end)
                        if tblFireRoots[uRoot].tblFireElements[i..","..v] then outputDebugString("fail!") end
                        tblFireRoots[uRoot].tblFireElements[i..","..v] = uFe
                    else
                        setFireSize(tblFireRoots[uRoot].tblFireElements[i..","..v], iNewSize)
                    end
                    tblFireRoots[uRoot].tblFireSizes[i..","..v] = iNewSize
                end
            end
        end
    end
end


--//
--||  getFireSizeInRoot
--||  	parameters:
--||  		uRoot       = the fire root
--||  		i,v         = the coordinates inside the fire root grid
--||  		tblCustomSizes    = use this table to get the fire sizes (default: sizes of tblFireRoots)
--||  	returns: fire size
--\\

function getFireSizeInRoot(uRoot, i, v, tblCustomSizes)
    if tblFireRoots[uRoot] then
        if (i >= 0 and i <= tblFireRoots[uRoot].max_i) and (v >= 0 and v <= tblFireRoots[uRoot].max_v) then
            if tblCustomSizes then 
                return tblCustomSizes[i..","..v] or 0
            else
                return tblFireRoots[uRoot].tblFireSizes[i..","..v] or 0
            end
        end
    end
end


--//
--||  destroyFireRoot
--||  	parameters:
--||  		uRoot       = the fire root
--\\

function destroyFireRoot(uRoot)
    triggerEvent("fireElementKI:onFireRootDestroyed", uRoot, tblFireRoots[uRoot].tblStatistics)
    if isTimer(tblFireRoots[uRoot].uUpdateTimer) then killTimer(tblFireRoots[uRoot].uUpdateTimer) end
    for i, uEle in pairs(tblFireRoots[uRoot].tblFireElements) do
        destroyFireElement(uEle)
    end
    if isElement(tblFireRoots[uRoot].uRadarArea) then destroyElement(tblFireRoots[uRoot].uRadarArea) end
    destroyElement(uRoot)
    tblFireRoots[uRoot] = nil
end