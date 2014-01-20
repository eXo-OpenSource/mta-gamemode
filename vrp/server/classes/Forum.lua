-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Forum.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

function Forum:constructor()
	-- Get News
	self.m_News = {}
		-- ToDo: Change to API
	if true then return end
	sql:queryFetch(Async.waitFor(self), "SELECT firstPostID FROM wbb4.wbb1_thread WHERE boardID = 2 LIMIT 3;")
	local row = Async.wait()
	
	for index, data in pairs(row) do
		local id = #self.m_News+1
		self.m_News[id] = {}
		sql:queryFetchSingle(Async.waitFor(self), "SELECT subject, message, time FROM wbb4.wbb1_post WHERE postID = ?;", data.firstPostID)
		row = Async.wait()
		
		self.m_News[id].title = row.subject
		self.m_News[id].text = row.message:match("%[ingamenews%](.+)%[/ingamenews%]")
		local time = getRealTime(row.time)
		self.m_News[id].date = string.format("[%02d.%02d.%04d]", time.monthday, time.month+1, time.year+1900)
	end
	
	nextframe(function()
		for k, v in pairs(getElementsByType("player")) do
			v:sendNews()
		end
	end)
end

function Forum:getNews()
	return self.m_News
end