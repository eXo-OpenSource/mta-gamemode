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
    name = name or ""
    self:outputLog(" ")
    self:outputLog(("TEST: Entering test: '%s'"):format(name))

    if self.init then
        self:init()
    end

    local testCounter = 0
    local succeededTestCounter = 0

    -- Iterate class and execute all methods (we don't have to check for methods of this class since it's not in the inherited class table)
    local runTests = function ()
        for name, method in pairs(getmetatable(self).__index) do
            if name ~= "init" and name ~= "destructor" then
                self.m_FailedHere = false
                testCounter = testCounter + 1
                method(self, name)

                if not self.m_FailedHere then
                    succeededTestCounter = succeededTestCounter + 1
                    self:outputLog(("SUCCESS: Test method '%s' succeeded"):format(name))
                end
            end
        end

        self:outputLog(("TEST: Test '%s' completed. Executed %d tests, %d succeeded, %d failed"):format(name, testCounter, succeededTestCounter, testCounter - succeededTestCounter))
        self:outputLog(" ")
        delete(self)
    end

    self.m_Coroutine = coroutine.create(runTests)
    self:resume()
end

function UnitTest:outputLog(message)
    outputServerLog(message)

    -- TODO: Output to file
end

function UnitTest:getTestMethodName()
    -- debug.getinfo does not work as we'll get 'method' as name then (@line 17)
    local index, value = debug.getlocal(4, 8)
    return tostring(value)
end

function UnitTest:markAsFailed()
    self.m_FailedHere = true
end

--
-- Checks if both parameters have the same value
-- Parameters:
--    actual: The actual value
--    expected: The expected value
-- Returns:
--    Returns true if both parameters are equal, false otherwise
--
function UnitTest:assertEquals(actual, expected)
    if expected == actual then
        return true
    else
        self:outputLog(("ERROR: Test method '%s' (line %d) failed. Expected '%s', got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, expected, actual))
        self:markAsFailed()
        return false
    end
end

--
-- Compares both tables by their keys and values (deep comparison)
-- Parameters:
--    actual: The actual key-value map
--    expected: The expected key-value map
-- Returns:
--    Returns true if both tables are equal, false otherwise
--
function UnitTest:assertTableEquals(actual, expected)
    -- Perform a deep comparison
    if table.compare(expected, actual) then
        return true
    else
        self:outputLog(("ERROR: Test method '%s' (line %d) failed.\nExpected:\n%s.\n\nGot:\n%s"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, tableToString(expected), tableToString(actual)))
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
        self:outputLog(("ERROR: Test method '%s' (line %d) failed. Expected true, got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, tostring(result)))
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
        self:outputLog(("ERROR: Test method '%s' (line %d) failed. Expected false, got '%s'"):format(self:getTestMethodName(), debug.getinfo(2, "l").currentline, tostring(result)))
        self:markAsFailed()
        return false
    end
end


function UnitTest:yield()
    if self.m_Coroutine and coroutine.status(self.m_Coroutine) == COROUTINE_STATUS_RUNNING then
        coroutine.yield()
    end
end

function UnitTest:resume()
    if self.m_Coroutine and coroutine.status(self.m_Coroutine) == COROUTINE_STATUS_SUSPENDED then
        coroutine.resume(self.m_Coroutine)
    end
end
