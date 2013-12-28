-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Forum.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

function Forum:constructor()
	outputDebug("forenctor")
	-- Get News
	self.m_News = {}
	sql:queryFetch(Async.waitFor(self), "SELECT firstPostID FROM wbb4.wbb1_thread WHERE boardID = 2 LIMIT 3;")
	local row = Async.wait()
	
	for index, data in pairs(row) do
		local id = #self.m_News+1
		self.m_News[id] = {}
		sql:queryFetchSingle(Async.waitFor(self), "SELECT subject, message FROM wbb4.wbb1_post WHERE postID = ?;", data.firstPostID)
		row = Async.wait()
		
		self.m_News[id].title = row.subject
		self.m_News[id].text = row.message:match("%[ingamenews%](.+)%[/ingamenews%]")
	end
end

function Forum:getNews()
	return self.m_News
end