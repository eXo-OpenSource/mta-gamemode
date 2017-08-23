MusicAPI = inherit(Object)
local MUSIC_API_URL = "http://tidido.com/api/search/fast?q=!TERM!&size%5Bsongs%5D=2000&size%5Bartists%5D=2&size%5Balbums%5D=2&size%5Busers%5D=2"
local BASE_IMG_URL = "http://am.cdnmonster.com/"
local SEARCH_STATUS = {
	PENDING = 1;
	SUCCESS = 2;
	ERROR   = 3;
}

function MusicAPI:constructor(term, callback)
	self.m_URL = MUSIC_API_URL:gsub("!TERM!", term)
	self.m_IMGURL = BASE_IMG_URL
	self.m_Callback = callback or function () error("No Callback") end
	self.m_SongData = {}
	self.m_AlbumData = {}
	self.m_ArtistsData = {}

	self.m_Status = SEARCH_STATUS.PENDING
	self:performSearch().next(fromJSON).done(
		bind(self.onSuccess, self),
		bind(self.onFailure, self)
	)
end

function MusicAPI:performSearch()
	return Promise:new(
		function (fullfill, reject)
			local options = {
				["connectionAttempts"] = 1
			}
			fetchRemote(self.m_URL, options,
				function (responseData, errno)
					if errno == 0 then
						fullfill(responseData)
					else
						reject(errno)
					end
				end
			)
		end
	)
end

function MusicAPI:onSuccess(data)
	self.m_Status = SEARCH_STATUS.SUCCESS
	if data["songs"] then
		self.m_SongData  = data["songs"]["data"]["songs"]
		self.m_AlbumData = data["songs"]["data"]["albums"]
		self.m_ArtistsData = data["songs"]["data"]["artists"]
	end

	self.m_Callback(self, true)
	outputDebug("Search completed successfully!")
end

function MusicAPI:onFailure(errno)
	self.m_Status = SEARCH_STATUS.ERROR

	self.m_Callback(self, false)
	outputDebug("Search failed!")
end

function MusicAPI:getSongs()
	return self.m_SongData
end

function MusicAPI:getAlbumData(albumId)
	if self.m_Status == SEARCH_STATUS.SUCCESS then
		local found = false
		for i, v in ipairs(self.m_AlbumData) do
			if tostring(v.id):lower() == tostring(albumId):lower() then
				found = v
				break;
			end
		end

		return found
	else
		return false
	end
end

function MusicAPI:getArtistData(artistId)
	if self.m_Status == SEARCH_STATUS.SUCCESS then
		local found = false
		for i, v in ipairs(self.m_ArtistsData) do
			if tostring(v.id):lower() == tostring(artistId):lower() then
				found = v
				break;
			end
		end

		return found
	else
		return false
	end
end

function testMusic(term)
	local search = MusicAPI:new(term,
		function (self, status)
			if status then
				local songs = self:getSongs()
				if #songs > 0 then
					local song = songs[1] -- Get the first song we found
					print("Name: "..song.name)
					print("Song-URL: "..song.url)
					local data = self:getAlbumData(song.albumId)
					if data then
						print(("Album-Name: %s"):format(data["name"]))
						print(("AlbumIMG-URL: %s/%s"):format(BASE_IMG_URL, data["avatar"]["sizes"]["q"][1]:gsub("//", "/")))

						local artistString = "Artist-Name(s): "
						local artistIMGString = "Artist-IMG(s): "
						for i, v in ipairs(data.aids) do
							local artist = self:getArtistData(v)
							if artist then
								artistString = ("%s%s"):format(artistString, artist.fullname)
								if i < #song.artistIds then
									artistString = artistString..", "
								end
								artistIMGString = artistIMGString..("%s/%s"):format(BASE_IMG_URL, artist["avatar"]["sizes"]["q"][1]:gsub("//", "/"))
								if i < #song.artistIds then
									artistIMGString = artistIMGString..", "
								end
							end
						end
						print(artistString)
						print(artistIMGString)
					end
				end
			end
		end
	)
end
