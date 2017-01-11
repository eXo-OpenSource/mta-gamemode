local bcrypt_i = 0
function bcrypt_test(player, password)

	local ForumID = player:getAccount().m_ForumId
	local username = player:getName()
	if not ForumID or ForumID == 0 then
		outputChatBox("ForumId not found", player) -- "Error: Invalid username or password"
		return false
	end

	row = board:queryFetchSingle("SELECT password FROM wcf1_user WHERE userID = ?", ForumID)
	if not row or not row.password then
		outputChatBox("Invalid ForumId", player) -- "Error: Invalid username or password"
		return false
	end

	local salt = string.sub(row.password, 1, 29)
	local tc = getTickCount()
	if salt and password and string.len(salt) > 0 and string.len(password) > 0 then
		outputServerLog("bcrypt_test Start Generate Hash for "..username.." Salt: "..salt)
		outputDebugString("bcrypt_test Start Generate Hash for "..username.." Salt: "..salt)
		pwhash = WBBC.getDoubleSaltedHash(password, salt)
		tc = getTickCount()-tc
		outputServerLog("bcrypt_test Generated for "..username..": "..pwhash.." Took: "..tc.."ms")
		outputDebugString("bcrypt_test Generated for "..username..": "..pwhash.." Took: "..tc.."ms")
	else
		outputServerLog("Bcrypt hash error")
		outputDebugString("Bcrypt hash error")
		return false
	end

	if pwhash ~= row.password then
		outputServerLog("Password wrong")
		outputDebugString("Password wrong")
		return false
	end
	bcrypt_i = bcrypt_i + 1
	outputServerLog(bcrypt_i.." Login OK")
	outputDebugString(bcrypt_i.." Login OK")
	outputChatBox(bcrypt_i.." Login OK", player, 0, 255, 0)

end
