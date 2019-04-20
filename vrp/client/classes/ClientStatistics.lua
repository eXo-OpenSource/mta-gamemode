-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ClientStatistics.lua
-- *  PURPOSE:     Class that collects statistics
-- *
-- ****************************************************************************
ClientStatistics = inherit(Singleton)

function ClientStatistics:constructor()
    addRemoteEvents{"requestClientStatistics"}
	addEventHandler("requestClientStatistics", root, bind(self.Event_RequestStatistics, self))
end

function ClientStatistics:Event_RequestStatistics()
    self.m_Data = {}
    self.m_Data = dxGetStatus()
    self.m_Data["VideoCardName"] = self.m_Data["VideoCardName"]:match("^%s*(.-)%s*$")
    self.m_Data["Resolution"] = ("%sx%s"):format(screenWidth, screenHeight)

    if not self.m_FpsTimerStarted then
        setTimer(bind(self.getFps, self), 1000 * 60 * 5, 1)
    end

    triggerServerEvent("receiveClientStatistics", localPlayer, self.m_Data)
end


function ClientStatistics:getFps()
    triggerServerEvent("fpsClientStatistics", localPlayer, localPlayer.FPS.frames, dxGetStatus()["VideoMemoryFreeForMTA"])
end

