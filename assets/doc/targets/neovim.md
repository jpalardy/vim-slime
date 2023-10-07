
### NeoVim :terminal

[NeoVim :terminal](https://neovim.io/doc/user/nvim_terminal_emulator.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "neovim"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration. The last terminal you opened before calling vim-slime will determine which `job-id` is presented as default.

To manually check the right value of `job-id` to use, try:

    echo &channel

from the buffer running your terminal.

You can also specify a function to query the jobid as

```lua
vim.g.slime_get_jobid = function()
  -- some way to select and return jobid
end
```

