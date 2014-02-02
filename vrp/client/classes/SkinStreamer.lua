SkinStreamer = inherit(Singleton)

function SkinStreamer:constructor()
	addEventHandler("onClientElementStreamIn", root, bind(SkinStreamer.onStreamIn, self))
	addEventHandler("onClientElementStreamOut", root, bind(SkinStreamer.onStreamOut, self))
end

function SkinStreamer:onStreamIn()
	if getElementType(source) ~= "ped" and getElementType(source) ~= "player" then
		return
	end
	
	if not source.m_Skin then return end
	
	source.m_Skin:setActive(true)
end

function SkinStreamer:onStreamOut()
	if getElementType(source) ~= "ped" and getElementType(source) ~= "player" then
		return
	end
	
	if not source.m_Skin then return end
	
	source.m_Skin:setActive(false)
end

