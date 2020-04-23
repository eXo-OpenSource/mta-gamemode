-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)
-- addRemoteEvents{"retrieveInfo"}

function Admin:constructor()
	addEventHandler("onClientWorldSound", root, bind(self.Event_worldSound, self))
	-- addEventHandler("onClientRender", root, bind(self.Event_worldSound, self))
	StaticFileTextureReplacer:new("Other/trans.png", "shad_ped")
end

function Admin:Event_worldSound(group, index, x, y, z)
    if source.type == "player" and source:getPublicSync("isInvisible") then
        cancelEvent()
    end
end
