-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDSuperSweeper.lua
-- *  PURPOSE:     SuperSweeper HUD class
-- *
-- ****************************************************************************

HUDSuperSweeper = inherit(GUIForm)
inherit(Singleton, HUDSuperSweeper)

addRemoteEvents{"showSuperSweeperHUD"}

function HUDSuperSweeper:constructor()
    GUIForm.constructor(self, screenWidth - 187 - 40, 40, 187, 30, false)
	self.m_Progress = GUIProgressBar:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_Progress:setForegroundColor(tocolor(50, 200, 255))
	self.m_Progress:setBackgroundColor(tocolor(180, 240, 255))
	self.m_VehicleHealthLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(self.m_Health), self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height * 0.75)):setColor(Color.Black)

	self.m_TimedPulse = TimedPulse:new(250)
	self.m_TimedPulse:registerHandler(bind(self.refresh, self))

    self.m_Health = 0
end

function HUDSuperSweeper:destructor()
    GUIForm.destructor(self)
	delete(self.m_TimedPulse)
end

function HUDSuperSweeper:refresh()
    if localPlayer.vehicle then
        self.m_Health = localPlayer.vehicle:getHealthInPercent()

        if not self.m_Health or self.m_Health < 0 or self.m_Health > 100 then
            self.m_Health = 0
        end

        self.m_VehicleHealthLabel:setText(string.format("Zustand: %s%%", self.m_Health))
        self.m_Progress:setProgress(self.m_Health)
    else
        self.m_Health = 0
    end
end

addEventHandler("showSuperSweeperHUD", root,
	function(show)
		--[[
		if show then
			HUDSuperSweeper:new()
		else
			delete(HUDSuperSweeper:getSingleton())
		end
		]]
	end
)
