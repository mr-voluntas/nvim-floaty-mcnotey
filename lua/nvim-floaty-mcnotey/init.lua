local M = {}
local config = {
	notes_path = vim.fn.expand("~/floaty-mcnotes.md"),
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
		for line in file:lines() do
			table.insert(notes, line)
		end
		file:close()
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
	local height = vim.o.lines
	local width = vim.o.columns

	-- 80% of the editor's height, capped at 30 lines
	local win_height = math.min(math.ceil(height * 0.7), 50)
	-- 80% of the editor's width, capped at 150 columns
	local win_width = math.min(math.ceil(width * 0.8), 190)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = math.ceil((height - win_height) / 2),
		col = math.ceil((width - win_width) / 2),
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

	return vim.api.nvim_open_win(buf, true, opts)
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
