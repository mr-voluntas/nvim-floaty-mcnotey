local M = {}

local config = {
	notes_path = vim.fn.expand("~/floaty-mcnotes.txt"),
}

function M:setup(conf)
	if conf and type(conf) == "table" then
		config = vim.tbl_deep_extend("force", config, conf)
	end
end

local function load_notes()
	local notes = {}
	local file = io.open(config.notes_path, "r")
	if file then
		for line in file(config.notes_path) do
			table.insert(notes, line)
		end
	else
		print("Warning: Could not open file for reading.")
	end
	return notes
end

local function create_buffer()
	local buf = vim.api.nvim_create_buf(true, false)
	if buf then
		vim.api.nvim_buf_set_name(buf, "floaty-mcnotes")
		local notes = load_notes()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, notes)
	else
		print("Error: Could not create new buffer.")
	end
	return buf
end

local function get_buffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if buf_name:match("floaty%-mcnotes") then
			return buf
		end
	end
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

	local buf = get_buffer()
	assert(vim.api.nvim_buf_is_valid(buf), "Error: Not a valid buffer.")

	-- autocommand to save changes to the original file
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local file = io.open(config.notes_path, "w")
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

	return vim.api.nvim_open_win(buf, true, window_opts)
end

function M:toggle_floaty_mcnotes()
	local buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(buf)
	if buf_name:match("floaty%-mcnotes") then
		vim.api.nvim_command("hide")
	else
		create_floaty_window()
	end
end

return M
