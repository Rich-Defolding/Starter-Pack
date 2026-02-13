local util = require("starter-pack/util")

local M = {}
local listeners = {}

--- @return number
function M.add_listener(name, callback)
	if M.has_event(name) then
		table.insert(listeners[name], callback)
	else
		listeners[name] = {callback}
	end
	return util.table_length(listeners[name])
end

function M.remove_event(name)
	listeners[name] = nil
end

function M.has_event(name)
	return listeners[name] ~= nil
end

function M.remove_listener(name, index)
	if not M.has_event(name) then
		return
	end
	local length = util.table_length(listeners[name])
	if index > length then
		return
	end
	table.remove(listeners[name], index)
end

function M.emit(name, data)
	if not M.has_event(name) then
		return
	end
	for _, callback in ipairs(listeners[name]) do
		callback(data)
	end
end

return M