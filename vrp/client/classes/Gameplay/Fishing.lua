Fishing = inherit(Singleton)
Fishing.Text = {
	[1] = "Wirf den Köder aus!",
	[2] = "Hole die Schnur ein!"
	}


function Fishing.load()
	local ped = Ped.create(161, Vector3(368.27, -2072.03, 8.02), 180)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Angler Lutz", "Verkaufe mir deinen Fang!")
	setElementData(ped, "clickable", true)
	ped:setData("onClickEvent", function ()
		triggerServerEvent("fishingPedClick", localPlayer)
	 end)
	 Blip:new("Fishing.png", 368.27, -2072.03, 600)
end

addRemoteEvents{"startFishingClient"}

function Fishing:constructor(step, markerId)
	self.m_MarkerId = markerId
	self.m_Step = step
	self.m_Start = getTickCount()
    self.m_Active = true
	self.m_Current = 0
	self.m_InterPolateStart = 0
	self.m_InterPolateTarget = 250

	self.m_Best = (self.m_InterPolateStart+self.m_InterPolateTarget)/2

	self.m_RenderBind = bind(self.render, self)
	self.m_ClickBind = bind(self.onClick, self)

	self.m_Text = Fishing.Text[step]

	self.m_Duration = math.random(500, 1500)

	self.m_Ped = 371.29, -2072.32, 8.02

	addEventHandler("onClientPreRender", root, self.m_RenderBind)
	addEventHandler("onClientKey", root, self.m_ClickBind)

end

function Fishing:destructor()
	removeEventHandler("onClientPreRender", root, self.m_RenderBind)
	removeEventHandler("onClientKey", root, self.m_ClickBind)
end

function Fishing:render()
	local left = screenWidth-300
	local top = screenHeight/2

	if self.m_Active == true then
		local now = getTickCount()
		local endTime = self.m_Start + self.m_Duration
		local elapsedTime = now - self.m_Start
		local duration = endTime - self.m_Start
		local progress = elapsedTime / duration

		local x, _, _ = interpolateBetween (
			self.m_InterPolateStart, 0, 0,
			self.m_InterPolateTarget, 0, 0,
			progress, "InOutQuad")
			self.m_Current = x

		if progress and progress > 1 then
			self.m_Start = getTickCount()
			if self.m_InterPolateTarget == 250 then
				self.m_InterPolateStart = 250
				self.m_InterPolateTarget = 0
			else
				self.m_InterPolateStart = 0
				self.m_InterPolateTarget = 250
			end
		end
	end

	dxDrawText(self.m_Text, left, top-35, left+250, top-5, tocolor(255, 255, 255, 255), 2, "center")
	dxDrawImage(left, top , 250, 30, "files/images/Other/RedGreenRed.png")
	dxDrawRectangle(left+self.m_Current, top-5 , 5, 40, tocolor ( 255, 255, 255, 255 ) )
	dxDrawText(_"Versuche die Mitte zu treffen!", left, top+35, left+250, top+65, tocolor(255, 255, 255, 255), 1, "center")
end

function Fishing:onClick(button, press)
    if press and button == "mouse1" then
        self.m_Active = false
		self:calculate()
		cancelEvent()
    end
end

function Fishing:calculate()
	local value = self.m_Current > 125 and math.abs(250-self.m_Current) or self.m_Current
	local p = math.abs((value/self.m_Best)*100)

	setTimer(function()
		delete(self)
		triggerServerEvent("fishingStepFinished", localPlayer, self.m_MarkerId, self.m_Step, p)
	end, 1000, 1)
end

addEventHandler("startFishingClient", root, function(step, id)
	Fishing:new(step, id)
end)

