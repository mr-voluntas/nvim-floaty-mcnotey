
# NVIM Floaty McNotey

A very minimal one-stop notes solution. Simply toggle a floaty mcnotey to write your notes

Specifiy a path to the notes file you wish to use, and that it, your all set

Toggle your floaty mcnotey where ever you are, make your notes, save with :w & close with :q



## Usage/Examples

```lua
return {
	"wxllxm/nvim-floaty-mcnotey",
	config = function()
		require("nvim-floaty-mcnotey").setup({ notes_path = "~/Notes.lua" })
	end,
	keys = {
		{
			"<leader>nn",
			":lua require('nvim-floaty-mcnotey').toggle_floaty_mcnotes()<CR>",
			desc = "Toggle Floaty McNotey",
			silent = true
		},
	},
}
```
