-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/DrugsWeed.lua
-- *  PURPOSE:     Weed class client
-- *
-- ****************************************************************************
DrugsWeed = inherit( Object )

function DrugsWeed:constructor( )
end

function DrugsWeed:destructor( )
end

function DrugsWeed:onUse(  )
  if isElement( self.m_ScreenSource )  then
    if isElement( self.m_ScreenSource )  then
        destroyElement( self.m_ScreenSource )
    end
    if  isElement( self.m_Shader ) then
      destroyElement( self.m_Shader )
    end
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
  if self.m_RenderBindFunc then
    removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  end
  self.m_ScreenSource = dxCreateScreenSource( screenWidth, screenHeight)
  self.m_Shader = dxCreateShader( "files/shader/drug-weedshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  self.m_StartTick = getTickCount()
  self.m_EndTick = self.m_StartTick + 1000
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)

  -- Give an Achievement
  localPlayer:giveAchievement(10)
end

function DrugsWeed:onRender()
  local now = getTickCount()
  local elap = now - self.m_StartTick
  local dur = self.m_EndTick - self.m_StartTick
  local prog = elap / dur
  local alpha = interpolateBetween(0,0,0 ,1,0,0, prog , "SineCurve")
  dxUpdateScreenSource( self.m_ScreenSource )
  dxSetShaderValue( self.m_Shader, "alpha", alpha)
  dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  dxDrawImage( 0, 0, screenWidth, screenHeight , self.m_Shader)
  if prog >= 1 then
    self.m_StartTick = getTickCount()
    self.m_EndTick = self.m_StartTick + 1000
  end
end

function DrugsWeed:stopRender( )
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
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
