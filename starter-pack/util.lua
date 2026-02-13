local M = {}

function M.table_length(t)
	local length = 0
	for _ in ipairs(t) do
		length = length + 1
	end
	return length
end

function M.split_lines(text)
	local lines = {}
	for line in text:gmatch("([^\r\n]+)") do
		table.insert(lines, line)
	end
	return lines
end

return M
