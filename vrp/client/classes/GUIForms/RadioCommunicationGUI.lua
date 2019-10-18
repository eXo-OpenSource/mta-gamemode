-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RadioCommunicationGUI.lua
-- *  PURPOSE:     RadioCommunicationGUI class
-- *
-- ****************************************************************************
RadioCommunicationGUI = inherit(GUIForm)
inherit(Singleton, RadioCommunicationGUI)
inherit(GUIMovable, RadioCommunicationGUI)

addRemoteEvents{"openRadioOverlay"}

function RadioCommunicationGUI:constructor(police)
	GUIForm.constructor(self, core:get("HUD", "radioOverlayX", screenWidth-((screenWidth*.2)*1.2)),  core:get("HUD", "radioOverlayY", screenHeight/2-(((screenWidth*.2)*2.14)*.5)), screenWidth*.2, (screenWidth*.2)*2.14, true)
	self.m_Radio = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/other/Radioset.png", self)
	self.m_Radio.onLeftClickDown = function()
		if not self.m_BlockMove then
			self:startMoving()
		end
	end
	self.m_Radio.onLeftClick = function()
		self:stopMoving()
		core:set("HUD", "radioOverlayX", self.m_AbsoluteX)
		core:set("HUD", "radioOverlayY", self.m_AbsoluteY)
	end
	self.m_Input = ""
	self.m_InputPre = ""
	self:createButtons()
	if police then 

	end
	self:createDisplay()
	self:setFrequency(core:get("HUD", "radioFrequency", ""), core:get("HUD", "radioFrequencyAlternate", ""))
	self.m_UpdateTimer = setTimer(bind(self.Event_onTick, self), 1000, 0)
	self:toggleKeys(true)
end

function RadioCommunicationGUI:createButtons() 
	self.m_NumberButtons = {}
	for i = 1, 12 do 
		local height = math.ceil(i/3)
		self.m_NumberButtons[i] = GUIRectangle:new((self.m_Width*.25)+(self.m_Width*.14*(i%3)), self.m_Height*.72-(self.m_Width*.1) + (self.m_Width*.12*(math.ceil(i/3))), self.m_Width*.11, self.m_Width*.1, tocolor(0, 0, 0, 70), self)
		self.m_NumberButtons[i].onHover = function() 
			self.m_NumberButtons[i]:setColor(Color.Clear) 
			self.m_BlockMove = true
		end 
		self.m_NumberButtons[i].onUnhover = function() 
			self.m_NumberButtons[i]:setColor(tocolor(0, 0, 0, 70)) 
			self.m_BlockMove = false
		end
	end
	
	self.m_NumberButtons[13] = GUIRectangle:new((self.m_Width*.25)+(self.m_Width*.14*3), self.m_Height*.72-(self.m_Width*.1) + (self.m_Width*.12*1), self.m_Width*.11, self.m_Width*.1, tocolor(0, 0, 0, 70), self)
	self.m_NumberButtons[13].onHover = function() 
		self.m_NumberButtons[13]:setColor(Color.Clear)
		self.m_BlockMove = true
	end 
	self.m_NumberButtons[13].onUnhover = function() 
		self.m_NumberButtons[13]:setColor(tocolor(0, 0, 0, 70)) 
		self.m_BlockMove = false
	end

	self.m_NumberButtons[14] = GUIRectangle:new((self.m_Width*.25)+(self.m_Width*.14*3), self.m_Height*.72-(self.m_Width*.1) + (self.m_Width*.12*2), self.m_Width*.11, self.m_Width*.1, tocolor(0, 0, 0, 70), self)
	self.m_NumberButtons[14].onHover = function() 
		self.m_BlockMove = true
		self.m_NumberButtons[14]:setColor(Color.Clear) 
	end 
	self.m_NumberButtons[14].onUnhover = function() 
		self.m_NumberButtons[14]:setColor(tocolor(0, 0, 0, 70)) 
		self.m_BlockMove = false
	end


	self.m_NumberButtons[15] = GUIRectangle:new((self.m_Width*.24)+(self.m_Width*.14*3), self.m_Height*.72-(self.m_Width*.1) + (self.m_Width*.12*3), self.m_Width*.11, self.m_Width*.21, tocolor(0, 0, 0, 70), self)
	self.m_NumberButtons[15].onHover = function() 
		self.m_NumberButtons[15]:setColor(Color.Clear) 
		self.m_BlockMove = true
	end 
	self.m_NumberButtons[15].onUnhover = function() 
		self.m_NumberButtons[15]:setColor(tocolor(0, 0, 0, 70)) 
		self.m_BlockMove = false	
	end

	for i = 1, #self.m_NumberButtons do 
		self.m_NumberButtons[i].onLeftClick = function() self:input(i) end
	end
