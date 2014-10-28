Player = inherit(MTAElement)

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:onUpdateSync(private, public)
	for k, v in pairs(private or {}) do
		self.m_PrivateSync[k] = v
	end
	for k, v in pairs(public or {}) do
		self.m_PublicSync[k] = v
	end
end


addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) )
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) )