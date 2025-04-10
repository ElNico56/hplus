-- h+ lexer

local patterns = {
	"^[{}]",    -- braces
	"^[%l%u_]+:?", -- variables
	"^%d+",     -- number
	"^%[%]=",   -- array assignment
	"^%[%]",    -- array
}

local function lex(src)
	local tokens = {}
	local pos = 1
	local buff = ""

	while pos <= #src do
		local chunk = src:sub(pos)
		local token = nil
		local matched = false

		if chunk:match"^%s" then
			pos = pos + 1
			matched = true
		else
			for _, pattern in ipairs(patterns) do
				token = chunk:match(pattern)
				if token then
					pos = pos + #token
					matched = true
					break
				end
			end
		end
		if not matched then
			buff = buff..chunk:sub(1, 1)
			pos = pos + 1
		else
			if buff ~= "" then
				table.insert(tokens, buff)
				buff = ""
			end
			table.insert(tokens, token)
		end
	end
	if buff ~= "" then
		table.insert(tokens, buff)
	end

	return tokens
end

return lex
