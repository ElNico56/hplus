-- h+

local lex = require"lexer"

local stack = {}
local vars = {}
local store = nil
local depth = 0
local buffer

local function copy(val)
	if type(val) == "table" then
		local cop = {}
		for i, v in ipairs(val) do
			cop[i] = v
		end
		return cop
	end
	return val
end

local function push(...)
	for _, v in ipairs{...} do
		table.insert(stack, v)
	end
end
local function pop()
	local v = table.remove(stack)
	if v == nil then error'Not enough values on the stack' end
	return v
end
local function truthy(v)
	if type(v) == 'number' then
		return v ~= 0
	elseif type(v) == "string" then
		return v ~= ""
	elseif type(v) == "table" then
		return #v > 0
	elseif type(v) == "boolean" then
		return v
	end
	return false
end

local function print_stack(value, seen)
	if seen == nil then seen = {} end
	for i, v in ipairs(value) do
		if type(v) == 'table' then
			if seen[v] then
				io.write'###'
			else
				seen[v] = true
				io.write'[ '
				print_stack(v, seen)
				io.write' ]'
			end
		else
			io.write(tostring(v))
		end
		io.write(i < #value and ' ' or '')
	end
end

local function execute(command)
	if depth > 0 then
		buffer[#buffer+1] = command
		if command == '}' then
			depth = depth - 1
			if depth == 0 then
				buffer[#buffer] = nil
				push(buffer)
			end
		elseif command == '{' then
			depth = depth + 1
		end
	elseif depth == -1 then
		push(command)
		depth = 0
	else
		if tonumber(command) then
			push(tonumber(command))
		elseif command:match"^\\." then         -- escape
			push(command:sub(2))
		elseif command:lower():match"^[%l%u]+:$" then -- save var
			local a = pop()
			local name = command:sub(1, -2):lower()
			vars[name] = a
		elseif command:match"^%l[%l%u]*$" then -- load var
			local name = command:lower()
			local var = vars[name]
			if var then
				push(var)
			else
				error("Variable not found: "..name)
			end
		elseif command:match"^%u[%l%u]*$" then -- eval var
			local name = command:lower()
			local var = vars[name]
			if var then
				if type(var) == 'table' then
					for _, v in ipairs(var) do
						execute(v)
					end
				elseif type(var) == 'string' then
					execute(var)
				else
					error("Non executable: "..var)
				end
			else
				error("Variable not found: "..name)
			end
		elseif command:match'^[()]+$' then -- planet
			local buff = {}
			for char in command:gmatch'.' do
				local val = pop()
				if char == ')' then
					table.insert(buff, 1, val)
				end
			end
			push(table.unpack(buff))
		elseif command:match'^![()]+$' then -- eval with planet
			local a = pop()
			local buff = {}
			for char in command:sub(2):gmatch'.' do
				local val = pop()
				if char == ')' then
					table.insert(buff, 1, val)
				end
			end
			if type(a) == 'table' then
				for _, v in ipairs(a) do
					execute(v)
				end
			elseif type(a) == 'string' then
				execute(a)
			else
				error("Non executable: "..a)
			end
			push(table.unpack(buff))
		elseif command == '!!' then -- foreach
			local func, list = pop(), pop()
			local buff = {}
			for _, v in ipairs(list) do
				push(v)
				if type(func) == 'table' then
					for _, cmd in ipairs(func) do
						execute(cmd)
					end
				elseif type(func) == 'string' then
					execute(func)
				else
					error("Non executable: "..func)
				end
				buff[#buff+1] = pop()
			end
			push(buff)
		elseif command == '||' then -- absolute value
			local a = pop()
			if type(a) == 'table' then
				push(#a)
			else
				push(math.abs(a))
			end
		elseif command == '<>' then -- range
			local a = pop()
			local buff = {}
			for i = 1, a do
				buff[#buff+1] = i - 1
			end
			push(buff)
		elseif command == '|' then -- or
			local b, a = pop(), pop()
			push((truthy(a) or truthy(b)) and 1 or 0)
		elseif command == '&' then -- and
			local b, a = pop(), pop()
			push((truthy(a) and truthy(b)) and 1 or 0)
		elseif command == '^^' then -- xor
			local b, a = pop(), pop()
			push((truthy(a) ~= truthy(b)) and 1 or 0)
		elseif command == '^' then -- not
			local a = pop()
			push(truthy(a) and 0 or 1)
		elseif command == ':' then -- swap / flip
			local b, a = pop(), pop()
			push(b, a)
		elseif command == ';' then -- pop
			pop()
		elseif command == '+' then -- add
			local b, a = pop(), pop()
			if type(a) == "number" and type(b) == "number" then
				push(a + b)
			elseif type(a) == "table" then
				local buff = {}
				for _, v in ipairs(a) do
					buff[#buff+1] = v
				end
				if type(b) == "table" then
					for _, v in ipairs(b) do
						buff[#buff+1] = v
					end
					push(buff)
				else
					buff[#buff+1] = b
					push(buff)
				end
			end
		elseif command == '-' then -- subtract
			local b, a = pop(), pop()
			push(a - b)
		elseif command == '*' then -- multiply
			local b, a = pop(), pop()
			push(a * b)
		elseif command == '/' then -- divide
			local b, a = pop(), pop()
			push(a / b)
		elseif command == '<' then -- less than
			local b, a = pop(), pop()
			push(a < b and 1 or 0)
		elseif command == '>' then -- greater than
			local b, a = pop(), pop()
			push(a > b and 1 or 0)
		elseif command == '=' then -- equal
			local b, a = pop(), pop()
			push(a == b and 1 or 0)
		elseif command == '!=' then -- not equal
			local b, a = pop(), pop()
			push(a ~= b and 1 or 0)
		elseif command == '?' then -- conditional
			local c, b, a = pop(), pop(), pop()
			push(truthy(a) and b or c)
		elseif command == '.' then -- duplicate
			local a = pop()
			push(a, copy(a))
		elseif command == ',' then -- over
			local b, a = pop(), pop()
			push(a, b, copy(a))
		elseif command == '>>' then -- rotate right
			local c, b, a = pop(), pop(), pop()
			push(c, a, b)
		elseif command == '<<' then -- rotate left
			local c, b, a = pop(), pop(), pop()
			push(b, c, a)
		elseif command == '>>>' then -- rotate right with copy
			local c, b, a = pop(), pop(), pop()
			push(c, a, b, copy(c))
		elseif command == '<<<' then -- rotate left with copy
			local c, b, a = pop(), pop(), pop()
			push(a, b, c, copy(a))
		elseif command == '[]' then -- index
			local b, a = pop(), pop()
			push(a[b + 1])
		elseif command == '[]=' then -- index assign
			local c, b, a = pop(), pop(), pop()
			a[b + 1] = c
			push(a)
		elseif command == '[...]' then -- pack
			local a = pop()
			local buff = {}
			for i = 1, a do
				table.insert(buff, 1, pop())
			end
			push(buff)
		elseif command == '...' then -- unpack
			local a = pop()
			for _, v in ipairs(a) do
				push(v)
			end
		elseif command == '{' then -- begin function
			depth = depth + 1
			buffer = {}
		elseif command == '}' then -- end function
			error'Unmatched }'
		elseif command == '\\' then -- escape
			depth = -1
		elseif command == '!' then -- eval
			local a = pop()
			if type(a) == 'table' then
				for _, v in ipairs(a) do
					execute(v)
				end
			elseif type(a) == "string" then
				execute(a)
			else
				error("Non executable: "..a)
			end
		elseif command == '$=' then -- save
			store = pop()
		elseif command == '$' then -- load
			push(store)
		elseif command == '#' then -- system functions
			local cmd = pop()
			if cmd == "output" then
				local val = pop()
				if type(val) == 'table' then
					print_stack(val)
					io.write'\n'
				else
					print(val)
				end
			elseif cmd == "input" then
				local input = io.read()
				push(input or "")
			end
		else
			print("Unknown command:", command)
		end
	end
end

if arg[1] == "lex" and arg[2] then
	print(table.concat(lex(arg[2]), '\n'))
elseif arg[1] then
	local file = assert(io.open(arg[1], 'r'))
	for _, token in ipairs(lex(file:read'*a')) do
		execute(token)
	end
	if #stack > 0 then
		print"--- stack ---"
		print_stack(stack)
	end
	if store then
		print"--- store ---"
		print_stack(store)
	end
	file:close()
else
	while true do
		io.write'\n\t> '
		local line = io.read()
		if line == "" then break end
		for _, token in ipairs(lex(line)) do
			execute(token)
		end
		print_stack(stack)
	end
end
