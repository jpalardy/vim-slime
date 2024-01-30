
### NeoVim :terminal

[NeoVim :terminal](https://neovim.io/doc/user/nvim_terminal_emulator.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "neovim"
```

#### Manual/Prompted Configuration

When you invoke `vim-slime` for the first time, you will be prompted for more configuration. The last terminal you opened before calling vim-slime will determine which `job-id` is presented as default. If that terminal is closed, one of the previously opened terminals will be suggested.

To use the terminal's PID as input instead of Neovim's internal job-id of the terminal:

```vim
let g:slime_input_pid=1
```
PIDs of processes of potential target terminals are visible to Neovim on Windows as well as MacOS and Linux.

##### Process Identification

To manually check the right value of `job-id`  (but not `PID`) try:

```vim
echo &channel
```

from the buffer running your terminal.

Another way to easily see the `PID` and job ID is to override the status bar of terminals to show the job id and PID.

```vim
autocmd TermOpen * setlocal statusline=%{bufname()}%=id:\ %{&channel}\ pid:\ %{jobpid(&channel)}
```

See `h:statusline` in NeoVim's documentiation for more details.

If you are using a plugin to manage your status line, see that plugin's documentation to see how to confiugre the status line to display `&channel` and `jobpid(&channel)`.

Many status line plugins for Neovim are configured in lua.

A useful Lua function to return the Job ID of a terminal is:

```lua
local function get_chan_jobid()
  return vim.api.nvim_eval('&channel > 0 ? &channel : ""')
end
```

A useful Lua function to return the Job PID of a terminal is:

```lua
local function get_chan_jobpid()
  return vim.api.nvim_eval('&channel > 0 ? jobpid(&channel) : ""')
end
```

Those confused by the syntax of the vimscript string passed as an argument to `vim.api.nvim_eval` should consult `:h ternary`.

### Automatic Configuration

Instead of the prompted job id input method detailed above, you can specify a lua function that will automatically configure vim-slime with a job id:

```lua
vim.g.slime_get_jobid = function()
  -- some way to select and return jobid
end
```
The details of how to implement this are left to the user.

This is not possible or straightforward to do in pure vimscript due to capitalization rules of functions stored as variables in Vimscript.

 `vim.api.nvim_eval` (see `:h nvim_eval()`) and other Neovim API functions are available to access all or almost all vimscript capabilities from Lua.
