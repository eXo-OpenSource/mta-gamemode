-- ****************************************************************************
-- *
-- *  PROJECT:     	vRoleplay
-- *  FILE:        	shared/classes/ConfigXML.lua
-- *  PURPOSE:     	XML config class and parser
-- *
-- ****************************************************************************
CLIENT = triggerClientEvent == nil
SERVER = triggerServerEvent == nil

ConfigXML = inherit(Object)

-- * onConfigChange / onClientConfigChange ( config, group, key, oldvalue, newvalue )
-- *	@desc:	Called upon config:set(), if cancelled, set will not change the value
-- *	@param:	table 	'config'	- The config which set was called upon
-- *	@param: string 	'group'		- The group of the variable, which was changed
-- *	@param: string 	'key'		- The key of the variable, which was changed
-- *	@param: any 	'oldvalue'	- The previous value of the variable, which was changed
-- *	@param: any 	'newvalue'	- The new value for the variable, which was changed
-- *
local onConfigChangeEvent = CLIENT and "onClientConfigChange" or
							SERVER and "onConfigChange"

addEvent(onConfigChangeEvent, false)


-- * ConfigXML.constructor(configfile)
-- *	@desc:	Creates or loads a config
-- *	@param:	string 'configfile' - The configfile to be opened or created
-- *
function ConfigXML:constructor(configfile)
	assert(type(configfile) == "string")
	self.m_File = configfile
	self.m_Cache = setmetatable({}, {
		__index = function(self, k)
			return {}
		end
	})

	self:_open()
end


-- * ConfigXML._open()
-- *	@desc:	Internal open function to either load or create an xml file
-- *
function ConfigXML:_open()
	if not self.m_Root then
		if not fileExists(self.m_File) then
			self.m_Root = xmlCreateFile(self.m_File, "config")
		else
			self.m_Root = xmlLoadFile(self.m_File)
			--assert(self.m_Root, "ConfigXML - Cannot load config file")

			if not self.m_Root then
				outputDebugString(("Config '%s' is corrupted. Recreate."):format(self.m_File))
				self.m_Root = xmlCreateFile(self.m_File, "config")
			end
		end
	end
end

-- * ConfigXML.destructor()
-- *	@desc:	Destructor for the config class. Also saves and unloads the XML file
-- *
function ConfigXML:destructor()
	if self.m_Root then
		xmlSaveFile(self.m_Root)
		xmlUnloadFile(self.m_Root)
	end
end


-- * ConfigXML.get(group, key, default)
-- *	@desc:	Gets a value
-- *	@param:	string 	'group' 	- The group of the configvariable to read
-- *	@param:	string 	'key' 		- The key of the configvariable to read
-- *	@param:	any 	'default' 	- The default value in case there was no value set for the key
-- *	@return: any - The value from the config, or default (if the value was nil or not set)
-- *
function ConfigXML:get(group, key, default)
	-- If not yet Cached, cache!
	if self.m_Cache[group][key] == nil then
		local cnode = xmlFindChild(self.m_Root, group, 0)

		if not cnode then return default end

		local knode = xmlFindChild(cnode, key, 0)

		if not knode then return default end

		self.m_Cache[group] = self.m_Cache[group] or {}
		self.m_Cache[group][key] = ConfigXML._readNode(knode)
	end

	-- We now have the value stored in m_Cache
	local value = self.m_Cache[group][key]
	if value == nil then
		return default
	end

	return value
end


-- * ConfigXML.set(group, key, value)
-- *	@desc:	Sets a value, will not be set if the onConfigChange-Event is cancelled
-- *	@param:	string 	'group' 	- The group of the configvariable to set
-- *	@param:	string 	'key' 		- The key of the configvariable to set
-- *	@param:	any 	'value' 	- The new value
-- *
function ConfigXML:set(group, key, value)
	local ev = triggerEvent(onConfigChangeEvent, root, self, group, key, self.m_Cache[group][key], value)

	if ev == false then return end
	self.m_Cache[group][key] = value

	local cnode = xmlFindChild(self.m_Root, group, 0)
	if not cnode then
		cnode = xmlCreateChild(self.m_Root, group)
	end

	local knode = xmlFindChild(cnode, key, 0)
	if not knode then
		knode = xmlCreateChild(cnode, key)
	end

	ConfigXML._writeNode(knode, value)
	xmlSaveFile(self.m_Root)

	return value
end


-- * ConfigXML._readNode(group, key, value)
-- *
function ConfigXML._readNode(node)
	local attrtype = xmlNodeGetAttribute(node, "type") or "string"

	if attrtype == "number" then 	return tonumber(xmlNodeGetValue(node)) end
	if attrtype == "boolean" then 	return xmlNodeGetValue(node) == "true" end
	if attrtype == "string" then 	return xmlNodeGetValue(node) end

	if attrtype == "table" then
		local value = {}
		local ival
		for k, v in ipairs(xmlNodeGetChildren(node)) do
			ival = ConfigXML._readNode(v)
			value[k] = ival
			value[xmlNodeGetName(v)] = ival
		end
		return value
	end
end

-- * ConfigXML._writeNode(group, key, value)
-- *
function ConfigXML._writeNode(node, data)
	if data == nil then
		xmlDestroyNode(node)
		return
	end

	local attrtype = type(data)
	xmlNodeSetAttribute(node, "type", attrtype)

	if attrtype == "number" or
		attrtype == "boolean" or
		attrtype == "string" then
		xmlNodeSetValue(node, tostring(data))

	elseif attrtype == "table" then
		xmlNodeSetValue(node, "")
		local newnode
		for k, v in pairs(data) do
			newnode = xmlFindChild(node, tostring(k), 0)
			if not newnode then
				newnode = xmlCreateChild(node, tostring(k))
			end
			ConfigXML._writeNode(newnode, v)
		end
	end
end
