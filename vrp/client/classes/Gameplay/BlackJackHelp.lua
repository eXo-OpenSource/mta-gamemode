-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/BlackJackHelp.lua
-- *  PURPOSE:     BlackJackHelp
-- *
-- ****************************************************************************

BlackJackHelp = inherit(GUIForm) 
inherit(Singleton, BlackJackHelp)

local cardPath = "files/images/CardDeck/"
local soundPath = "files/audio/"

blackjackHelpGeneral = [[
	Du erhälst zwei Karten vom Dealer und der Dealer gibt sich anschließend zwei Karten (eine unaufgedeckt).
	Nun musst du entscheiden ob du noch eine Karte ziehen willst (Hit) oder der Dealer am Zug ist seine Karten zu ziehen (stand).
	Solltest du schon bei den ersten beiden Karten einen Blackjack haben erhälst du deinen Einsatz 2,5 mal so hoch als gewinn. 
	Andernfalls erhälst du durch einen regulären Gewinn deinen Einsatz doppelt zurück.
	Bei Unentschieden erhälst du deinen Einsatz zurück.
]]

blackjackGoalGeneral = [[
	Das Ziel des Spieles ist es mit dem Wert der gezogenen Karten die du erhälst den Dealer zu überbieten aber gleichzeitig unter dem Wert 21 zu bleiben.
	Deswegen erhälst du die Option entweder eine Karte zu ziehen (Hit) oder aufzuhören und den Dealer ziehen zu lassen (Stand).
	Sobald du dich dafür entscheidest den Dealer ziehen zu lassen, kannst du nicht mehr die Hit-Option nutzen.

	Der Dealer bleibt stehen sobald er den Wert 17 erreicht hat und dann werden deine und seine Karten vergliechen, sofern du nicht vorher durch Überschreiten der Zahl 21 verloren hast.
	
	Sollte der Dealer beim Ziehen seiner Karten die 21 überschreiten oder aber die Zahl 17 erreichen und beim Vergleich weniger als du haben, gewinnst du.
]]


blackjackInsuranceGeneral = [[
	Angenommen du erahnst, dass der Dealer bereits durch die zwei Anfangskarten einen Blackjack hat (Ass und eine 10), so kannst du eine Insurance-Wette abschließen, welche dir im Fall, 
	dass der Dealer wirlklich mit beiden Karten ein Blackjack hat deinen Einsatz doppelt zurückgibt. 
	Wenn du die Wette abschließt, zahlst du deinen jetzigen Einsatz ein und erhälst ihn im Falle des Gewinnes doppelt, verlierst aber den ursprünglichen Einsatz.
]]

