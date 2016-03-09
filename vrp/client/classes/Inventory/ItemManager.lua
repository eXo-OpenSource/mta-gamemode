-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/ItemManager.lua
-- *  PURPOSE:     ItemManager client
-- *
-- ****************************************************************************

ItemManager = inherit( Singleton )

addRemoteEvents{ "onClientItemUse", "onClientItemExpire"}
function ItemManager:constructor( )
    self:loadEffectItems( )
    addEventHandler( "onClientItemUse", localPlayer, bind( ItemManager.onItemUse, self))
    addEventHandler( "onClientItemExpire", localPlayer, bind( ItemManager.onItemExpire, self))
end

function ItemManager:onItemUse( Item )
  if self.m_Items[Item].onUse then
    self.m_Items[Item]:onUse()
  end
end

function ItemManager:onItemExpire( Item )
  if self.m_Items[Item].onExpire then
    self.m_Items[Item]:onExpire()
  end
end

function ItemManager:loadEffectItems( )
  self.m_Items = {  }
  self.m_Items["Weed"] = DrugsWeed:new();
end


function ItemManager:destructor( )

end
