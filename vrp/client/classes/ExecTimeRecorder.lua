-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ExecTimeRecorder.lua
-- *  PURPOSE:     Debugging class to show execution times (mainly for render purposes)
-- *
-- ****************************************************************************


ExecTimeRecorder = inherit(Singleton)

function ExecTimeRecorder:constructor()
    addCommandHandler("exec_time", bind(ExecTimeRecorder.exec_time, self))
    self.m_Enabled = false
    self.m_RenderHandler = bind(ExecTimeRecorder.renderResults, self)
end

function ExecTimeRecorder:exec_time()
    self.m_Enabled = not self.m_Enabled
    if self.m_Enabled then
        addEventHandler("onClientRender", root, self.m_RenderHandler, true, "low-9999")
        self.m_Recordings = {}
    else
        removeEventHandler("onClientRender", root, self.m_RenderHandler)
        self.m_Recordings = nil
    end
end

function ExecTimeRecorder:startRecording(name)
    if not self.m_Enabled then return false end
    self.m_Recordings[name] = {getTickCount(), 0, 0}
end

function ExecTimeRecorder:addIteration(name, drawCall)
    if not self.m_Enabled then return false end
    if self.m_Recordings[name] then
        if drawCall then
            self.m_Recordings[name][3] = self.m_Recordings[name][3] + 1
        else
            self.m_Recordings[name][2] = self.m_Recordings[name][2] + 1
        end
    end
end

function ExecTimeRecorder:endRecording(name, iterations, drawCalls)
    if not self.m_Enabled then return false end
    if self.m_Recordings[name] then
        self.m_Recordings[name][1] = getTickCount() - self.m_Recordings[name][1]
        self.m_Recordings[name][2] = iterations and iterations or self.m_Recordings[name][2]
        self.m_Recordings[name][3] = drawCalls and drawCalls or self.m_Recordings[name][3]
    end
end

function ExecTimeRecorder:renderResults()
    local i = 0
    local total = 0
    for name, recDat in pairs(self.m_Recordings) do
        dxDrawText(("%dms > %s (%d iterations, %d draws)"):format(recDat[1], name, recDat[2], recDat[3]), 10, screenHeight/2 - 200 + i*20)
        i = i + 1
        total = total + recDat[1]
    end
    i = i + 1
    dxDrawText(total.."ms", 10, screenHeight/2 - 200 + i*20)
    self.m_Recordings = {}
end

