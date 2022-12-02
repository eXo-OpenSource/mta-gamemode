-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemPresent.lua
-- *  PURPOSE:     Present class
-- *
-- ****************************************************************************
ItemPresent = inherit(Item)

function ItemPresent:constructor()

    self.m_Model = 2070
	self.m_Presents = {}
end

function ItemPresent:destructor()

end

function ItemPresent:use()
end

function ItemPresent:addObject(Id, pos, rot, interior, dimension)
    self.m_Presents[Id] = createObject(self.m_Model, pos, rot)
    self.m_Presents[Id]:setInterior(interior)
    self.m_Presents[Id]:setDimension(dimension)
    self.m_Presents[Id]:setCollisionsEnabled(false)
    self.m_Presents[Id]:setScale(0.6)
	self.m_Presents[Id].Id = Id
	self.m_Presents[Id].Type = "Present"

    self.m_Presents[Id].Dummy = createObject(2912, Vector3(pos.x, pos.y, pos.z), rot)
    self.m_Presents[Id].Dummy:setInterior(interior)
    self.m_Presents[Id].Dummy:setDimension(dimension)
    self.m_Presents[Id].Dummy:setAlpha(0)
    self.m_Presents[Id].Dummy.Type = "Present"
    self.m_Presents[Id].Dummy.Present = self.m_Presents[Id]
    self.m_Presents[Id].Dummy:attach(self.m_Presents[Id], 0, 0, -0.5)
    self.m_Presents[Id].Dummy:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Presents[Id].Dummy, bind(self.onPresentClick, self))
	return self.m_Presents[Id]
end

function ItemPresent:onPresentClick(button, state, player)
    if source.Type ~= "Present" then return end
    if getDistanceBetweenPoints3D(source.position, player.position) > 5 then return end
	if button == "left" and state == "down" then
        if source.Present:getModel() == self.m_Model then
            if player:getInventory():getFreePlacesForItem("Päckchen") >= 1 then
                source.Present:destroy()
                source:destroy()
                player:getInventory():giveItem("Päckchen", 1)
                player:sendInfo(_("Du hast einen Päckchen gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Päckchen tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Päckchen")))
            end
        end
    end
end
