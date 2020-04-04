-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PedScale.lua
-- *  PURPOSE:     Ped scale class
-- *
-- ****************************************************************************

PedScale = inherit(Singleton)

function PedScale:constructor()
    self.m_Infos = {}

    Player.getQuitHook():register(
		function(player)
			if self.m_Infos[player] then
				self:removePedScale(player)
			end
		end
    )
    
end

function PedScale:setPedScale(ped, scaleX, scaleY, scaleZ, offset)
    if isElement(ped) then
        self.m_Infos[ped] = {scaleX, scaleY, scaleZ, offset}
        self:updateClients()
    end
end

function PedScale:removePedScale(ped)
    if self.m_Infos[ped] then
        self.m_Infos[ped] = nil
        self:updateClients()
    end
end

function PedScale:updateClients(player)
    if player then
        player:triggerEvent("retrievePedScaleInfos", self.m_Infos)
    else
        triggerClientEvent("retrievePedScaleInfos", root, self.m_Infos)
    end
end