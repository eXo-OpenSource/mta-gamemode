-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/PoliceAnnouncements.lua
-- *  PURPOSE:     Police Announcement Sounds class
-- *
-- ****************************************************************************
PoliceAnnouncements = inherit(Singleton)

addRemoteEvents{"PoliceAnnouncement:wanted", "PoliceAnnouncement:chase"}
function PoliceAnnouncements:constructor()
    self.m_WantedBind = bind(self.playWantedSound, self)
    self.m_ChaseBind = bind(self.playChaseSound, self)

    addEventHandler("PoliceAnnouncement:wanted", root, self.m_WantedBind)
    addEventHandler("PoliceAnnouncement:chase", root, self.m_ChaseBind)
end

function PoliceAnnouncements:destructor()
    removeEventHandler("PoliceAnnouncement:wanted", root, self.m_WantedBind)
    removeEventHandler("PoliceAnnouncement:chase", root, self.m_ChaseBind)
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
    local static = playSFX("genrl", 52, 3, true)
    static:setVolume(0.25)
    setTimer(
        function()
            sound1 = playSFX("script", 3, 0) --Can you attend
            if sound1 then --so we know he's got the soundfiles
                sound1:setVolume(volume)
            end
            addEventHandler("onClientSoundStopped", sound1, 
                function()
                    local soundId = POLICE_ANNOUNCEMENT_WANTED_REASONS[wantedreason] and POLICE_ANNOUNCEMENT_CRIMES[POLICE_ANNOUNCEMENT_WANTED_REASONS[wantedreason]] or POLICE_ANNOUNCEMENT_CRIMES["hazard"]
                    sound2 = playSFX("script", 4, soundId-1) -- a [CrimeId] in
                    sound2:setVolume(volume)
                    addEventHandler("onClientSoundStopped", sound2,
                        function ()
                            local soundId = POLICE_ANNOUNCEMENT_ZONES[zone] and POLICE_ANNOUNCEMENT_ZONES[zone] or POLICE_ANNOUNCEMENT_ZONES["San Andreas"]
                            sound3 = playSFX("script", 0, soundId-1) --Zone Name
                            sound3:setVolume(volume)
                            addEventHandler("onClientSoundStopped", sound3, 
                                function()
                                    sound4 = playSFX("script", 3, 7) --Suspect last seen
                                    sound4:setVolume(volume)
                                    addEventHandler("onClientSoundStopped", sound4, 
                                        function()
                                            if not modelId then 
                                                sound5 = playSFX("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["foot"]-1) --on foot
                                                sound5:setVolume(volume)
                                                setTimer(stopSound, (getSoundLength(sound5)*1000)+50, 1, static)
                                            else
                                                if self:isBike(modelId) then
                                                    sound5 = playSFX("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["bike"]-1) --on a
                                                    sound5:setVolume(volume)
                                                else
                                                    sound5 = playSFX("script", 3, POLICE_ANNOUNCEMENT_MOVEMENT_TYPES["vehicle"]-1) --in a
                                                    sound5:setVolume(volume)
                                                end
                                                addEventHandler("onClientSoundStopped", sound5, 
                                                    function()
                                                        local soundId = self:getColorSound(color)
                                                        sound6 = playSFX("script", 1, soundId-1) --Color
                                                        sound6:setVolume(volume)
                                                        addEventHandler("onClientSoundStopped", sound6, 
                                                            function()
                                                                local soundId = self:getVehicleSound(modelId) --Vehicle
                                                                sound7 = playSFX("script", 5, soundId-1)
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
    local sound = playSFX3D("spc_fa", 10, soundId, vehicle:getPosition())
    if sound then
        sound:attach(vehicle)
        sound:setVolume(core:get("Sounds", "PoliceMegaphoneVolume", 1))
        sound:setMaxDistance(175)
    end
end

function PoliceAnnouncement:syncSirens(sirenTable)
    for key, value in pairs(sirenTable) do

    end
end

function PoliceAnnouncements:playSiren(vehicle, type)
    if type == 1 then
        vehicle.sirenSound = playSFX("genrl", 67, 10)
    elseif type == 2 then
        vehicle.sirenSound = playSFX("genrl", 67, 11)
    end
end

function PoliceAnnouncement:stopSirenOnDestroy()

end
--addEventHandler("onClientElementDestroy", root)