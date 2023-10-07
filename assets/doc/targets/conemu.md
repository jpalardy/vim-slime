
### ConEmu

[ConEmu](https://conemu.github.io/) is *not* the default, to use it you will have to add this line to your .vimrc:

    let g:slime_target = "conemu"

When you invoke vim-slime for the first time, you will be prompted for more
configuration.

ConEmu console server HWND

    This is what you put in the -GuiMacro flag. It will be "0" if you didn't put
    anything, addressing the active tab/split of the first found ConEmu window.

By default the windows clipboard is used to pass the text to ConEmu. If you
experience issues with this, make sure the `conemuc` executable is in your
`path`.

