# NeoVim :terminal

[NeoVim :terminal](https://neovim.io/doc/user/nvim_terminal_emulator.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "neovim"
```

When you invoke `vim-slime` for the first time, `:SlimeConfig` or one of the send functions, you will be prompted for more configuration.

## Manual/Prompted Configuration

If the global variable `g:slime_suggest_default` is:

- Nonzero (logical True): The last terminal you opened before calling vim-slime will determine which `job-id` is presented as default. If that terminal is closed, one of the previously opened terminals will be suggested on subsequent configurations. The user can tab through a popup menu of valid configuration values.

- `0`: (logical False): No default will be suggested.


In either case, in Neovim's default configuration, menu-based completion can be activated with `<Tab>`/`<S-Tab>`, and the menu can be navigated with `<Tab>`/`<S-Tab` or `<C-n>`/`<C-p>`.  Autocompletion plugins such as [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) can interfere with this.

To use the terminal's PID as input instead of Neovim's internal job-id of the terminal:

```vim
let g:slime_input_pid=1
```

The `PID` is included in the terminal buffers' name, visible in the default terminal window status bar.


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

As menioned earlier, the `PID` of a process is included in the name of a terminal buffer.

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

### Statusline Plugins

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

## Status-Line Modifications for Configured Buffers

Here is an example snippet of vimscript` to set the status line for buffers that are configured to send code to a terminal:

```vim
" Function to safely check for b:slime_config and return the jobid
function! GetSlimeJobId()
  if exists("b:slime_config") && type(b:slime_config) == v:t_dict && has_key(b:slime_config, 'jobid') && !empty(b:slime_config['jobid'])
    return ' | jobid: ' . b:slime_config['jobid'] . ' '
  endif
  return ''
endfunction

" Function to safely check for b:slime_config and return the pid
function! GetSlimePid()
  if exists("b:slime_config") && type(b:slime_config) == v:t_dict && has_key(b:slime_config, 'pid') && !empty(b:slime_config['pid'])
    return 'pid: ' . b:slime_config['pid']
  endif
  return ''
endfunction


"default statuslin with :set ruler
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" Append the custom function outputs to the right side of the status line, with " | " as a separator
```

### Lua Functions For Returning Config Components


```lua
local function get_slime_jobid()
  if vim.b.slime_config and vim.b.slime_config.jobid then
    return vim.b.slime_config.jobid
  else
    return ""
  end
end
```

```lua
local function get_slime_pid()
  if vim.b.slime_config and vim.b.slime_config.pid then
    return vim.b.slime_config.pid
  else
    return ""
  end
end
```

Can be useful for status line plugins.

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

 ## Example Installation and Configuration with [lazy.nvim](https://github.com/folke/lazy.nvim)


 ```lua
{
	"jpalardy/vim-slime",
	init = function()
		-- these two should be set before the plugin loads
		vim.g.slime_target = "neovim"
		vim.g.slime_no_mappings = true
	end,
	config = function()
		vim.g.slime_input_pid = false
		vim.g.slime_suggest_default = true
		vim.g.slime_menu_config = false
		-- called MotionSend but works with textobjects as well
		vim.keymap.set("n", "gz", "<Plug>SlimeMotionSend", { remap = true, silent = false })
		vim.keymap.set("n", "gzz", "<Plug>SlimeLineSend", { remap = true, silent = false })
		vim.keymap.set("x", "gz", "<Plug>SlimeRegionSend", { remap = true, silent = false })
		vim.keymap.set("n", "gzc", "<Plug>SlimeConfig", { remap = true, silent = false })
	end,
}
 ```
