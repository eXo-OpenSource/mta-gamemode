

ANIMATION_GROUPS = {"Standard", "Tänze", "Sonstiges", "Vulgär"}

ANIMATIONS = {
	["Hände hoch"] = 			{["group"] = "Standard", ["block"] = "shop", ["animation"] = "SHP_HandsUp_Scr", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["hinlegen"] = 				{["group"] = "Standard", ["block"] = "beach", ["animation"] = "bather", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["ducken"] = 				{["group"] = "Standard", ["block"] = "ped", ["animation"] = "cower", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["hinsetzen"] = 			{["group"] = "Standard", ["block"] = "beach", ["animation"] = "ParkSit_M_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["hinsetzen (Sessel)"] = 	{["group"] = "Standard", ["block"] = "BEACH", ["animation"] = "SitnWait_loop_W", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["sprechen"] = 				{["group"] = "Standard", ["block"] = "ped", ["animation"] = "IDLE_chat", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["winken"] = 				{["group"] = "Standard", ["block"] = "ON_LOOKERS", ["animation"] = "wave_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Arme verschränken"] = 	{["group"] = "Standard", ["block"] = "cop_ambient", ["animation"] = "Coplook_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["lachen"] = 				{["group"] = "Standard", ["block"] = "rapping", ["animation"] = "Laugh_01", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Links/Rechts schauen"] =	{["group"] = "Standard", ["block"] = "ped", ["animation"] = "roadcross", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Strecken"] =				{["group"] = "Standard", ["block"] = "playidles", ["animation"] = "stretch", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Handstand"] =				{["group"] = "Standard", ["block"] = "dam_jump", ["animation"] = "DAM_Dive_Loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Waffe beidhändig"] =		{["group"] = "Standard", ["block"] = "ped", ["animation"] = "arrestgun", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Waffe Gangster"] =		{["group"] = "Standard", ["block"] = "ped", ["animation"] = "gang_gunstand", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bombe plazieren"] =		{["group"] = "Standard", ["block"] = "bomber", ["animation"] = "bom_plant", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Wave"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_a", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Chill"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_b", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Ruhig"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_d", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Wild"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_e", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Hip-Hop"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dance_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Strip"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_A", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Nuttig"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_B", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Sexy"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_C", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Taichi"] = 				{["group"] = "Tänze", ["block"] = "park", ["animation"] = "Tai_Chi_Loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Fuck you"] = 				{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "fucku", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Po klatschen"] =			{["group"] = "Sonstiges", ["block"] = "sweet", ["animation"] = "sweet_ass_slap", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bitch Slap"] =			{["group"] = "Sonstiges", ["block"] = "misc", ["animation"] = "bitchslap", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
--	["Crack"] =					{["group"] = "Sonstiges", ["block"] = "crack", ["animation"] = "crckdeth2 ", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},
	["Überreichen"] =			{["group"] = "Sonstiges", ["block"] = "dealer", ["animation"] = "dealer_deal", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bezahlen"] =				{["group"] = "Sonstiges", ["block"] = "dealer", ["animation"] = "drugs_buy", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Geld abheben"] =			{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "atm", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Kaugummi"] =				{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "gum_eat", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Pinkeln"] =				{["group"] = "Vulgär", ["block"] = "PAULNMAC", ["animation"] = "Piss_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true, ["object"] = 1904},
	["Wichsen"] =				{["group"] = "Vulgär", ["block"] = "PAULNMAC", ["animation"] = "wank_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sex oben"] =				{["group"] = "Vulgär", ["block"] = "sex", ["animation"] = "sex_1_cum_p", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sex unten"] =				{["group"] = "Vulgär", ["block"] = "sex", ["animation"] = "sex_1_cum_w", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Kotzen"] =				{["group"] = "Vulgär", ["block"] = "food", ["animation"] = "EAT_Vomit_P", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},

}

