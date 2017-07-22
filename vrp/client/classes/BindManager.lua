-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/BindManager.lua
-- *  PURPOSE:     Responsible for managing binds
-- *
-- ****************************************************************************
BindManager = inherit(Singleton)

function BindManager:constructor()
    self.m_Binds = {}
    self.m_PressedKeys = {}
    

    self.m_Modifiers = {
        ["lalt"] = true,
        ["ralt"] = true,
        ["lctrl"] = true,
        ["rctrl"] = true,
        ["lshift"] = true,
        ["rshift"] = true
    }

    table.insert(self.m_Binds, {
        keys = {
            "lctrl",
            "g"
        },
        action = {
            name = "say",
            parameters = "This is sparta!"
        }
    })

    table.insert(self.m_Binds, {
        keys = {
            "lctrl",
            "1"
        },
        action = {
            name = "s",
            parameters = "Sie werden gesucht! Halten Sie sofort an, steigen Sie aus und nehmen Sie die Hände hinter den Kopf"
        }
    })

    table.insert(self.m_Binds, {
        keys = {
            "lctrl",
            "2"
        },
        action = {
            name = "s",
            parameters = "Letzte Warnung! Bleiben Sie sofort stehen oder wir wenden Gewalt an!"
        }
    })

    addEventHandler("onClientKey", root, bind(self.Event_OnClientKey, self))
    addEventHandler("onClientRender", root, function()
        local keys = {}

        for k, v in pairs(self.m_PressedKeys) do
            if v then
                table.insert(keys, k)
            end
        end

        dxDrawText(table.concat(keys, " "), 100, 500)
    end)
end

function BindManager:Event_OnClientKey(button, pressOrRelease)
    self.m_PressedKeys[button] = pressOrRelease

    if self:CheckForBind() then
        cancelEvent()
    end
end

function BindManager:CheckForBind()
    local bindTrigerred = false

    for k, v in pairs(self.m_Binds) do
        local allKeysPressed = true

        for _, key in pairs(v.keys) do
            if not self.m_PressedKeys[key] then
                allKeysPressed = false
            end
        end

        if allKeysPressed then
            bindTrigerred = true

            if v.action.name ~= "say" then
                executeCommandHandler(v.action.name, v.action.parameters)
            end
            
            triggerServerEvent("bindTrigger", localPlayer, v.action.name, v.action.parameters)
        end
    end

    return bindTrigerred
end


