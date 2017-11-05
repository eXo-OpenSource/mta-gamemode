-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/BindManager.lua
-- *  PURPOSE:     Responsible for managing binds
-- *
-- ****************************************************************************
BindManager = inherit(Singleton)
BindManager.filePath = "binds.json"


function BindManager:constructor()
    self.m_PressedKeys = {}

    addEventHandler("onClientKey", root, bind(self.Event_OnClientKey, self))
    --[[ DEBUG:
	addEventHandler("onClientRender", root, function()
        local keys = {}

        for k, v in pairs(self.m_PressedKeys) do
            if v then
                table.insert(keys, k)
            end
        end

        dxDrawText(table.concat(keys, " "), 100, 500)
    end)
	]]
	self:loadLocalBinds()
end

function BindManager:destructor()
	self:saveLocalBinds()
end

function BindManager:Event_OnClientKey(button, pressOrRelease)
	if GUIInputControl.ms_CurrentInputFocus or isChatBoxInputActive() or isConsoleActive() then -- Textboxes
		return
	end

	if table.find(KeyBindings.DisallowedKeys, button:lower()) then return end
	self.m_PressedKeys[button] = pressOrRelease

	if self:CheckForBind() then
        cancelEvent()
    end
end

function BindManager:getBinds()
	return self.m_Binds
end

function BindManager:changeKey(index, key1, key2)
	if index and self.m_Binds[index] then
		if key2 then
			self.m_Binds[index].keys = {key2, key1}
		else
			self.m_Binds[index].keys = {key1}
		end
		return true
	end
	return false
end

function BindManager:removeBind(index)
	if index and self.m_Binds[index] then
		self.m_Binds[index] = nil
		return true
	end
	return false
end

function BindManager:addBind(action, parameters)
	table.insert(self.m_Binds, {
        keys = {
        },
        action = {
            name = action,
            parameters = parameters
        }
    })
end


function BindManager:editBind(index, action, parameters)
	if index and self.m_Binds[index] then
		self.m_Binds[index].action = {
				name = action,
				parameters = parameters
			}
		return true
	end
	return false
end


function BindManager:CheckForBind()
    local bindTrigerred = false

    for k, v in pairs(self.m_Binds) do
       	if #v.keys > 0 then
			local allKeysPressed = true


			for _, key in pairs(v.keys) do
				if not self.m_PressedKeys[key] then
					allKeysPressed = false
				end
			end

			if allKeysPressed then
				bindTrigerred = true

				triggerServerEvent("bindTrigger", localPlayer, v.action.name, v.action.parameters)
			end
		end
    end

    return bindTrigerred
end

function BindManager:loadLocalBinds()
	if not fileExists(BindManager.filePath) then
		fileClose(fileCreate(BindManager.filePath))
	end

	local fileHandle = fileOpen(BindManager.filePath, true)
	local text = fileRead(fileHandle, fileGetSize(fileHandle))
	self.m_Binds = fromJSON(text) or {}
	fileClose(fileHandle)
end

function BindManager:saveLocalBinds()
	if fileExists(BindManager.filePath) then
		fileDelete(BindManager.filePath)
	end
	fileClose(fileCreate(BindManager.filePath))

	local fileHandle = fileOpen(BindManager.filePath, false)

	fileWrite(fileHandle, toJSON(self.m_Binds, false, "tabs"))
	fileClose(fileHandle)
end
