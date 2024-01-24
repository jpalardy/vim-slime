
### NeoVim :terminal

[NeoVim :terminal](https://neovim.io/doc/user/nvim_terminal_emulator.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "neovim"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration. The last terminal you opened before calling vim-slime will determine which `job-id` is presented as default. If that terminal is closed, one of the previously opened terminals will be suggested.

To use the terminal's PID as input instead of Neovim's internal job-id of the terminal:

```vim
let g:slime_input_pid=1
```

On Windows Neovim assigns a PID as well.

To manually check the right value of `job-id`  (but not `PID`) try:

```vim
    echo &channel
```

from the buffer running your terminal.

Another way to easily see the `PID` and job ID is to override the status bar of terminals to show the job id and PID.

```vim
 autocmd TermOpen * setlocal statusline=%{bufname()}%=id:\ %{b:terminal_job_id}\ pid:\ %{b:terminal_job_pid}
```

See `h:statusline` in Vim's documentiation for more details.

If you are using a plugin to manage your status line, see that plugin's documentation to see how to confiugre the status line to display `b:terminal_job_id` and `b:terminal_job_pid`.

You can also specify a function to query the jobid as

```lua
vim.g.slime_get_jobid = function()
  -- some way to select and return jobid
end
```
