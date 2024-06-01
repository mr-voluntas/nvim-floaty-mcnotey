
# NVIM Floaty McNotey

A very minimal one-stop notes solution. Simply toggle a floaty mcnotey to write your notes

Specifiy a path to the notes file you wish to use, and that it, your all set

Toggle your floaty mcnotey where ever you are, make your notes, save with :w & close with :q



## Usage/Examples

```lua
return {
	"wxllxm/nvim-floaty-mcnotey",
	config = function()
		require("nvim-floaty-mcnotey").setup("~/Documents/notes/Floaty-McNoties.txt")
		vim.keymap.set("n", "<leader>fn", vim.cmd.Float, {})
	end,
}
```
