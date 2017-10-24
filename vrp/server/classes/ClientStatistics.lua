-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ClientStatistics.lua
-- *  PURPOSE:     Class that collects statistics
-- *
-- ****************************************************************************
ClientStatistics = inherit(Singleton)

function ClientStatistics:constructor()
    addRemoteEvents{"receiveClientStatistics", "fpsClientStatistics"}
	addEventHandler("receiveClientStatistics", root, bind(self.Event_ReceiveStatistics, self))
	addEventHandler("fpsClientStatistics", root, bind(self.Event_ReceiveFps, self))
end

function ClientStatistics:handle(client)
    client:triggerEvent("requestClientStatistics")
end

function ClientStatistics:Event_ReceiveStatistics(data)
    local playerId = client:getId()
    local serial = client:getSerial()

    if not playerId or not serial then
        error("ClientStatistics call without proper user --> id or serial missing")
        return
    end
    
    local result = sql:queryFetch("SELECT * FROM ??_client_statistics WHERE UserId = ? AND Serial = ?;", sql:getPrefix(), playerId, serial)

    
    if not result or #result == 0 then
        sql:queryExec("INSERT INTO ??_client_statistics (UserId, Serial, GPU, VRAM, Resolution, `Window`, `AllowScreenUpload`) VALUES (?, ?, ?, ?, ?, ?, ?)",
            sql:getPrefix(), playerId, serial, data.VideoCardName and data.VideoCardName or "", data.VideoCardRAM and data.VideoCardRAM or 0, data.Resolution and data.Resolution or "", data.SettingWindowed and 1 or 0, data.AllowScreenUpload and 1 or 0)
    else
        sql:queryExec("UPDATE ??_client_statistics SET GPU = ?, VRAM = ?, Resolution = ?, `Window` = ?, `AllowScreenUpload` = ? WHERE UserId = ? AND Serial = ?",
            sql:getPrefix(), data.VideoCardName and data.VideoCardName or "", data.VideoCardRAM and data.VideoCardRAM or 0, data.Resolution and data.Resolution or "", data.SettingWindowed and 1 or 0, data.AllowScreenUpload and 1 or 0, playerId, serial)
    end
end

function ClientStatistics:Event_ReceiveFps(fps, freeVram)
    local playerId = client:getId()
    local serial = client:getSerial()

    if not playerId or not serial then
        error("ClientStatistics call without proper user --> id or serial missing")
        return
    end
    
    local result = sql:queryFetch("SELECT * FROM ??_client_statistics WHERE UserId = ? AND Serial = ?;", sql:getPrefix(), playerId, serial)

    
    if not result or #result == 0 then
        sql:queryExec("INSERT INTO ??_client_statistics (UserId, Serial, FPS, FreeVRAM) VALUES (?, ?, ?, ?)",
            sql:getPrefix(), playerId, serial, fps and fps or 0, freeVram and freeVram or 0)
    else
        sql:queryExec("UPDATE ??_client_statistics SET FPS = ?, FreeVRAM = ? WHERE UserId = ? AND Serial = ?",
            sql:getPrefix(), fps and fps or 0, freeVram and freeVram or 0, playerId, serial)
    end
end

--[[
CREATE TABLE `vrp_client_statistics` (
`UserId`  int NULL ,
`Serial`  varchar(32) NULL ,
`GPU`  varchar(128) NULL ,
`VRAM`  int NULL ,
`Resolution`  varchar(16) NULL ,
`Window`  tinyint(1) NULL ,
`AllowScreenUpload`  tinyint(1) NULL ,
PRIMARY KEY (`UserId`, `Serial`)
)
;

ALTER TABLE vrp_client_statistics ADD FPS INT NULL;
ALTER TABLE vrp_client_statistics ADD FreeVRAM INT NULL;

{
  AllowScreenUpload = true,
  DepthBufferFormat = "intz",
  Resolution = "1600x900",
  Setting32BitColor = true,
  SettingAnisotropicFiltering = 0,
  SettingAntiAliasing = 3,
  SettingAspectRatio = "auto",
  SettingDrawDistance = 100,
  SettingFOV = 70,
  SettingFXQuality = 3,
  SettingGrassEffect = true,
  SettingHUDMatchAspectRatio = true,
  SettingHeatHaze = true,
  SettingHighDetailVehicles = true,
  SettingStreamingVideoMemoryForGTA = 256,
  SettingVolumetricShadows = true,
  SettingWindowed = true,
  TestMode = "none",
  UsingDepthBuffer = false,
  VideoCardMaxAnisotropy = 4,
  VideoCardName = "NVIDIA GeForce GTX 960M",
  VideoCardNumRenderTargets = 4,
  VideoCardPSVersion = "3",
  VideoCardRAM = 1024,
  VideoMemoryFreeForMTA = 653,
  VideoMemoryUsedByFonts = 87,
  VideoMemoryUsedByRenderTargets = 55,
  VideoMemoryUsedByTextures = 61
}
]]
