# NeoVim :terminal

[NeoVim :terminal](https://neovim.io/doc/user/nvim_terminal_emulator.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "neovim"
```


## Manual/Prompted Configuration

When you invoke `vim-slime` for the first time, you will be prompted for more configuration. The last terminal you opened before calling vim-slime will determine which `job-id` is presented as default. If that terminal is closed, one of the previously opened terminals will be suggested on subsequent configurations. The user can tab through a popup menu of valid configuration values.

To use the terminal's PID as input instead of Neovim's internal job-id of the terminal:

```vim
let g:slime_input_pid=1
```
PIDs of processes of potential target terminals are visible to Neovim on Windows as well as MacOS and Linux.



## Menu Prompted Configuration

To be prompted with a numbered menu of all available terminals which the user can select from by inputting a number, or, if the mouse is enabled, clicking on an entry, set `g:slime_menu_config` to a nonzero value.

```vim
let g:slime_menu_config=1
```

This takes precedence over `g:slime_input_pid`.

The default order of fields in each terminal description in the menu is 

1. `pid`  The system process identifier of the shell.
2. `jobid` The Neovim internal job number of the terminal.
3. `term_title` Usually either the systemname, username, and current directory of the shell, or the name of the currently running process in that shell. (unlabeled by default)
4. `name` The name of the terminal buffer (unlabeled by default).

The user can reorder these items and set their labels in the menu in the menu by setting a global variable,  `g:slime_neovim_menu_order`, that should be an array of dictionaries. Keys should be exactly the names of the fields, shown above, and the values (which should  be strings) will be the labels in the menu, according to user preference.  Use empty strings for no label.  The dictionaries in the array can be in the user's preferred order.

For example:

```vim
let g:slime_neovim_menu_order = [{'name': 'buffer name: '}, {'pid': 'shell process identifier: '}, {'jobid': 'neovim internal job identifier: '}, {'term_title': 'process or pwd: '}]
```

The user can also set the delimeter (including whitespace) string between the fields (`, ` by default) with `g:slime_neovim_menu_delimiter`.

```vim
let g:slime_neovim_menu_delimiter = ' | '
```

No validation is performed on these customization values so be sure they are properly set.


## Terminal Process Identification

To manually check the right value of `job-id`  (but not `PID`) try:

```vim
echo &channel
```

from the buffer running your terminal.

Another way to easily see the `PID` and job ID is to override the status bar of terminals to show the job id and PID.

```vim
" in case an external process kills the terminal's shell and &channel doesn't exist anymore
function! Safe_jobpid(channel_in)
  let pid_out = ""
  " in case an external process kills the terminal's shell; jobpid will error
  try
    let pid_out = string(jobpid(a:channel_in))
  catch /^Vim\%((\a\+)\)\=:E900/
  endtry
  return pid_out
endfunction

autocmd TermOpen * setlocal statusline=%{bufname()}%=id:\ %{&channel}\ pid:\ %{Safe_jobpid(&channel)}
```

See `h:statusline` in Neovim's documentiation for more details.

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
  local out = vim.api.nvim_exec2([[
  let pid_out = ""
  
  try
  let pid_out = string(jobpid(&channel))
  " in case an external process kills the terminal's shell; jobpid will error
  catch /^Vim\%((\a\+)\)\=:E900/
  endtry
  		echo pid_out
  ]], {output = true})
  return out["output"] --returns as string
end
```

Those confused by the syntax of the vimscript string passed as an argument to `vim.api.nvim_eval` should consult `:h ternary`.

## Automatic Configuration

Instead of the prompted job id input method detailed above, you can specify a lua function that will automatically configure vim-slime with a job id:

```lua
vim.g.slime_get_jobid = function()
  -- some way to select and return jobid
end
```

The details of how to implement this are left to the user.

This is not possible or straightforward to do in pure vimscript due to capitalization rules of functions stored as variables in Vimscript.

 `vim.api.nvim_eval` (see `:h nvim_eval()`) and other Neovim API functions are available to access all or almost all vimscript capabilities from Lua.