end

function RadioCommunicationGUI:createDisplay() 
	self.m_DisplayTopLeft = GUILabel:new(self.m_Width*.21, self.m_Height*.5, self.m_Width*.62, (self.m_Height*.18)*.2, os.date('%H-%M-%S'), self):setAlignY("top"):setFont(VRPFont((self.m_Height*.18)*.13, Fonts.Digital)):setColor(tocolor(26, 53, 27)):setAlignX("left")
	self.m_DisplayTopCenter = GUILabel:new(self.m_Width*.19, self.m_Height*.5, self.m_Width*.62, (self.m_Height*.18)*.2, "CB", self):setAlignY("top"):setFont(VRPFont((self.m_Height*.18)*.13, Fonts.Digital)):setColor(tocolor(26, 53, 27)):setAlignX("center")
	self.m_DisplayTopRight = GUILabel:new(self.m_Width*.19, self.m_Height*.5, self.m_Width*.62, (self.m_Height*.18)*.2, "100%", self):setAlignY("top"):setFont(VRPFont((self.m_Height*.18)*.13, Fonts.Digital)):setColor(tocolor(26, 53, 27)):setAlignX("right")
	
	
	self.m_DisplayCenter = GUILabel:new(self.m_Width*.2, self.m_Height*.51+(self.m_Height*.18)*.3, self.m_Width*.62, (self.m_Height*.18)*.3, _"- MHz", self):setAlignY("center"):setFont(VRPFont((self.m_Height*.28)*.2, Fonts.Digital)):setColor(tocolor(26, 53, 27)):setAlignX("center")
	self.m_DisplayBottom = GUILabel:new(self.m_Width*.2, self.m_Height*.52+(self.m_Height*.18)*.6, self.m_Width*.62, (self.m_Height*.18)*.3, _"- MHz", self):setAlignY("bottom"):setFont(VRPFont((self.m_Height*.18)*.2, Fonts.Digital)):setColor(tocolor(26, 53, 27)):setAlignX("center")
end

