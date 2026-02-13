local util = require("starter-pack/util")

local M = {}
local locale = {}

function M.parse_po(text)
	local parsed = {}
	local lines = util.split_lines(text)
	local msgid = nil
	for _, line in pairs(lines) do
		if line:match("^msgid") then
			msgid = line:sub(8, line:len()-1)
		elseif line:match("^msgstr") and msgid then
			parsed[msgid] = line:sub(9, line:len()-1)
			msgid = nil
		end
	end
	return parsed
end

function M.set_locale(t)
	for k, v in pairs(t) do
		locale[k] = v
	end
end

function M.clean()
	for k, _ in pairs(locale) do
		locale[k] = nil
	end
end

function M.setup(path)
	M.clean()
	local txt, error = sys.load_resource(path)
	if error or not txt then
		return
	end
	M.set_locale(M.parse_po(txt))
end

function M.t(text)
	local t = locale[text]
	if t then
		return t
	end
	return text
end

return M
