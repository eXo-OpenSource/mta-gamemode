

RadioStationManager = inherit(Singleton)
RadioStationManager.FilePath = "radio_stations.xml"
RadioStationManager.Presets = {
    {"You FM", "http://metafiles.gl-systemhaus.de/hr/youfm_2.m3u"},
	{"181.FM", "http://www.181.fm/winamp.pls?station=181-power&style=mp3&description=Power%20181%20(Top%2040)&file=181-power.pls"},
	{"RMF Dance", "http://files.kusmierz.be/rmf/rmfdance-3.mp3"},
	{"Kronehit", "http://onair-ha1.krone.at/kronehit-hd.mp3.m3u"},
	{"Life Radio", "http://94.136.28.10:8000/liferadio.m3u"},
	{"OE3", "http://mp3stream7.apasf.apa.at:8000"},
	{"FM 4", "http://mp3stream1.apasf.apa.at:8000/listen.pls"},
	{"NSW-LiVE", "http://nsw-radio.de"},
	{"Technobase.fm", "http://listen.technobase.fm/dsl.asx"},
	{"Hardbase.fm", "http://listen.hardbase.fm/tunein-dsl-asx"},
	{"Housetime.fm", "http://listen.housetime.fm/tunein-dsl-asx"},
	{"Techno4Ever", "http://www.techno4ever.net/t4e/stream/dsl_listen.asx"},
	{"ClubTime.fm", "http://listen.ClubTime.fm/dsl.pls"},
	{"CoreTime.fm", "http://listen.CoreTime.fm/dsl.pls"},
	{"Lounge FM Austria", "http://digital.lounge.fm"},
	{"Rock Antenne", "http://www.rockantenne.de/webradio/rockantenne.m3u"},
	{"Raute Musik Rock", "http://rock-high.rautemusik.fm/listen.pls"},
	{"I Love Radio", "http://www.iloveradio.de/iloveradio.m3u"},
	{"1Live", "http://www.wdr.de/wdrlive/media/einslive.m3u"},
	{"1Live diggi", "http://www.wdr.de/wdrlive/media/einslivedigi.m3u"},
    {"FFS (nicht 24/7 online)", "http://ffs-gaming.com:8008/ffs.ogg"},
    
	-- GTA channels
	{"Playback FM", 1},
	{"K-Rose", 2},
	{"K-DST", 3},
	{"Bounce FM", 4},
	{"SF-UR", 5},
	{"Radio Los Santos", 6},
	{"Radio X", 7},
	{"CSR 103.9", 8},
	{"K-Jah West", 9},
	{"Master Sounds 98.3", 10},
	{"WCTR", 11},
	{"User Track Player", 12}
}

function RadioStationManager:constructor()
    if not fileExists(RadioStationManager.FilePath) then
        local node = xmlCreateFile(RadioStationManager.FilePath, "stations")
        for i, v in ipairs(RadioStationManager.Presets) do
            local newChild = node:createChild("station")
            newChild:setAttribute("name", v[1])
            newChild:setAttribute("url", v[2])
            newChild:setAttribute("gta", type(v[2]) == "number" and "true" or nil)
        end
        node:saveFile()
        node:unload()
    end
    self:loadFromConfig()
end

function RadioStationManager:loadFromConfig()
    self.m_Stations = {}
	local node = xmlLoadFile(RadioStationManager.FilePath)
	for i,child in ipairs(node:getChildren()) do
		self.m_Stations[i] = {child:getAttribute("name"), child:getAttribute("url")}
		if child:getAttribute("gta") then
			self.m_Stations[i][2] = tonumber(self.m_Stations[i][2]) -- convert the radio station number to a real number
		end
	end
	node:unload()
end

function RadioStationManager:getStations()
    return self.m_Stations
end


function RadioStationManager:saveStations(newStations)
	if newStations and type(newStations) == "table" then
		self.m_Stations = newStations
	end
    local node = xmlCreateFile(RadioStationManager.FilePath, "stations") --override the old file
	for i, v in ipairs(self.m_Stations) do
		local newChild = node:createChild("station")
		newChild:setAttribute("name", v[1])
		newChild:setAttribute("url", v[2])
		newChild:setAttribute("gta", type(v[2]) == "number" and "true" or nil)
	end
	node:saveFile()
	node:unload()
end