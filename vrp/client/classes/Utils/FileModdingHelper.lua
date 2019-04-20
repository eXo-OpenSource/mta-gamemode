

-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Utils/FileModdingHelper.lua
-- *  PURPOSE:     helper class to provide custom file locations clientside
-- *
-- ****************************************************************************

FileModdingHelper = inherit(Singleton)
FileModdingHelper.WeaponImagePath = "files/images/Weapons/"
function FileModdingHelper:constructor()
    self.m_WeaponImagePath = ""
    self.m_FilePaths = {
        weapons = {}
    }

    self:makePaths()
end

function FileModdingHelper:getWeaponImage(weaponID)
    return self.m_FilePaths.weapons[weaponID]
end

function FileModdingHelper:makePaths()
    --weapons
    self.m_FilePaths.weapons = {}
    for weaponID in pairs(WEAPON_NAMES) do
        local path = FileModdingHelper.WeaponImagePath..weaponID..".png"
        local customPath = "_custom/"..path
        if fileExists(customPath) then
            self.m_FilePaths.weapons[weaponID] = customPath
        else
            self.m_FilePaths.weapons[weaponID] = path
        end
    end
    --vest 
    local path = FileModdingHelper.WeaponImagePath..(-1)..".png"
    local customPath = "_custom/"..path
    self.m_FilePaths.weapons[-1] = fileExists(customPath) and customPath or path
end

function FileModdingHelper:makePath(fileName)
	if isBlip then
		if fileExists("_custom/files/images/Radar/Blips/"..fileName) then
			return "_custom/files/images/Radar/Blips/"..fileName
		end
		return "files/images/Radar/Blips/"..fileName
	else
		local designSet = (self.m_DesignSet == RadarDesign.Monochrome) and "Radar_Monochrome" or "Radar_GTA"
		if fileExists("_custom/files/images/Radar/"..designSet.."/Radar.png") then
			return "_custom/files/images/Radar/"..designSet.."/Radar.png"
		elseif fileExists("_custom/files/images/Radar/"..designSet.."/Radar.jpg") then
			return "_custom/files/images/Radar/"..designSet.."/Radar.jpg"
		end
		return "files/images/Radar/"..designSet.."/Radar.jpg"
	end
end