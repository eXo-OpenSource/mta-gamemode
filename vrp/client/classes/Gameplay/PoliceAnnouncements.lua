-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/PoliceAnnouncements.lua
-- *  PURPOSE:     Police Announcement Sounds class
-- *
-- ****************************************************************************
PoliceAnnouncements = inherit(Singleton)

addRemoteEvents{"PoliceAnnouncement:wanted", "PoliceAnnouncement:chase", "PoliceAnnouncement:siren", "PoliceAnnouncement:syncSiren"}
function PoliceAnnouncements:constructor()
    self.m_SirenSounds = {}

    self.m_WantedBind = bind(self.playWantedSound, self)
    self.m_ChaseBind = bind(self.playChaseSound, self)
    self.m_SirenBind = bind(self.startSiren, self)
    self.m_SirenSync = bind(self.syncSirens, self)
    self.m_SirenColHit = bind(self.onSirenColHit, self)
    self.m_SirenColLeave = bind(self.onSirenColLeave, self)

    addEventHandler("PoliceAnnouncement:wanted", root, self.m_WantedBind)
    addEventHandler("PoliceAnnouncement:chase", root, self.m_ChaseBind)
    addEventHandler("PoliceAnnouncement:siren", root, self.m_SirenBind)
    addEventHandler("PoliceAnnouncement:syncSiren", root, self.m_SirenSync)
end

function PoliceAnnouncements:destructor()
    removeEventHandler("PoliceAnnouncement:wanted", root, self.m_WantedBind)
    removeEventHandler("PoliceAnnouncement:chase", root, self.m_ChaseBind)
    removeEventHandler("PoliceAnnouncement:siren", root, self.m_SirenBind)
    removeEventHandler("PoliceAnnouncement:syncSiren", root, self.m_SirenSync)
end

function PoliceAnnouncements:playSound(container, bank, id, x, y, z, loop)
    local custombank = bank + 1
    if custombank < 10 then custombank = "0"..custombank end
    local customid = id + 1
    if customid < 10 then 
        customid = "00"..customid
    elseif customid < 100 then 
        customid = "0"..customid 
    end
    local path = "_custom/files/audio/police/"..container.."/Bank_0"..custombank.."/sound_"..customid..".wav"
    if fileExists(path) then
        if type(x) == "boolean" or not x then
            return playSound(path, x)
        else
            return playSound3D(path, x, y, z, loop)
        end
    else
        if type(x) == "boolean" or not x then
            return playSFX(container, bank, id, x)
        else
            return playSFX3D(container, bank, id, x, y, z, loop)
        end
    end
end