function RadioCommunicationGUI:input(id) 
	if id < 10 or id == 12 then
		if id == 12 then 
			id = 0
		elseif id == 1 then 
			id = 2 
		elseif id == 3 then 
			id = 1 
		elseif id == 2 then 
			id = 3 
		elseif id == 4 then 
			id = 5  
		elseif id == 5 then 
			id = 6 
		elseif id == 6 then 
			id = 4 
		elseif id == 7 then 
			id = 8 
		elseif id == 8 then 
			id = 9 
		elseif id == 9 then 
			id = 7
		end
		self.m_Input = ("%s%s"):format(self.m_Input, id)
		self:format()
		playSound("files/audio/walkie_click.ogg")
	elseif id == 10 then 
		self.m_Input = self.m_Input:sub(2)
		self:format()
		playSound("files/audio/walkie_click.ogg")
	elseif id == 11 then 
		self.m_Input = self.m_Input:sub(1, #self.m_Input-1)
		self:format()
		playSound("files/audio/walkie_click.ogg")
	elseif id == 13 then 
		self.m_Input = ""
		self.m_DisplayCenter:setText("- MHz")
		playSound("files/audio/walkie_click.ogg")
	elseif id == 14 then 
		self:send()
	elseif id == 15 then 
		playSound("files/audio/walkie_click.ogg")
		self:setFrequency(self.m_InputPre, self.m_Input)
	end
end

function RadioCommunicationGUI:format() 
	local display = ""
	if self.m_Input == "" then 
		self.m_DisplayCenter:setText(("%s MHz"):format("-"))	
	elseif #self.m_Input == 3 then 
		display = ("%s.%s"):format(self.m_Input:sub(1, #self.m_Input-2), self.m_Input:sub(-2))
		self.m_DisplayCenter:setText(("%s MHz"):format(display))
	elseif #self.m_Input >= 4 then 
		display = ("%s.%s"):format(self.m_Input:sub(1, #self.m_Input-3), self.m_Input:sub(-3))
		if #self.m_Input > 5 then 
			self.m_Input = self.m_Input:sub(2)
			display = display:sub(2)
		end
		self.m_DisplayCenter:setText(("%s MHz"):format(display))	
	else 
		self.m_DisplayCenter:setText(("%s MHz"):format(self.m_Input))
	end
end

function RadioCommunicationGUI:formatSecond()
	local display = ""
	if self.m_InputPre == "" then 
		self.m_DisplayBottom:setText(("%s MHz"):format("-"))	
	elseif #self.m_InputPre == 3 then 
		display = ("%s.%s"):format(self.m_InputPre:sub(1, #self.m_InputPre-2), self.m_InputPre:sub(-2))
		self.m_DisplayBottom:setText(("%s MHz"):format(display))
	elseif #self.m_InputPre >= 4 then 
		display = ("%s.%s"):format(self.m_InputPre:sub(1, #self.m_InputPre-3), self.m_InputPre:sub(-3))
		if #self.m_InputPre > 5 then 
			self.m_InputPre = self.m_InputPre:sub(2)
			display = display:sub(2)
		end
		self.m_DisplayBottom:setText(("%s MHz"):format(display))	
	else 
		self.m_DisplayBottom:setText(("%s MHz"):format(self.m_Input))
	end
end

function RadioCommunicationGUI:setFrequency(first, second)
	self.m_Input = first 
	self:format()
	self.m_InputPre = second
	self:formatSecond()
end

function RadioCommunicationGUI:Event_onTick() 
	self.m_DisplayTopLeft:setText(os.date('%H-%M-%S'))
end

function RadioCommunicationGUI:send() 
    if tonumber(self.m_Input) then 
        if tonumber(self.m_Input) < 99 then 
            self.m_Input = tostring(tonumber(self.m_Input) * 1000)
        end
    end
	core:set("HUD", "radioFrequencyAlternate", self.m_InputPre)
	playSound("files/audio/walkie_beep.ogg")
	self:setFrequency(self.m_Input, self.m_InputPre)
	triggerServerEvent("RadioCommunication:tuneFrequency", localPlayer, self.m_Input)
end

function RadioCommunicationGUI:destructor() 
	GUIForm.destructor(self)
	if self.m_UpdateTimer and isTimer(self.m_UpdateTimer) then 
		killTimer(self.m_UpdateTimer)
	end
end

addEvent("RadioCommunication:updateFrequency", true)
addEventHandler("RadioCommunication:updateFrequency", localPlayer, function(input) 
	core:set("HUD", "radioFrequency", input)
end)

addEvent("RadioCommunication:playStaticNoise", true)
addEventHandler("RadioCommunication:playStaticNoise", localPlayer, function(input) 
	if core:get("Sounds", "StaticNoise", true) then
		playSoundFrontEnd(47)
		setTimer(playSoundFrontEnd, 500, 1, 48)
	end
end)