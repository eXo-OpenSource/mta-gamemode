--//	eXo 3-0 		//**
--//	Strobe,27.1,16	//**

Area = inherit(Object)

function Area:constructor( dataset )
	outputChatBox(tostring(dataset))
	self.m_Name = dataset["Name"]
	self.m_ID = dataset["ID"]
	self.m_Owner = dataset["Besitzer"]
end	


--// Following

--[[

	Area:attack, Area:destroy, ...
	
	
	
	]]