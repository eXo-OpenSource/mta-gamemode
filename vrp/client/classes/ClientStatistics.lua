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
    local tX, tY = guiGetScreenSize()

    self.m_Data = {}
    self.m_Data = dxGetStatus()
    self.m_Data["VideoCardName"] = self.m_Data["VideoCardName"]:match("^%s*(.-)%s*$")
    self.m_Data["Resolution"] = tX.."x"..tY

    triggerServerEvent("receiveClientStatistics", localPlayer, self.m_Data)
end

