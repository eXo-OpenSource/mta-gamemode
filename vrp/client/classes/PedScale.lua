-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/PedScale.lua
-- *  PURPOSE:     Ped scale class
-- *
-- ****************************************************************************

PedScale = inherit(Singleton)
addRemoteEvents{"retrievePedScaleInfos"}

function PedScale:constructor()
    self.m_Infos = {}

    addEventHandler("retrievePedScaleInfos", root, bind(self.retrieveInfos, self))
end

function PedScale:retrieveInfos(infos)
    for ped, info in pairs(self.m_Infos) do
        if isElement(ped) then
            engineRemoveShaderFromWorldTexture(info.shader, "*", ped)
        end
        destroyElement(info.shader)
    end

    self.m_Infos = {}
    for ped, scale in pairs(infos) do
        if isElement(ped) then
            self.m_Infos[ped] = {
                scaleX = scale[1], 
                scaleY = scale[2], 
                scaleZ = scale[3],
                offset = scale[4],
                shader = dxCreateShader("files/shader/pedSize.fx", 0, 0, false, "ped")
            }
            dxSetShaderValue(self.m_Infos[ped].shader, "size", self.m_Infos[ped].scaleY-1, self.m_Infos[ped].scaleZ-1, self.m_Infos[ped].scaleX-1)
            dxSetShaderValue(self.m_Infos[ped].shader, "offset", 0, self.m_Infos[ped].offset, 0)
            engineApplyShaderToWorldTexture(self.m_Infos[ped].shader, "*", ped)
        end
    end
end
