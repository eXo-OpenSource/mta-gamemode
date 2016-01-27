--//	eXo 3-0 		//**
--//	Strobe,27.1,16	//**

Gangwar = inherit(Singleton)

function Gangwar:constructor( )
	self.m_Areas = {	}
	local sql_query = "SELECT * FROM ??_gangwar"
	local drow = sql:queryFetch(sql_query,sql:getPrefix())
	if drow then 
		for i, datarow in ipairs( drow ) do 
			Area:new( datarow )
		end
	end
end	

