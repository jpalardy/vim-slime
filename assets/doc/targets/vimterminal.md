
### Vim :terminal

[Vim :terminal](https://vimhelp.org/terminal.txt.html) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "vimterminal"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

Vim terminal configuration can be set by using the following in your `.vimrc`:

```vim
let g:slime_vimterminal_config = {options}
```

You can specify if you have frequently used commands:

```vim
let g:slime_vimterminal_cmd = "command"
```

If you use Node, set it as follows:

```vim
let g:slime_vimterminal_cmd = "node"
```

You can make the vim terminal closed automatically:

```vim
let g:slime_vimterminal_config = {"term_finish": "close"}
```

for possible options, see `:help term_start()`

