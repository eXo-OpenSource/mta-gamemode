function testad()
	playerusername = "Heaven"
	new(FormInfo, playerusername)
	
	m_Box1 = DXBox:new(125, 174, 450, 5)
	m_Box1:setColor(19, 64, 121, 255)
	
	m_Box2 = DXBox:new(125, 234, 217, 616)
	m_Box2:setColor(0, 0, 0, 255)
	
	m_Box3 = DXBox:new(125, 179, 450, 45)
	m_Box3:setColor(255, 255, 255, 255)
	
	m_Label1 = DXLabel:new("Verfügbar", 125, 179, 575, 224) 
	m_Label1:setColor(0, 0, 0, 255)
	m_Label1:setFont(gtaonlinefont[23])
	m_Label1:setAlignX("center")
	m_Label1:setAlignY("center")
	
	
	m_Label2 = DXLabel:new("Verfügbar", 575, 179, 800, 224) 
	m_Label2:setColor(255, 255, 255, 255)
	m_Label2:setFont(gtaonlinefont[23])
	m_Label2:setAlignX("center")
	m_Label2:setAlignY("center")
	
	m_Label3 = DXLabel:new("Gesperrt", 800, 179, 1025, 224) 
	m_Label3:setColor(255, 255, 255, 255)
	m_Label3:setFont(gtaonlinefont[23])
	m_Label3:setAlignX("center")
	m_Label3:setAlignY("center")
	
	m_Label4 = DXLabel:new("Gesperrt", 1025, 179, 1250, 224) 
	m_Label4:setColor(255, 255, 255, 255)
	m_Label4:setFont(gtaonlinefont[23])
	m_Label4:setAlignX("center")
	m_Label4:setAlignY("center")
	
	m_Label5 = DXLabel:new("Gesperrt", 1250, 179, 1475, 224) 
	m_Label5:setColor(255, 255, 255, 255)
	m_Label5:setFont(gtaonlinefont[23])
	m_Label5:setAlignX("center")
	m_Label5:setAlignY("center")
	
	m_Box4 = DXBox:new(575, 234, 225, 616)
	m_Box4:setColor(0, 0, 0, 255)
	
	m_Box5 = DXBox:new(800, 234, 225, 616)
	m_Box5:setColor(0, 0, 0, 170)
	
	m_Box6 = DXBox:new(1025, 234, 225, 616)
	m_Box6:setColor(0, 0, 0, 170)
	
	m_Box7 = DXBox:new(1250, 234, 225, 616)
	m_Box7:setColor(0, 0, 0, 170)
	
	m_Box8 = DXBox:new(346, 234, 225, 567)
	m_Box8:setColor(0, 0, 0, 255)
	
	m_Label6 = DXLabel:new("1", 135, 244, 298, 634) 
	m_Label6:setColor(32, 35, 40, 255)
	m_Label6:setFont(gtaonlinefont[120])
	m_Label6:setAlignX("left")
	m_Label6:setAlignY("top")
	
	m_Box9 = DXBox:new(346, 234, 225, 34)
	m_Box9:setColor(4, 78, 153, 255)
	
	m_Label7 = DXLabel:new(playerusername, 346, 234, 571, 268) 
	m_Label7:setColor(255, 255, 255, 255)
	m_Label7:setFont(gtaonlinefont[12])
	m_Label7:setAlignX("center")
	m_Label7:setAlignY("center")
	
	-- LEVEL
	m_Image1 = DXImage:new("world.png", 415, 278, 95, 95)
	
	m_Label8 = DXLabel:new("Level", 415, 278, 505, 373) 
	m_Label8:setColor(255, 255, 255, 255)
	m_Label8:setFont(gtaonlinefont[50])
	m_Label8:setAlignX("center")
	m_Label8:setAlignY("center")
	
	
	m_Label9 = DXLabel:new("Fahren", 356, 396, 561, 424) 
	m_Label9:setColor(255, 255, 255, 255)
	m_Label9:setFont(gtaonlinefont[12])
	m_Label9:setAlignX("left")
	m_Label9:setAlignY("center")
	
	
	m_Label10 = DXLabel:new("Schießen", 356, 459, 561, 487)
	m_Label10:setColor(255, 255, 255, 255)
	m_Label10:setFont(gtaonlinefont[12])
	m_Label10:setAlignX("left")
	m_Label10:setAlignY("center")
	
	m_Label11 = DXLabel:new("Fliegen", 356, 522, 561, 550) 
	m_Label11:setColor(255, 255, 255, 255)
	m_Label11:setFont(gtaonlinefont[12])
	m_Label11:setAlignX("left")
	m_Label11:setAlignY("center")
	
	m_Label12 = DXLabel:new("Schleichen", 356, 585, 561, 613) 
	m_Label12:setColor(255, 255, 255, 255)
	m_Label12:setFont(gtaonlinefont[12])
	m_Label12:setAlignX("left")
	m_Label12:setAlignY("center")
	
	m_Label13 = DXLabel:new("Ausdauer", 356, 651, 561, 679) 
	m_Label13:setColor(255, 255, 255, 255)
	m_Label13:setFont(gtaonlinefont[12])
	m_Label13:setAlignX("left")
	m_Label13:setAlignY("center")
	
	m_Label14 = DXLabel:new("Gerätezugang", 356, 725, 561, 753) 
	m_Label14:setColor(255, 255, 255, 255)
	m_Label14:setFont(gtaonlinefont[12])
	m_Label14:setAlignX("left")
	m_Label14:setAlignY("center")
	
	m_Box10 = DXBox:new(356, 434, 205, 15)
	m_Box10:setColor(12, 25, 42, 255)
	
	m_Box11 = DXBox:new(356, 497, 205, 15)
	m_Box11:setColor(12, 25, 42, 255)
	
	m_Box12 = DXBox:new(356, 560, 205, 15)
	m_Box12:setColor(12, 25, 42, 255)
	
	m_Box13 = DXBox:new(356, 624, 205, 15)
	m_Box13:setColor(12, 25, 42, 255)
	
	m_Box14 = DXBox:new(356, 689, 205, 15)
	m_Box14:setColor(12, 25, 42, 255)
	
	-- local prozent = (205/100)
	-- local fahrenwert = prozent*char1_fahren1  -- Höchste = 252
	-- local schiessenwert = prozent*char1_schiessen1
	-- local fliegenwert = prozent*char1_fliegen1
	-- local schleichenwert = prozent*char1_schleichen1
	-- local ausdauerwert = prozent*char1_ausdauer1
	
	m_Box15 = DXBox:new(356, 434, "fahrenwert", 15)
	m_Box15:setColor(23, 76, 133, 255)
	
	m_Box16 = DXBox:new(356, 497, "schiessenwert", 15)
	m_Box16:setColor(23, 76, 133, 255)
	
	m_Box17 = DXBox:new(356, 560, "fliegenwert", 15)
	m_Box17:setColor(23, 76, 133, 255)
	
	m_Box18 = DXBox:new(356, 624, "schleichenwert", 15)
	m_Box18:setColor(23, 76, 133, 255)
	
	m_Box19 = DXBox:new(356, 689, "ausdauerwert", 15)
	m_Box19:setColor(23, 76, 133, 255)
	
	
	m_Image2 = DXImage:new("cross.png", 356, 763, 24, 24)
	m_Image3 = DXImage:new("cross.png", 390, 763, 24, 24)
	m_Image4 = DXImage:new("cross.png", 424, 763, 24, 24)
	m_Image5 = DXImage:new("cross.png", 458, 763, 24, 24)
	
	m_Label15 = DXLabel:new("2", 585, 244, 748, 634) 
	m_Label15:setColor(7, 7, 7, 255)
	m_Label15:setFont(gtaonlinefont[120])
	m_Label15:setAlignX("left")
	m_Label15:setAlignY("top")
	
	m_Label16 = DXLabel:new("3", 810, 244, 973, 634) 
	m_Label16:setColor(0, 0, 0, 100)
	m_Label16:setFont(gtaonlinefont[120])
	m_Label16:setAlignX("left")
	m_Label16:setAlignY("top")
	
	m_Label17 = DXLabel:new("4", 1035, 244, 1198, 634) 
	m_Label17:setColor(0, 0, 0, 100)
	m_Label17:setFont(gtaonlinefont[120])
	m_Label17:setAlignX("left")
	m_Label17:setAlignY("top")
	
	m_Label18 = DXLabel:new("5", 1260, 244, 1423, 634)
	m_Label18:setColor(0, 0, 0, 100)
	m_Label18:setFont(gtaonlinefont[120])
	m_Label18:setAlignX("left")
	m_Label18:setAlignY("top")
	
	m_Box20 = DXBox:new(1084, 860, 391, 31)
	m_Box20:setColor(0, 0, 0, 170)
	
    m_Label19 = DXLabel:new("Drücke 'ENTER' um fortzufahren", 1084, 860, 1475, 890)
	m_Label18:setColor(255, 255, 255, 255)
	m_Label18:setFont(gtaonlinefont[12])
	m_Label18:setAlignX("center")
	m_Label18:setAlignY("center")
	
end
addCommandHandler("jo", testad)