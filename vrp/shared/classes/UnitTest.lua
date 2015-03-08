-- ****************************************************************************
-- *
-- *  PROJECT:      vRoleplay
-- *  FILE:         shared/classes/UnitTest.lua
-- *  PURPOSE:      Simple unit test class
-- *  NOTE:         DO NOT CREATE AN INSTANCE OF THIS CLASS
-- *
-- ****************************************************************************
UnitTest = inherit(Object)

function UnitTest:virtual_constructor(name)
    self:outputLog("TEST: Entering test: "..(name or ""))

    -- Iterate class and execute all methods (we don't have to check for methods of this class since it's not in the inherited class table)
    for name, method in pairs(getmetatable(self).__index) do
        self.m_FailedHere = false
        method(self, name)

        if not self.m_FailedHere then
            self:outputLog(("SUCCESS: Test method '%s' succeeded"):format(name))
        end
    end
end

function UnitTest:outputLog(message)
    outputServerLog(message)

    -- TODO: Output to file
end

function UnitTest:getTestMethodName()
    -- debug.getinfo does not work as we'll get 'method' as name then (@line 17)
    local t, name = debug.getlocal(4, 5)
    return tostring(name)
end

function UnitTest:markAsFailed()
    self.m_FailedHere = true
end

--
-- Checks if both parameters have the same value
-- Parameters:
--    expected: The expected value
--    actual: The actual value
-- Returns:
--    Returns true if both parameters are equal, false otherwise
--
function UnitTest:assertEquals(expected, actual)
    if expected == actual then
        return true
    else
        self:outputLog(("ERROR: Test '%s' (line %n) failed. Expected '%s', got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, expected, actual))
        self:markAsFailed()
        return false
    end
end

--
-- Compares both tables by their keys and values (deep comparison)
-- Parameters:
--    expected: The expected key-value map
--    actual: The actual key-value map
-- Returns:
--    Returns true if both tables are equal, false otherwise
--
function UnitTest:assertTableEquals(expected, actual)
    -- Perform a deep comparison
    if table.compare(expected, actual) then
        return true
    else
        self:outputLog(("ERROR: Test '%s' (line %d) failed. Expected:\n%s.\n\nGot:\n%s"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, expected, actual))
        self:markAsFailed()
        return false
    end
end

--
-- Checks if we got true
-- Parameters:
--    result: The boolean value
-- Returns:
--    Returns true if the test succeeded, false otherwise
--
function UnitTest:assertTrue(result)
    if result then
        return true
    else
        self:outputLog(("ERROR: Test '%s' (line %d) failed. Expected true, got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, tostring(result)))
        self:markAsFailed()
        return false
    end
end

--
-- Checks if we got false (we cannot implement this by self:assertTrue(not result) as we'd get a wrong result from debug.getinfo then (due to the wrong stack level))
-- Parameters:
--    result: The boolean value
-- Returns:
--    Returns true if the test succeeded, false otherwise
--
function UnitTest:assertFalse(result)
    if result == false then
        return true
    else
        self:outputLog(("ERROR: Test '%s' (line %d) failed. Expected false, got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, tostring(result)))
        self:markAsFailed()
        return false
    end
end
