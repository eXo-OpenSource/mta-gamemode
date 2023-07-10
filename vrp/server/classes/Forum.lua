-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Forum.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

Config.register("BOARD_BASE_URL", "string", "")
Config.register("BOARD_SECRET", "string", "")

function Forum:constructor()
	self.m_BaseUrl = Config.get("BOARD_BASE_URL")
	self.m_Secret = Config.get("BOARD_SECRET")
end

function Forum:destructor()
end

function Forum:userCreate(username, password, email, callback)
	return fetchRemote(self.m_BaseUrl .. "?user-api&method=create", {
		queueName = "Forum:userCreate",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			username = username,
			password = password,
			email = email
		}
	}, callback)
end

function Forum:userLogin(username, password, callback)
	return fetchRemote(self.m_BaseUrl .. "?user-api&method=login", {
		queueName = "Forum:userLogin",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			username = username,
			password = password
		}
	}, callback)
end

function Forum:userGet(forumId, callback)
	local data = {
		secret = self.m_Secret
	}

	if type(forumId) == "table" then
		for k, v in ipairs(forumId) do
			data["userID[" .. (k - 1) .. "]"] = v
		end
	else
		data.userID = forumId
	end

	fetchRemote(self.m_BaseUrl .. "?user-api&method=get", {
		queueName = "Forum:userGet",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = data
	}, callback)
end

function Forum:userUpdate(forumId, data, callback)
	--[[
		data = {
			username = 'tomate',
			wscApiId = 1,
			userOptionXX = 'bruh' // XX <- number 00 to 99
		}
	]]
	local formData = {
		secret = self.m_Secret,
		userID = forumId
	}

	for k, v in pairs(data) do
		formData[k] = v
	end

	fetchRemote(self.m_BaseUrl .. "?user-api&method=update", {
		queueName = "Forum:userUpdate",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = formData
	}, callback)
end

function Forum:groupGet(groupId, callback)
	fetchRemote(self.m_BaseUrl .. "?user-group-api&method=get", {
		queueName = "Forum:groupGet",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			groupID = groupId
		}
	}, callback)
end

function Forum:groupAddMember(forumId, groupId, callback)
	local data = {
		secret = self.m_Secret,
		groupID = groupId
	}

	if type(forumId) == "table" then
		for k, v in ipairs(forumId) do
			data["userID[" .. (k - 1) .. "]"] = v
		end
	else
		data.userID = forumId
	end

	fetchRemote(self.m_BaseUrl .. "?user-group-api&method=add", {
		queueName = "Forum:groupAddMember",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = data
	}, callback)
end

function Forum:groupRemoveMember(forumId, groupId, callback)
	local data = {
		secret = self.m_Secret,
		groupID = groupId
	}

	if type(forumId) == "table" then
		for k, v in ipairs(forumId) do
			data["userID[" .. (k - 1) .. "]"] = v
		end
	else
		data.userID = forumId
	end

	fetchRemote(self.m_BaseUrl .. "?user-group-api&method=remove", {
		queueName = "Forum:groupRemoveMember",
		connectionAttempts = FORUM_MAX_CONNECTION_ATTEMPTS,
		connectTimeout = 5000,
		method = "POST",
		formFields = data
	}, callback)
end
