-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/ItemManager.lua
-- *  PURPOSE:     Weed class client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
DrugsWeed = inherit( Object )


function DrugsWeed:constructor( )

end

function DrugsWeed:onUse(  )
  if self.m_ScreenSource then
      destroyElement( self.m_ScreenSource )
      destroyElement( self.m_Shader )
      removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  end
  self.m_ScreenSource = dxCreateScreenSource( w, h)
  self.m_Shader = dxCreateShader( "files/shader/drug-weedshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
end

function DrugsWeed:onRender()
  dxUpdateScreenSource( self.m_ScreenSource )
  dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  dxDrawImage( 0, 0, w, h , self.m_Shader)
end

function DrugsWeed:onExpire()
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if self.m_ScreenSource then
    destroyElement( self.m_ScreenSource )
  end
  if self.m_Shader then
    destroyElement( self.m_Shader )
  end
end

function DrugsWeed:destructor( )

end
