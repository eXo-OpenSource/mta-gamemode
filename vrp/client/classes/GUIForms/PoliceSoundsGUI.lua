-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PoliceSoundsGUI.lua
-- *  PURPOSE:     GUI Grid Wrapper
-- *
-- ****************************************************************************
PoliceSoundsGUI = inherit(GUIForm)
inherit(Singleton, PoliceSoundsGUI)

function PoliceSoundsGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Polizei Sounds", true, true, self)
	
    self.m_WantedSoundCheckBox = GUIGridCheckbox:new(1, 1, 1, 1, "Funk-Ansage bei Wantedvergabe", self.m_Window)
    self.m_WantedSoundCheckBox:setChecked(core:get("Sounds", "WantedRadioEnabled", true))
    self.m_WantedSoundCheckBox.onChange = function (state)
        core:set("Sounds", "WantedRadioEnabled", state)
        self.m_WantedSoundSlider:setEnabled(state)
    end

    self.m_WantedSoundSlider = GUIGridSlider:new(1, 2, 6, 1, self.m_Window)
    self.m_WantedSoundSlider:setRange(0.1, 2)
    self.m_WantedSoundSlider:setValue(core:get("Sounds", "WantedRadioVolume", 1))
    self.m_WantedSoundSlider.onUpdate = function(volume)
        local scale = math.round(volume, 1)
        core:set("Sounds", "WantedRadioVolume", volume)
    end
	
    self.m_MegaphoneCheckBox = GUIGridCheckbox:new(1, 4, 1, 1, "Megafon Lautstärke", self.m_Window)
    self.m_MegaphoneCheckBox:setChecked(core:get("Sounds", "PoliceMegaphoneEnabled", true))
    self.m_MegaphoneCheckBox.onChange = function (state)
        core:set("Sounds", "PoliceMegaphoneEnabled", state)
        self.m_MegaphoneSlider:setEnabled(state)
    end

    self.m_MegaphoneSlider = GUIGridSlider:new(1, 5, 6, 1, self.m_Window)
    self.m_MegaphoneSlider:setRange(0.1, 2)
    self.m_MegaphoneSlider:setValue(core:get("Sounds", "PoliceMegaphoneVolume", 1))
    self.m_MegaphoneSlider.onUpdate = function(volume)
        local scale = math.round(volume, 1)
        core:set("Sounds", "PoliceMegaphoneVolume", volume)
    end
    
    self.m_SirenHallCheckBox = GUIGridCheckbox:new(1, 7, 1, 1, "Sirenenhall", self.m_Window)
    self.m_SirenHallCheckBox:setChecked(core:get("Sounds", "SirenhallEnabled", true))
    self.m_SirenHallCheckBox.onChange = function (state)
        core:set("Sounds", "SirenhallEnabled", state)
        self.m_SirenHallSlider:setEnabled(state)
    end

    self.m_SirenHallSlider = GUIGridSlider:new(1, 8, 6, 1, self.m_Window)
    self.m_SirenHallSlider:setRange(0.1, 2)
    self.m_SirenHallSlider:setValue(core:get("Sounds", "SirenhallVolume", 1))
    self.m_SirenHallSlider.onUpdate = function(volume)
        local scale = math.round(volume, 1)
        core:set("Sounds", "SirenhallVolume", volume)
        PoliceAnnouncements:getSingleton():setSirenVolume(volume)
    end
    local testsound = playSFX("spc_fa", 10, 34)
    if testsound then
        stopSound(testsound)
    else
        self.m_Label = GUIGridLabel:new(1, 9, 7, 1, "Fehler: Dir fehlen Sound-Dateien, lade Sie dir im Forum herunter!", self.m_Window)
    end
end

function PoliceSoundsGUI:destructor()
	GUIForm.destructor(self)
end

function PoliceSoundsGUI:setMainWindow(windowInstance)
    self.m_MainWindow = windowInstance
    self.m_Window:addBackButton(function () delete(self) self.m_MainWindow:getSingleton():show() end)
end