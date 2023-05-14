Housing = inherit(Singleton)

addRemoteEvents{"housingReciveElements","housingCreateObject"}

function Housing:constructor()
	self.m_Element = false
	self.m_HousingElements = {}
	self.m_ClickHandler = bind(self.onClick,self)
	self.m_IsCreating = false
	
	addEventHandler("onClientClick", root, self.m_ClickHandler)
end

function Housing:reciveHouseElements(elements)
	self.m_HousingElements = elements or {}
end

function Housing:onClick(btn,std,_,_,_,_,_,element)
	if HouseGUI:getSingleton():InHouse() then
		if element and isElement(element) and self.m_HousingElements[element] then
			
		elseif self.m_IsCreating then
			
		end
	end
end

function Housing:destructor()

end