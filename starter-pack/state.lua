local M = {}
local state = {}

function M.set(key, value)
	state[key] = value
end

function M.get(key)
	return state[key]
end

function M.remove(key)
	state[key] = nil
end

function M.has(key)
	return state[key] ~= nil
end

return M