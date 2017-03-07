TSConnect = inherit(Object)

function TSConnect:constructor(api, queryUser, queryPass, queryPort, tsIP, tsPort)
	self.m_APIUrl = api
	self.m_Query = {
		user	 = queryUser;
		password = queryPass;
		port	 = queryPort;
	}
	self.m_TeamspeakServer = {
		ip   = tsIP;
		port = tsPort;
	}
end

function TSConnect:destructor()
end

function TSConnect:callAPI(callback, method, ...)
	return callRemote(self.m_APIUrl, method, ..., self.m_Query.user, self.m_Query.password, self.m_TeamspeakServer.ip, self.m_Query.port, self.m_TeamspeakServer.port)
end

function TSConnect:asyncCallAPI(...)
	local status = self:callAPI(Async.waitFor(), ...)
	return status, Async.wait()
end

TSConnect.Methods = {
	SEND_MESSAGE_TO_UID    = "tsMessageToClient",
	SEND_MESSAGE_TO_SERVER = "tsMessageToServer",
	GET_UID_BY_NAME        = "tsGetUidByName",
	GET_NAME_BY_UID        = "tsGetNameByUid",
	KICK_UID               = "tsKick",
	BAN_UID                = "tsBan",
	ADD_UID_TO_GROUP       = "tsAddUserToServergroup",
	REM_UID_FROM_GROUP     = "tsRemoveUserFromServergroup",
	ADD_UID_TO_CH_GROUP    = "tsAddUserToChannelgroup",
	MOVE_UID_TO_CHANNEL    = "tsMoveToChannel",
	POKE_UID               = "tsClientPoke",
	SET_UID_DESC           = "tsSetDescription",
	FIND_USER              = "tsFindUser",
}
