-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/DrugsShroom.lua
-- *  PURPOSE:     Shroom class client
-- *
-- ****************************************************************************
DrugsShroom = inherit( Object )

function DrugsShroom:constructor( )
end

function DrugsShroom:destructor( )
end

function DrugsShroom:onUse(  )
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
  if self.m_RenderBindFunc then
    removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  end
  self.m_ScreenSource = dxCreateScreenSource( screenWidth, screenHeight)
  self.m_Shader = dxCreateShader( "files/shader/drug-Shroomshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  self.m_StartTick = getTickCount()
  self.m_EndTick = self.m_StartTick + 1000
  self.m_StartAmount = 1
  self.m_EndAmount = 0.5
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  setGameSpeed( 1.1 )
end

function DrugsShroom:stopRender( )
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
end


function DrugsShroom:onRender()
  local now = getTickCount()
  local elap = now - self.m_StartTick
  local dur = self.m_EndTick - self.m_StartTick
  local prog = elap / dur
  local amount, alpha  = interpolateBetween(self.m_StartAmount, 0.3 ,0 ,self.m_EndAmount , 1.0, 0, prog , "SineCurve")
  if now % 5 == 0 then
    dxUpdateScreenSource( self.m_ScreenSource )
  end
  dxSetShaderValue( self.m_Shader, "Threshhold", amount)
  dxSetShaderValue( self.m_Shader, "alpha", alpha)
  dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  dxDrawImage( 0, 0, screenWidth, screenHeight , self.m_Shader)
  if prog >= 2 then
    self.m_StartTick = getTickCount()
    self.m_EndTick = self.m_StartTick + 1000
    self.m_EndAmount = math.random( 0.3, 0.6)
    self.m_StartAmount = amount
  end
end

function DrugsShroom:onExpire()
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if self.m_ScreenSource then
    destroyElement( self.m_ScreenSource )
  end
  if self.m_Shader then
    destroyElement( self.m_Shader )
  end
  setGameSpeed( 1 )
end
