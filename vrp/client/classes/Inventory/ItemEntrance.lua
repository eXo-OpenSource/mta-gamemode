ItemEntrance = inherit(GUIForm)
inherit(Singleton, ItemEntrance)
local lastTitle, lastDesc
local w,h = guiGetScreenSize()
local fontHeight = dxGetFontHeight(3, "default-bold")
local fontHeight2 = dxGetFontHeight(1.5, "default-bold")
local lastEntranceTry = getTickCount()
addEvent("drawEntranceTitleDesc", true)
addEventHandler("drawEntranceTitleDesc", localPlayer, function(state, title, desc) 
	if not state then 
		removeEventHandler("onClientRender", root, ItemEntrance.Event_OnRender)
	else 
		lastTitle = title 
		lastDesc = desc
		removeEventHandler("onClientRender", root, ItemEntrance.Event_OnRender)
		addEventHandler("onClientRender", root, ItemEntrance.Event_OnRender)
	end
end)

addEvent("onTryEnterance")
addEventHandler("onTryEnterance", root, function() 
	local id = localPlayer:getPrivateSync("EntranceId")
	local now = getTickCount()
	if id and now >= lastEntranceTry+1000 then 
		lastEntranceTry = now
		triggerServerEvent("confirmEntranceEnter", localPlayer, id)
	end
end)

local instance = nil
addEvent("promptEntranceOption", true)
addEventHandler("promptEntranceOption", localPlayer,
	function(id, pos)
		if not instance then
			instance = ItemEntrance:new(id, pos)
		else 
			--instance:setIdLabel( id )
			instance:setPosLabel ( pos ) 
		end
	end
)

addEvent("itemEntrancePlayLock", true)
addEventHandler("itemEntrancePlayLock", root,
	function(state)
		if isElement(source.Sound) then
			source.Sound:destroy()
		end
		local sound 
		if state then
			sound = Sound3D.create("files/audio/Items/doorLockSound.mp3", source:getPosition())
		else 
			sound = Sound3D.create("files/audio/Items/doorUnlockSound.mp3", source:getPosition())
		end
		sound:setInterior(source:getInterior())
		sound:setDimension(source:getDimension())
		sound:attach(source)
		source.Sound = sound
	end
)

addEvent("itemEntrancePlayEnter", true)
addEventHandler("itemEntrancePlayEnter", root,
	function()
		if isElement(source.Sound) then
			source.Sound:destroy()
		end
		local sound = Sound3D.create("files/audio/Items/doorGoThru.mp3", source:getPosition())
		sound:setInterior(source:getInterior())
		sound:setDimension(source:getDimension())
		sound:attach(source)
		source.Sound = sound
	end
)

function ItemEntrance:Event_OnRender() 
	if lastTitle and lastDesc then 
		local key = core:get("KeyBindings", "KeyEntranceUse", KeyBinds:getSingleton().m_Keys["KeyEntranceUse"]["defaultKey"])
		dxDrawText(lastTitle, 0, 0, w, h*0.9+1, tocolor(0, 0, 0, 255), 3, "default-bold", "center", "bottom")
		dxDrawText(lastTitle, 0, 0, w, h*0.9, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "bottom")
		dxDrawText(lastDesc, 0, 0, w, (h*0.9+fontHeight)+1, tocolor(255, 255, 255, 255), 1.5, "default-bold", "center", "bottom")
		dxDrawText(lastDesc, 0, 0, w, h*0.9+fontHeight, tocolor(255, 255, 255, 255), 1.5, "default-bold", "center", "bottom")
		dxDrawText(("Drücke %s zum Eintreten!"):format(key:upper()), 0, 0, w, h*0.9+fontHeight*1.1+fontHeight2*1.1, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "bottom")
	end
end

function ItemEntrance:constructor( id, pos )
	GUIWindow.updateGrid()        
	self.m_Width = grid("x", 10) 
	self.m_Height = grid("y", 7) 
	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Eingang", true, false, self)
	self.m_CoordLabel = GUIGridLabel:new(1, 1, 12, 1, "Koordinate: "..pos[1].." , "..pos[2].." , "..pos[3], self.m_Window):setFont(VRPFont(18, Fonts.EkMukta))
	self.m_EditKeyPadLink = GUIGridEdit:new(1, 2, 3, 1, self.m_Window):setNumeric(true, true):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("+Keypad ID")
	self.m_RemoveKeyPadLink = GUIGridEdit:new(4, 2, 3, 1, self.m_Window):setNumeric(true, true):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("-Keypad ID")
	self.m_EditInterior = GUIGridEdit:new(7, 2, 3, 1, self.m_Window):setNumeric(true, true):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Interior")
	self.m_EntrancePosX = GUIGridEdit:new(1, 3, 3, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(18, Fonts.EkMukta)):setCaption("X-Position")
	self.m_EntrancePosY = GUIGridEdit:new(4, 3, 3, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Y-Position")
	self.m_EntrancePosZ = GUIGridEdit:new(7, 3, 3, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Z-Position")
	self.m_Info = GUIGridLabel:new(1, 4, 6, 1, "Gib hier die ID des anderen Eingangs, für selbe Dimension/Interior", self.m_Window):setFont(VRPFont(16, Fonts.EkMukta))
	self.m_EntranceLink = GUIGridEdit:new(7, 4, 3, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Eingang-ID")
	self.m_EntranceTitel = GUIGridEdit:new(1, 5, 3, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Titel")
	self.m_EntranceDesc = GUIGridEdit:new(4, 5, 6, 1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(20, Fonts.EkMukta)):setCaption("Beschreibung")
	self.m_AcceptButton = GUIGridButton:new(1, 6, 4, 1, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIGridButton:new(6, 6, 4, 1, FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
	--self:setIdLabel( id ) 
end


function ItemEntrance:setIdLabel( id ) 
	if self.m_Window then 
		self.m_Window:setTitleBarText ( "Gehört zu Keypad #"..id )
	end
end

function ItemEntrance:setPosLabel( pos ) 
	if self.m_Window then 
		instance.m_CoordLabel:setText ("Koordinate: "..pos[1].." , "..pos[2].." , "..pos[3])
	end
end

function ItemEntrance:destructor()
	GUIForm.destructor(self)
	instance = nil
end

function ItemEntrance:closeForm() 
	delete(self)
end

function ItemEntrance:submitForm() 
	local addKeyPad = self.m_EditKeyPadLink:getText()
	local removeKeyPad = self.m_RemoveKeyPadLink:getText()
	local interior = self.m_EditInterior:getText()
	local posX = self.m_EntrancePosX:getText() 
	local posY = self.m_EntrancePosY:getText() 
	local posZ = self.m_EntrancePosZ:getText() 
	local title = self.m_EntranceTitel:getText()
	local desc = self.m_EntranceDesc:getText()
	local entranceLink = self.m_EntranceLink:getText()
	if not posX or not posY or not posZ then 
		posX = false 
		posY = false 
		posZ = false
		entranceLink = false
	end
	triggerServerEvent("onEntranceDataChange", localPlayer, addKeyPad, removeKeyPad, interior, posX, posY, posZ, entranceLink, title, desc)
	delete(self)
end