function BlackJackHelp:constructor(mainInstance) -- soz, for not using gridsystem

	GUIForm.constructor(self, screenWidth/2 - 700/2, screenHeight/2-600/2, 700, 600, false)
	
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(51,120,37), self)

	self.m_Page = 1
	GUILabel:new(0, 20, self.m_Width, self.m_Height-40, "Blackjack - Spielregeln", self):setAlignX("center"):setFont(VRPFont(36))
	GUIRectangle:new(0, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(self.m_Width-10, 0, 10, self.m_Height, Color.Wood, self)
	GUIRectangle:new(0, 0, self.m_Width, 10, Color.Wood, self)
	GUIRectangle:new(0, self.m_Height-10, self.m_Width, 10, Color.Wood, self)

	self.m_Pages = {}

	self.m_Pages[1] = {}
	self.m_Pages[1].title = GUILabel:new(60, 100, self.m_Width-120, 26, "Ziel", self):setAlignX("left"):setFont(VRPFont(26, Fonts.EkMukta_Bold))
	self.m_Pages[1].content = GUILabel:new(60, 140, self.m_Width-120, self.m_Height-110, blackjackGoalGeneral, self):setAlignX("left"):setFont(VRPFont(24))


	self.m_Pages[3] = {}
	self.m_Pages[3].title = GUILabel:new(60, 100, self.m_Width-120, 26, "Ablauf", self):setAlignX("left"):setFont(VRPFont(26, Fonts.EkMukta_Bold))
	self.m_Pages[3].content = GUILabel:new(60, 140, self.m_Width-120, self.m_Height-110, blackjackHelpGeneral, self):setAlignX("left"):setFont(VRPFont(24))

	self.m_Pages[4] = {}
	self.m_Pages[4].title = GUILabel:new(60, 100, self.m_Width-120, 26, "Insurance", self):setAlignX("left"):setFont(VRPFont(26, Fonts.EkMukta_Bold))
	self.m_Pages[4].content = GUILabel:new(60, 140, self.m_Width-120, self.m_Height-110, blackjackInsuranceGeneral, self):setAlignX("left"):setFont(VRPFont(24))


	self.m_Pages[2] = {}
	self.m_Pages[2].title = GUILabel:new(60, 100, self.m_Width-120, 26, "Karten", self):setAlignX("left"):setFont(VRPFont(26, Fonts.EkMukta_Bold))
	self.m_Pages[2].image = GUIImage:new(60, 140, 72, 100, self:makeCardPath("h11"), self)
	self.m_Pages[2].image2 = GUIImage:new(60+80, 140, 72, 100, self:makeCardPath("h12"), self)
	self.m_Pages[2].image3 = GUIImage:new(60+160, 140, 72, 100, self:makeCardPath("h13"), self)
	self.m_Pages[2].label1 = GUILabel:new(60+240, 140, 300, 100, "= Wert 10", self):setAlignX("center"):setFont(VRPFont(32, Fonts.EkMukta_Bold)):setAlignY("center")


	self.m_Pages[2].image4 = GUIImage:new(60, 270, 72, 100, self:makeCardPath("h01"), self)
	self.m_Pages[2].label2 = GUILabel:new(60+140, 270, 450, 100, "= Wert 11 oder 1 je nachdem was besser ist", self):setAlignX("center"):setFont(VRPFont(32, Fonts.EkMukta_Bold)):setAlignY("center")

	self.m_Pages[2].image5 = GUIImage:new(60, 400, 72, 100, self:makeCardPath("h02"), self)
	self.m_Pages[2].image6 = GUIImage:new(60+30, 400, 72, 100, self:makeCardPath("h03"), self)
	self.m_Pages[2].image7 = GUIImage:new(60+30*2, 400, 72, 100, self:makeCardPath("h04"), self)
	self.m_Pages[2].image8 = GUIImage:new(60+30*3, 400, 72, 100, self:makeCardPath("h05"), self)
	self.m_Pages[2].image9 = GUIImage:new(60+30*4, 400, 72, 100, self:makeCardPath("h06"), self)
	self.m_Pages[2].image10 = GUIImage:new(60+30*5, 400, 72, 100, self:makeCardPath("h07"), self)
	self.m_Pages[2].image11 = GUIImage:new(60+30*6, 400, 72, 100, self:makeCardPath("h08"), self)
	self.m_Pages[2].image12 = GUIImage:new(60+30*7, 400, 72, 100, self:makeCardPath("h09"), self)
	self.m_Pages[2].image13 = GUIImage:new(60+30*8, 400, 72, 100, self:makeCardPath("h10"), self)
	self.m_Pages[2].label3 = GUILabel:new(60+30*9, 400, 340, 100, "= 1,2,3 ... 10", self):setAlignX("center"):setFont(VRPFont(32, Fonts.EkMukta_Bold)):setAlignY("center")




	self.m_BtnLeft = GUIButton:new(60, self.m_Height-60, 40, 40, "<", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_BtnLeft.m_AnimatedBar:setColor(Color.Black)
	self.m_BtnLeft.onLeftClick = function() self:left() end

	self.m_BtnRight = GUIButton:new(self.m_Width-160, self.m_Height-60, 40, 40, ">", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_BtnRight.m_AnimatedBar:setColor(Color.Black)
	self.m_BtnRight.onLeftClick = function() self:right() end


	self.m_Main = mainInstance

	self.m_BtnBack = GUIButton:new(10, 20, 80, 26, "Zurück", self):setAlternativeColor(tocolor(51,120,37)):setBackgroundColor(Color.White)
	self.m_BtnBack.m_AnimatedBar:setColor(Color.Black)
	self.m_BtnBack.onLeftClick = function() self.m_Main:setVisible(true);GUIForm.destructor(self);delete(self); self.m_Main.m_Info = nil end

	self:showPage()


end

function BlackJackHelp:showPage()
	for i = 1, 4 do 
		for k, element in pairs(self.m_Pages[i]) do 
			element:setVisible(false)
		end
	end
	
	for k, element in pairs(self.m_Pages[self.m_Page]) do 
		element:setVisible(true)
	end
end

function BlackJackHelp:right() 
	playSound(self:makeSoundPath("card_draw.ogg"))
	self.m_Page = self.m_Page + 1 
	if self.m_Page == 4 then 
		self.m_BtnRight:setVisible(false)
		self.m_BtnLeft:setVisible(true)
	else 
		self.m_BtnRight:setVisible(true)
	end
	self:showPage()
end

function BlackJackHelp:left() 
	playSound(self:makeSoundPath("card_draw.ogg"))
	self.m_Page = self.m_Page - 1
	if self.m_Page == 1 then 
		self.m_BtnLeft:setVisible(false)
		self.m_BtnRight:setVisible(true)
	else 
		self.m_BtnLeft:setVisible(true)
	end
	self:showPage()
end

function BlackJackHelp:destructor() 

end

function BlackJackHelp:makeCardPath(file) 
	return ("%s%s.png"):format(cardPath, file)
end

function BlackJackHelp:makeSoundPath(file) 
	return ("%s%s"):format(soundPath, file)
end


