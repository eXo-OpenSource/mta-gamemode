-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Forum.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

function Forum:constructor()
	self.m_BaseUrl = "https://forum.exo-reallife.de/index.php"
	self.m_Secret = "2c522310a801d8ed8d9afd0e6cacb844"
end

function Forum:destructor()
end

function Forum:userCreate(username, password, email, callback)
	fetchRemote(self.m_BaseUrl .. "?user-api&method=register", {
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
	fetchRemote(self.m_BaseUrl .. "?user-api&method=login", {
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			username = username,
			password = password
		}
	}, callback)
end

function Forum:userGet(forumId, callback)
	fetchRemote(self.m_BaseUrl .. "?user-api&method=get", {
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			userID = forumId
		}
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
		method = "POST",
		formFields = formData
	}, callback)
end

function Forum:groupAddMember(forumId, groupId, callback)
	fetchRemote(self.m_BaseUrl .. "?user-group-api&method=addMember", {
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			userID = forumId,
			groupID = groupId
		}
	}, callback)
end

function Forum:groupRemoveMember(forumId, groupId, callback)
	fetchRemote(self.m_BaseUrl .. "?user-group-api&method=removeMember", {
		method = "POST",
		formFields = {
			secret = self.m_Secret,
			userID = forumId,
			groupID = groupId
		}
	}, callback)
end
