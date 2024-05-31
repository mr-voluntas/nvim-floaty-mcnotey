local M = {}

function M:setup(opts)
	-- if no opts then set to default
	if not opts then
		self.notes_path = vim.fn.expand("~/floaty-mcnotes.txt")
	end
	print(type(opts))
	-- if opts are not recieved as table, throw error
	-- if not (type(opts) == "table") then
	-- error("opts must be a table", 1)
	-- end
	-- set note path from opts
	self.notes_path = opts.notes_path
end

local function load_notes()
	local notes = {}
	for line in io.lines(M.notes_path) do
		table.insert(notes, line)
	end
	return notes
end

local function create_buffer()
	-- create new buffer
	local buf = vim.api.nvim_create_buf(true, false)
	-- call it floaty-mcnotes
	vim.api.nvim_buf_set_name(buf, "floaty-mcnotes")
	-- check its loaded
	local is_buf_loaded = vim.api.nvim_buf_is_loaded(buf)
	if is_buf_loaded then
		-- load notes and add it into the buffer
		local notes = load_notes()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, notes)
		return buf
	end
end

local function get_buffer()
	-- loop through buffers to find one called "floaty-mcnotes"
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		local floaty_buf_name = "floaty%-mcnotes"
		local found = string.match(buf_name, floaty_buf_name)
		if found then
			return buf
		end
	end
	-- if it cant find one, create one
	return create_buffer()
end

local function create_floaty_window()
	-- screen diamentions
	local screen_height = vim.opt.lines:get()
	local screen_width = vim.opt.columns:get()
	-- floating window diamentions (height * 0.8 == 80% of the window)
	local window_height = math.ceil(screen_height * 0.8)
	local window_width = math.ceil(screen_width * 0.8)
	-- calculates the center of the screen
	local row = math.floor((screen_height - window_height) / 2)
	local cols = math.floor((screen_width - window_width) / 2)

	-- floaty window options
	local window_opts = {
		style = "minimal",
		relative = "editor",
		width = window_width,
		height = window_height,
		row = row,
		col = cols,
		anchor = "NW",
		border = {
			"╭",
			"─",
			"╮",
			"│",
			"╯",
			"─",
			"╰",
			"│",
		},
	}

	-- autocommand to save changes to the original file
	local buf = get_buffer()
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local file = io.open(M.notes_path, "w")
			if file then
				for _, line in ipairs(lines) do
					file:write(line, "\n")
				end
				file:close()
			else
				print("Error: Could not open file for writing")
			end
		end,
	})

	-- return the new floaty window to use for toggling
	return vim.api.nvim_open_win(buf, true, window_opts)
end

function M:toggle_floaty_mcnotes()
	local buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(buf)
	local floaty_buf_name = "floaty%-mcnotes"
	-- if the current buffer is floaty-mcnotes, hide it, else open it
	if string.match(buf_name, floaty_buf_name) then
		vim.api.nvim_command("hide")
	else
		create_floaty_window()
	end
end

return M
