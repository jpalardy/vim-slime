
### GNU Screen

By default, [GNU Screen](https://www.gnu.org/software/screen/) is assumed, you don't have to do anything. If you want
to be explicit, you can add this line to your .vimrc:

    let g:slime_target = "screen"

Because Screen doesn't accept input from STDIN, a file is used to pipe data
between Vim and Screen. By default this file is set to `$HOME/.slime_paste`.
The name of the file used can be configured through a variable:

    let g:slime_paste_file = expand("$HOME/.slime_paste")
    " or maybe...
    let g:slime_paste_file = tempname()

⚠️  This file is not erased by the plugin and will always contain the last thing you sent over.

When you invoke vim-slime for the first time, you will be prompted for more configuration.

screen session name:

    This is what you put in the -S flag, or one of the line from "screen -ls".

screen window name:

    This is the window number or name, zero-based.

