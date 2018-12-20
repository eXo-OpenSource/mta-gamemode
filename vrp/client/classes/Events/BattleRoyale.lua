BattleRoyale = inherit(Singleton)
addRemoteEvents{"battleRoyalePrepare", "battleRoyaleStatusUpdate"}

function BattleRoyale:constructor()
	self.m_UpdateStatusEvent = bind(self.updateStatus, self)
	self.m_ExitPlane = bind(self.exitPlane, self)
	self.m_ZoneRenderEvent = bind(self.renderZone, self)

	addEventHandler("battleRoyaleStatusUpdate", root, self.m_UpdateStatusEvent)
	addEventHandler("onClientRender", root, self.m_ZoneRenderEvent)
	bindKey("f", "up", self.m_ExitPlane)
end

function BattleRoyale:exitPlane()
	if self.m_Data.status == "starting" and self.m_Data.canJump then
		triggerServerEvent("battleRoyaleLeavePlane", localPlayer)
	end
end

function BattleRoyale:updateStatus(data)
	self.m_Data = data

    if data then
        if not self.m_Message then
            self.m_Message = ShortMessage:new("", "Battle Royale", Color.Red , -1)
		end
		--[[local data = {
			status = "preparing",
			playersAlive = 123,
			timeTillZoneGetsSmaller = 123,
			andMoreStuff = 123
		}]]
		local text = ""

		if data.status == "preparing" then
			text = tostring(data.playersAlive) .. " Spieler in der Lobby"
		elseif data.status == "running" then
			text = tostring(data.playersAlive) .. " Spieler am Leben"
			local t = timespanArray(data.travelTime)
			text = text .. "\n" .. tostring(t["min"]) .. ":" .. tostring(t["sec"])
		elseif data.status == "starting" then
			text = tostring(data.playersAlive) .. " Spieler am Leben"
			if data.canJump and localPlayer:getAlpha() == 0 then
				text = text .. "\n" .. "Drücke 'F' um zu springen!"
			end
		end

        self.m_Message:setText(text)
        self.m_Message.onLeftClick = function ()
            if not self.m_Data then
                self.m_Message:delete()
                self.m_Message = nil
            end
        end
    else
        if self.m_Message then
            self.m_Message:delete()
            self.m_Message = nil
        end
    end

end

function BattleRoyale:renderZone()
	if self.m_Data.currentZone then
		local pos = self.m_Data.currentZone

		for i = 1, 100 do

			-- North
			dxDrawLine3D(pos.x, pos.y - pos.height, 10 * i, pos.x + pos.width, pos.y - pos.height, 10 * i, Color.Red, 10)

			-- South
			dxDrawLine3D(pos.x, pos.y, 10 * i, pos.x + pos.width, pos.y, 10 * i, Color.Red, 10)

			-- East
			dxDrawLine3D(pos.x + pos.width, pos.y - pos.height, 10 * i, pos.x + pos.width, pos.y, 10 * i, Color.Red, 10)

			-- West
			dxDrawLine3D(pos.x, pos.y - pos.height, 10 * i, pos.x, pos.y, 10 * i, Color.Red, 10)



			---------------------------------------------

			-- North
			-- dxDrawLine3D(pos.x, pos.y, 10 * i, pos.x + pos.width, pos.y, 10 * i, Color.Red, 10)

 			-- South
			-- dxDrawLine3D(pos.x + pos.width, pos.y + pos.height, 10 * i, pos.x + pos.width, pos.y, 10 * i, Color.Red, 10)

			-- West
			-- dxDrawLine3D(pos.x, pos.y, 10 * i, pos.x, pos.y + pos.height, 10 * i, Color.Red, 10)

			-- East
			-- dxDrawLine3D(pos.x + pos.width, pos.y + pos.height, 10 * i, pos.x, pos.y + pos.height, 10 * i, Color.Red, 10)
		end
	end
end

function BattleRoyale.start()
    BattleRoyale:new()
end
addEventHandler("battleRoyalePrepare", root, BattleRoyale.start)


function BattleRoyale.destruct()
    delete(BattleRoyale:getSingleton())
end
addEventHandler("battleRoyaleDestruct", root, BattleRoyale.destruct)
