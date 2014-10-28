Player = inherit(MTAElement)

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:onUpdateSync(private, public)
	self.m_PrivateSync = private
	self.m_PublicSync = public
end


addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) )
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) )