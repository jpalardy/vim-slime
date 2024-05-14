
### GNU Screen

By default, [GNU Screen](https://www.gnu.org/software/screen/) is assumed, you don't have to do anything. If you want to be explicit, you can add this line to your `.vimrc`:

```vim
let g:slime_target = "screen"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

screen session name:

    This is what you put in the -S flag, or one of the line from "screen -ls".

screen window name:

    This is the window number or name, zero-based.

