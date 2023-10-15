
### kitty

[kitty](https://sw.kovidgoyal.net/kitty/) is *not* the default, to use it you will have to add this line to your `.vimrc`:

```vim
let g:slime_target = "kitty"
```

When you invoke `vim-slime` for the first time, you will be prompted for more configuration.

kitty target window

    This is the id of the kitty window that you wish to target.
    See e.g. the value of $KITTY_WINDOW_ID in the target window.

kitty listen on

    Specifies where kitty should listen to control messages.
    See e.g. the value of $KITTY_LISTEN_ON in the target window.

    Can be left blank if:
    - KITTY_LISTEN_ON is exported in the shell running vim
    - running vim (but not nvim) inside kitty

To work properly, `kitty` must also be started with the following options:

```sh
kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty
```

See more [here](https://sw.kovidgoyal.net/kitty/remote-control.html). This can also be added to your `kitty.conf` file as:

```
allow_remote_control yes
listen_on unix:/tmp/mykitty
```

### bracketed-paste

Some REPLs can interfere with your text pasting. The [bracketed-paste](https://cirw.in/blog/bracketed-paste) mode exists to allow raw pasting.

`kitty` supports bracketed-paste, use:

```vim
let g:slime_bracketed_paste = 1
" or
let b:slime_bracketed_paste = 1
```

(It is disabled by default because it can create issues with ipython; see [#265](https://github.com/jpalardy/vim-slime/pull/265)).

