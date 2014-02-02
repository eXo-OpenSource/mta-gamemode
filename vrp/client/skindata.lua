--[[
Documentation:
skindata[skinid] = 
{
	["texturename"] = {
		[1] = { posx, posy, endx, endy }; -- Schuhe
		[2] = { posx, posy, endx, endy }; -- Hose
		[3] = { posx, posy, endx, endy }; -- Hemd
		[4] = { posx, posy, endx, endy }; -- Hut / Mütze
	}
}
]]
skindata = {
[19] = { -- bmydj / DJ
	textures = {
		{
			tex = "bmydj";
			[1] = { 0.5, 1.0, -0.7, -0.5 }; -- schuhe
			[2] = { 0.0, 0.5, -1.0, -0.5 }; -- hose
		};
	};
	color = {
		[1] = {
			{ 255,   0,   0 };
			{   0,   0, 255 };
			{   0, 255,   0 };
		};
		[2] = {
			{ 255,   0,   0 };
			{   0,   0, 255 };
			{   0, 255,   0 };
		}
	};
}
}