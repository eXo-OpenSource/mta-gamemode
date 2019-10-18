-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/RadioCommunication.lua
-- *  PURPOSE:     RadioCommunication class
-- *
-- ****************************************************************************
RadioCommunication = inherit(Singleton)


function RadioCommunication:constructor()
    self.m_Channels = {}
    addRemoteEvents{"RadioCommunication:tuneFrequency"}
    addEventHandler("RadioCommunication:tuneFrequency", root, bind(self.Event_tuneFrequency, self))
    addCommandHandler("r", bind(self.Event_OnMessageCommand, self))
end

function RadioCommunication:destructor()

end

function RadioCommunication:allowPlayer(player, bool) 
    player:triggerEvent("onAllowRadioCommunication", bool)
    player.m_RadioCommunication = bool
end

function RadioCommunication:Event_OnMessageCommand(send, cmd, ... )
	local argTable = { ... }
	local text = table.concat(argTable , " ")
    self:sendMessage(send, text)
end

function RadioCommunication:sendMessage(sender, message, channel)
    if sender and message then 
        channel = channel or 1
        local channelCount = 1
        message = message:gsub("%%", "%%%%")
        for frequency, data in pairs(self.m_Channels) do 
            for player, bool in pairs(data) do 
                if player == sender then
                    if channel == channelCount then
                         if message ~= "" then
                            return self:broadcast(sender, frequency, ("%s sagt: %s"):format(sender:getName(), message))
                        end
                    else 
                        channelCount = channelCount + 1
                    end
                end
            end
        end
    end
end

function RadioCommunication:broadcast(sender, frequency, message) 
    if self.m_Channels[frequency] then 
        local receivedPlayers = {}
        for player, bool in pairs(self.m_Channels[frequency]) do
            if player.m_RadioCommunication then
                player:triggerEvent("RadioCommunication:playStaticNoise")
                player:sendMessage(("#03cafc** [%s]#b3eaff %s #03cafc**"):format(self:format(frequency), message), 3, 202, 252, true)
        	    if player ~= sender then
			        receivedPlayers[#receivedPlayers+1] = player
			    end
            end
        end
        StatisticsLogger:getSingleton():addChatLog(sender, "funk", message, receivedPlayers)
    end
end

function RadioCommunication:loadPlayer(player) 
    if player.m_RadioFrequency then 
        for frequency, bool in pairs(player.m_RadioFrequency) do 
            self:joinChannel(frequency, player)  
        end
    end
end

function RadioCommunication:joinChannel(frequency, player)
    if player then
        if not self.m_Channels[frequency] then 
            self.m_Channels[frequency] = {}
        end 
        self.m_Channels[frequency][player] = true
        if not player.m_RadioFrequency then player.m_RadioFrequency = {} end
        player.m_RadioFrequency[frequency] = true
        player:triggerEvent("RadioCommunication:updateFrequency", frequency)
    end
end

function RadioCommunication:disconnectFromAllChannels(player) 
    if player.m_RadioFrequency then 
        for frequency, bool in pairs(player.m_RadioFrequency) do 
            self.m_Channels[frequency][player] = nil
            player.m_RadioFrequency[frequency] = nil
        end
    end
end

function RadioCommunication:Event_tuneFrequency(frequency) 
    if frequency and frequency ~= "" then
        local display = self:format(frequency)
        display = display:sub(1, #display-4)
        if tonumber(display) then 
            if tonumber(display) < 69 or tonumber(display) > 99.999 then 
                return client:sendError(_("Ungültige Frequenz! Bitte stelle eine Frequenz zwischen 69.000 MHz und 99.999 MHz ein!", client))
            end
        else 
            return client:sendError(_("Ungültige Frequenz! Bitte stelle eine Frequenz zwischen 69.000 MHz und 99.999 MHz ein!", client))
        end
    end
    self:disconnectFromAllChannels(client)
    if frequency ~= "" then
        client:sendInfo(_("Das Funkgerät ist nun auf die Frequenz %s eingestellt!", client, self:format(frequency)))
        self:joinChannel(frequency, client)
    else 
        client:sendInfo(_("Das Funkgerät ist nun in keine Frequenz eingestellt!", client))
    end
end


function RadioCommunication:format(input) 
	local display = ""
    if tonumber(input) then 
        if tonumber(input) < 99 then 
            input = tostring(tonumber(input) * 1000)
        end
    end
	if input == "" then 
		return (("%s MHz"):format("-"))	
	elseif #input == 3 then 
		display = ("%s.%s"):format(input:sub(1, #input-2), input:sub(-2))
		return (("%s MHz"):format(display))
	elseif #input >= 4 then 
		display = ("%s.%s"):format(input:sub(1, #input-3), input:sub(-3))
		if #input > 5 then 
			input = input:sub(2)
			display = display:sub(2)
		end
		return (("%s MHz"):format(display))	
	else 
		return (("%s MHz"):format(input))
	end
end
