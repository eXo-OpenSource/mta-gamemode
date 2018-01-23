-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/ItemManager.lua
-- *  PURPOSE:     ItemManager client
-- *
-- ****************************************************************************

ItemManager = inherit( Singleton )
local w,h = guiGetScreenSize()

addRemoteEvents{ "onClientItemUse", "onClientItemExpire"}
function ItemManager:constructor( )
    self:loadEffectItems( )
	self:initWearables()
    addEventHandler( "onClientItemUse", localPlayer, bind( ItemManager.onItemUse, self))
    addEventHandler( "onClientItemExpire", localPlayer, bind( ItemManager.onItemExpire, self))
end

function ItemManager:onItemUse( Item , Expiretime)
  if self.m_Items[Item].onUse then
    if self.m_ActiveDrug then
      self.m_Items[self.m_ActiveDrug]:stopRender()
    end
    self.m_Items[Item]:onUse()
    self.m_ActiveDrug = Item
    if Expiretime then
        self.m_ItemExpire = Expiretime / 1000
        self.m_LastTick = getTickCount()
        if self.m_ExpireFunc then
          removeEventHandler( "onClientRender", root, self.m_ExpireFunc )
        end
        self.m_ExpireFunc = bind( ItemManager.renderExpireTime, self )
        addEventHandler( "onClientRender", root, self.m_ExpireFunc )
    end
  end
end

function ItemManager:renderExpireTime( )
  local now = getTickCount()
  if now - self.m_LastTick >= 1000 then
    self.m_ItemExpire = self.m_ItemExpire -1
    self.m_LastTick = now
    if self.m_ItemExpire <= 0 then
      removeEventHandler( "onClientRender", root, self.m_ExpireFunc )
    end
  end
  dxDrawText( self.m_ItemExpire, 0 ,h*0.1 ,w , h, tocolor( 255,255,255,255), 1, "default-bold","center","top")
end

function ItemManager:onItemExpire( Item )
  if self.m_Items[Item].onExpire then
    self.m_Items[Item]:onExpire()
    removeEventHandler( "onClientRender", root, self.m_ExpireFunc )
  end
end

function ItemManager:loadEffectItems( )
  self.m_Items = {  }
  self.m_Items["Weed"] = DrugsWeed:new();
  self.m_Items["Heroin"] = DrugsHeroin:new();
  self.m_Items["Shrooms"] = DrugsShroom:new();
  self.m_Items["Kokain"] = DrugsCocaine:new();
  self.m_Items["Weed-Samen"] = Plant:new();

  ItemDestructable:new();
  ItemSlam:new();
  ItemSmokeGrenade:new();
end

function ItemManager:initWearables()
	  WearableHelmet:new()
end


function ItemManager:destructor( )

end
