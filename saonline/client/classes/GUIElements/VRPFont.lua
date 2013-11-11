-- Not actually a GUI Element but useful for proper font sizes

-- This rescales our font to look good on a certain pixel height
local VRPFonts = {}
function VRPFont(height)
	local fontsize = math.floor(height/1.65)
	if not VRPFonts[fontsize] then
		outputDebug("creating font "..tostring(fontsize) .. " px - ".. tostring(height))
		VRPFonts[fontsize] = dxCreateFont("files/fonts/gtafont.ttf", fontsize)
	end
	
	return VRPFonts[fontsize]
end

-- This gets the text width for a font which is 'height' pixels high
function VRPTextWidth(text, height)
	return dxGetTextWidth(text, 1, VRPFont(height))
end