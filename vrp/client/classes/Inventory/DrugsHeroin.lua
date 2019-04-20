-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/DrugsHeroin.lua
-- *  PURPOSE:     Heroin class client
-- *
-- ****************************************************************************
DrugsHeroin = inherit( Object )

function DrugsHeroin:constructor( )
end

function DrugsHeroin:destructor( )
end

function DrugsHeroin:onUse(  )
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
  self.m_Shader = dxCreateShader( "files/shader/drug-heroinshader.fx" )
  self.m_RenderBindFunc = function() self:onRender() end
  addEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  self.m_StartTick = getTickCount()
  self.m_EndTick = self.m_StartTick + 1000
  self.m_StartAmount = 1
  self.m_EndAmount = 1.5
  self.m_StartWidth = 0.001
  self.m_EndWidth = math.random( 0.001,0.005)
end

function DrugsHeroin:stopRender( )
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if isElement( self.m_ScreenSource )  then
      destroyElement( self.m_ScreenSource )
  end
  if  isElement( self.m_Shader ) then
    destroyElement( self.m_Shader )
  end
end

function DrugsHeroin:onRender()
  local now = getTickCount()
  local elap = now - self.m_StartTick
  local dur = self.m_EndTick - self.m_StartTick
  local prog = elap / dur
  local amount, width = interpolateBetween(self.m_StartAmount, self.m_StartWidth ,0 ,self.m_EndAmount , self.m_EndWidth ,0, prog , "SineCurve")
  dxUpdateScreenSource( self.m_ScreenSource )
  dxSetShaderValue( self.m_Shader, "Amount", amount)
  dxSetShaderValue( self.m_Shader, "Width", width)
  dxSetShaderValue( self.m_Shader, "ScreenTexture", self.m_ScreenSource)
  dxDrawImage( 0, 0, screenWidth, screenHeight , self.m_Shader)
  if prog >= 1 then
    self.m_StartTick = getTickCount()
    self.m_EndTick = self.m_StartTick + 1000
    self.m_StartAmount = amount
    self.m_EndAmount = math.random( 3, 7)
    self.m_EndWidth = math.random( 0.001,0.009)
    self.m_StartWidth = width
  end
end

function DrugsHeroin:onExpire()
  removeEventHandler("onClientHUDRender", root, self.m_RenderBindFunc)
  if self.m_ScreenSource then
    destroyElement( self.m_ScreenSource )
  end
  if self.m_Shader then
    destroyElement( self.m_Shader )
  end
end