function PoliceAnnouncements:playNeedhelpSound(zone)
    if POLICE_NEEDHELP_ANNOUNCEMENTS[zone] then
        local random = math.random(1, #POLICE_NEEDHELP_ANNOUNCEMENTS[zone])
        local soundId = POLICE_NEEDHELP_ANNOUNCEMENTS[zone][random]
        sound = playSFX("radio", "Police", soundId)
        sound:setVolume(1)
        if sound then
            sound:setVolume(1)
        end
    end
end

function PoliceAnnouncements:playWantedSound(zone, wantedreason, modelId, color)
    if core:get("Sounds", "WantedRadioEnabled", true) == false then return end
    local volume = core:get("Sounds", "WantedRadioVolume", 1)
    local static = self:playSound("genrl", 52, 3, true)
    static:setVolume(0.25)
    setTimer(
        function()
            sound1 = self:playSound("script", 3, 0) --Can you attend
            if sound1 then --so we know he's got the soundfiles
                sound1:setVolume(volume)
            end
            addEventHandler("onClientSoundStopped", sound1, 
                function()
                    local soundId = POLICE_ANNOUNCEMENT_WANTED_REASONS[wantedreason] and POLICE_ANNOUNCEMENT_CRIMES[POLICE_ANNOUNCEMENT_WANTED_REASONS[wantedreason]] or POLICE_ANNOUNCEMENT_CRIMES["hazard"]
                    sound2 = self:playSound("script", 4, soundId-1) -- a [CrimeId] in
                    sound2:setVolume(volume)
                    addEventHandler("onClientSoundStopped", sound2,
                        function ()
                            local soundId = POLICE_ANNOUNCEMENT_ZONES[zone] and POLICE_ANNOUNCEMENT_ZONES[zone] or POLICE_ANNOUNCEMENT_ZONES["San Andreas"]
                            sound3 = self:playSound("script", 0, soundId-1) --Zone Name
                            sound3:setVolume(volume)
                            addEventHandler("onClientSoundStopped", sound3, 
                                function()
                                    sound4 = self:playSound("script", 3, 7) --Suspect last seen
                                    sound4:setVolume(volume)
                                    addEventHandler("onClientSoundStopped", sound4, 
                                        function()
                                            if not modelId then 
                                                sound5 = self:playSound("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["foot"]-1) --on foot
                                                sound5:setVolume(volume)
                                                setTimer(stopSound, (getSoundLength(sound5)*1000)+50, 1, static)
                                            else
                                                if self:isBike(modelId) then
                                                    sound5 = self:playSound("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["bike"]-1) --on a
                                                    sound5:setVolume(volume)
                                                else
                                                    sound5 = self:playSound("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["vehicle"]-1) --in a
                                                    sound5:setVolume(volume)
                                                end
                                                addEventHandler("onClientSoundStopped", sound5, 
                                                    function()
                                                        local soundId = self:getColorSound(color)
                                                        sound6 = self:playSound("script", 1, soundId-1) --Color
                                                        sound6:setVolume(volume)
                                                        addEventHandler("onClientSoundStopped", sound6, 
                                                            function()
                                                                local soundId = self:getVehicleSound(modelId) --Vehicle
                                                                sound7 = self:playSound("script", 5, soundId-1)
                                                                sound7:setVolume(volume)
                                                                setTimer(stopSound, (getSoundLength(sound7)*1000)+50, 1, static)
                                                            end
                                                        )
                                                    end
                                                )
                                            end
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    , 50, 1)
end

function PoliceAnnouncements:isBike(modelId)
    local name = getVehicleNameFromModel(modelId)
    local vehType = VehicleCategory:getSingleton():getCategoryName(VehicleCategory:getSingleton():getModelCategory(modelId))
    if name == "NRG-500" or vehType == "Fahrrad" or vehType == "Motorrad" then
        return true
    else
        return false
    end
end

function PoliceAnnouncements:getVehicleSound(modelId)
    local name = getVehicleNameFromModel(modelId)
    local vehType = VehicleCategory:getSingleton():getCategoryName(VehicleCategory:getSingleton():getModelCategory(modelId))
    if POLICE_ANNOUNCEMENT_VEHICLES[name] then
        return POLICE_ANNOUNCEMENT_VEHICLES[name]
    elseif POLICE_ANNOUNCEMENT_VEHICLES[vehType] then
        return POLICE_ANNOUNCEMENT_VEHICLES[vehType]
    else
        return POLICE_ANNOUNCEMENT_VEHICLES["Limousine"]
    end
end

function PoliceAnnouncements:getColorSound(vehcolor)
    local colorFound = false
    local color = getColorNameFromVehicle(vehcolor, vehcolor)
    for key, value in pairs(POLICE_ANNOUNCEMENT_COLORS) do
        if string.find(color, key) then
            colorFound = true
            color = key
        end
    end
    if colorFound then
        return POLICE_ANNOUNCEMENT_COLORS[color]
    else
        return POLICE_ANNOUNCEMENT_COLORS["Unerkannt"]
    end
end

function PoliceAnnouncements:playChaseSound(vehicle, type, id)
    if core:get("Sounds", "PoliceMegaphoneEnabled", true) == false then return end
    local soundId = POLICE_ANNOUNCEMENT_CHASE_SOUNDS[type][id]
    local x, y, z = getElementPosition(vehicle)
    local sound = self:playSound("spc_fa", 10, soundId, x, y, z)
    if sound then
        sound:attach(vehicle)
        sound:setVolume(core:get("Sounds", "PoliceMegaphoneVolume", 1))
        sound:setMaxDistance(175)
    end
end

function PoliceAnnouncements:syncSirens(sirenTable)
    for vehicle, sirenType in pairs(sirenTable) do
        self:playSiren(vehicle, sirenType)
    end
end

function PoliceAnnouncements:playSiren(vehicle, sirenType)
    if core:get("Sounds", "SirenhallEnabled", false) == false then return end
    local x, y, z = getElementPosition(vehicle)
    if vehicle.controller then vehicle.controller:setControlState("horn", false) end
    vehicle:setSirensOn(false)

    if sirenType == "active" then
        if vehicle.sirenSound and vehicle.sirenSound:getData("sirenType") == "secondary" then
            vehicle.sirenSound:destroy()
            vehicle.sirenShape:destroy()
        elseif vehicle.sirenSound and vehicle.sirenSound:getData("sirenType") == "active" then
            return
        end
        vehicle.sirenSound = self:playSound("genrl", 67, 10, x, y, z, true)
    elseif sirenType == "secondary" then
        if vehicle.sirenSound and vehicle.sirenSound:getData("sirenType") == "active" then
            vehicle.sirenSound:destroy()
            vehicle.sirenShape:destroy()
        elseif vehicle.sirenSound and vehicle.sirenSound:getData("sirenType") == "secondary" then
            return
        end
        vehicle.sirenSound = self:playSound("genrl", 67, 11, x, y, z, true)
    elseif sirenType == "inactive" then
        if vehicle.sirenSound then vehicle.sirenSound:destroy() vehicle.sirenSound = nil end
        if self.m_SirenSounds[vehicle] then self.m_SirenSounds[vehicle] = nil end
        if vehicle.sirenShape then vehicle.sirenShape:destroy() vehicle.sirenShape = nil end
    end

    if vehicle.sirenSound then
        vehicle.sirenSound:setData("sirenType", sirenType)
        self.m_SirenSounds[vehicle] = vehicle.sirenSound
        vehicle.sirenSound:attach(vehicle)
        vehicle.sirenSound:setVolume(core:get("Sounds", "SirenhallVolume", 1))
        vehicle.sirenSound:setMaxDistance(300)
        vehicle.sirenShape = createColSphere(x, y, z, 200)
        vehicle.sirenShape:setData("owner", vehicle)
        vehicle.sirenShape:attach(vehicle)
        addEventHandler("onClientColShapeHit", vehicle.sirenShape, self.m_SirenColHit)
        addEventHandler("onClientColShapeLeave", vehicle.sirenShape, self.m_SirenColLeave)
        setTimer(function() self:colShapeCheck(vehicle) end, 1000, 1)
    end
    setTimer(setVehicleSirensOn, 100, 1, vehicle, false)
end

function PoliceAnnouncements:startSiren(vehicle, sirenType)
    self:playSiren(vehicle, sirenType)
end

function PoliceAnnouncements:setSirenVolume(volume)
    for key, sound in pairs(self.m_SirenSounds) do
        sound:setVolume(volume)
    end
end

function PoliceAnnouncements:onSirenColHit(element) 
    if element == localPlayer then
        local vehicle = source:getData("owner")
        vehicle.sirenSound:setEffectEnabled("reverb", false) 
    end 
end

function PoliceAnnouncements:onSirenColLeave(element) 
    if element == localPlayer then
        local vehicle = source:getData("owner")
        vehicle.sirenSound:setEffectEnabled("reverb", true) 
    end 
end

function PoliceAnnouncements:colShapeCheck(vehicle)
    if vehicle.sirenShape and isElement(vehicle.sirenShape) then
        if localPlayer.vehicle == vehicle then
            return
        end
        if not isElementWithinColShape(localPlayer, vehicle.sirenShape) then 
            vehicle.sirenSound:setEffectEnabled("reverb", true) 
        end
    end
end