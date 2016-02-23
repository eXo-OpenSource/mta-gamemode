-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolTheoryGUI.lua
-- *  PURPOSE:     DrivingSchoolTheoryGUI
-- *
-- ****************************************************************************
DrivingSchoolTheoryGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolTheoryGUI)

addRemoteEvents{ "showDrivingSchoolTest" }

local Questions = {	}
local width,height = screenWidth*0.4,screenHeight*0.4

function DrivingSchoolTheoryGUI:constructor(type)
	GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2 - height/2, width,height, false)
	GUIRectangle:new(0, 0, self.m_Width,self.m_Height, tocolor(200,200,200,200), self)
	GUIRectangle:new(0, 0, self.m_Width,self.m_Height*0.05,Color.Black , self)
	self.m_Title = GUILabel:new( 0, 0, self.m_Width,self.m_Height*0.05, "Theoretische Fahrprüfung ( Klasse B )", self)
	self.m_Title:setAlignX( "center" )
	self.m_Title:setAlignY( "top" )
	self.m_Title:setColor(Color.White)

end


function DrivingSchoolTheoryGUI:submitQuestion( ) 

end

function DrivingSchoolTheoryGUI:nextQuestion()

end

addEventHandler("showDrivingSchoolTest", root,
	function(type)
		DrivingSchoolTheoryGUI:new(type)
	end
)

addEventHandler("hideDrivingSchoolTheoryGUI", root,
	function()
		DrivingSchoolTheoryGUI:getSingleton():delete()
	end
)
